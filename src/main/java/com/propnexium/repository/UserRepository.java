package com.propnexium.repository;

import com.propnexium.entity.User;
import com.propnexium.entity.enums.UserRole;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

       Optional<User> findByEmail(String email);

       boolean existsByEmail(String email);

       List<User> findByRole(UserRole role);

       long countByRole(UserRole role);

       List<User> findByIsActiveTrue();

       List<User> findByIsEmailVerifiedFalse();

       @Query("SELECT COUNT(u) FROM User u WHERE u.isActive = true")
       long countActiveUsers();

       /** N most-recently registered users (for admin dashboard preview). */
       @Query("SELECT u FROM User u ORDER BY u.createdAt DESC")
       List<User> findRecentUsers(Pageable pageable);

       /**
        * Admin user management: filter by role and/or name/email search,
        * paginated newest-first.
        */
       @Query("""
                     SELECT u FROM User u
                     WHERE (:role IS NULL OR u.role = :role)
                       AND (:search IS NULL
                            OR LOWER(u.name)  LIKE LOWER(CONCAT('%', :search, '%'))
                            OR LOWER(u.email) LIKE LOWER(CONCAT('%', :search, '%')))
                     ORDER BY u.createdAt DESC
                     """)
       Page<User> findForAdmin(@Param("role") UserRole role,
                     @Param("search") String search,
                     Pageable pageable);

       // ---------- Admin Analytics Queries ----------

       // Monthly user registrations for last 12 months
       @Query(value = """
                     SELECT DATE_FORMAT(u.created_at, '%b %Y') as month,
                            COUNT(*) as count
                     FROM users u
                     WHERE u.created_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
                     GROUP BY DATE_FORMAT(u.created_at, '%b %Y'), DATE_FORMAT(u.created_at, '%Y-%m')
                     ORDER BY DATE_FORMAT(u.created_at, '%Y-%m') ASC
                     """, nativeQuery = true)
       List<java.util.Map<String, Object>> getMonthlyUserRegistrations();

       // Top 5 agents by listing count (and their total views)
       @Query(value = """
                     SELECT u.id, u.name, u.email,
                            COUNT(p.id) as listingCount,
                            COALESCE(SUM(p.view_count), 0) as totalViews
                     FROM users u
                     LEFT JOIN properties p ON p.agent_id = u.id AND p.status != 'DELETED'
                     WHERE u.role = 'AGENT'
                     GROUP BY u.id, u.name, u.email
                     ORDER BY listingCount DESC LIMIT 5
                     """, nativeQuery = true)
       List<java.util.Map<String, Object>> getTopAgentsByListings();
}
