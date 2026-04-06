package com.propnexium.service;

import com.propnexium.dto.request.ReviewDto;
import com.propnexium.entity.Review;

import java.util.List;
import java.util.Map;

public interface ReviewService {
    Review submitReview(Long agentId, Long reviewerId, ReviewDto dto);

    List<Review> getReviewsForAgent(Long agentId);

    boolean hasReviewed(Long reviewerId, Long agentId);

    double getAverageRating(Long agentId);

    Map<Integer, Long> getRatingDistribution(Long agentId);
}
