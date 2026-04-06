package com.propnexium.dto.response;

import com.propnexium.entity.enums.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO for returning property data in API responses.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PropertyResponse {

    private Long id;
    private String title;
    private String description;
    private BigDecimal price;
    private Boolean priceNegotiable;
    private String location;
    private String city;
    private String state;
    private String pincode;
    private PropertyType type;
    private PropertyCategory category;
    private Integer bedrooms;
    private Integer bathrooms;
    private Integer balconies;
    private BigDecimal areaSqft;
    private Furnishing furnishing;
    private Parking parking;
    private Facing facing;
    private PropertyStatus status;
    private Boolean isFeatured;
    private Integer viewCount;
    private BigDecimal maintenanceCharge;
    private Integer yearBuilt;
    private LocalDateTime createdAt;

    // Agent summary
    private Long agentId;
    private String agentName;
    private String agentEmail;
    private String agentPhone;

    // Primary image URL (for listing cards)
    private String primaryImageUrl;

    // Full image list (for detail page)
    private List<String> imageUrls;
}
