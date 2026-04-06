package com.propnexium.entity;
import com.propnexium.entity.enums.*;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "properties", indexes = {
        @Index(name = "idx_city", columnList = "city"),
        @Index(name = "idx_type", columnList = "type"),
        @Index(name = "idx_category", columnList = "category"),
        @Index(name = "idx_status", columnList = "status"),
        @Index(name = "idx_price", columnList = "price")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@ToString(exclude = { "agent", "images", "amenities", "inquiries", "wishlists" })
public class Property {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** The agent (User) who listed this property */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private User agent;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "price", nullable = false, precision = 15, scale = 2)
    private BigDecimal price;

    @Column(name = "price_negotiable")
    @Builder.Default
    private Boolean priceNegotiable = false;

    @Column(name = "location", length = 300)
    private String location;

    @Column(name = "city", nullable = false, length = 100)
    private String city;

    @Column(name = "state", length = 100)
    private String state;

    @Column(name = "pincode", length = 6)
    private String pincode;

    @Column(name = "latitude", precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private BigDecimal longitude;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, columnDefinition = "ENUM('APARTMENT','HOUSE','VILLA','PLOT','COMMERCIAL','STUDIO','PENTHOUSE')")
    private PropertyType type;

    @Enumerated(EnumType.STRING)
    @Column(name = "category", columnDefinition = "ENUM('BUY','RENT') DEFAULT 'BUY'")
    @Builder.Default
    private PropertyCategory category = PropertyCategory.BUY;

    @Column(name = "bedrooms")
    @Builder.Default
    private Integer bedrooms = 0;

    @Column(name = "bathrooms")
    @Builder.Default
    private Integer bathrooms = 0;

    @Column(name = "balconies")
    @Builder.Default
    private Integer balconies = 0;

    @Column(name = "area_sqft", precision = 10, scale = 2)
    private BigDecimal areaSqft;

    @Column(name = "total_floors")
    private Integer totalFloors;

    @Column(name = "floor_number")
    private Integer floorNumber;

    @Enumerated(EnumType.STRING)
    @Column(name = "furnishing", columnDefinition = "ENUM('UNFURNISHED','SEMI_FURNISHED','FULLY_FURNISHED') DEFAULT 'UNFURNISHED'")
    @Builder.Default
    private Furnishing furnishing = Furnishing.UNFURNISHED;

    @Enumerated(EnumType.STRING)
    @Column(name = "parking", columnDefinition = "ENUM('NONE','ONE','TWO','THREE_PLUS') DEFAULT 'NONE'")
    @Builder.Default
    private Parking parking = Parking.NONE;

    @Enumerated(EnumType.STRING)
    @Column(name = "facing", columnDefinition = "ENUM('NORTH','SOUTH','EAST','WEST','NORTH_EAST','NORTH_WEST','SOUTH_EAST','SOUTH_WEST')")
    private Facing facing;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", columnDefinition = "ENUM('AVAILABLE','SOLD','RENTED','UNDER_REVIEW','REJECTED') DEFAULT 'UNDER_REVIEW'")
    @Builder.Default
    private PropertyStatus status = PropertyStatus.UNDER_REVIEW;

    @Column(name = "is_featured")
    @Builder.Default
    private Boolean isFeatured = false;

    @Column(name = "view_count")
    @Builder.Default
    private Integer viewCount = 0;

    @Column(name = "maintenance_charge", precision = 10, scale = 2)
    private BigDecimal maintenanceCharge;

    @Column(name = "year_built")
    private Integer yearBuilt;

    @Column(name = "possession_date")
    private LocalDate possessionDate;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // ===================== RELATIONSHIPS =====================

    @OneToMany(mappedBy = "property", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<PropertyImage> images = new ArrayList<>();

    @OneToOne(mappedBy = "property", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private PropertyAmenities amenities;

    @OneToMany(mappedBy = "property", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Inquiry> inquiries = new ArrayList<>();

    @OneToMany(mappedBy = "property", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Wishlist> wishlists = new ArrayList<>();
}
