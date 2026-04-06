package com.propnexium.service.impl;

import com.propnexium.entity.Property;
import com.propnexium.entity.User;
import com.propnexium.entity.Wishlist;
import com.propnexium.entity.enums.NotificationType;
import com.propnexium.exception.DuplicateResourceException;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.repository.WishlistRepository;
import com.propnexium.service.NotificationService;
import com.propnexium.service.WishlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class WishlistServiceImpl implements WishlistService {

    private final WishlistRepository wishlistRepository;
    private final UserRepository userRepository;
    private final PropertyRepository propertyRepository;
    private final NotificationService notificationService;

    // -------------------------------------------------------------------------
    @Override
    @Transactional(readOnly = true)
    public List<Long> getUserWishlistPropertyIds(Long userId) {
        return wishlistRepository.findPropertyIdsByUserId(userId);
    }

    @Override
    public void addToWishlist(Long userId, Long propertyId) {
        if (wishlistRepository.existsByUserIdAndPropertyId(userId, propertyId)) {
            throw new DuplicateResourceException("Property is already in your wishlist");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found: " + propertyId));

        Wishlist wishlist = Wishlist.builder()
                .user(user)
                .property(property)
                .build();
        wishlistRepository.save(wishlist);

        // Notify the user
        notificationService.createNotification(
                userId,
                "Property Added to Wishlist",
                "Property \"" + property.getTitle() + "\" added to your wishlist.",
                NotificationType.WISHLIST,
                "/properties/" + propertyId);
    }

    @Override
    public void removeFromWishlist(Long userId, Long propertyId) {
        wishlistRepository.deleteByUserIdAndPropertyId(userId, propertyId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Wishlist> getByUser(Long userId) {
        List<Wishlist> wishlists = wishlistRepository.findByUserId(userId,
                PageRequest.of(0, Integer.MAX_VALUE, Sort.by(Sort.Direction.DESC, "addedAt")))
                .getContent();
        // Eagerly initialize property images for UI rendering
        wishlists.forEach(w -> {
            if (w.getProperty() != null && w.getProperty().getImages() != null) {
                w.getProperty().getImages().size();
            }
        });
        return wishlists;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Wishlist> getRecentByUser(Long userId, int limit) {
        List<Wishlist> wishlists = wishlistRepository.findByUserId(userId,
                PageRequest.of(0, limit, Sort.by(Sort.Direction.DESC, "addedAt")))
                .getContent();
        // Eagerly initialize property images for UI rendering
        wishlists.forEach(w -> {
            if (w.getProperty() != null && w.getProperty().getImages() != null) {
                w.getProperty().getImages().size();
            }
        });
        return wishlists;
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isInWishlist(Long userId, Long propertyId) {
        return wishlistRepository.existsByUserIdAndPropertyId(userId, propertyId);
    }

    @Override
    @Transactional(readOnly = true)
    public long countByUser(Long userId) {
        return wishlistRepository.countByUserId(userId);
    }
}
