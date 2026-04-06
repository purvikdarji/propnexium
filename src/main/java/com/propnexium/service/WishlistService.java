package com.propnexium.service;

import com.propnexium.entity.Wishlist;

import java.util.List;

/**
 * Service interface for Wishlist operations.
 */
public interface WishlistService {
    /**
     * Get only the IDs of properties in the user's wishlist.
     */
    List<Long> getUserWishlistPropertyIds(Long userId);

    /**
     * Add a property to user's wishlist.
     * Throws DuplicateResourceException if already saved.
     * Creates a WISHLIST notification for the user.
     */
    void addToWishlist(Long userId, Long propertyId);

    /**
     * Remove a property from user's wishlist.
     */
    void removeFromWishlist(Long userId, Long propertyId);

    /**
     * Get all wishlist items for a user (with property eagerly loaded).
     */
    List<Wishlist> getByUser(Long userId);

    /**
     * Get the most recently saved wishlist items (limit = n).
     */
    List<Wishlist> getRecentByUser(Long userId, int limit);

    /**
     * Check whether a property is already in the user's wishlist.
     */
    boolean isInWishlist(Long userId, Long propertyId);

    /**
     * Count the total number of wishlist entries for a user.
     */
    long countByUser(Long userId);
}
