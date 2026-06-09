package com.propnexium.kafka.producer;

import com.propnexium.kafka.event.UserRegisteredEvent;
import com.propnexium.kafka.event.BookingCreatedEvent;
import com.propnexium.kafka.event.PropertyStatusChangedEvent;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.TopicPartition;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.concurrent.CompletableFuture;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for {@link KafkaEventPublisher}.
 *
 * Strategy: mock KafkaTemplate so no real broker is needed.
 * Feature flags are injected via ReflectionTestUtils to simulate
 * different configuration profiles.
 */
@ExtendWith(MockitoExtension.class)
class KafkaEventPublisherTest {

    @Mock
    private KafkaTemplate<String, Object> kafkaTemplate;

    @InjectMocks
    private KafkaEventPublisher publisher;

    // ── Helpers ─────────────────────────────────────────────────────────────

    /**
     * Returns a successful CompletableFuture<SendResult> so kafkaTemplate.send()
     * can be stubbed without a real broker.
     */
    private CompletableFuture<SendResult<String, Object>> successFuture() {
        RecordMetadata metadata = new RecordMetadata(
                new TopicPartition("test-topic", 0), 0L, 0, 0L, 0, 0);
        ProducerRecord<String, Object> record = new ProducerRecord<>("test-topic", "key", "value");
        SendResult<String, Object> result = new SendResult<>(record, metadata);
        return CompletableFuture.completedFuture(result);
    }

    /** Returns a failed CompletableFuture to simulate broker errors. */
    private CompletableFuture<SendResult<String, Object>> failureFuture() {
        CompletableFuture<SendResult<String, Object>> future = new CompletableFuture<>();
        future.completeExceptionally(new RuntimeException("Broker unavailable"));
        return future;
    }

    // ── user.registered ─────────────────────────────────────────────────────

    @Test
    @DisplayName("publishUserRegistered: returns true and sends to Kafka when flag is on")
    void publishUserRegistered_flagOn_sendsToKafka() {
        // Arrange: enable flag
        ReflectionTestUtils.setField(publisher, "userRegisteredEnabled", true);
        when(kafkaTemplate.send(anyString(), anyString(), any())).thenReturn(successFuture());

        UserRegisteredEvent event = UserRegisteredEvent.builder()
                .userId(1L).name("Test User").email("test@example.com")
                .role("USER").registeredAt(LocalDateTime.now()).build();

        // Act
        boolean result = publisher.publishUserRegistered(event);

        // Assert
        assertThat(result).isTrue();
        verify(kafkaTemplate).send(eq("propnexium.user.registered"), eq("1"), eq(event));
    }

    @Test
    @DisplayName("publishUserRegistered: returns false and does NOT call kafkaTemplate when flag is off")
    void publishUserRegistered_flagOff_skipsKafka() {
        // Arrange: disable flag (default)
        ReflectionTestUtils.setField(publisher, "userRegisteredEnabled", false);

        UserRegisteredEvent event = UserRegisteredEvent.builder()
                .userId(2L).name("Another User").email("another@example.com")
                .role("AGENT").registeredAt(LocalDateTime.now()).build();

        // Act
        boolean result = publisher.publishUserRegistered(event);

        // Assert
        assertThat(result).isFalse();
        verifyNoInteractions(kafkaTemplate); // zero Kafka calls
    }

    @Test
    @DisplayName("publishUserRegistered: does NOT throw when Kafka send fails")
    void publishUserRegistered_kafkaFailure_doesNotThrow() {
        ReflectionTestUtils.setField(publisher, "userRegisteredEnabled", true);
        when(kafkaTemplate.send(anyString(), anyString(), any())).thenReturn(failureFuture());

        UserRegisteredEvent event = UserRegisteredEvent.builder()
                .userId(3L).name("Fail User").email("fail@example.com")
                .role("USER").registeredAt(LocalDateTime.now()).build();

        // Act — must not throw; error is logged only
        boolean result = publisher.publishUserRegistered(event);

        assertThat(result).isTrue(); // send was attempted
        verify(kafkaTemplate).send(anyString(), anyString(), any());
    }

    // ── booking.created ──────────────────────────────────────────────────────

    @Test
    @DisplayName("publishBookingCreated: keys by propertyId, not bookingId")
    void publishBookingCreated_usesPropertyIdAsKey() {
        ReflectionTestUtils.setField(publisher, "bookingCreatedEnabled", true);
        when(kafkaTemplate.send(anyString(), anyString(), any())).thenReturn(successFuture());

        BookingCreatedEvent event = BookingCreatedEvent.builder()
                .bookingId(99L).propertyId(42L).build();

        publisher.publishBookingCreated(event);

        // Key must be propertyId (42), not bookingId (99) — ordering per property
        verify(kafkaTemplate).send(
                eq("propnexium.booking.created"), eq("42"), eq(event));
    }

    // ── property.status.changed ───────────────────────────────────────────────

    @Test
    @DisplayName("publishPropertyStatusChanged: sends event with correct topic")
    void publishPropertyStatusChanged_sendsCorrectTopic() {
        ReflectionTestUtils.setField(publisher, "propertyStatusChangedEnabled", true);
        when(kafkaTemplate.send(anyString(), anyString(), any())).thenReturn(successFuture());

        PropertyStatusChangedEvent event = PropertyStatusChangedEvent.builder()
                .propertyId(10L).agentId(5L)
                .oldStatus("UNDER_REVIEW").newStatus("AVAILABLE")
                .price(BigDecimal.valueOf(5000000))
                .changedAt(LocalDateTime.now()).build();

        boolean result = publisher.publishPropertyStatusChanged(event);

        assertThat(result).isTrue();
        verify(kafkaTemplate).send(
                eq("propnexium.property.status.changed"), eq("10"), eq(event));
    }
}
