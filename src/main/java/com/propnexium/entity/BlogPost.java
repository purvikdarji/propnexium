package com.propnexium.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.fasterxml.jackson.annotation.JsonIgnore;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "blog_posts")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BlogPost {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, unique = true, length = 220)
    private String slug;

    @Column(name = "cover_image", length = 300)
    private String coverImage;

    @Column(columnDefinition = "LONGTEXT", nullable = false)
    private String content;

    @Column(length = 300)
    private String excerpt;

    @Column(nullable = false, length = 50)
    private String category;

    @Column(length = 200)
    private String tags;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id")
    @JsonIgnore
    private User author;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private PostStatus status = PostStatus.DRAFT;

    @Column(name = "view_count")
    @Builder.Default
    private int viewCount = 0;

    @Column(name = "read_time_minutes")
    @Builder.Default
    private int readTimeMinutes = 3;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    @Column(name = "created_at")
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum PostStatus {
        DRAFT, PUBLISHED
    }

    // -- For JSTL Compatibility (LocalDateTime support is limited in JSTL fmt) --
    public java.util.Date getPublishedDate() {
        return publishedAt != null ? java.sql.Timestamp.valueOf(publishedAt) : null;
    }

    public java.util.Date getCreatedDate() {
        return createdAt != null ? java.sql.Timestamp.valueOf(createdAt) : null;
    }
}
