package com.propnexium.repository;

import com.propnexium.entity.Property;
import com.propnexium.entity.enums.PropertyCategory;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.entity.enums.PropertyType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface PropertyRepository extends JpaRepository<Property, Long> {

  // ---------- By Agent ----------
  List<Property> findByAgentId(Long agentId);

  Page<Property> findByAgentId(Long agentId, Pageable pageable);

  long countByAgentId(Long agentId);

  long countByAgentIdAndStatus(Long agentId, PropertyStatus status);

  long countByAgentIdAndStatusNot(Long agentId, PropertyStatus status);

  Page<Property> findByAgentIdAndStatus(Long agentId, PropertyStatus status, Pageable pageable);

  List<Property> findByAgentIdAndStatusNot(Long agentId, PropertyStatus status);

  @Query("SELECT COALESCE(SUM(p.viewCount), 0) FROM Property p WHERE p.agent.id = :agentId")
  long sumViewCountByAgentId(@Param("agentId") Long agentId);

  @Query("SELECT p FROM Property p WHERE p.agent.id = :agentId ORDER BY p.createdAt DESC")
  List<Property> findRecentByAgentId(@Param("agentId") Long agentId, Pageable pageable);

  // ---------- By Status ----------
  Page<Property> findByStatus(PropertyStatus status, Pageable pageable);

  List<Property> findByStatus(PropertyStatus status);

  long countByStatus(PropertyStatus status);

  // ---------- By City ----------
  Page<Property> findByCityIgnoreCase(String city, Pageable pageable);

  @Query("SELECT DISTINCT p.city FROM Property p WHERE p.city IS NOT NULL ORDER BY p.city ASC")
  List<String> findDistinctCities();

  // ---------- By Type ----------
  Page<Property> findByType(PropertyType type, Pageable pageable);

  // ---------- By Category ----------
  Page<Property> findByCategory(PropertyCategory category, Pageable pageable);

  // ---------- By City + Category ----------
  Page<Property> findByCityIgnoreCaseAndCategory(String city, PropertyCategory category, Pageable pageable);

  // ---------- Price Range ----------
  Page<Property> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice, Pageable pageable);

  // ---------- Featured ----------
  @EntityGraph(attributePaths = {"images"})
  List<Property> findByIsFeaturedTrueAndStatus(PropertyStatus status);

  @EntityGraph(attributePaths = {"images"})
  @Query("SELECT p FROM Property p WHERE p.isFeatured = true AND p.status = 'AVAILABLE' ORDER BY p.createdAt DESC")
  List<Property> findFeaturedProperties(Pageable pageable);

  // ---------- View Count (increment) ----------
  @Modifying
  @Query("UPDATE Property p SET p.viewCount = p.viewCount + 1 WHERE p.id = :id")
  void incrementViewCount(@Param("id") Long id);

  // ---------- Advanced Search (JPQL) ----------
  @EntityGraph(attributePaths = {"images"})
  @Query("""
      SELECT p FROM Property p
      WHERE (:city IS NULL OR LOWER(p.city) = LOWER(:city))
        AND (:type IS NULL OR p.type = :type)
        AND (:category IS NULL OR p.category = :category)
        AND (:minPrice IS NULL OR p.price >= :minPrice)
        AND (:maxPrice IS NULL OR p.price <= :maxPrice)
        AND (:minBedrooms IS NULL OR p.bedrooms >= :minBedrooms)
        AND p.status = 'AVAILABLE'
      """)
  Page<Property> advancedSearch(
      @Param("city") String city,
      @Param("type") PropertyType type,
      @Param("category") PropertyCategory category,
      @Param("minPrice") BigDecimal minPrice,
      @Param("maxPrice") BigDecimal maxPrice,
      @Param("minBedrooms") Integer minBedrooms,
      Pageable pageable);

  // ---------- Recent Listings ----------
  @EntityGraph(attributePaths = {"images"})
  @Query("SELECT p FROM Property p WHERE p.status = 'AVAILABLE' ORDER BY p.createdAt DESC")
  List<Property> findRecentAvailableProperties(Pageable pageable);

  // ---------- Nearby Properties (same city, by status) ----------
  @Query("SELECT p FROM Property p WHERE p.city = :city AND p.status = :status AND p.id != :excludeId ORDER BY p.createdAt DESC")
  List<Property> findNearbyProperties(
      @Param("city") String city,
      @Param("status") PropertyStatus status,
      @Param("excludeId") Long excludeId,
      Pageable pageable);

  // ---------- Similar Properties ----------
  @Query("""
      SELECT p FROM Property p
      WHERE p.city = :city
        AND p.type = :type
        AND p.id <> :excludeId
        AND p.status = 'AVAILABLE'
      ORDER BY p.createdAt DESC
      """)
  List<Property> findSimilarProperties(
      @Param("city") String city,
      @Param("type") PropertyType type,
      @Param("excludeId") Long excludeId,
      Pageable pageable);

  // ---------- Admin: property count by city ----------
  @Query("SELECT p.city, COUNT(p) FROM Property p GROUP BY p.city ORDER BY COUNT(p) DESC")
  List<Object[]> countGroupByCity();

  // ---------- Homepage: popular cities with count and min price ----------
  @Query(value = """
      SELECT p.city as city,
             COUNT(*) as listingCount,
             MIN(p.price) as minPrice
      FROM properties p
      WHERE p.status = 'AVAILABLE'
      GROUP BY p.city
      ORDER BY listingCount DESC
      LIMIT :limit
      """, nativeQuery = true)
  List<java.util.Map<String, Object>> getPopularCitiesWithStats(@Param("limit") int limit);

  // ---------- Homepage: distinct cities count ----------
  @Query("SELECT COUNT(DISTINCT p.city) FROM Property p WHERE p.status = 'AVAILABLE'")
  long countDistinctCitiesAvailable();

  // ---------- Admin: all properties filterable by status ----------
  @Query("""
      SELECT p FROM Property p
      WHERE (:status IS NULL OR p.status = :status)
      ORDER BY p.createdAt DESC
      """)
  Page<Property> findAllForAdmin(@Param("status") PropertyStatus status, Pageable pageable);

  // ══════════════════════════════════════════════════════════════════════════════
  // FULLTEXT Search (native MySQL queries — require FULLTEXT index on title,
  // description)
  // ══════════════════════════════════════════════════════════════════════════════

  /**
   * Native FULLTEXT search with optional filters and relevance-score ordering.
   * :keyword should be pre-processed into Boolean Mode tokens e.g. "+sea*
   * +view*".
   * When null, the MATCH clause is skipped and all filters-only results are
   * returned.
   */
  @Query(value = """
      SELECT * FROM properties p
      WHERE p.status = 'AVAILABLE'
        AND (:keyword IS NULL OR MATCH(p.title, p.description, p.city)
             AGAINST (:keyword IN BOOLEAN MODE))
        AND (:city IS NULL OR p.city = :city)
        AND (:type IS NULL OR p.type = :type)
        AND (:category IS NULL OR p.category = :category)
        AND (:minPrice IS NULL OR p.price >= :minPrice)
        AND (:maxPrice IS NULL OR p.price <= :maxPrice)
        AND (:bedrooms IS NULL OR p.bedrooms >= :bedrooms)
        AND (:furnishing IS NULL OR p.furnishing = :furnishing)
      ORDER BY
        CASE WHEN :keyword IS NOT NULL
             THEN MATCH(p.title, p.description, p.city) AGAINST (:keyword IN BOOLEAN MODE)
             ELSE 0 END DESC,
        p.created_at DESC
      LIMIT :lim OFFSET :offset
      """, nativeQuery = true)
  List<Property> fullTextSearch(
      @Param("keyword") String keyword,
      @Param("city") String city,
      @Param("type") String type,
      @Param("category") String category,
      @Param("minPrice") BigDecimal minPrice,
      @Param("maxPrice") BigDecimal maxPrice,
      @Param("bedrooms") Integer bedrooms,
      @Param("furnishing") String furnishing,
      @Param("lim") int lim,
      @Param("offset") int offset);

  /**
   * Total count for the same FULLTEXT + filter query (without pagination).
   */
  @Query(value = """
      SELECT COUNT(*) FROM properties p
      WHERE p.status = 'AVAILABLE'
        AND (:keyword IS NULL OR MATCH(p.title, p.description, p.city)
             AGAINST (:keyword IN BOOLEAN MODE))
        AND (:city IS NULL OR p.city = :city)
        AND (:type IS NULL OR p.type = :type)
        AND (:category IS NULL OR p.category = :category)
        AND (:minPrice IS NULL OR p.price >= :minPrice)
        AND (:maxPrice IS NULL OR p.price <= :maxPrice)
        AND (:bedrooms IS NULL OR p.bedrooms >= :bedrooms)
        AND (:furnishing IS NULL OR p.furnishing = :furnishing)
      """, nativeQuery = true)
  long fullTextSearchCount(
      @Param("keyword") String keyword,
      @Param("city") String city,
      @Param("type") String type,
      @Param("category") String category,
      @Param("minPrice") BigDecimal minPrice,
      @Param("maxPrice") BigDecimal maxPrice,
      @Param("bedrooms") Integer bedrooms,
      @Param("furnishing") String furnishing);

  /**
   * Autocomplete: up to 8 distinct property titles containing :prefix.
   */
  @Query(value = """
      SELECT DISTINCT title FROM properties
      WHERE title LIKE :prefix
        AND status = 'AVAILABLE'
      LIMIT 8
      """, nativeQuery = true)
  List<String> findAutocompleteSuggestions(@Param("prefix") String prefix);

  // ---------- Admin Analytics Queries ----------

  // Monthly listings count for last 12 months
  @Query(value = """
      SELECT DATE_FORMAT(p.created_at, '%b %Y') as month,
             COUNT(*) as count
      FROM properties p
      WHERE p.created_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
      GROUP BY DATE_FORMAT(p.created_at, '%b %Y'), DATE_FORMAT(p.created_at, '%Y-%m')
      ORDER BY DATE_FORMAT(p.created_at, '%Y-%m') ASC
      """, nativeQuery = true)
  List<java.util.Map<String, Object>> getMonthlyListingCounts();

  // Properties by type distribution
  @Query(value = """
      SELECT p.type as type, COUNT(*) as count
      FROM properties p
      WHERE p.status != 'DELETED'
      GROUP BY p.type
      ORDER BY count DESC
      """, nativeQuery = true)
  List<java.util.Map<String, Object>> getPropertyTypeDistribution();

  // Buy vs Rent split
  @Query(value = """
      SELECT p.category as category, COUNT(*) as count
      FROM properties p
      WHERE p.status != 'DELETED'
      GROUP BY p.category
      """, nativeQuery = true)
  List<java.util.Map<String, Object>> getListingCategoryDistribution();

  // Top 5 most viewed
  @Query(value = """
      SELECT p.id, p.title, p.city, p.price, p.view_count,
             u.name, u.email
      FROM properties p
      JOIN users u ON p.agent_id = u.id
      WHERE p.status = 'AVAILABLE'
      ORDER BY p.view_count DESC LIMIT 5
      """, nativeQuery = true)
  List<java.util.Map<String, Object>> getMostViewedProperties();

  // Total platform value
  @Query(value = """
      SELECT COALESCE(SUM(price), 0)
      FROM properties WHERE status = 'AVAILABLE'
      """, nativeQuery = true)
  BigDecimal getTotalPlatformValue();

  // ---------- DataLoader utility: back-date createdAt for seeded properties ----------
  @Modifying
  @Query(value = "UPDATE properties SET created_at = :createdAt WHERE id = :id", nativeQuery = true)
  void updateCreatedAt(@Param("id") Long id, @Param("createdAt") java.time.LocalDateTime createdAt);
}
