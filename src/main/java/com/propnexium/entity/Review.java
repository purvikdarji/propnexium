package com.propnexium.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * Entity: reviews
 *
 * Relationships:
 * users (1) <---> (N) reviews [as agent — the one being reviewed]
 * users (1) <---> (N) reviews [as reviewer — the one writing the review]
 * properties (1) <---> (N) reviews [optional — review may reference a property]
 *
 * Unique constraint: (reviewer_id, agent_id) — one review per reviewer per
 * agent.
 */
@Entity
@Table(name = "reviews", uniqueConstraints = @UniqueConstraint(name = "uq_reviewer_agent", columnNames = {
        "reviewer_id", "agent_id" }))
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@ToString(exclude = { "agent", "reviewer", "property" })
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** The agent (User) being reviewed */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private User agent;

    /** The user writing the review */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewer_id", nullable = false)
    private User reviewer;

    /** Optional — review may reference a specific property transaction */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = true)
    private Property property;

    /** Overall Rating: 1–5 (often the average of sub-ratings) */
    @Column(name = "rating", nullable = false)
    private Integer rating;

    @Column(name = "communication_rating")
    private Integer communicationRating;

    @Column(name = "accuracy_rating")
    private Integer accuracyRating;

    @Column(name = "negotiation_rating")
    private Integer negotiationRating;

    @Column(name = "is_verified_buyer", nullable = false)
    @Builder.Default
    private boolean isVerifiedBuyer = false;

    @Column(name = "comment", columnDefinition = "TEXT")
    private String comment;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public String getFormattedDate() {
        if (createdAt == null) {
            return "";
        }
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy"));
    }
}
