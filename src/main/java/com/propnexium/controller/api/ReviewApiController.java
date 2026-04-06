package com.propnexium.controller.api;

import com.propnexium.dto.request.ReviewDto;
import com.propnexium.dto.response.ApiResponse;
import com.propnexium.entity.Review;
import com.propnexium.entity.User;
import com.propnexium.exception.DuplicateResourceException;
import com.propnexium.service.ReviewService;
import com.propnexium.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/reviews")
@RequiredArgsConstructor
public class ReviewApiController {

    private final ReviewService reviewService;
    private final UserService userService;

    // POST /api/v1/reviews/agent/{agentId} — submit review (authenticated)
    @PostMapping("/agent/{agentId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<Review>> submitReview(
            @PathVariable Long agentId,
            @RequestBody @Valid ReviewDto dto) {

        User reviewer;
        try {
            reviewer = userService.getCurrentUser();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Authentication required"));
        }

        if (reviewer.getId().equals(agentId)) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("You cannot review yourself"));
        }

        try {
            Review review = reviewService.submitReview(agentId, reviewer.getId(), dto);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success(review, "Review submitted successfully!"));
        } catch (DuplicateResourceException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    // GET /api/v1/reviews/agent/{agentId} — get reviews for agent
    @GetMapping("/agent/{agentId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getAgentReviews(
            @PathVariable Long agentId) {

        List<Review> reviews = reviewService.getReviewsForAgent(agentId);
        double average = reviewService.getAverageRating(agentId);
        Map<Integer, Long> distribution = reviewService.getRatingDistribution(agentId);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("reviews", reviews);
        data.put("averageRating", Math.round(average * 10.0) / 10.0);
        data.put("totalReviews", reviews.size());
        data.put("distribution", distribution);

        return ResponseEntity.ok(ApiResponse.success(data, "Reviews retrieved"));
    }

    // GET /api/v1/reviews/agent/{agentId}/has-reviewed — check if current user
    // reviewed
    @GetMapping("/agent/{agentId}/has-reviewed")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<Boolean>> hasReviewed(@PathVariable Long agentId) {
        User reviewer = userService.getCurrentUser();
        boolean has = reviewService.hasReviewed(reviewer.getId(), agentId);
        return ResponseEntity.ok(ApiResponse.success(has, has ? "Already reviewed" : "Not reviewed yet"));
    }
}
