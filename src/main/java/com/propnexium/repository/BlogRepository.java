package com.propnexium.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.propnexium.entity.BlogPost;

public interface BlogRepository extends JpaRepository<BlogPost, Long> {

    Page<BlogPost> findByStatusOrderByPublishedAtDesc(BlogPost.PostStatus status, Pageable pageable);

    Page<BlogPost> findByStatusAndCategoryOrderByPublishedAtDesc(BlogPost.PostStatus status, String category, Pageable pageable);

    Optional<BlogPost> findBySlug(String slug);
    
    Optional<BlogPost> findBySlugAndStatus(String slug, BlogPost.PostStatus status);

    List<BlogPost> findTop3ByCategoryAndStatusAndIdNotOrderByPublishedAtDesc(String category, BlogPost.PostStatus status, Long id);

    List<BlogPost> findTop6ByStatusOrderByViewCountDesc(BlogPost.PostStatus status);

    @Modifying
    @org.springframework.transaction.annotation.Transactional
    @Query("UPDATE BlogPost b SET b.viewCount = b.viewCount + 1 WHERE b.id = :id")
    void incrementViewCount(@Param("id") Long id);

    @Query("SELECT DISTINCT b.category FROM BlogPost b WHERE b.status = :status")
    List<String> findDistinctCategoryByStatus(@Param("status") BlogPost.PostStatus status);
}
