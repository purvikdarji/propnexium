package com.propnexium.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDate;
import org.springframework.format.annotation.DateTimeFormat;

@Data
public class BookingRequestDto {

    private Long propertyId;

    @NotNull(message = "Visit date is required")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate visitDate;

    @NotBlank(message = "Time slot is required")
    private String timeSlot;

    @NotBlank(message = "Visitor name is required")
    @Size(max = 100, message = "Name must be less than 100 characters")
    private String visitorName;

    @NotBlank(message = "Visitor phone is required")
    @Pattern(regexp = "^[0-9]{10}$", message = "Phone must be a valid 10-digit number")
    private String visitorPhone;

    @NotBlank(message = "Visitor email is required")
    @Email(message = "Please provide a valid email address")
    private String visitorEmail;

    private String notes;
}
