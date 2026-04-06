package com.propnexium.repository;

import com.propnexium.entity.Review;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {

    List<Review> findByAgentId(Long agentId);

    List<Review> findByAgentIdOrderByCreatedAtDesc(Long agentId);

    Page<Review> findByAgentId(Long agentId, Pageable pageable);

    List<Review> findByReviewerId(Long reviewerId);

    Optional<Review> findByReviewerIdAndAgentId(Long reviewerId, Long agentId);

    boolean existsByReviewerIdAndAgentId(Long reviewerId, Long agentId);

    long countByAgentId(Long agentId);

    /** Average rating for an agent */
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.agent.id = :agentId")
    Double findAverageRatingByAgentId(@Param("agentId") Long agentId);

    /** Rating distribution for an agent */
    @Query("SELECT r.rating, COUNT(r) FROM Review r WHERE r.agent.id = :agentId GROUP BY r.rating")
    List<Object[]> findRatingDistributionByAgentId(@Param("agentId") Long agentId);
}
