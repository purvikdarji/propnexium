package com.propnexium.dto.request;

import com.propnexium.entity.Property;
import com.propnexium.entity.PropertyAmenities;
import com.propnexium.entity.enums.*;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for the 5-section "Add / Edit Property" form.
 */
@Data
@NoArgsConstructor
public class PropertyCreateDto {

    // ─── Section 1: Basic Info ────────────────────────────────────────────────

    @NotBlank(message = "Property title is required")
    @Size(min = 5, max = 200, message = "Title must be 5–200 characters")
    private String title;

    @Size(max = 2000, message = "Description max 2000 characters")
    private String description;

    @NotNull(message = "Property type is required")
    private PropertyType type;

    @NotNull(message = "Category (Buy/Rent) is required")
    private PropertyCategory category;

    // ─── Section 2: Pricing ───────────────────────────────────────────────────

    @NotNull(message = "Price is required")
    @DecimalMin(value = "100000.0", message = "Minimum price is ₹1,00,000")
    private Double price;

    private Boolean priceNegotiable = false;

    private Double maintenanceCharge;

    // ─── Section 3: Property Details ─────────────────────────────────────────

    @Min(value = 0, message = "Bedrooms cannot be negative")
    @Max(value = 20, message = "Bedrooms max 20")
    private Integer bedrooms;

    @Min(value = 0, message = "Bathrooms cannot be negative")
    @Max(value = 20, message = "Bathrooms max 20")
    private Integer bathrooms;

    @Min(value = 0, message = "Balconies cannot be negative")
    @Max(value = 10, message = "Balconies max 10")
    private Integer balconies;

    @DecimalMin(value = "0.0", message = "Area cannot be negative")
    private Double areaSqft;

    private Integer totalFloors;
    private Integer floorNumber;
    private Integer yearBuilt;

    private Furnishing furnishing;
    private Parking parking;
    private Facing facing;

    // ─── Section 4: Location ─────────────────────────────────────────────────

    @NotBlank(message = "City is required")
    private String city;

    @NotBlank(message = "Address / locality is required")
    private String location;

    private String state;

    @Pattern(regexp = "^$|^[0-9]{6}$", message = "Pincode must be 6 digits")
    private String pincode;

    // Optional geocoded coordinates (from Nominatim / draggable marker)
    private Double latitude;
    private Double longitude;

    // ─── Section 5: Amenities ────────────────────────────────────────────────

    private Boolean hasGym = false;
    private Boolean hasSwimmingPool = false;
    private Boolean hasSecurity = false;
    private Boolean hasLift = false;
    private Boolean hasPowerBackup = false;
    private Boolean hasClubHouse = false;
    private Boolean hasChildrenPlayArea = false;
    private Boolean hasGarden = false;
    private Boolean hasIntercom = false;
    private Boolean hasRainwaterHarvesting = false;
    private Boolean hasWasteManagement = false;
    private Boolean hasVisitorParking = false;

    /**
     * Pre-fill constructor — populates this DTO from an existing Property entity.
     * Used by the edit form ({@code GET /agent/properties/{id}/edit}).
     */
    public PropertyCreateDto(Property p) {
        if (p == null)
            return;
        this.title = p.getTitle();
        this.description = p.getDescription();
        this.type = p.getType();
        this.category = p.getCategory();
        this.price = p.getPrice() != null ? p.getPrice().doubleValue() : null;
        this.priceNegotiable = p.getPriceNegotiable();
        this.maintenanceCharge = p.getMaintenanceCharge() != null ? p.getMaintenanceCharge().doubleValue() : null;
        this.bedrooms = p.getBedrooms();
        this.bathrooms = p.getBathrooms();
        this.balconies = p.getBalconies();
        this.areaSqft = p.getAreaSqft() != null ? p.getAreaSqft().doubleValue() : null;
        this.totalFloors = p.getTotalFloors();
        this.floorNumber = p.getFloorNumber();
        this.yearBuilt = p.getYearBuilt();
        this.furnishing = p.getFurnishing();
        this.parking = p.getParking();
        this.facing = p.getFacing();
        this.city = p.getCity();
        this.location = p.getLocation();
        this.state = p.getState();
        this.pincode = p.getPincode();
        this.latitude = p.getLatitude() != null ? p.getLatitude().doubleValue() : null;
        this.longitude = p.getLongitude() != null ? p.getLongitude().doubleValue() : null;

        PropertyAmenities a = p.getAmenities();
        if (a != null) {
            this.hasGym = a.getHasGym();
            this.hasSwimmingPool = a.getHasSwimmingPool();
            this.hasSecurity = a.getHasSecurity();
            this.hasLift = a.getHasLift();
            this.hasPowerBackup = a.getHasPowerBackup();
            this.hasClubHouse = a.getHasClubHouse();
            this.hasChildrenPlayArea = a.getHasChildrenPlayArea();
            this.hasGarden = a.getHasGarden();
            this.hasIntercom = a.getHasIntercom();
            this.hasRainwaterHarvesting = a.getHasRainwaterHarvesting();
            this.hasWasteManagement = a.getHasWasteManagement();
            this.hasVisitorParking = a.getHasVisitorParking();
        }
    }

    /** Convenience: return priceNegotiable safely (never null). */
    public boolean isPriceNegotiable() {
        return Boolean.TRUE.equals(priceNegotiable);
    }
}
