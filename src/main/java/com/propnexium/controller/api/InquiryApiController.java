package com.propnexium.controller.api;

import com.propnexium.dto.request.InquiryDto;
import com.propnexium.entity.Inquiry;
import com.propnexium.entity.User;
import com.propnexium.service.InquiryService;
import com.propnexium.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * REST API for inquiry operations.
 * Base path: /api/v1/inquiries
 */
@RestController
@RequestMapping("/api/v1/inquiries")
@RequiredArgsConstructor
public class InquiryApiController {

    private final InquiryService inquiryService;
    private final UserService userService;

    /**
     * POST /api/v1/inquiries/property/{propertyId}
     * Submit an inquiry for a property. Works for both guests and logged-in users.
     */
    @PostMapping("/property/{propertyId}")
    public ResponseEntity<?> submitInquiry(
            @PathVariable Long propertyId,
            @RequestBody @Valid InquiryDto dto) {

        Long userId = null;
        try {
            User current = userService.getCurrentUser();
            if (current != null)
                userId = current.getId();
        } catch (Exception ignored) {
            /* guest user */ }

        try {
            Inquiry saved = inquiryService.createInquiry(propertyId, userId, dto);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Inquiry submitted successfully",
                    "inquiryId", saved.getId()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", e.getMessage()));
        }
    }
}
