package com.propnexium.controller.web.admin;

import com.propnexium.entity.News;
import com.propnexium.service.NewsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/news")
@PreAuthorize("hasRole('ADMIN')")
public class AdminNewsController {

    @Autowired
    private NewsService newsService;

    @GetMapping
    public String listNews(Model model) {
        model.addAttribute("newsList", newsService.getAllNews());
        return "admin/news/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("news", new News());
        model.addAttribute("pageTitle", "Add News Article");
        return "admin/news/form";
    }

    @PostMapping("/new")
    public String createNews(@ModelAttribute News news, RedirectAttributes redirectAttrs) {
        // default author if empty
        if (news.getAuthor() == null || news.getAuthor().trim().isEmpty()) {
            news.setAuthor("PropNexium Admin");
        }
        newsService.createNews(news);
        redirectAttrs.addFlashAttribute("successMessage", "News article created successfully!");
        return "redirect:/admin/news";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        model.addAttribute("news", newsService.getNewsById(id));
        model.addAttribute("pageTitle", "Edit News Article");
        return "admin/news/form";
    }

    @PostMapping("/edit/{id}")
    public String updateNews(@PathVariable Long id, @ModelAttribute News news, RedirectAttributes redirectAttrs) {
        if (news.getAuthor() == null || news.getAuthor().trim().isEmpty()) {
            news.setAuthor("PropNexium Admin");
        }
        newsService.updateNews(id, news);
        redirectAttrs.addFlashAttribute("successMessage", "News article updated successfully!");
        return "redirect:/admin/news";
    }

    @PostMapping("/delete/{id}")
    public String deleteNews(@PathVariable Long id, RedirectAttributes redirectAttrs) {
        newsService.deleteNews(id);
        redirectAttrs.addFlashAttribute("successMessage", "News article deleted successfully!");
        return "redirect:/admin/news";
    }
}
