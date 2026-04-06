package com.propnexium.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ReviewDto {
    @NotNull(message = "Rating is required")
    @Min(value = 1, message = "Minimum rating is 1")
    @Max(value = 5, message = "Maximum rating is 5")
    private Integer rating;

    @Min(value = 1, message = "Minimum communication rating is 1")
    @Max(value = 5, message = "Maximum communication rating is 5")
    private Integer communicationRating;

    @Min(value = 1, message = "Minimum accuracy rating is 1")
    @Max(value = 5, message = "Maximum accuracy rating is 5")
    private Integer accuracyRating;

    @Min(value = 1, message = "Minimum negotiation rating is 1")
    @Max(value = 5, message = "Maximum negotiation rating is 5")
    private Integer negotiationRating;

    @Size(max = 1000, message = "Review cannot exceed 1000 characters")
    private String comment;

    private Long propertyId;
}
