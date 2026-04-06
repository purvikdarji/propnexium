package com.propnexium.controller.web;

import com.propnexium.dto.response.ApiResponse;
import com.propnexium.entity.User;
import com.propnexium.service.PropertyReportService;
import com.propnexium.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.propnexium.entity.PropertyReport.ReportStatus;
import com.propnexium.repository.PropertyReportRepository;

@Slf4j
@Controller
@RequiredArgsConstructor
public class PropertyReportController {

    private final PropertyReportService propertyReportService;
    private final PropertyReportRepository reportRepository;
    private final UserService userService;

    // ── AJAX: Submit report ────────────────────────────────────────────────────

    @PostMapping("/properties/{id}/report")
    @ResponseBody
    public ResponseEntity<ApiResponse<String>> submitReport(
            @PathVariable Long id,
            @RequestParam String reason,
            @RequestParam(required = false) String description,
            @AuthenticationPrincipal UserDetails userDetails) {

        User reporter = userService.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
        propertyReportService.submitReport(id, reporter.getId(), reason, description);
        return ResponseEntity.ok(
                ApiResponse.success(null, "Report submitted. Our team will review it shortly."));
    }

    // ── Admin: Report queue ─────────────────────────────────────────────────

    @GetMapping("/admin/reports")
    @PreAuthorize("hasRole('ADMIN')")
    public String reportsPage(Model model) {
        model.addAttribute("pendingReports",
                propertyReportService.findByStatus(ReportStatus.PENDING));
        model.addAttribute("underReviewReports",
                propertyReportService.findByStatus(ReportStatus.UNDER_REVIEW));
        model.addAttribute("pendingCount",
                reportRepository.countByStatus(ReportStatus.PENDING));
        return "admin/reports";
    }

    // ── Admin: Put under review ─────────────────────────────────────────────

    @PostMapping("/admin/reports/{id}/under-review")
    @PreAuthorize("hasRole('ADMIN')")
    public String putUnderReview(@PathVariable Long id, RedirectAttributes ra) {
        propertyReportService.putUnderReview(id);
        ra.addFlashAttribute("successMessage",
                "Listing put under review. Agent has been notified.");
        return "redirect:/admin/reports";
    }

    // ── Admin: Dismiss ──────────────────────────────────────────────────────

    @PostMapping("/admin/reports/{id}/dismiss")
    @PreAuthorize("hasRole('ADMIN')")
    public String dismiss(@PathVariable Long id, RedirectAttributes ra) {
        propertyReportService.dismissReport(id);
        ra.addFlashAttribute("successMessage", "Report dismissed.");
        return "redirect:/admin/reports";
    }

    // ── Admin: Remove listing ───────────────────────────────────────────────

    @PostMapping("/admin/reports/{id}/remove")
    @PreAuthorize("hasRole('ADMIN')")
    public String removeListing(@PathVariable Long id, RedirectAttributes ra) {
        propertyReportService.removeListing(id);
        ra.addFlashAttribute("successMessage", "Listing removed from platform.");
        return "redirect:/admin/reports";
    }
}
