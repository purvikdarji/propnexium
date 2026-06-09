package com.propnexium.config;

import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.core.*;
import org.springframework.kafka.listener.ContainerProperties;
import org.springframework.kafka.listener.DeadLetterPublishingRecoverer;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.springframework.kafka.support.serializer.ErrorHandlingDeserializer;
import org.springframework.kafka.support.serializer.JsonDeserializer;
import org.springframework.kafka.support.serializer.JsonSerializer;
import org.springframework.util.backoff.FixedBackOff;

import java.util.HashMap;
import java.util.Map;

/**
 * Central Kafka configuration for PropNexium.
 *
 * Design decisions:
 * - KRaft mode (no Zookeeper) via Docker Bitnami image.
 * - Idempotent producer (enable.idempotence=true + acks=all) ensures
 *   exactly-once semantics per broker session with zero duplicate writes
 *   on retry after transient failures.
 * - Manual offset commit (MANUAL_IMMEDIATE) — offset is committed only
 *   AFTER the listener method returns successfully. If it throws, the
 *   message is retried, then dead-lettered.
 * - DeadLetterPublishingRecoverer — after {@code retryAttempts} exhausted,
 *   the message is published to {@code <topic>.DLT} for manual inspection.
 * - Topics are pre-created here via KafkaAdmin to avoid relying on
 *   auto-create, giving us explicit control over partitions & replicas.
 */
@Slf4j
@Configuration
public class KafkaConfig {

    @Value("${spring.kafka.bootstrap-servers}")
    private String bootstrapServers;

    @Value("${kafka.consumer.group.email}")
    private String emailGroupId;

    @Value("${kafka.consumer.group.notification}")
    private String notificationGroupId;

    @Value("${kafka.consumer.group.saved-search}")
    private String savedSearchGroupId;

    @Value("${kafka.retry.attempts:3}")
    private long retryAttempts;

    @Value("${kafka.retry.backoff-ms:1000}")
    private long retryBackoffMs;

    // ─── Topic Declarations ───────────────────────────────────────────────────
    // Partitions: 3 (local dev). Scale to 6+ in prod for parallel consumers.
    // Replicas: 1 (local single-broker). Set to 3 in prod KRaft cluster.

    @Bean public NewTopic userRegisteredTopic() {
        return TopicBuilder.name(KafkaTopics.USER_REGISTERED).partitions(3).replicas(1).build();
    }
    @Bean public NewTopic propertySubmittedTopic() {
        return TopicBuilder.name(KafkaTopics.PROPERTY_SUBMITTED).partitions(3).replicas(1).build();
    }
    @Bean public NewTopic propertyStatusChangedTopic() {
        return TopicBuilder.name(KafkaTopics.PROPERTY_STATUS_CHANGED).partitions(6).replicas(1).build();
    }
    @Bean public NewTopic bookingCreatedTopic() {
        return TopicBuilder.name(KafkaTopics.BOOKING_CREATED).partitions(6).replicas(1).build();
    }
    @Bean public NewTopic bookingStatusChangedTopic() {
        return TopicBuilder.name(KafkaTopics.BOOKING_STATUS_CHANGED).partitions(6).replicas(1).build();
    }
    @Bean public NewTopic inquiryRepliedTopic() {
        return TopicBuilder.name(KafkaTopics.INQUIRY_REPLIED).partitions(6).replicas(1).build();
    }

    // ─── Dead Letter Topics (DLT) ─────────────────────────────────────────────
    // Spring-Kafka's DeadLetterPublishingRecoverer looks for <topic>.DLT by
    // convention. We pre-create them with 1 partition each (low volume expected).

    @Bean public NewTopic userRegisteredDlt() {
        return TopicBuilder.name(KafkaTopics.USER_REGISTERED + ".DLT").partitions(1).replicas(1).build();
    }
    @Bean public NewTopic propertyStatusChangedDlt() {
        return TopicBuilder.name(KafkaTopics.PROPERTY_STATUS_CHANGED + ".DLT").partitions(1).replicas(1).build();
    }
    @Bean public NewTopic bookingCreatedDlt() {
        return TopicBuilder.name(KafkaTopics.BOOKING_CREATED + ".DLT").partitions(1).replicas(1).build();
    }
    @Bean public NewTopic bookingStatusChangedDlt() {
        return TopicBuilder.name(KafkaTopics.BOOKING_STATUS_CHANGED + ".DLT").partitions(1).replicas(1).build();
    }
    @Bean public NewTopic inquiryRepliedDlt() {
        return TopicBuilder.name(KafkaTopics.INQUIRY_REPLIED + ".DLT").partitions(1).replicas(1).build();
    }
    @Bean public NewTopic propertySubmittedDlt() {
        return TopicBuilder.name(KafkaTopics.PROPERTY_SUBMITTED + ".DLT").partitions(1).replicas(1).build();
    }

    // ─── Producer ─────────────────────────────────────────────────────────────

    @Bean
    public ProducerFactory<String, Object> producerFactory() {
        Map<String, Object> props = new HashMap<>();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonSerializer.class);
        // Idempotence: broker deduplicates retried messages within a session.
        // Requires acks=all and max.in.flight.requests.per.connection <= 5.
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, 3);
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
        // Include Spring type header so the consumer can pick the right class.
        props.put(JsonSerializer.ADD_TYPE_INFO_HEADERS, true);
        return new DefaultKafkaProducerFactory<>(props);
    }

    @Bean
    public KafkaTemplate<String, Object> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }

    // ─── Consumer ─────────────────────────────────────────────────────────────

    /**
     * Creates a ConsumerFactory wired to the given consumer group ID.
     * Each logical consumer group gets its own factory so group IDs don't leak.
     */
    private ConsumerFactory<String, Object> consumerFactory(String groupId) {
        Map<String, Object> props = new HashMap<>();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "latest");
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        // ErrorHandlingDeserializer wraps JsonDeserializer so a malformed
        // message is caught and forwarded to DLT instead of crash-looping.
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, ErrorHandlingDeserializer.class);
        props.put(ErrorHandlingDeserializer.VALUE_DESERIALIZER_CLASS, JsonDeserializer.class.getName());
        props.put(JsonDeserializer.TRUSTED_PACKAGES, "com.propnexium.kafka.event");
        props.put(JsonDeserializer.USE_TYPE_INFO_HEADERS, true);
        return new DefaultKafkaConsumerFactory<>(props);
    }

    /**
     * Creates a KafkaListenerContainerFactory for the given group.
     * All factories share the same DLT recoverer and error handler.
     */
    private ConcurrentKafkaListenerContainerFactory<String, Object>
            listenerContainerFactory(String groupId) {

        ConcurrentKafkaListenerContainerFactory<String, Object> factory =
                new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory(groupId));

        // MANUAL_IMMEDIATE: ack() commits the offset synchronously right
        // after the listener signals success. Crash before ack = redelivery.
        factory.getContainerProperties().setAckMode(ContainerProperties.AckMode.MANUAL_IMMEDIATE);

        // Dead Letter Topic recoverer — sends to <topic>.DLT on exhaustion.
        DeadLetterPublishingRecoverer recoverer =
                new DeadLetterPublishingRecoverer(kafkaTemplate());

        // Retry up to retryAttempts times with fixed backoff, then DLT.
        DefaultErrorHandler errorHandler =
                new DefaultErrorHandler(recoverer, new FixedBackOff(retryBackoffMs, retryAttempts));

        // Log retried exceptions but do NOT stop the container — keep processing.
        errorHandler.setRetryListeners((record, ex, deliveryAttempt) ->
                log.warn("[Kafka] Retry attempt {} for topic={} partition={} offset={}: {}",
                        deliveryAttempt,
                        record.topic(), record.partition(), record.offset(),
                        ex.getMessage()));

        factory.setCommonErrorHandler(errorHandler);
        return factory;
    }

    // ── Named factories referenced in @KafkaListener(containerFactory = "...") ─

    @Bean("emailKafkaListenerContainerFactory")
    public ConcurrentKafkaListenerContainerFactory<String, Object> emailListenerFactory() {
        return listenerContainerFactory(emailGroupId);
    }

    @Bean("notificationKafkaListenerContainerFactory")
    public ConcurrentKafkaListenerContainerFactory<String, Object> notificationListenerFactory() {
        return listenerContainerFactory(notificationGroupId);
    }

    @Bean("savedSearchKafkaListenerContainerFactory")
    public ConcurrentKafkaListenerContainerFactory<String, Object> savedSearchListenerFactory() {
        return listenerContainerFactory(savedSearchGroupId);
    }
}
