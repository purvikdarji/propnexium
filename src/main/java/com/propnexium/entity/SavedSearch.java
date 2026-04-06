package com.propnexium.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Entity: saved_searches
 *
 * Stores a user's named search filter combination (as JSON).
 * Allows users to bookmark searches and re-run them later.
 *
 * MySQL DDL:
 * CREATE TABLE saved_searches (
 *   id BIGINT PRIMARY KEY AUTO_INCREMENT,
 *   user_id BIGINT NOT NULL,
 *   name VARCHAR(100) NOT NULL,
 *   filters_json TEXT NOT NULL,
 *   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 *   FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
 *   INDEX idx_user_id (user_id)
 * );
 */
@Entity
@Table(name = "saved_searches", indexes = {
        @Index(name = "idx_ss_user_id", columnList = "user_id")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class SavedSearch {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnore
    private User user;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(name = "filters_json", nullable = false, columnDefinition = "TEXT")
    private String filtersJson;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
