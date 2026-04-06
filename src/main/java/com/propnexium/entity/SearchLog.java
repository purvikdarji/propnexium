package com.propnexium.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entity: search_logs
 *
 * Relationships:
 * users (1) <---> (N) search_logs [nullable — guests can trigger searches]
 */
@Entity
@Table(name = "search_logs")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@ToString(exclude = "user")
public class SearchLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Nullable — guests (unauthenticated users) can perform searches */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = true)
    private User user;

    @Column(name = "keyword", length = 200)
    private String keyword;

    @Column(name = "search_city", length = 100)
    private String searchCity;

    @Column(name = "search_type", length = 30)
    private String searchType;

    @Column(name = "search_category", length = 10)
    private String searchCategory;

    @Column(name = "min_price", precision = 15, scale = 2)
    private BigDecimal minPrice;

    @Column(name = "max_price", precision = 15, scale = 2)
    private BigDecimal maxPrice;

    @Column(name = "result_count")
    private Integer resultCount;

    @Column(name = "search_time_ms")
    private Long searchTimeMs;

    @CreationTimestamp
    @Column(name = "searched_at", updatable = false)
    private LocalDateTime searchedAt;
}
