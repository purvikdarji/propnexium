package com.propnexium.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Kafka message payload published when a new user registers.
 *
 * Why a separate DTO (not the User entity)?
 * - JPA entities hold lazy-loaded collections that cause serialization errors.
 * - Decouples the message schema from the DB schema — DB columns can change
 *   without breaking consumers that rely on the event contract.
 * - Keeps message size small: only fields consumers actually need.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserRegisteredEvent {

    /** Internal DB id — used as Kafka message key for ordering per user. */
    private Long userId;

    private String name;
    private String email;

    /** "USER" or "AGENT" */
    private String role;

    private LocalDateTime registeredAt;
}
