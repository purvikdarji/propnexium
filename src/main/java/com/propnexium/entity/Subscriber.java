package com.propnexium.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "subscribers", indexes = {
        @Index(name = "idx_sub_email", columnList = "email"),
        @Index(name = "idx_sub_token", columnList = "unsubscribe_token")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class Subscriber {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 150)
    private String email;

    @Column(name = "is_subscribed", nullable = false)
    @Builder.Default
    private boolean isSubscribed = true;

    @Column(name = "unsubscribe_token", unique = true, length = 100)
    private String unsubscribeToken;

    @Column(name = "subscribed_at")
    private LocalDateTime subscribedAt;

    @Column(name = "unsubscribed_at")
    private LocalDateTime unsubscribedAt;
}
