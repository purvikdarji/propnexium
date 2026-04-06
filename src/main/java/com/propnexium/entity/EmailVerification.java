package com.propnexium.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "email_verifications")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class EmailVerification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    @JsonIgnore
    private User user;

    @Column(nullable = false, unique = true, length = 100)
    private String token;

    @Column(name = "expiry_at", nullable = false)
    private LocalDateTime expiryAt;

    @Column(name = "verified_at")
    private LocalDateTime verifiedAt;

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(this.expiryAt);
    }

    public boolean isVerified() {
        return this.verifiedAt != null;
    }
}
