package com.propnexium.entity;

import jakarta.persistence.*;
import lombok.*;

/**
 * Entity: property_amenities
 *
 * Relationships:
 * properties (1) <---> (1) property_amenities
 */
@Entity
@Table(name = "property_amenities")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@ToString(exclude = "property")
public class PropertyAmenities {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false, unique = true)
    private Property property;

    @Column(name = "has_gym")
    @Builder.Default
    private Boolean hasGym = false;

    @Column(name = "has_swimming_pool")
    @Builder.Default
    private Boolean hasSwimmingPool = false;

    @Column(name = "has_security")
    @Builder.Default
    private Boolean hasSecurity = false;

    @Column(name = "has_lift")
    @Builder.Default
    private Boolean hasLift = false;

    @Column(name = "has_power_backup")
    @Builder.Default
    private Boolean hasPowerBackup = false;

    @Column(name = "has_club_house")
    @Builder.Default
    private Boolean hasClubHouse = false;

    @Column(name = "has_children_play_area")
    @Builder.Default
    private Boolean hasChildrenPlayArea = false;

    @Column(name = "has_garden")
    @Builder.Default
    private Boolean hasGarden = false;

    @Column(name = "has_intercom")
    @Builder.Default
    private Boolean hasIntercom = false;

    @Column(name = "has_rainwater_harvesting")
    @Builder.Default
    private Boolean hasRainwaterHarvesting = false;

    @Column(name = "has_waste_management")
    @Builder.Default
    private Boolean hasWasteManagement = false;

    @Column(name = "has_visitor_parking")
    @Builder.Default
    private Boolean hasVisitorParking = false;
}
