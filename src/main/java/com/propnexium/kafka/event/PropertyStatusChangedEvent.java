package com.propnexium.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Kafka message payload published whenever a property's status changes
 * (admin approve/reject, agent soft-delete, etc.).
 *
 * Key consumers:
 * - SavedSearchConsumer: alerts buyers when newStatus = "AVAILABLE".
 * - NotificationConsumer: notifies the agent of the decision.
 *
 * Including both oldStatus and newStatus lets consumers implement precise
 * transition logic (e.g., only alert on UNDER_REVIEW → AVAILABLE, not
 * every AVAILABLE → AVAILABLE no-op).
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PropertyStatusChangedEvent {

    private Long propertyId;
    private Long agentId;
    private String title;
    private String city;
    private String type;
    private String category;
    private BigDecimal price;

    /** Previous status before this change, e.g. "UNDER_REVIEW" */
    private String oldStatus;

    /** New status after this change, e.g. "AVAILABLE" */
    private String newStatus;

    private LocalDateTime changedAt;
}
