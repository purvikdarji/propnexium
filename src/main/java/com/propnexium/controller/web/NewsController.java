package com.propnexium.controller.web;

import com.propnexium.service.NewsService;
import com.propnexium.service.SubscriberService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class NewsController {

    @Autowired
    private NewsService newsService;

    @Autowired
    private SubscriberService subscriberService;

    @GetMapping("/news")
    public String showNews(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isSubscribed = false;

        if (auth != null && auth.isAuthenticated() && !auth.getPrincipal().equals("anonymousUser")) {
            String email = auth.getName(); // assuming username is the email
            isSubscribed = subscriberService.isEmailSubscribed(email);
        }

        if (isSubscribed) {
            model.addAttribute("newsList", newsService.getAllNews());
        }
        
        model.addAttribute("hasAccess", isSubscribed);
        model.addAttribute("hideFooterSubscribe", true);
        return "news/index";
    }

    @org.springframework.web.bind.annotation.PostMapping("/news/unsubscribe")
    public String unsubscribeFromNews(org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttrs) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !auth.getPrincipal().equals("anonymousUser")) {
            String email = auth.getName();
            subscriberService.unsubscribeByEmail(email);
            redirectAttrs.addFlashAttribute("successMessage", "You have successfully unsubscribed from PropNexium News.");
        }
        return "redirect:/news";
    }
}
