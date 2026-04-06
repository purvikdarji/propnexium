package com.propnexium.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "property_bookings")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PropertyBooking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    @JsonIgnore
    private Property property;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnore
    private User user;
    
    @Column(name = "visit_date", nullable = false)
    private LocalDate visitDate;
    
    @Column(name = "time_slot", nullable = false, length = 20)
    private String timeSlot;
    
    @Column(name = "visitor_name", nullable = false, length = 100)
    private String visitorName;
    
    @Column(name = "visitor_phone", nullable = false, length = 15)
    private String visitorPhone;
    
    @Column(name = "visitor_email", nullable = false, length = 150)
    private String visitorEmail;
    
    @Column(columnDefinition = "TEXT")
    private String notes;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private BookingStatus status = BookingStatus.PENDING;
    
    @Column(name = "agent_notes", columnDefinition = "TEXT")
    private String agentNotes;
    
    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    public enum BookingStatus {
        PENDING, CONFIRMED, RESCHEDULED, CANCELLED, COMPLETED
    }
}
