package com.propnexium.controller.web;
import com.propnexium.entity.Property;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.InquiryStatus;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.entity.enums.UserRole;
import com.propnexium.repository.WishlistRepository;
import com.propnexium.service.InquiryService;
import com.propnexium.service.PropertyService;
import com.propnexium.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminDashboardController {

    private final UserService userService;
    private final PropertyService propertyService;
    private final InquiryService inquiryService;
    private final WishlistRepository wishlistRepository;

    @GetMapping("/dashboard")
    public String dashboard(Model model) {

        model.addAttribute("totalUsers", userService.countAll());
        model.addAttribute("totalAgents", userService.countByRole(UserRole.AGENT));
        model.addAttribute("totalProperties", propertyService.countAll());
        model.addAttribute("availableProperties", propertyService.countByStatus(PropertyStatus.AVAILABLE));
        model.addAttribute("pendingReview", propertyService.countByStatus(PropertyStatus.UNDER_REVIEW));
        model.addAttribute("totalInquiries", inquiryService.countAll());
        model.addAttribute("pendingInquiries", inquiryService.countByStatus(InquiryStatus.PENDING));
        model.addAttribute("recentUsers", userService.getRecentUsers(5));
        model.addAttribute("pendingProperties", propertyService.findByStatus(PropertyStatus.UNDER_REVIEW, 0, 5));
        model.addAttribute("cityStats", propertyService.getPropertyCountByCity());
        return "admin/dashboard";    }

    @GetMapping("/users")
    public String manageUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String search,
            Model model) {

        Page<User> users = userService.findAllPaginated(role, search, page, 15);

        // Build wishlist count map per user on this page
        Map<Long, Long> wishlistCounts = users.getContent().stream()
                .collect(Collectors.toMap(
                        User::getId,
                        u -> wishlistRepository.countByUserId(u.getId())));

        model.addAttribute("users", users);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", users.getTotalPages());
        model.addAttribute("filterRole", role);
        model.addAttribute("search", search);
        model.addAttribute("allRoles", UserRole.values());
        model.addAttribute("wishlistCounts", wishlistCounts);
        return "admin/users";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /admin/users/{id}/toggle-status
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/users/{id}/toggle-status")
    public String toggleUserStatus(@PathVariable Long id,
            RedirectAttributes redirectAttrs) {
        boolean newStatus = userService.toggleActiveStatus(id);
        redirectAttrs.addFlashAttribute("successMessage",
                "User status updated to " + (newStatus ? "ACTIVE" : "INACTIVE") + ".");
        return "redirect:/admin/users";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET /admin/properties
    // ─────────────────────────────────────────────────────────────────────────
    @GetMapping("/properties")
    public String manageProperties(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) String status,
            Model model) {

        Page<Property> properties = propertyService.findAllForAdmin(status, page, 15);
        model.addAttribute("properties", properties);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", properties.getTotalPages());
        model.addAttribute("filterStatus", status);
        model.addAttribute("allStatuses", PropertyStatus.values());
        model.addAttribute("pendingReview", propertyService.countByStatus(PropertyStatus.UNDER_REVIEW));
        return "admin/properties";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /admin/properties/{id}/approve
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/properties/{id}/approve")
    public String approveProperty(@PathVariable Long id,
            RedirectAttributes redirectAttrs) {
        propertyService.updateStatus(id, PropertyStatus.AVAILABLE);
        redirectAttrs.addFlashAttribute("successMessage",
                "Property approved and is now AVAILABLE.");
        return "redirect:/admin/properties?status=UNDER_REVIEW";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /admin/properties/{id}/reject
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/properties/{id}/reject")
    public String rejectProperty(@PathVariable Long id,
            @RequestParam(required = false) String reason,
            RedirectAttributes redirectAttrs) {
        propertyService.updateStatus(id, PropertyStatus.REJECTED);
        redirectAttrs.addFlashAttribute("successMessage", "Property has been rejected.");
        return "redirect:/admin/properties?status=UNDER_REVIEW";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /admin/properties/{id}/toggle-featured (AJAX)
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/properties/{id}/toggle-featured")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleFeatured(@PathVariable Long id) {
        boolean newValue = propertyService.toggleFeatured(id);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "featured", newValue,
                "message", "Featured status: " + (newValue ? "YES" : "NO")));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET /admin/properties/{id} — Redirect to public details view
    // ─────────────────────────────────────────────────────────────────────────
    @GetMapping("/properties/{id}")
    public String viewPropertyRedirect(@PathVariable Long id) {
        return "redirect:/properties/" + id;
    }
}
