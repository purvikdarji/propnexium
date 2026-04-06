package com.propnexium.service.impl;

import com.propnexium.dto.request.ReviewDto;
import com.propnexium.entity.Property;
import com.propnexium.entity.Review;
import com.propnexium.entity.User;
import com.propnexium.exception.DuplicateResourceException;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.repository.InquiryRepository;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.ReviewRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.AgentProfileService;
import com.propnexium.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional
public class ReviewServiceImpl implements ReviewService {

    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;
    private final PropertyRepository propertyRepository;
    private final AgentProfileService agentProfileService;
    private final InquiryRepository inquiryRepository;

    @Override
    public Review submitReview(Long agentId, Long reviewerId, ReviewDto dto) {
        if (agentId.equals(reviewerId)) {
            throw new IllegalArgumentException("You cannot review yourself");
        }

        if (reviewRepository.existsByReviewerIdAndAgentId(reviewerId, agentId)) {
            throw new DuplicateResourceException("You have already reviewed this agent");
        }

        User agent = userRepository.findById(agentId)
                .orElseThrow(() -> new ResourceNotFoundException("Agent User", "id", agentId));

        User reviewer = userRepository.findById(reviewerId)
                .orElseThrow(() -> new ResourceNotFoundException("Reviewer User", "id", reviewerId));

        Property property = null;
        if (dto.getPropertyId() != null) {
            property = propertyRepository.findById(dto.getPropertyId())
                    .orElse(null);
        }

        boolean isVerified = inquiryRepository.existsByUserIdAndProperty_Agent_Id(reviewerId, agentId);

        Review review = Review.builder()
                .agent(agent)
                .reviewer(reviewer)
                .property(property)
                .rating(dto.getRating())
                .communicationRating(dto.getCommunicationRating())
                .accuracyRating(dto.getAccuracyRating())
                .negotiationRating(dto.getNegotiationRating())
                .isVerifiedBuyer(isVerified)
                .comment(dto.getComment())
                .build();

        Review savedReview = reviewRepository.save(review);

        // Recalculate and update the agent's average rating
        agentProfileService.updateRating(agentId);

        return savedReview;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Review> getReviewsForAgent(Long agentId) {
        return reviewRepository.findByAgentIdOrderByCreatedAtDesc(agentId);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean hasReviewed(Long reviewerId, Long agentId) {
        return reviewRepository.existsByReviewerIdAndAgentId(reviewerId, agentId);
    }

    @Override
    @Transactional(readOnly = true)
    public double getAverageRating(Long agentId) {
        Double avg = reviewRepository.findAverageRatingByAgentId(agentId);
        return avg != null ? avg : 0.0;
    }

    @Override
    @Transactional(readOnly = true)
    public Map<Integer, Long> getRatingDistribution(Long agentId) {
        List<Object[]> rows = reviewRepository.findRatingDistributionByAgentId(agentId);

        Map<Integer, Long> distribution = new LinkedHashMap<>();
        for (int i = 5; i >= 1; i--) {
            distribution.put(i, 0L);
        }

        for (Object[] row : rows) {
            Integer rating = (Integer) row[0];
            Long count = (Long) row[1];
            if (rating != null && rating >= 1 && rating <= 5) {
                distribution.put(rating, count);
            }
        }
        return distribution;
    }
}
