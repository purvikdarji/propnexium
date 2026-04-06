package com.propnexium.controller.web.admin;

import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.repository.PropertyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.List;

@Controller
@RequestMapping("/admin/properties")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
@Slf4j
public class AdminBulkController {

    private final PropertyRepository propertyRepository;

    @PostMapping("/bulk-approve")
    public String bulkApprove(
            @RequestParam List<Long> ids,
            RedirectAttributes redirectAttrs) {

        int[] count = {0};
        for (Long id : ids) {
            propertyRepository.findById(id).ifPresent(p -> {
                p.setStatus(PropertyStatus.AVAILABLE);
                p.setUpdatedAt(LocalDateTime.now());
                propertyRepository.save(p);
                count[0]++;
            });
        }
        log.info("Admin bulk-approved {} properties: {}", count[0], ids);
        redirectAttrs.addFlashAttribute("successMessage",
                count[0] + " propert" + (count[0] == 1 ? "y" : "ies") + " approved successfully.");
        return "redirect:/admin/properties";
    }

    @PostMapping("/bulk-reject")
    public String bulkReject(
            @RequestParam List<Long> ids,
            RedirectAttributes redirectAttrs) {

        int[] count = {0};
        for (Long id : ids) {
            propertyRepository.findById(id).ifPresent(p -> {
                p.setStatus(PropertyStatus.REJECTED);
                p.setUpdatedAt(LocalDateTime.now());
                propertyRepository.save(p);
                count[0]++;
            });
        }
        log.info("Admin bulk-rejected {} properties: {}", count[0], ids);
        redirectAttrs.addFlashAttribute("successMessage",
                count[0] + " propert" + (count[0] == 1 ? "y" : "ies") + " rejected.");
        return "redirect:/admin/properties";
    }
}
