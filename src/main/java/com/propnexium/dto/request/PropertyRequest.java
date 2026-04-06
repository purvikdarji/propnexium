package com.propnexium.dto.request;

import com.propnexium.entity.enums.*;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;

/**
 * DTO for creating or updating a property listing.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PropertyRequest {

    @NotBlank(message = "Title is required")
    @Size(max = 200, message = "Title must be at most 200 characters")
    private String title;

    private String description;

    @NotNull(message = "Price is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Price must be greater than 0")
    private BigDecimal price;

    private Boolean priceNegotiable = false;

    private String location;

    @NotBlank(message = "City is required")
    private String city;

    private String state;

    private String pincode;

    @NotNull(message = "Property type is required")
    private PropertyType type;

    private PropertyCategory category = PropertyCategory.BUY;

    @Min(value = 0)
    private Integer bedrooms;
    @Min(value = 0)
    private Integer bathrooms;
    @Min(value = 0)
    private Integer balconies;

    @DecimalMin(value = "0.0")
    private BigDecimal areaSqft;

    private Integer totalFloors;
    private Integer floorNumber;

    private Furnishing furnishing = Furnishing.UNFURNISHED;
    private Parking parking = Parking.NONE;
    private Facing facing;

    private BigDecimal maintenanceCharge;
    private Integer yearBuilt;
}
