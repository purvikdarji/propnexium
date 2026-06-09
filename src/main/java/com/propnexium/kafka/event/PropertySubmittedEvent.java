package com.propnexium.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Kafka message payload published when an agent submits a new property
 * listing (status = UNDER_REVIEW). Admin consumers use this to create
 * in-app notifications and/or send alert emails to admins.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PropertySubmittedEvent {

    /** Kafka message key — routes all events for same property to same partition. */
    private Long propertyId;

    private Long agentId;
    private String agentName;
    private String title;
    private String city;
    private LocalDateTime submittedAt;
}
