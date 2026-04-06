package com.propnexium.service;

import java.util.List;

import org.springframework.data.domain.Page;

import com.propnexium.entity.BlogPost;

public interface BlogService {
    Page<BlogPost> getPublishedPosts(String category, int page, int size);
    BlogPost getPostBySlug(String slug);
    List<BlogPost> getRelatedPosts(BlogPost post);
    List<BlogPost> getPopularPosts();
    String generateSlug(String title);
    int calculateReadTime(String content);
}
