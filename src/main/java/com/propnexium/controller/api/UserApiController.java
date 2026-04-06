package com.propnexium.controller.api;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * REST API controller for user registration and profile management.
 * TODO: Implement registration, profile update, and user info endpoints.
 */
@RestController
@RequestMapping("/api/users")
public class UserApiController {

    @PostMapping("/register")
    public ResponseEntity<?> register() {
        // TODO: User registration with validation
        return ResponseEntity.ok(Map.of("message", "Registration — coming soon"));
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile() {
        // TODO: Return authenticated user profile
        return ResponseEntity.ok(Map.of("message", "Profile — coming soon"));
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile() {
        // TODO: Update profile
        return ResponseEntity.ok(Map.of("message", "Update profile — coming soon"));
    }
}
