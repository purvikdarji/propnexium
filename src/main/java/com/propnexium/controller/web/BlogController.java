package com.propnexium.controller.web;

import org.springframework.data.domain.Page;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.propnexium.entity.BlogPost;
import com.propnexium.repository.BlogRepository;
import com.propnexium.service.BlogService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/blog")
@RequiredArgsConstructor
public class BlogController {

    private final BlogService blogService;
    private final BlogRepository blogRepository;

    @GetMapping
    public String blogListing(
            @RequestParam(required = false) String category,
            @RequestParam(defaultValue = "0") int page,
            Model model) {

        Page<BlogPost> posts = blogService.getPublishedPosts(category, page, 9);

        model.addAttribute("posts", posts);
        model.addAttribute("currentCategory", category);
        model.addAttribute("categories", blogRepository.findDistinctCategoryByStatus(BlogPost.PostStatus.PUBLISHED));
        model.addAttribute("popularPosts", blogService.getPopularPosts());

        return "blog/index";
    }

    @GetMapping("/{slug}")
    public String blogDetail(@PathVariable String slug, Model model) {

        BlogPost post = blogService.getPostBySlug(slug);
        
        // Ensure accurate increment
        blogRepository.incrementViewCount(post.getId());
        post.setViewCount(post.getViewCount() + 1);

        model.addAttribute("post", post);
        model.addAttribute("relatedPosts", blogService.getRelatedPosts(post));
        model.addAttribute("popularPosts", blogService.getPopularPosts());

        return "blog/detail";
    }
}
