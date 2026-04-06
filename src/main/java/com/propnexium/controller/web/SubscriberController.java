package com.propnexium.controller.web;

import com.propnexium.dto.response.ApiResponse;
import com.propnexium.service.SubscriberService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class SubscriberController {

    @Autowired
    private SubscriberService subscriberService;

    /** POST /subscribe — AJAX from footer newsletter form */
    @PostMapping("/subscribe")
    @ResponseBody
    public ResponseEntity<ApiResponse<String>> subscribe(@RequestParam String email) {
        ApiResponse<String> response = subscriberService.subscribe(email);
        return ResponseEntity.ok(response);
    }

    /** GET /unsubscribe?token={token} — one-click unsubscribe from email */
    @GetMapping("/unsubscribe")
    public String unsubscribe(@RequestParam String token,
                              RedirectAttributes redirectAttrs) {
        try {
            subscriberService.unsubscribe(token);
            redirectAttrs.addFlashAttribute("successMessage",
                    "You have been unsubscribed successfully.");
        } catch (Exception e) {
            redirectAttrs.addFlashAttribute("errorMessage",
                    "Invalid or expired unsubscribe link.");
        }
        return "redirect:/";
    }

    @GetMapping("/admin/subscribers")
    @PreAuthorize("hasRole('ADMIN')")
    public String subscribersPage(Model model) {
        model.addAttribute("subscribers", subscriberService.getActiveSubscribers());
        model.addAttribute("totalCount", subscriberService.getActiveCount());
        return "admin/subscribers";
    }

    /** POST /admin/subscribers/remove/{id} — admin action to delete a subscriber */
    @PostMapping("/admin/subscribers/remove/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public String removeSubscriber(@PathVariable Long id, RedirectAttributes redirectAttrs) {
        subscriberService.removeSubscriber(id);
        redirectAttrs.addFlashAttribute("successMessage", "Subscriber removed effectively.");
        return "redirect:/admin/subscribers";
    }
}
