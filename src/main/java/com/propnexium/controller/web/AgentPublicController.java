package com.propnexium.controller.web;

import com.propnexium.entity.AgentProfile;
import com.propnexium.entity.Property;
import com.propnexium.entity.Review;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.entity.enums.UserRole;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.AgentProfileService;
import com.propnexium.service.PropertyService;
import com.propnexium.service.ReviewService;
import com.propnexium.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequiredArgsConstructor
public class AgentPublicController {

    private final UserRepository userRepository;
    private final AgentProfileService agentProfileService;
    private final ReviewService reviewService;
    private final PropertyService propertyService;
    private final UserService userService;

    @GetMapping("/agents/{id}")
    public String agentPublicProfile(@PathVariable Long id, Model model) {
        User agent = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Agent", "id", id));

        if (agent.getRole() != UserRole.AGENT && agent.getRole() != UserRole.ADMIN) {
            throw new ResourceNotFoundException("Agent", "id", id);
        }

        AgentProfile profile = agentProfileService.findByUserId(id);
        List<Review> reviews = reviewService.getReviewsForAgent(id);
        double avgRating = reviewService.getAverageRating(id);
        Map<Integer, Long> distribution = reviewService.getRatingDistribution(id);

        List<Property> allRecent = propertyService.getRecentByAgent(id, 20);
        List<Property> listings = allRecent.stream()
                .filter(p -> p.getStatus() == PropertyStatus.AVAILABLE)
                .limit(6)
                .collect(Collectors.toList());

        boolean canReview = false;
        boolean hasReviewed = false;
        User currentUser = null;
        try {
            currentUser = userService.getCurrentUser();
        } catch (Exception ignored) {
            // Not authenticated
        }

        if (currentUser != null && !currentUser.getId().equals(id)) {
            hasReviewed = reviewService.hasReviewed(currentUser.getId(), id);
            canReview = !hasReviewed;
        }

        model.addAttribute("agent", agent);
        model.addAttribute("profile", profile != null ? profile : new AgentProfile());
        model.addAttribute("reviews", reviews);
        model.addAttribute("avgRating", avgRating);
        model.addAttribute("distribution", distribution);
        model.addAttribute("listings", listings);
        model.addAttribute("canReview", canReview);
        model.addAttribute("hasReviewed", hasReviewed);

        return "agent/public-profile";
    }
}
