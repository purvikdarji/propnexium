package com.propnexium.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * Entity: wishlists
 *
 * Relationships:
 * users (1) <---> (N) wishlists
 * properties (1) <---> (N) wishlists
 *
 * Unique constraint: (user_id, property_id) — a user can save a property only
 * once.
 */
@Entity
@Table(name = "wishlists", uniqueConstraints = @UniqueConstraint(name = "uq_user_property", columnNames = { "user_id",
        "property_id" }))
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@ToString(exclude = { "user", "property" })
public class Wishlist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    private Property property;

    @CreationTimestamp
    @Column(name = "added_at", updatable = false)
    private LocalDateTime addedAt;
}
