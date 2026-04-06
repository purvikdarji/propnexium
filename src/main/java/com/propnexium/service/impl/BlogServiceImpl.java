package com.propnexium.service.impl;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.propnexium.entity.BlogPost;
import com.propnexium.repository.BlogRepository;
import com.propnexium.service.BlogService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BlogServiceImpl implements BlogService {

    private final BlogRepository blogRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<BlogPost> getPublishedPosts(String category, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        if (category != null && !category.isEmpty()) {
            return blogRepository.findByStatusAndCategoryOrderByPublishedAtDesc(BlogPost.PostStatus.PUBLISHED, category, pageable);
        }
        return blogRepository.findByStatusOrderByPublishedAtDesc(BlogPost.PostStatus.PUBLISHED, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public BlogPost getPostBySlug(String slug) {
        return blogRepository.findBySlugAndStatus(slug, BlogPost.PostStatus.PUBLISHED)
                .orElseThrow(() -> new RuntimeException("Blog post not found"));
    }

    @Override
    @Transactional(readOnly = true)
    public List<BlogPost> getRelatedPosts(BlogPost post) {
        return blogRepository.findTop3ByCategoryAndStatusAndIdNotOrderByPublishedAtDesc(
                post.getCategory(), BlogPost.PostStatus.PUBLISHED, post.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public List<BlogPost> getPopularPosts() {
        return blogRepository.findTop6ByStatusOrderByViewCountDesc(BlogPost.PostStatus.PUBLISHED);
    }

    @Override
    public String generateSlug(String title) {
        String baseSlug = title.toLowerCase()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("-+", "-")
                .replaceAll("^-|-$", "");
                
        String slug = baseSlug;
        int count = 2;
        
        while (blogRepository.findBySlug(slug).isPresent()) {
            slug = baseSlug + "-" + count;
            count++;
        }
        
        return slug;
    }

    @Override
    public int calculateReadTime(String content) {
        if (content == null || content.trim().isEmpty()) {
            return 1;
        }
        // Count words in content (split on whitespace)
        String[] words = content.trim().split("\\s+");
        int count = words.length;
        
        // Divide by 200 (avg reading speed), minimum 1 minute
        int readTime = count / 200;
        return Math.max(1, readTime);
    }
}
