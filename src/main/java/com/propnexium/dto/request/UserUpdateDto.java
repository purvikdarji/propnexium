package com.propnexium.dto.request;

import com.propnexium.entity.User;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * DTO for updating user profile fields (name, phone).
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserUpdateDto {

    @NotBlank(message = "Full name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;

    @Pattern(regexp = "^[0-9]{10}$|^$", message = "Enter a valid 10-digit phone number")
    private String phone;

    /** Convenience constructor — pre-fills from an existing User entity. */
    public UserUpdateDto(User user) {
        this.name = user.getName();
        this.phone = user.getPhone();
    }
}
