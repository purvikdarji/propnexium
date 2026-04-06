package com.propnexium.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entity: agent_profiles
 *
 * Relationships:
 * users (1) <---> (1) agent_profiles
 */
@Entity
@Table(name = "agent_profiles")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@ToString(exclude = "user")
public class AgentProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "agency_name", length = 100)
    private String agencyName;

    @Column(name = "license_number", length = 50, unique = true)
    private String licenseNumber;

    @Column(name = "experience_years")
    @Builder.Default
    private Integer experienceYears = 0;

    @Column(name = "bio", columnDefinition = "TEXT")
    private String bio;

    @Column(name = "rating", precision = 3, scale = 1)
    @Builder.Default
    private BigDecimal rating = BigDecimal.ZERO;

    @Column(name = "total_listings")
    @Builder.Default
    private Integer totalListings = 0;

    @Column(name = "total_sold")
    @Builder.Default
    private Integer totalSold = 0;

    @Column(name = "website", length = 200)
    private String website;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
