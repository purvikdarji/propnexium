package com.propnexium.repository;

import com.propnexium.entity.SearchLog;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface SearchLogRepository extends JpaRepository<SearchLog, Long> {

        List<SearchLog> findByUserId(Long userId);

        /** Top searched cities */
        @Query("SELECT sl.searchCity, COUNT(sl) as cnt FROM SearchLog sl " +
                        "WHERE sl.searchCity IS NOT NULL " +
                        "GROUP BY sl.searchCity ORDER BY cnt DESC")
        List<Object[]> findTopSearchedCities(Pageable pageable);

        /** Top searched types */
        @Query("SELECT sl.searchType, COUNT(sl) as cnt FROM SearchLog sl " +
                        "WHERE sl.searchType IS NOT NULL " +
                        "GROUP BY sl.searchType ORDER BY cnt DESC")
        List<Object[]> findTopSearchedTypes(Pageable pageable);

        long countByUserId(Long userId);

        /**
         * Returns the top N most-searched cities in the last 30 days.
         * Map keys: "city" (String), "searchCount" (Long).
         */
        @Query(value = """
                        SELECT search_city AS city, COUNT(*) AS searchCount
                        FROM search_logs
                        WHERE search_city IS NOT NULL
                          AND searched_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
                        GROUP BY search_city
                        ORDER BY searchCount DESC
                        LIMIT :limit
                        """, nativeQuery = true)
        List<Map<String, Object>> getPopularSearchCities(@Param("limit") int limit);

        // ---------- Admin Analytics Queries ----------

        // Most searched cities (last 30 days)
        @Query(value = """
                        SELECT search_city as city, COUNT(*) as searchCount
                        FROM search_logs
                        WHERE search_city IS NOT NULL
                        AND searched_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
                        GROUP BY search_city
                        ORDER BY searchCount DESC LIMIT 6
                        """, nativeQuery = true)
        List<Map<String, Object>> getMostSearchedCities();

        // Most searched city (last 30 days) — single result
        @Query(value = """
                        SELECT search_city FROM search_logs
                        WHERE search_city IS NOT NULL
                        AND searched_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
                        GROUP BY search_city ORDER BY COUNT(*) DESC LIMIT 1
                        """, nativeQuery = true)
        String getMostSearchedCity();

        /** Trending city + type combinations last 30 days */
        @Query(value = """
                        SELECT search_city as city, search_type as type,
                               COUNT(*) as searchCount
                        FROM search_logs
                        WHERE searched_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
                          AND search_city IS NOT NULL
                        GROUP BY search_city, search_type
                        ORDER BY searchCount DESC LIMIT 20
                        """, nativeQuery = true)
        List<Map<String, Object>> getTrendingCityTypeCombinations();

        /** Result count bucket distribution for last 30 days */
        @Query(value = """
                        SELECT
                          SUM(CASE WHEN result_count = 0 THEN 1 ELSE 0 END) as noResults,
                          SUM(CASE WHEN result_count BETWEEN 1 AND 5 THEN 1 ELSE 0 END) as oneToFive,
                          SUM(CASE WHEN result_count BETWEEN 6 AND 20 THEN 1 ELSE 0 END) as sixToTwenty,
                          SUM(CASE WHEN result_count BETWEEN 21 AND 50 THEN 1 ELSE 0 END) as twentyToFifty,
                          SUM(CASE WHEN result_count > 50 THEN 1 ELSE 0 END) as fiftyPlus
                        FROM search_logs
                        WHERE searched_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
                        """, nativeQuery = true)
        Map<String, Object> getResultCountDistribution();
}
