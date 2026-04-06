package com.propnexium.entity;

import com.propnexium.entity.enums.InquiryStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * Entity: inquiries
 *
 * Relationships:
 * properties (1) <---> (N) inquiries
 * users (1) <---> (N) inquiries [as inquirer, nullable — guest can inquire]
 */
@Entity
@Table(name = "inquiries", indexes = {
        @Index(name = "idx_property_id", columnList = "property_id"),
        @Index(name = "idx_status", columnList = "status")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@ToString(exclude = { "property", "user" })
public class Inquiry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    private Property property;

    /** Nullable — guest users can submit inquiries without an account */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = true)
    private User user;

    @Column(name = "inquirer_name", nullable = false, length = 100)
    private String inquirerName;

    @Column(name = "inquirer_email", nullable = false, length = 100)
    private String inquirerEmail;

    @Column(name = "inquirer_phone", length = 15)
    private String inquirerPhone;

    @Column(name = "message", nullable = false, columnDefinition = "TEXT")
    private String message;

    @Column(name = "agent_reply", columnDefinition = "TEXT")
    private String agentReply;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", columnDefinition = "ENUM('PENDING','REPLIED','CLOSED') DEFAULT 'PENDING'")
    @Builder.Default
    private InquiryStatus status = InquiryStatus.PENDING;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "replied_at")
    private LocalDateTime repliedAt;
}
