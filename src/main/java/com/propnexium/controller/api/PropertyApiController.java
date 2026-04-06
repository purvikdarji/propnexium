package com.propnexium.controller.api;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * REST API controller for property operations.
 * TODO: Implement full CRUD, search, and image upload endpoints.
 */
@RestController
@RequestMapping("/api/properties")
public class PropertyApiController {

    @GetMapping
    public ResponseEntity<?> getAllProperties() {
        // TODO: Return paginated property list
        return ResponseEntity.ok(Map.of("message", "Property API — coming soon"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getPropertyById(@PathVariable Long id) {
        // TODO: Return property detail DTO
        return ResponseEntity.ok(Map.of("id", id));
    }

    @PostMapping
    public ResponseEntity<?> createProperty() {
        // TODO: Create property (AGENT role required)
        return ResponseEntity.ok(Map.of("message", "Create property — coming soon"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateProperty(@PathVariable Long id) {
        // TODO: Update property
        return ResponseEntity.ok(Map.of("id", id));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteProperty(@PathVariable Long id) {
        // TODO: Delete property
        return ResponseEntity.noContent().build();
    }
}
