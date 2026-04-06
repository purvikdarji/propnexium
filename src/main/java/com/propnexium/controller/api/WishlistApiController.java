package com.propnexium.controller.api;

import com.propnexium.entity.Wishlist;
import com.propnexium.exception.DuplicateResourceException;
import com.propnexium.service.UserService;
import com.propnexium.service.WishlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST API for wishlist operations.
 * Base path: /api/v1/wishlist
 * All endpoints require authentication.
 */
@RestController
@RequestMapping("/api/v1/wishlist")
@PreAuthorize("isAuthenticated()")
@RequiredArgsConstructor
public class WishlistApiController {

    private final WishlistService wishlistService;
    private final UserService userService;

    /** POST /api/v1/wishlist/{propertyId} — add to wishlist */
    @PostMapping("/{propertyId}")
    public ResponseEntity<?> addToWishlist(@PathVariable Long propertyId) {
        try {
            Long userId = userService.getCurrentUser().getId();
            wishlistService.addToWishlist(userId, propertyId);
            return ResponseEntity.ok(Map.of("message", "Property added to wishlist"));
        } catch (DuplicateResourceException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    /** DELETE /api/v1/wishlist/{propertyId} — remove from wishlist */
    @DeleteMapping("/{propertyId}")
    public ResponseEntity<?> removeFromWishlist(@PathVariable Long propertyId) {
        Long userId = userService.getCurrentUser().getId();
        wishlistService.removeFromWishlist(userId, propertyId);
        return ResponseEntity.ok(Map.of("message", "Property removed from wishlist"));
    }

    /** GET /api/v1/wishlist — get user's entire wishlist */
    @GetMapping
    public ResponseEntity<List<Wishlist>> getWishlist() {
        Long userId = userService.getCurrentUser().getId();
        return ResponseEntity.ok(wishlistService.getByUser(userId));
    }

    /**
     * GET /api/v1/wishlist/{propertyId}/check — returns {inWishlist: true/false}
     */
    @GetMapping("/{propertyId}/check")
    public ResponseEntity<Map<String, Boolean>> checkWishlist(@PathVariable Long propertyId) {
        Long userId = userService.getCurrentUser().getId();
        boolean inWishlist = wishlistService.isInWishlist(userId, propertyId);
        return ResponseEntity.ok(Map.of("inWishlist", inWishlist));
    }
}
