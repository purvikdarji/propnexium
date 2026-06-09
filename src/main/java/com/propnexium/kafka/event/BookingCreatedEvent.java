package com.propnexium.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Kafka message payload published when a user creates a new site-visit booking.
 *
 * Replaces the TransactionSynchronization.afterCommit() pattern in
 * BookingServiceImpl — the same data is now durably stored in Kafka and
 * delivered to both the email consumer and the notification consumer.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingCreatedEvent {

    private Long bookingId;
    private Long propertyId;
    private String propertyTitle;
    private Long agentId;

    /** May be null for anonymous visitors; used only for in-app notifications. */
    private Long userId;

    private String visitorName;
    private String visitorEmail;
    private LocalDate visitDate;
    private String timeSlot;
    private LocalDateTime createdAt;
}
