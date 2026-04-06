package com.propnexium.dto.response;

import com.propnexium.entity.enums.UserRole;
import lombok.*;

import java.time.LocalDateTime;

/**
 * DTO for returning user profile data in API responses.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {

    private Long id;
    private String name;
    private String email;
    private String phone;
    private UserRole role;
    private String profilePicture;
    private Boolean isActive;
    private Boolean isEmailVerified;
    private LocalDateTime createdAt;
}
