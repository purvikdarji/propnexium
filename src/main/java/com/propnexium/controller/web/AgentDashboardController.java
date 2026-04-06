package com.propnexium.controller.web;

import com.propnexium.dto.request.AgentProfileDto;
import com.propnexium.entity.AgentProfile;
import com.propnexium.entity.Inquiry;
import com.propnexium.entity.Property;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.InquiryStatus;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.service.AgentProfileService;
import com.propnexium.service.InquiryService;
import com.propnexium.service.NotificationService;
import com.propnexium.service.PropertyService;
import com.propnexium.service.UserService;
import com.propnexium.util.FileStorageService;
import com.propnexium.exception.InvalidFileException;
import org.springframework.web.multipart.MultipartFile;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/agent")
@PreAuthorize("hasAnyRole('AGENT','ADMIN')")
@RequiredArgsConstructor
public class AgentDashboardController {

        private final UserService userService;
        private final PropertyService propertyService;
        private final InquiryService inquiryService;
        private final AgentProfileService agentProfileService;
        private final NotificationService notificationService;
        private final FileStorageService fileStorageService;

        @GetMapping("/dashboard")
        public String dashboard(Model model) {
                User agent = userService.getCurrentUser();
                AgentProfile profile = agentProfileService.findByUserId(agent.getId());

                long totalListings = propertyService.countByAgent(agent.getId());
                long availableListings = propertyService.countByAgentAndStatus(agent.getId(), PropertyStatus.AVAILABLE);
                long pendingListings = propertyService.countByAgentAndStatus(agent.getId(),
                                PropertyStatus.UNDER_REVIEW);
                long soldListings = propertyService.countByAgentAndStatus(agent.getId(), PropertyStatus.SOLD);

                long totalInquiries = inquiryService.countByAgent(agent.getId());
                long pendingInquiries = inquiryService.countByAgentAndStatus(agent.getId(), InquiryStatus.PENDING);

                long totalViews = propertyService.getTotalViewsByAgent(agent.getId());

                List<Property> recentListings = propertyService.getRecentByAgent(agent.getId(), 5);
                List<Inquiry> recentInquiries = inquiryService.getRecentByAgent(agent.getId(), 5);

                boolean profileComplete = profile != null
                                && profile.getAgencyName() != null
                                && profile.getLicenseNumber() != null
                                && profile.getBio() != null;

                model.addAttribute("agent", agent);
                model.addAttribute("agentProfile", profile);
                model.addAttribute("totalListings", totalListings);
                model.addAttribute("availableListings", availableListings);
                model.addAttribute("pendingListings", pendingListings);
                model.addAttribute("soldListings", soldListings);
                model.addAttribute("totalInquiries", totalInquiries);
                model.addAttribute("pendingInquiries", pendingInquiries);
                model.addAttribute("totalViews", totalViews);
                model.addAttribute("recentListings", recentListings);
                model.addAttribute("recentInquiries", recentInquiries);
                model.addAttribute("profileComplete", profileComplete);
                model.addAttribute("unreadNotifications",
                                notificationService.countUnread(agent.getId()));

                return "agent/dashboard";
        }

        // ─────────────────────────────────────────────────────────────────────────
        // GET /agent/profile
        // ─────────────────────────────────────────────────────────────────────────
        @GetMapping("/profile")
        public String agentProfile(Model model) {
                User agent = userService.getCurrentUser();
                AgentProfile prof = agentProfileService.findByUserId(agent.getId());

                long totalListings = propertyService.countByAgent(agent.getId());

                model.addAttribute("agent", agent);
                model.addAttribute("profile", prof);
                model.addAttribute("profileDto", new AgentProfileDto(prof));
                model.addAttribute("totalListings", totalListings);
                model.addAttribute("pendingListings",
                                propertyService.countByAgentAndStatus(agent.getId(), PropertyStatus.UNDER_REVIEW));
                model.addAttribute("pendingInquiries",
                                inquiryService.countByAgentAndStatus(agent.getId(), InquiryStatus.PENDING));
                return "agent/profile";
        }

        // ─────────────────────────────────────────────────────────────────────────
        // POST /agent/profile/update
        // ─────────────────────────────────────────────────────────────────────────
        @PostMapping("/profile/update")
        public String updateAgentProfile(
                        @ModelAttribute("profileDto") @Valid AgentProfileDto dto,
                        BindingResult result,
                        RedirectAttributes redirectAttrs,
                        Model model) {

                if (result.hasErrors()) {
                        User agent = userService.getCurrentUser();
                        model.addAttribute("agent", agent);
                        model.addAttribute("profile", agentProfileService.findByUserId(agent.getId()));
                        model.addAttribute("totalListings", propertyService.countByAgent(agent.getId()));
                        model.addAttribute("pendingListings",
                                        propertyService.countByAgentAndStatus(agent.getId(),
                                                        PropertyStatus.UNDER_REVIEW));
                        model.addAttribute("pendingInquiries",
                                        inquiryService.countByAgentAndStatus(agent.getId(), InquiryStatus.PENDING));
                        return "agent/profile";
                }

                User agent = userService.getCurrentUser();
                agentProfileService.updateProfile(agent.getId(), dto);
                redirectAttrs.addFlashAttribute("successMessage", "Agent profile updated successfully!");
                return "redirect:/agent/profile";
        }

        // ─────────────────────────────────────────────────────────────────────────
        // POST /agent/profile/picture
        // ─────────────────────────────────────────────────────────────────────────
        @PostMapping("/profile/picture")
        public String uploadProfilePicture(
                        @RequestParam("file") MultipartFile file,
                        RedirectAttributes redirectAttrs) {

                try {
                        User agent = userService.getCurrentUser();
                        String filename = fileStorageService.storeFile(file, "profile-pictures");
                        String imageUrl = "/uploads/profile-pictures/" + filename;
                        userService.updateProfilePicture(agent.getId(), imageUrl);
                        redirectAttrs.addFlashAttribute("successMessage", "Profile picture updated!");
                } catch (InvalidFileException e) {
                        redirectAttrs.addFlashAttribute("errorMessage", e.getMessage());
                }
                return "redirect:/agent/profile";
        }
}
