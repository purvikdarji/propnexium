package com.propnexium.entity;

import com.propnexium.entity.enums.UserRole;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Entity: users
 *
 * Relationships:
 * users (1) <---> (1) agent_profiles
 * users (1) <---> (N) properties [as agent]
 * users (1) <---> (N) inquiries [as inquirer]
 * users (1) <---> (N) wishlists
 * users (1) <---> (N) reviews [as agent]
 * users (1) <---> (N) reviews [as reviewer]
 * users (1) <---> (N) notifications
 */
@Entity
@Table(name = "users", indexes = {
        @Index(name = "idx_email", columnList = "email"),
        @Index(name = "idx_role", columnList = "role")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@ToString(exclude = { "properties", "inquiries", "wishlists", "notifications",
        "agentReviews", "reviewerReviews", "agentProfile" })
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "email", nullable = false, unique = true, length = 100)
    private String email;

    @Column(name = "password", nullable = false, length = 255)
    private String password;

    @Column(name = "phone", length = 15)
    private String phone;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", columnDefinition = "ENUM('ADMIN','AGENT','USER') DEFAULT 'USER'")
    @Builder.Default
    private UserRole role = UserRole.USER;

    @Column(name = "profile_picture", length = 300)
    private String profilePicture;

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    @Column(name = "is_email_verified")
    @Builder.Default
    private Boolean isEmailVerified = false;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "last_login")
    private LocalDateTime lastLogin;

    @Column(name = "total_properties_viewed")
    @Builder.Default
    private Integer totalPropertiesViewed = 0;

    @Column(name = "total_searches_count")
    @Builder.Default
    private Integer totalSearchesCount = 0;

    // ===================== RELATIONSHIPS =====================

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY, optional = true)
    private AgentProfile agentProfile;

    @OneToMany(mappedBy = "agent", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Property> properties = new ArrayList<>();

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Inquiry> inquiries = new ArrayList<>();

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Wishlist> wishlists = new ArrayList<>();

    /** Reviews where this user IS the agent being reviewed */
    @OneToMany(mappedBy = "agent", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Review> agentReviews = new ArrayList<>();

    /** Reviews written BY this user */
    @OneToMany(mappedBy = "reviewer", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Review> reviewerReviews = new ArrayList<>();

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Notification> notifications = new ArrayList<>();
}
