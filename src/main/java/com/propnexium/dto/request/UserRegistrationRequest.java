package com.propnexium.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;

/**
 * DTO for user registration requests.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserRegistrationRequest {

    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be 2–100 characters")
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 100, message = "Password must be at least 8 characters")
    private String password;

    @Pattern(regexp = "^[0-9]{10,15}$", message = "Invalid phone number")
    private String phone;
}
