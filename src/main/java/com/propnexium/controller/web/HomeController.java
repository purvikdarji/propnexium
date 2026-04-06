package com.propnexium.controller.web;

import com.propnexium.entity.Property;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.entity.enums.UserRole;
import com.propnexium.service.EmailService;
import com.propnexium.service.PropertyService;
import com.propnexium.service.UserService;
import com.propnexium.service.WishlistService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Home / general-purpose web controller.
 */
@Controller
@RequiredArgsConstructor
public class HomeController {

    private final PropertyService propertyService;
    private final UserService userService;
    private final EmailService emailService;
    private final WishlistService wishlistService;

    @GetMapping({ "/", "/home" })
    public String homepage(HttpSession session, Model model) {

        // Featured properties
        List<Property> featuredProperties = propertyService.findFeaturedProperties(8);

        // Platform stats
        long totalAvailable = propertyService.countByStatus(PropertyStatus.AVAILABLE);
        long totalAgents = userService.countByRole(UserRole.AGENT);
        long distinctCities = propertyService.countDistinctCities();

        // Popular cities with listing count and min price
        List<Map<String, Object>> popularCities = propertyService.getPopularCitiesWithStats(8);

        // Recently viewed from session
        @SuppressWarnings("unchecked")
        List<Long> recentIds = (List<Long>) session.getAttribute("recentlyViewed");
        List<Property> recentlyViewed = new ArrayList<>();
        if (recentIds != null && !recentIds.isEmpty()) {
            recentlyViewed = propertyService.findAllByIdsOrdered(recentIds);
        }

        // Wishlist for highlighting
        User currentUser = userService.getCurrentUser();
        List<Long> savedPropertyIds = new ArrayList<>();
        if (currentUser != null) {
            savedPropertyIds = wishlistService.getUserWishlistPropertyIds(currentUser.getId());
        }

        model.addAttribute("featuredProperties", featuredProperties);
        model.addAttribute("totalAvailable", totalAvailable);
        model.addAttribute("totalAgents", totalAgents);
        model.addAttribute("distinctCities", distinctCities);
        model.addAttribute("popularCities", popularCities);
        model.addAttribute("recentlyViewed", recentlyViewed);
        model.addAttribute("savedPropertyIds", savedPropertyIds);

        return "home/index";
    }

    // Standalone Mortgage & Loan Calculator page
    @GetMapping("/calculator")
    public String calculatorPage(Model model) {
        model.addAttribute("cities", propertyService.getDistinctCities());
        return "tools/calculator";
    }

    // Contact Us page
    @GetMapping("/contact")
    public String contactPage() {
        return "home/contact";
    }

    @GetMapping("/privacy")
    public String privacyPolicy() {
        return "home/privacy";
    }

    @GetMapping("/terms")
    public String termsOfService() {
        return "home/terms";
    }

    @GetMapping("/sitemap")
    public String sitemap() {
        return "home/sitemap";
    }

    // Contact form submission
    @PostMapping("/contact")
    public String submitContact(
            @RequestParam String name,
            @RequestParam String email,
            @RequestParam String subject,
            @RequestParam String message,
            RedirectAttributes redirectAttrs) {

        // Send email to admin inbox asynchronously
        emailService.sendContactFormEmail(name, email, subject, message);

        redirectAttrs.addFlashAttribute("successMessage",
                "Thank you, " + name + "! Your message has been sent. We'll reply within 24 hours.");
        return "redirect:/contact";
    }

    @GetMapping("/dashboard")
    public String dashboard() {
        // Generic dashboard redirect based on role
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth instanceof AnonymousAuthenticationToken) {
            return "redirect:/auth/login";
        }
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        boolean isAgent = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_AGENT"));
        if (isAdmin)
            return "redirect:/admin/dashboard";
        if (isAgent)
            return "redirect:/agent/dashboard";
        return "redirect:/user/dashboard";
    }
}
