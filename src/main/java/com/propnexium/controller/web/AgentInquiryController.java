package com.propnexium.controller.web;
import com.propnexium.entity.Inquiry;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.InquiryStatus;
import com.propnexium.exception.UnauthorizedAccessException;
import com.propnexium.service.InquiryService;
import com.propnexium.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/agent/inquiries")
@PreAuthorize("hasAnyRole('AGENT','ADMIN')")
@RequiredArgsConstructor
public class AgentInquiryController {

    private final InquiryService inquiryService;
    private final UserService userService;

    @GetMapping
    public String inquiryInbox(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) String status,
            Model model) {

        User agent = userService.getCurrentUser();
        Pageable pageable = PageRequest.of(page, 10, Sort.by("createdAt").descending());

        Page<Inquiry> inquiries;
        if (status != null && !status.isBlank()) {
            try {
                InquiryStatus is = InquiryStatus.valueOf(status);
                inquiries = inquiryService.findByAgentIdAndStatus(agent.getId(), is, pageable);
            } catch (IllegalArgumentException e) {
                inquiries = inquiryService.findByAgent(agent.getId(), pageable);
                status = null;
            }
        } else {
            inquiries = inquiryService.findByAgent(agent.getId(), pageable);
        }

        long pendingCount = inquiryService.countByAgentAndStatus(agent.getId(), InquiryStatus.PENDING);
        long repliedCount = inquiryService.countByAgentAndStatus(agent.getId(), InquiryStatus.REPLIED);
        long closedCount = inquiryService.countByAgentAndStatus(agent.getId(), InquiryStatus.CLOSED);

        model.addAttribute("inquiries", inquiries);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", inquiries.getTotalPages());
        model.addAttribute("filterStatus", status);
        model.addAttribute("pendingCount", pendingCount);
        model.addAttribute("repliedCount", repliedCount);
        model.addAttribute("closedCount", closedCount);
        model.addAttribute("agent", agent);
        return "agent/inquiries";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET /agent/inquiries/{id} — inquiry detail
    // ─────────────────────────────────────────────────────────────────────────
    @GetMapping("/{id}")
    public String viewInquiry(@PathVariable Long id, Model model) {
        User agent = userService.getCurrentUser();
        Inquiry inquiry = inquiryService.findById(id);

        if (!inquiry.getProperty().getAgent().getId().equals(agent.getId())) {
            throw new UnauthorizedAccessException("You can only view inquiries on your own properties");
        }

        model.addAttribute("inquiry", inquiry);
        model.addAttribute("property", inquiry.getProperty());
        model.addAttribute("agent", agent);
        return "agent/inquiry-detail";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /agent/inquiries/{id}/reply — submit reply
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/{id}/reply")
    public String replyToInquiry(
            @PathVariable Long id,
            @RequestParam String replyText,
            RedirectAttributes redirectAttrs) {

        if (replyText == null || replyText.isBlank()) {
            redirectAttrs.addFlashAttribute("errorMessage", "Reply cannot be empty.");
            return "redirect:/agent/inquiries/" + id;
        }

        try {
            User agent = userService.getCurrentUser();
            inquiryService.replyToInquiry(id, agent.getId(), replyText.trim());
            redirectAttrs.addFlashAttribute("successMessage",
                    "Reply sent! The inquirer has been notified by email.");
        } catch (Exception e) {
            redirectAttrs.addFlashAttribute("errorMessage", "Failed to send reply: " + e.getMessage());
        }
        return "redirect:/agent/inquiries/" + id;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /agent/inquiries/{id}/close — close inquiry
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/{id}/close")
    public String closeInquiry(@PathVariable Long id, RedirectAttributes redirectAttrs) {
        try {
            User agent = userService.getCurrentUser();
            inquiryService.closeInquiry(id, agent.getId());
            redirectAttrs.addFlashAttribute("successMessage", "Inquiry marked as closed.");
        } catch (Exception e) {
            redirectAttrs.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/agent/inquiries";
    }
}
