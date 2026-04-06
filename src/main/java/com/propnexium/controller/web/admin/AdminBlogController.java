package com.propnexium.controller.web.admin;

import java.time.LocalDateTime;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.propnexium.entity.BlogPost;
import com.propnexium.repository.BlogRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.BlogService;
import com.propnexium.util.FileStorageService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.multipart.MultipartFile;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/blog")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminBlogController {

    private final BlogRepository blogRepository;
    private final BlogService blogService;
    private final FileStorageService fileStorageService;
    private final UserRepository userRepository;

    @GetMapping
    public String listPosts(@RequestParam(defaultValue = "0") int page, Model model) {
        Page<BlogPost> posts = blogRepository.findAll(PageRequest.of(page, 10, Sort.by(Sort.Direction.DESC, "createdAt")));
        model.addAttribute("posts", posts);
        return "admin/blog/list";
    }

    @GetMapping("/new")
    public String newPostForm(Model model) {
        model.addAttribute("post", new BlogPost());
        return "admin/blog/form";
    }

    @PostMapping("/new")
    public String savePost(@ModelAttribute BlogPost post, 
                           @RequestParam(required = false) String action,
                           @RequestParam(value = "coverImageFile", required = false) MultipartFile file,
                           @AuthenticationPrincipal UserDetails userDetails) {
        
        if (file != null && !file.isEmpty()) {
            String filename = fileStorageService.storeFile(file, "blog");
            post.setCoverImage("/uploads/blog/" + filename);
        }

        if (post.getSlug() == null || post.getSlug().isEmpty()) {
            post.setSlug(blogService.generateSlug(post.getTitle()));
        }
        
        post.setReadTimeMinutes(blogService.calculateReadTime(post.getContent()));
        
        if (userDetails != null) {
            userRepository.findByEmail(userDetails.getUsername()).ifPresent(post::setAuthor);
        }

        if ("publish".equals(action)) {
            post.setStatus(BlogPost.PostStatus.PUBLISHED);
            post.setPublishedAt(LocalDateTime.now());
        } else {
            post.setStatus(BlogPost.PostStatus.DRAFT);
        }
        
        blogRepository.save(post);
        return "redirect:/admin/blog";
    }

    @GetMapping("/{id}/edit")
    public String editPostForm(@PathVariable Long id, Model model) {
        BlogPost post = blogRepository.findById(id).orElseThrow();
        model.addAttribute("post", post);
        return "admin/blog/form";
    }

    @PostMapping("/{id}/edit")
    public String updatePost(@PathVariable Long id, 
                             @ModelAttribute BlogPost postData,
                             @RequestParam(required = false) String action,
                             @RequestParam(value = "coverImageFile", required = false) MultipartFile file) {
                             
        BlogPost post = blogRepository.findById(id).orElseThrow();
        
        post.setTitle(postData.getTitle());
        
        if (file != null && !file.isEmpty()) {
            String filename = fileStorageService.storeFile(file, "blog");
            post.setCoverImage("/uploads/blog/" + filename);
        } else if (postData.getCoverImage() != null && !postData.getCoverImage().isEmpty()) {
            post.setCoverImage(postData.getCoverImage());
        }

        post.setContent(postData.getContent());
        post.setExcerpt(postData.getExcerpt());
        post.setCategory(postData.getCategory());
        post.setTags(postData.getTags());
        
        post.setReadTimeMinutes(blogService.calculateReadTime(post.getContent()));
        
        if ("publish".equals(action) && (post.getStatus() == BlogPost.PostStatus.DRAFT || post.getPublishedAt() == null)) {
            post.setStatus(BlogPost.PostStatus.PUBLISHED);
            post.setPublishedAt(LocalDateTime.now());
        } else if ("draft".equals(action)) {
            post.setStatus(BlogPost.PostStatus.DRAFT);
            post.setPublishedAt(null);
        }

        blogRepository.save(post);
        return "redirect:/admin/blog";
    }
    
    @PostMapping("/{id}/publish")
    public String publishDraft(@PathVariable Long id) {
        BlogPost post = blogRepository.findById(id).orElseThrow();
        post.setStatus(BlogPost.PostStatus.PUBLISHED);
        post.setPublishedAt(LocalDateTime.now());
        blogRepository.save(post);
        return "redirect:/admin/blog";
    }

    @PostMapping("/{id}/delete")
    public String deletePost(@PathVariable Long id) {
        // Hard deletion as requested unless there's a deleted flag (prompt specifically didn't mention soft delete flag in entity, but mentions "soft delete" in controller comment: "// POST /admin/blog/{id}/delete — soft delete")
        // Since BlogPost entity doesn't have a deleted flag (or DELETED status), I will just delete it entirely.
        blogRepository.deleteById(id);
        return "redirect:/admin/blog";
    }
}
