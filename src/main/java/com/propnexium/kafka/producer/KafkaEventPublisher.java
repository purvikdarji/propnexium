package com.propnexium.kafka.producer;

import com.propnexium.config.KafkaTopics;
import com.propnexium.kafka.event.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

/**
 * Central Kafka producer service for PropNexium.
 *
 * Design decisions:
 * - Each publish method checks its own per-topic feature flag before sending.
 *   If the flag is false, the method is a no-op and the caller's legacy
 *   fallback path handles the work. This enables zero-downtime, topic-by-topic
 *   migration.
 * - All sends are fire-and-forget from the caller's perspective (non-blocking).
 *   The CompletableFuture callback only logs — it never throws back to the
 *   calling service thread. Email / notification failures are handled by the
 *   consumer's retry + DLT mechanism, not the producer.
 * - The Kafka message KEY is always a domain entity ID (String). This ensures
 *   all events for the same entity land on the same partition in insertion order.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class KafkaEventPublisher {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    // ── Per-topic feature flags ───────────────────────────────────────────────

    @Value("${kafka.topics.user-registered.enabled:false}")
    private boolean userRegisteredEnabled;

    @Value("${kafka.topics.property-submitted.enabled:false}")
    private boolean propertySubmittedEnabled;

    @Value("${kafka.topics.property-status-changed.enabled:false}")
    private boolean propertyStatusChangedEnabled;

    @Value("${kafka.topics.booking-created.enabled:false}")
    private boolean bookingCreatedEnabled;

    @Value("${kafka.topics.booking-status-changed.enabled:false}")
    private boolean bookingStatusChangedEnabled;

    @Value("${kafka.topics.inquiry-replied.enabled:false}")
    private boolean inquiryRepliedEnabled;

    // ─── Public publish methods ───────────────────────────────────────────────

    /**
     * Publishes a {@link UserRegisteredEvent}.
     *
     * @param event fully populated event DTO
     * @return true if the send was attempted, false if the feature flag is off
     */
    public boolean publishUserRegistered(UserRegisteredEvent event) {
        if (!userRegisteredEnabled) {
            log.debug("[Kafka] user-registered topic disabled — skipping publish for userId={}", event.getUserId());
            return false;
        }
        send(KafkaTopics.USER_REGISTERED, String.valueOf(event.getUserId()), event);
        return true;
    }

    /**
     * Publishes a {@link PropertySubmittedEvent}.
     */
    public boolean publishPropertySubmitted(PropertySubmittedEvent event) {
        if (!propertySubmittedEnabled) {
            log.debug("[Kafka] property-submitted topic disabled — skipping for propertyId={}", event.getPropertyId());
            return false;
        }
        send(KafkaTopics.PROPERTY_SUBMITTED, String.valueOf(event.getPropertyId()), event);
        return true;
    }

    /**
     * Publishes a {@link PropertyStatusChangedEvent}.
     */
    public boolean publishPropertyStatusChanged(PropertyStatusChangedEvent event) {
        if (!propertyStatusChangedEnabled) {
            log.debug("[Kafka] property-status-changed topic disabled — skipping for propertyId={}", event.getPropertyId());
            return false;
        }
        send(KafkaTopics.PROPERTY_STATUS_CHANGED, String.valueOf(event.getPropertyId()), event);
        return true;
    }

    /**
     * Publishes a {@link BookingCreatedEvent}.
     */
    public boolean publishBookingCreated(BookingCreatedEvent event) {
        if (!bookingCreatedEnabled) {
            log.debug("[Kafka] booking-created topic disabled — skipping for bookingId={}", event.getBookingId());
            return false;
        }
        // Key by propertyId so all bookings for the same property stay ordered.
        send(KafkaTopics.BOOKING_CREATED, String.valueOf(event.getPropertyId()), event);
        return true;
    }

    /**
     * Publishes a {@link BookingStatusChangedEvent}.
     */
    public boolean publishBookingStatusChanged(BookingStatusChangedEvent event) {
        if (!bookingStatusChangedEnabled) {
            log.debug("[Kafka] booking-status-changed topic disabled — skipping for bookingId={}", event.getBookingId());
            return false;
        }
        send(KafkaTopics.BOOKING_STATUS_CHANGED, String.valueOf(event.getPropertyId()), event);
        return true;
    }

    /**
     * Publishes an {@link InquiryRepliedEvent}.
     */
    public boolean publishInquiryReplied(InquiryRepliedEvent event) {
        if (!inquiryRepliedEnabled) {
            log.debug("[Kafka] inquiry-replied topic disabled — skipping for inquiryId={}", event.getInquiryId());
            return false;
        }
        send(KafkaTopics.INQUIRY_REPLIED, String.valueOf(event.getPropertyId()), event);
        return true;
    }

    // ─── Internal helper ──────────────────────────────────────────────────────

    /**
     * Sends a message to the given topic and attaches a completion callback.
     *
     * Trade-off: send() is async. If the broker is unavailable the message is
     * buffered in the producer's in-memory queue (controlled by buffer.memory).
     * For synchronous guarantee use kafkaTemplate.send(...).get() but that
     * blocks the request thread — not appropriate for web handler context.
     */
    private void send(String topic, String key, Object payload) {
        CompletableFuture<SendResult<String, Object>> future =
                kafkaTemplate.send(topic, key, payload);

        future.whenComplete((result, ex) -> {
            if (ex != null) {
                // Do NOT re-throw — the caller has already returned a response
                // to the user. The idempotent producer will retry automatically.
                log.error("[Kafka] Failed to publish to topic={} key={}: {}",
                        topic, key, ex.getMessage(), ex);
            } else {
                log.debug("[Kafka] Published to topic={} partition={} offset={} key={}",
                        topic,
                        result.getRecordMetadata().partition(),
                        result.getRecordMetadata().offset(),
                        key);
            }
        });
    }
}
