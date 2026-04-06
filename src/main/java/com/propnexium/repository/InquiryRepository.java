package com.propnexium.repository;

import com.propnexium.entity.Inquiry;
import com.propnexium.entity.enums.InquiryStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InquiryRepository extends JpaRepository<Inquiry, Long> {

        List<Inquiry> findByPropertyId(Long propertyId);

        Page<Inquiry> findByPropertyId(Long propertyId, Pageable pageable);

        List<Inquiry> findByUserId(Long userId);

        Page<Inquiry> findByUserId(Long userId, Pageable pageable);

        long countByUserId(Long userId);

        boolean existsByUserIdAndProperty_Agent_Id(Long userId, Long agentId);

        /**
         * Most-recent N inquiries by a user (for dashboard preview), property eagerly
         * fetched.
         */
        @Query("""
                        SELECT i FROM Inquiry i
                        JOIN FETCH i.property
                        WHERE i.user.id = :userId
                        ORDER BY i.createdAt DESC
                        """)
        List<Inquiry> findRecentByUserId(@Param("userId") Long userId, Pageable pageable);

        Page<Inquiry> findByStatus(InquiryStatus status, Pageable pageable);

        long countByPropertyId(Long propertyId);

        long countByStatus(InquiryStatus status);

        // ---------- Agent queries ----------

        /**
         * All inquiries for properties owned by a given agent, paginated newest-first.
         */
        @Query("""
                        SELECT i FROM Inquiry i
                        JOIN i.property p
                        WHERE p.agent.id = :agentId
                        ORDER BY i.createdAt DESC
                        """)
        Page<Inquiry> findByAgentId(@Param("agentId") Long agentId, Pageable pageable);

        /** Count of all inquiries for this agent's properties. */
        @Query("""
                        SELECT COUNT(i) FROM Inquiry i
                        JOIN i.property p
                        WHERE p.agent.id = :agentId
                        """)
        long countByAgentId(@Param("agentId") Long agentId);

        /** Count of inquiries with a given status for this agent's properties. */
        @Query("""
                        SELECT COUNT(i) FROM Inquiry i
                        JOIN i.property p
                        WHERE p.agent.id = :agentId AND i.status = :status
                        """)
        long countByAgentIdAndStatus(@Param("agentId") Long agentId,
                        @Param("status") InquiryStatus status);

        /**
         * N most-recent inquiries for this agent's properties (with property eagerly
         * fetched).
         */
        @Query("""
                        SELECT i FROM Inquiry i
                        JOIN FETCH i.property p
                        WHERE p.agent.id = :agentId
                        ORDER BY i.createdAt DESC
                        """)
        List<Inquiry> findRecentByAgentId(@Param("agentId") Long agentId, Pageable pageable);

        /** Unread (PENDING) inquiries for an agent */
        @Query("""
                        SELECT COUNT(i) FROM Inquiry i
                        JOIN i.property p
                        WHERE p.agent.id = :agentId AND i.status = 'PENDING'
                        """)
        long countPendingByAgentId(@Param("agentId") Long agentId);

        /**
         * Filtered paginated inquiries for an agent's properties by status.
         */
        @Query("""
                        SELECT i FROM Inquiry i
                        JOIN i.property p
                        WHERE p.agent.id = :agentId AND i.status = :status
                        ORDER BY i.createdAt DESC
                        """)
        Page<Inquiry> findByAgentIdAndStatus(@Param("agentId") Long agentId,
                        @Param("status") InquiryStatus status,
                        Pageable pageable);

        /**
         * Find pending inquiries older than a given date (for auto-close / reminders).
         */
        @Query("""
                        SELECT i FROM Inquiry i
                        WHERE i.status = :status AND i.createdAt < :before
                        """)
        List<Inquiry> findByStatusAndCreatedAtBefore(@Param("status") InquiryStatus status,
                        @Param("before") java.time.LocalDateTime before);

        // ---------- Admin Analytics Queries ----------

        // Inquiry status distribution
        @Query(value = """
                        SELECT i.status, COUNT(*) as count
                        FROM inquiries i
                        GROUP BY i.status
                        """, nativeQuery = true)
        List<java.util.Map<String, Object>> getInquiryStatusDistribution();

        // Inquiry resolution % (REPLIED + CLOSED / total)
        @Query(value = """
                        SELECT
                          COUNT(*) as total,
                          SUM(CASE WHEN status IN ('REPLIED','CLOSED') THEN 1 ELSE 0 END) as resolved
                        FROM inquiries
                        """, nativeQuery = true)
        java.util.Map<String, Object> getInquiryResolutionStats();
}
