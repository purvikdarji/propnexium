package com.propnexium.kafka.consumer;

import com.propnexium.config.KafkaTopics;
import com.propnexium.kafka.event.*;
import com.propnexium.service.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

/**
 * Kafka consumer responsible for all email delivery in PropNexium.
 *
 * Consumer group: {@code propnexium-email-group}
 *
 * Why a dedicated consumer group for email?
 * - Isolated from notification and saved-search groups so a slow SMTP server
 *   doesn't cause consumer-group rebalancing that delays in-app notifications.
 * - Can be scaled independently by increasing partition count + replicas.
 *
 * At-least-once delivery:
 * - Manual MANUAL_IMMEDIATE ack — offset committed only after the email send
 *   returns (or throws).
 * - On exception, the DefaultErrorHandler retries up to kafka.retry.attempts
 *   times. After exhaustion the message is forwarded to the DLT topic so ops
 *   can inspect and replay it without manual offset manipulation.
 *
 * Idempotency note:
 * - Email sends are inherently non-idempotent (duplicate sends happen on retry).
 * - Acceptable for PropNexium — duplicate welcome/booking emails are rare and
 *   low-harm compared to silently lost emails.
 * - To make them idempotent, store a processed messageId in Redis/DB before
 *   sending and skip if already processed.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EmailNotificationConsumer {

    private final EmailService emailService;

    // ─── User Events ──────────────────────────────────────────────────────────

    /**
     * Handles user.registered → sends welcome email.
     * The existing EmailServiceImpl.sendWelcomeEmail(User) requires a User entity,
     * so we call the legacy overload sendWelcomeEmail(String, String) which only
     * needs email + name and is safe to call from a non-JPA context.
     */
    @KafkaListener(
            topics = KafkaTopics.USER_REGISTERED,
            containerFactory = "emailKafkaListenerContainerFactory"
    )
    public void onUserRegistered(
            @Payload UserRegisteredEvent event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment ack) {

        log.info("[Kafka/Email] Received user.registered: userId={} topic={} offset={}",
                event.getUserId(), topic, offset);
        try {
            emailService.sendWelcomeEmail(event.getEmail(), event.getName());
            ack.acknowledge(); // commit offset only on success
            log.info("[Kafka/Email] Welcome email sent to userId={}", event.getUserId());
        } catch (Exception ex) {
            // Do NOT ack — DefaultErrorHandler will retry, then DLT.
            log.error("[Kafka/Email] Failed to send welcome email for userId={}: {}",
                    event.getUserId(), ex.getMessage(), ex);
            throw ex; // rethrow to trigger retry mechanism
        }
    }

    // ─── Booking Events ───────────────────────────────────────────────────────

    /**
     * Handles booking.created → sends confirmation to user AND alert to agent.
     * These are two email sends per message — both must succeed for the offset
     * to be committed. If the agent alert fails, the user confirmation may be
     * re-sent on retry (acceptable at-least-once trade-off).
     */
    @KafkaListener(
            topics = KafkaTopics.BOOKING_CREATED,
            containerFactory = "emailKafkaListenerContainerFactory"
    )
    public void onBookingCreated(
            @Payload BookingCreatedEvent event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment ack) {

        log.info("[Kafka/Email] Received booking.created: bookingId={} topic={} offset={}",
                event.getBookingId(), topic, offset);
        try {
            emailService.sendBookingConfirmationEmail(event.getBookingId());
            emailService.sendBookingAlertToAgent(event.getBookingId());
            ack.acknowledge();
            log.info("[Kafka/Email] Booking emails sent for bookingId={}", event.getBookingId());
        } catch (Exception ex) {
            log.error("[Kafka/Email] Failed booking email for bookingId={}: {}",
                    event.getBookingId(), ex.getMessage(), ex);
            throw ex;
        }
    }

    /**
     * Handles booking.status.changed → sends appropriate status update email.
     * Determines direction (user ← agent action, or agent ← user action) by
     * comparing initiatorId with agentId.
     */
    @KafkaListener(
            topics = KafkaTopics.BOOKING_STATUS_CHANGED,
            containerFactory = "emailKafkaListenerContainerFactory"
    )
    public void onBookingStatusChanged(
            @Payload BookingStatusChangedEvent event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment ack) {

        log.info("[Kafka/Email] Received booking.status.changed: bookingId={} newStatus={} topic={} offset={}",
                event.getBookingId(), event.getNewStatus(), topic, offset);
        try {
            boolean agentInitiated = event.getAgentId() != null
                    && event.getAgentId().equals(event.getInitiatorId());

            if (agentInitiated) {
                // Agent acted (confirm/cancel) → notify the user
                emailService.sendBookingStatusEmailToUser(event.getBookingId(), event.getStatusMessage());
            } else {
                // User acted (cancel) → notify the agent
                emailService.sendBookingCancellationAlertToAgent(event.getBookingId());
            }
            ack.acknowledge();
            log.info("[Kafka/Email] Booking status email sent for bookingId={}", event.getBookingId());
        } catch (Exception ex) {
            log.error("[Kafka/Email] Failed status email for bookingId={}: {}",
                    event.getBookingId(), ex.getMessage(), ex);
            throw ex;
        }
    }

    // ─── Inquiry Events ───────────────────────────────────────────────────────

    /**
     * Handles inquiry.replied → sends agent's reply to the inquirer's email.
     * Uses the legacy sendEmail(to, subject, body) to avoid requiring the full
     * Inquiry entity in the consumer (which would require a DB lookup).
     */
    @KafkaListener(
            topics = KafkaTopics.INQUIRY_REPLIED,
            containerFactory = "emailKafkaListenerContainerFactory"
    )
    public void onInquiryReplied(
            @Payload InquiryRepliedEvent event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment ack) {

        log.info("[Kafka/Email] Received inquiry.replied: inquiryId={} topic={} offset={}",
                event.getInquiryId(), topic, offset);
        try {
            String subject = "Reply to Your Inquiry: " + event.getPropertyTitle();
            String htmlBody = buildInquiryReplyEmailBody(event);
            emailService.sendEmail(event.getInquirerEmail(), subject, htmlBody);
            ack.acknowledge();
            log.info("[Kafka/Email] Inquiry reply email sent to {}", event.getInquirerEmail());
        } catch (Exception ex) {
            log.error("[Kafka/Email] Failed inquiry reply email for inquiryId={}: {}",
                    event.getInquiryId(), ex.getMessage(), ex);
            throw ex;
        }
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private String buildInquiryReplyEmailBody(InquiryRepliedEvent event) {
        return "<html><body style='font-family:Arial,sans-serif;padding:20px;'>" +
                "<h2>Reply to Your Inquiry</h2>" +
                "<p>Hi " + event.getInquirerName() + ",</p>" +
                "<p>You received a reply to your inquiry about <strong>"
                + event.getPropertyTitle() + "</strong>:</p>" +
                "<blockquote style='background:#f0f4ff;padding:15px;border-left:4px solid #1A73E8;'>"
                + event.getAgentReply() + "</blockquote>" +
                "<p>Best,<br>The PropNexium Team</p>" +
                "</body></html>";
    }
}
