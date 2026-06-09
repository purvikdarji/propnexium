package com.propnexium.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Kafka message payload published when a booking's status changes:
 * PENDING → CONFIRMED, CONFIRMED → RESCHEDULED, * → CANCELLED, etc.
 *
 * The consumer determines who to notify:
 * - Agent cancelled? → notify user.
 * - User cancelled? → notify agent.
 * - Agent confirmed? → notify user.
 *
 * The {@code initiatorId} field indicates who triggered the change so
 * the consumer can differentiate user vs. agent actions without a DB lookup.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingStatusChangedEvent {

    private Long bookingId;
    private Long propertyId;
    private String propertyTitle;
    private Long userId;
    private Long agentId;

    /** ID of the user or agent that triggered this status change. */
    private Long initiatorId;

    private String oldStatus;
    private String newStatus;

    /** Human-readable message sent to the notified party (e.g. "Confirmed", "Declined"). */
    private String statusMessage;

    /** Optional notes the agent attached when confirming/rescheduling. */
    private String agentNotes;

    private LocalDateTime changedAt;
}
