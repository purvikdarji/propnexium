package com.propnexium.dto.request;

import com.propnexium.entity.AgentProfile;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for editing an agent's professional profile.
 */
@Data
@NoArgsConstructor
public class AgentProfileDto {

    @Size(max = 100, message = "Agency name cannot exceed 100 characters")
    private String agencyName;

    @Size(max = 50, message = "License number too long")
    private String licenseNumber;

    @Min(value = 0, message = "Experience cannot be negative")
    @Max(value = 50, message = "Experience cannot exceed 50 years")
    private Integer experienceYears;

    @Size(max = 1000, message = "Bio cannot exceed 1000 characters")
    private String bio;

    @Size(max = 200, message = "Website URL too long")
    private String website;

    /**
     * Pre-fills the form from an existing AgentProfile.
     * Safe to call with null — leaves all fields as null.
     */
    public AgentProfileDto(AgentProfile profile) {
        if (profile != null) {
            this.agencyName = profile.getAgencyName();
            this.licenseNumber = profile.getLicenseNumber();
            this.experienceYears = profile.getExperienceYears();
            this.bio = profile.getBio();
            this.website = profile.getWebsite();
        }
    }
}
