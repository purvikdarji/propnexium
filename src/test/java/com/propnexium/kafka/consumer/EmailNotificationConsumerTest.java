package com.propnexium.kafka.consumer;

import com.propnexium.kafka.event.*;
import com.propnexium.service.EmailService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.kafka.support.Acknowledgment;

import java.time.LocalDate;
import java.time.LocalDateTime;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for {@link EmailNotificationConsumer}.
 *
 * Tests the consumer's routing and delegation logic via direct method invocation
 * using pure Mockito — no Spring context, no Kafka broker, no database needed.
 *
 * Each test:
 * 1. Constructs an event payload.
 * 2. Calls the listener method directly with a mocked Acknowledgment.
 * 3. Asserts the correct EmailService method was called.
 * 4. Asserts acknowledge() was called (offset committed on success).
 */
@ExtendWith(MockitoExtension.class)
class EmailNotificationConsumerTest {

    @Mock private EmailService emailService;
    @Mock private Acknowledgment ack;

    @InjectMocks
    private EmailNotificationConsumer consumer;

    // ── user.registered ───────────────────────────────────────────────────────

    @Test
    @DisplayName("onUserRegistered → sendWelcomeEmail is called and offset committed")
    void onUserRegistered_sendsWelcomeEmailAndAcks() {
        UserRegisteredEvent event = UserRegisteredEvent.builder()
                .userId(1L).name("Purvik Darji").email("purvik@example.com")
                .role("USER").registeredAt(LocalDateTime.now()).build();

        consumer.onUserRegistered(event, "propnexium.user.registered", 0L, ack);

        verify(emailService).sendWelcomeEmail("purvik@example.com", "Purvik Darji");
        verify(ack).acknowledge();
    }

    @Test
    @DisplayName("onUserRegistered: EmailService failure → exception propagates, no ack")
    void onUserRegistered_emailFailure_throwsAndDoesNotAck() {
        UserRegisteredEvent event = UserRegisteredEvent.builder()
                .userId(2L).name("Fail User").email("fail@example.com")
                .role("USER").registeredAt(LocalDateTime.now()).build();

        doThrow(new RuntimeException("SMTP error"))
                .when(emailService).sendWelcomeEmail(anyString(), anyString());

        org.junit.jupiter.api.Assertions.assertThrows(RuntimeException.class,
                () -> consumer.onUserRegistered(event, "propnexium.user.registered", 1L, ack));

        verify(ack, never()).acknowledge(); // no ack on failure → triggers retry
    }

    // ── booking.created ───────────────────────────────────────────────────────

    @Test
    @DisplayName("onBookingCreated → both confirmation and agent alert emails are sent")
    void onBookingCreated_sendsBothEmails() {
        BookingCreatedEvent event = BookingCreatedEvent.builder()
                .bookingId(10L).propertyId(20L).propertyTitle("Luxury Flat")
                .agentId(5L).userId(1L).visitorName("Test Visitor")
                .visitorEmail("visitor@example.com")
                .visitDate(LocalDate.now().plusDays(3)).timeSlot("10:00 AM")
                .createdAt(LocalDateTime.now()).build();

        consumer.onBookingCreated(event, "propnexium.booking.created", 0L, ack);

        verify(emailService).sendBookingConfirmationEmail(10L);
        verify(emailService).sendBookingAlertToAgent(10L);
        verify(ack).acknowledge();
    }

    // ── booking.status.changed ────────────────────────────────────────────────

    @Test
    @DisplayName("onBookingStatusChanged: agent initiated → notify user via sendBookingStatusEmailToUser")
    void onBookingStatusChanged_agentInitiated_notifiesUser() {
        BookingStatusChangedEvent event = BookingStatusChangedEvent.builder()
                .bookingId(30L).propertyId(20L).propertyTitle("Flat")
                .userId(1L).agentId(5L)
                .initiatorId(5L) // agent confirmed
                .oldStatus("PENDING").newStatus("CONFIRMED")
                .statusMessage("Confirmed").changedAt(LocalDateTime.now()).build();

        consumer.onBookingStatusChanged(event, "propnexium.booking.status.changed", 0L, ack);

        verify(emailService).sendBookingStatusEmailToUser(30L, "Confirmed");
        verify(emailService, never()).sendBookingCancellationAlertToAgent(anyLong());
        verify(ack).acknowledge();
    }

    @Test
    @DisplayName("onBookingStatusChanged: user initiated → notify agent via sendBookingCancellationAlertToAgent")
    void onBookingStatusChanged_userInitiated_notifiesAgent() {
        BookingStatusChangedEvent event = BookingStatusChangedEvent.builder()
                .bookingId(31L).propertyId(21L).propertyTitle("Villa")
                .userId(1L).agentId(5L)
                .initiatorId(1L) // user cancelled
                .oldStatus("CONFIRMED").newStatus("CANCELLED")
                .statusMessage("Cancelled").changedAt(LocalDateTime.now()).build();

        consumer.onBookingStatusChanged(event, "propnexium.booking.status.changed", 1L, ack);

        verify(emailService).sendBookingCancellationAlertToAgent(31L);
        verify(emailService, never()).sendBookingStatusEmailToUser(anyLong(), anyString());
        verify(ack).acknowledge();
    }

    // ── inquiry.replied ───────────────────────────────────────────────────────

    @Test
    @DisplayName("onInquiryReplied → sendEmail with correct recipient and subject")
    void onInquiryReplied_sendsReplyEmail() {
        InquiryRepliedEvent event = InquiryRepliedEvent.builder()
                .inquiryId(7L).propertyId(30L)
                .propertyTitle("Office Space in Bangalore")
                .inquirerName("Buyer Name").inquirerEmail("buyer@example.com")
                .inquirerUserId(null) // guest inquiry
                .agentReply("Thank you! Call 9876543210.")
                .repliedAt(LocalDateTime.now()).build();

        consumer.onInquiryReplied(event, "propnexium.inquiry.replied", 0L, ack);

        verify(emailService).sendEmail(
                eq("buyer@example.com"),
                contains("Office Space in Bangalore"),
                anyString()
        );
        verify(ack).acknowledge();
    }

    @Test
    @DisplayName("onInquiryReplied: email failure → exception propagates, no ack")
    void onInquiryReplied_emailFailure_throwsAndDoesNotAck() {
        InquiryRepliedEvent event = InquiryRepliedEvent.builder()
                .inquiryId(8L).propertyId(31L).propertyTitle("Test Property")
                .inquirerName("Test").inquirerEmail("test@example.com")
                .agentReply("Reply").repliedAt(LocalDateTime.now()).build();

        doThrow(new RuntimeException("SMTP timeout"))
                .when(emailService).sendEmail(anyString(), anyString(), anyString());

        org.junit.jupiter.api.Assertions.assertThrows(RuntimeException.class,
                () -> consumer.onInquiryReplied(event, "propnexium.inquiry.replied", 1L, ack));

        verify(ack, never()).acknowledge();
    }
}
