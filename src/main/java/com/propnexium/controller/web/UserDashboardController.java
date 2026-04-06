package com.propnexium.controller.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.propnexium.dto.request.UserUpdateDto;
import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.entity.SavedSearch;
import com.propnexium.entity.User;
import com.propnexium.service.*;
import com.propnexium.util.FileStorageService;
import com.propnexium.exception.InvalidFileException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Controller
@RequestMapping("/user")
@PreAuthorize("isAuthenticated()")
@RequiredArgsConstructor
public class UserDashboardController {
    private static final Logger log = LoggerFactory.getLogger(UserDashboardController.class);

    private final UserService userService;
    private final WishlistService wishlistService;
    private final InquiryService inquiryService;
    private final NotificationService notificationService;
    private final FileStorageService fileStorageService;
    private final SavedSearchService savedSearchService;
    private final ObjectMapper objectMapper;

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        User currentUser = userService.getCurrentUser();
        model.addAttribute("user", currentUser);
        if (currentUser.getCreatedAt() != null) {
            model.addAttribute("memberSince",
                    currentUser.getCreatedAt().format(DateTimeFormatter.ofPattern("MMM yyyy", Locale.ENGLISH)));
        }
        model.addAttribute("wishlistCount", wishlistService.countByUser(currentUser.getId()));
        model.addAttribute("inquiryCount", inquiryService.countByUser(currentUser.getId()));
        model.addAttribute("recentWishlist", wishlistService.getRecentByUser(currentUser.getId(), 4));
        model.addAttribute("recentInquiries", inquiryService.getRecentByUser(currentUser.getId(), 5));
        model.addAttribute("unreadNotifications", notificationService.countUnread(currentUser.getId()));

        // ── Saved Searches ────────────────────────────────────────────────────
        List<SavedSearch> savedSearches = savedSearchService.getUserSavedSearches(currentUser.getId());
        Map<Long, String> savedSearchUrls = new HashMap<>();
        Map<Long, List<String>> savedSearchLabels = new HashMap<>();
        for (SavedSearch ss : savedSearches) {
            savedSearchUrls.put(ss.getId(), savedSearchService.buildSearchUrl(ss));
            try {
                SearchCriteriaDto criteria = objectMapper.readValue(
                        ss.getFiltersJson(), SearchCriteriaDto.class);
                savedSearchLabels.put(ss.getId(), criteria.getActiveFilterLabels());
            } catch (Exception e) {
                log.warn("Could not parse filtersJson for saved search {}: {}", ss.getId(), e.getMessage());
                savedSearchLabels.put(ss.getId(), List.of());
            }
        }
        model.addAttribute("savedSearches", savedSearches);
        model.addAttribute("savedSearchUrls", savedSearchUrls);
        model.addAttribute("savedSearchLabels", savedSearchLabels);

        return "user/dashboard";
    }

    @GetMapping("/profile")
    public String profilePage(Model model) {
        User currentUser = userService.getCurrentUser();
        model.addAttribute("user", currentUser);
        model.addAttribute("updateDto", new UserUpdateDto(currentUser));
        if (currentUser.getCreatedAt() != null) {
            model.addAttribute("memberSince",
                    currentUser.getCreatedAt().format(DateTimeFormatter.ofPattern("MMM yyyy", Locale.ENGLISH)));
        }
        return "user/profile";
    }

    @PostMapping("/profile/update")
    public String updateProfile(
            @ModelAttribute("updateDto") @Valid UserUpdateDto dto,
            BindingResult result,
            RedirectAttributes redirectAttrs,
            Model model) {

        if (result.hasErrors()) {
            model.addAttribute("user", userService.getCurrentUser());
            result.getFieldErrors("name").stream().findFirst()
                    .ifPresent(e -> model.addAttribute("nameError", e.getDefaultMessage()));
            result.getFieldErrors("phone").stream().findFirst()
                    .ifPresent(e -> model.addAttribute("phoneError", e.getDefaultMessage()));
            return "user/profile";
        }

        try {
            userService.updateProfile(userService.getCurrentUser().getId(), dto);
            redirectAttrs.addFlashAttribute("successMessage", "Profile updated successfully!");
        } catch (Exception e) {
            redirectAttrs.addFlashAttribute("errorMessage", "Update failed: " + e.getMessage());
        }
        return "redirect:/user/profile";
    }

    /** POST /user/profile/picture */
    @PostMapping("/profile/picture")
    public String uploadProfilePicture(
            @RequestParam("picture") MultipartFile file,
            RedirectAttributes redirectAttrs) {

        try {
            User currentUser = userService.getCurrentUser();
            String filename = fileStorageService.storeFile(file, "profile-pictures");
            String imageUrl = "/uploads/profile-pictures/" + filename;
            userService.updateProfilePicture(currentUser.getId(), imageUrl);
            redirectAttrs.addFlashAttribute("successMessage", "Profile picture updated!");
        } catch (InvalidFileException e) {
            redirectAttrs.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/user/profile";
    }

    /** POST /user/change-password */
    @PostMapping("/change-password")
    public String changePassword(
            @RequestParam String currentPassword,
            @RequestParam String newPassword,
            @RequestParam String confirmNewPassword,
            RedirectAttributes redirectAttrs) {

        if (!newPassword.equals(confirmNewPassword)) {
            redirectAttrs.addFlashAttribute("passwordError", "New passwords do not match");
            return "redirect:/user/profile";
        }

        try {
            userService.changePassword(
                    userService.getCurrentUser().getId(), currentPassword, newPassword);
            redirectAttrs.addFlashAttribute("passwordSuccess", "Password changed successfully!");
        } catch (BadCredentialsException e) {
            redirectAttrs.addFlashAttribute("passwordError", "Current password is incorrect");
        } catch (Exception e) {
            redirectAttrs.addFlashAttribute("passwordError", e.getMessage());
        }
        return "redirect:/user/profile";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Wishlist, Inquiries, Notifications pages
    // ─────────────────────────────────────────────────────────────────────────

    /** GET /user/wishlist */
    @GetMapping("/wishlist")
    public String wishlistPage(Model model) {
        User currentUser = userService.getCurrentUser();
        model.addAttribute("wishlistItems", wishlistService.getByUser(currentUser.getId()));
        return "user/wishlist";
    }

    /** GET /user/inquiries */
    @GetMapping("/inquiries")
    public String inquiriesPage(Model model) {
        log.info("Accessing inquiries page");
        try {
            User currentUser = userService.getCurrentUser();
            log.info("Current user ID: {}", currentUser != null ? currentUser.getId() : "NULL");
            model.addAttribute("inquiries", inquiryService.getByUser(currentUser.getId()));
            return "user/inquiries";
        } catch (Exception e) {
            log.error("Error in inquiriesPage", e);
            throw e;
        }
    }

    /** GET /user/notifications */
    @GetMapping("/notifications")
    public String notificationsPage(Model model) {
        log.info("Accessing notifications page");
        try {
            User currentUser = userService.getCurrentUser();
            log.info("Current user ID: {}", currentUser != null ? currentUser.getId() : "NULL");
            model.addAttribute("notifications", notificationService.getByUser(currentUser.getId()));
            notificationService.markAllRead(currentUser.getId()); // mark all as read on view
            return "user/notifications";
        } catch (Exception e) {
            log.error("Error in notificationsPage", e);
            throw e;
        }
    }

    /**
     * POST /user/wishlist/remove — form-based fallback (used when JS is disabled).
     * The primary remove path is DELETE /api/v1/wishlist/{propertyId} (AJAX).
     */
    @PostMapping("/wishlist/remove")
    public String removeFromWishlist(
            @RequestParam Long propertyId,
            RedirectAttributes redirectAttrs) {
        wishlistService.removeFromWishlist(userService.getCurrentUser().getId(), propertyId);
        redirectAttrs.addFlashAttribute("successMessage", "Property removed from wishlist.");
        return "redirect:/user/wishlist";
    }
}
