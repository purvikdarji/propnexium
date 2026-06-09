package com.propnexium.kafka.consumer;

import com.propnexium.config.KafkaTopics;
import com.propnexium.entity.enums.NotificationType;
import com.propnexium.kafka.event.*;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

/**
 * Kafka consumer responsible for in-app notification creation.
 *
 * Consumer group: {@code propnexium-notification-group}
 *
 * This consumer is intentionally separate from the email consumer so:
 * - A DB failure creating a notification doesn't block or retry email sends.
 * - Notification throughput can be tuned independently.
 *
 * All handlers use the NotificationService.createNotification() which is a
 * simple INSERT — fast and unlikely to fail. Retries + DLT are still
 * configured as a safety net.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationConsumer {

    private final NotificationService notificationService;
    private final UserRepository userRepository;

    // ─── Property Events ──────────────────────────────────────────────────────

    /**
     * property.submitted → notify all admins of the new listing.
     */
    @KafkaListener(
            topics = KafkaTopics.PROPERTY_SUBMITTED,
            containerFactory = "notificationKafkaListenerContainerFactory"
    )
    public void onPropertySubmitted(
            @Payload PropertySubmittedEvent event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment ack) {

        log.info("[Kafka/Notification] property.submitted: propertyId={} offset={}", event.getPropertyId(), offset);
        try {
            // Notify every admin — fan-out within the consumer
            userRepository.findByRole(com.propnexium.entity.enums.UserRole.ADMIN)
                    .forEach(admin -> notificationService.createNotification(
                            admin.getId(),
                            "New Property Submitted for Review",
                            "Agent " + event.getAgentName() + " submitted: " + event.getTitle(),
                            NotificationType.SYSTEM,
                            "/admin/properties/" + event.getPropertyId()
                    ));
            ack.acknowledge();
        } catch (Exception ex) {
            log.error("[Kafka/Notification] Failed admin notification for propertyId={}: {}",
                    event.getPropertyId(), ex.getMessage(), ex);
            throw ex;
        }
    }

    /**
     * property.status.changed → notify the agent of the admin decision.
     */
    @KafkaListener(
            topics = KafkaTopics.PROPERTY_STATUS_CHANGED,
            containerFactory = "notificationKafkaListenerContainerFactory"
    )
    public void onPropertyStatusChanged(
            @Payload PropertyStatusChangedEvent event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment ack) {

        log.info("[Kafka/Notification] property.status.changed: propertyId={} {} → {} offset={}",
                event.getPropertyId(), event.getOldStatus(), event.getNewStatus(), offset);
        try {
            String message = buildPropertyStatusMessage(event);
            notificationService.createNotification(
                    event.getAgentId(),
                    "Property Status Updated",
                    message,
                    NotificationType.SYSTEM,
                    "/agent/properties/" + event.getPropertyId()
            );
            ack.acknowledge();
        } catch (Exception ex) {
            log.error("[Kafka/Notification] Failed status notification for propertyId={}: {}",
                    event.getPropertyId(), ex.getMessage(), ex);
            throw ex;
        }
    }

    // ─── Booking Events ───────────────────────────────────────────────────────

    /**
     * booking.created → notify the agent of the new visit request.
     */
    @KafkaListener(
            topics = KafkaTopics.BOOKING_CREATED,
            containerFactory = "notificationKafkaListenerContainerFactory"
    )
    public void onBookingCreated(
            @Payload BookingCreatedEvent event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment ack) {

        log.info("[Kafka/Notification] booking.created: bookingId={} offset={}", event.getBookingId(), offset);
        try {
            notificationService.createNotification(
                    event.getAgentId(),
                    "New Site Visit Request",
                    "New visit request for '" + event.getPropertyTitle()
                            + "' from " + event.getVisitorName()
                            + " on " + event.getVisitDate(),
                    NotificationType.BOOKING,
                    "/agent/bookings"
            );
            ack.acknowledge();
        } catch (Exception ex) {
            log.error("[Kafka/Notification] Failed notification for bookingId={}: {}",
                    event.getBookingId(), ex.getMessage(), ex);
            throw ex;
        }
    }

    /**
     * booking.status.changed → notify user or agent depending on who acted.
     */
    @KafkaListener(
            topics = KafkaTopics.BOOKING_STATUS_CHANGED,
            containerFactory = "notificationKafkaListenerContainerFactory"
    )
    public void onBookingStatusChanged(
            @Payload BookingStatusChangedEvent event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment ack) {

        log.info("[Kafka/Notification] booking.status.changed: bookingId={} {} → {} offset={}",
                event.getBookingId(), event.getOldStatus(), event.getNewStatus(), offset);
        try {
            boolean agentInitiated = event.getAgentId() != null
                    && event.getAgentId().equals(event.getInitiatorId());

            if (agentInitiated) {
                // Notify the user
                if (event.getUserId() != null) {
                    notificationService.createNotification(
                            event.getUserId(),
                            "Site Visit " + event.getStatusMessage(),
                            "Your visit for '" + event.getPropertyTitle() + "' has been "
                                    + event.getNewStatus().toLowerCase() + " by the agent.",
                            NotificationType.BOOKING,
                            "/user/bookings"
                    );
                }
            } else {
                // User cancelled → notify the agent
                notificationService.createNotification(
                        event.getAgentId(),
                        "Site Visit Cancelled by Visitor",
                        "The visit for '" + event.getPropertyTitle() + "' has been cancelled by the visitor.",
                        NotificationType.BOOKING,
                        "/agent/bookings"
                );
            }
            ack.acknowledge();
        } catch (Exception ex) {
            log.error("[Kafka/Notification] Failed notification for bookingId={}: {}",
                    event.getBookingId(), ex.getMessage(), ex);
            throw ex;
        }
    }

    // ─── Inquiry Events ───────────────────────────────────────────────────────

    /**
     * inquiry.replied → notify the registered inquirer (skip for guests).
     */
    @KafkaListener(
            topics = KafkaTopics.INQUIRY_REPLIED,
            containerFactory = "notificationKafkaListenerContainerFactory"
    )
    public void onInquiryReplied(
            @Payload InquiryRepliedEvent event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment ack) {

        log.info("[Kafka/Notification] inquiry.replied: inquiryId={} offset={}", event.getInquiryId(), offset);
        try {
            // Only create in-app notification for registered users (userId not null)
            if (event.getInquirerUserId() != null) {
                notificationService.createNotification(
                        event.getInquirerUserId(),
                        "Agent Replied to Your Inquiry",
                        "Your inquiry about \"" + event.getPropertyTitle() + "\" has been answered.",
                        NotificationType.INQUIRY,
                        "/user/inquiries"
                );
            }
            ack.acknowledge();
        } catch (Exception ex) {
            log.error("[Kafka/Notification] Failed notification for inquiryId={}: {}",
                    event.getInquiryId(), ex.getMessage(), ex);
            throw ex;
        }
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private String buildPropertyStatusMessage(PropertyStatusChangedEvent event) {
        return switch (event.getNewStatus()) {
            case "AVAILABLE"   -> "Your listing '" + event.getTitle() + "' has been approved and is now live!";
            case "REJECTED"    -> "Your listing '" + event.getTitle() + "' was not approved. Please contact support.";
            case "UNDER_REVIEW"-> "Your listing '" + event.getTitle() + "' is under review.";
            default            -> "Status of '" + event.getTitle() + "' changed to " + event.getNewStatus() + ".";
        };
    }
}
