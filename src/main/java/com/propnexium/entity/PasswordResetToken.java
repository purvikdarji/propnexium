package com.propnexium.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * Entity: password_reset_tokens
 *
 * Stores short-lived, one-time tokens used to reset a user's password.
 */
@Entity
@Table(
    name = "password_reset_tokens",
    indexes = {
        @Index(name = "idx_prt_token",   columnList = "token"),
        @Index(name = "idx_prt_user_id", columnList = "user_id")
    }
)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PasswordResetToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Random UUID stored as the reset link token. */
    @Column(nullable = false, unique = true, length = 100)
    private String token;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /** When the token stops being valid. */
    @Column(nullable = false)
    private LocalDateTime expiryAt;

    /** True once the token has been consumed. */
    @Column(nullable = false)
    @Builder.Default
    private boolean used = false;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    // ── helpers ─────────────────────────────────────────────────────────────

    /** @return true if the token is past its expiry time. */
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(this.expiryAt);
    }
}
