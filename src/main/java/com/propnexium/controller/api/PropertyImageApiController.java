package com.propnexium.controller.api;

import com.propnexium.dto.response.ApiResponse;
import com.propnexium.entity.Property;
import com.propnexium.entity.PropertyImage;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.UserRole;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.exception.UnauthorizedAccessException;
import com.propnexium.service.PropertyImageService;
import com.propnexium.service.PropertyService;
import com.propnexium.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/properties/{propertyId}/images")
@PreAuthorize("hasAnyRole('AGENT','ADMIN')")
@RequiredArgsConstructor
public class PropertyImageApiController {

    private final PropertyImageService propertyImageService;
    private final PropertyService propertyService;
    private final UserService userService;

    // ─── GET — list all images ───────────────────────────────────────────────
    @GetMapping
    public ResponseEntity<ApiResponse<List<PropertyImage>>> getImages(
            @PathVariable Long propertyId) {

        List<PropertyImage> images = propertyImageService.getImagesByProperty(propertyId);
        return ResponseEntity.ok(ApiResponse.success(images, "Images retrieved"));
    }

    // ─── POST — upload more images ───────────────────────────────────────────
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<List<PropertyImage>>> uploadImages(
            @PathVariable Long propertyId,
            @RequestParam("images") List<MultipartFile> images) {

        try {
            User agent = userService.getCurrentUser();
            Property property = getVerifiedProperty(propertyId, agent);
            List<PropertyImage> uploaded = propertyImageService.uploadImages(property, images);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success(uploaded, uploaded.size() + " image(s) uploaded"));
        } catch (UnauthorizedAccessException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Upload failed: " + e.getMessage()));
        }
    }

    // ─── DELETE — remove a single image ─────────────────────────────────────
    @DeleteMapping("/{imageId}")
    public ResponseEntity<ApiResponse<String>> deleteImage(
            @PathVariable Long propertyId,
            @PathVariable Long imageId) {

        try {
            User agent = userService.getCurrentUser();
            getVerifiedProperty(propertyId, agent);
            propertyImageService.deleteImage(imageId, propertyId);
            return ResponseEntity.ok(ApiResponse.success(null, "Image deleted"));
        } catch (UnauthorizedAccessException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Delete failed: " + e.getMessage()));
        }
    }

    // ─── PATCH — set primary image ───────────────────────────────────────────
    @PatchMapping("/{imageId}/set-primary")
    public ResponseEntity<ApiResponse<String>> setPrimary(
            @PathVariable Long propertyId,
            @PathVariable Long imageId) {

        try {
            User agent = userService.getCurrentUser();
            getVerifiedProperty(propertyId, agent);
            propertyImageService.setPrimary(imageId, propertyId);
            return ResponseEntity.ok(ApiResponse.success(null, "Primary image updated"));
        } catch (UnauthorizedAccessException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Operation failed: " + e.getMessage()));
        }
    }

    // ─── PATCH — reorder images ──────────────────────────────────────────────
    @PatchMapping("/reorder")
    public ResponseEntity<ApiResponse<String>> reorderImages(
            @PathVariable Long propertyId,
            @RequestBody List<Map<String, Long>> orderData) {

        try {
            User agent = userService.getCurrentUser();
            getVerifiedProperty(propertyId, agent);
            propertyImageService.reorderImages(orderData);
            return ResponseEntity.ok(ApiResponse.success(null, "Image order updated"));
        } catch (UnauthorizedAccessException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Reorder failed: " + e.getMessage()));
        }
    }

    // ─── Helper ──────────────────────────────────────────────────────────────
    private Property getVerifiedProperty(Long propertyId, User agent) {
        Property property = propertyService.findById(propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property", "id", propertyId));

        boolean isAdmin = UserRole.ADMIN.equals(agent.getRole());
        if (!isAdmin && !property.getAgent().getId().equals(agent.getId())) {
            throw new UnauthorizedAccessException(
                    "You can only manage images for your own properties");
        }
        return property;
    }
}
