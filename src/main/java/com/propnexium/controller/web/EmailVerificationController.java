package com.propnexium.controller.web;

import com.propnexium.entity.User;
import com.propnexium.exception.BusinessException;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.exception.TokenExpiredException;
import com.propnexium.service.EmailVerificationService;
import com.propnexium.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Slf4j
@Controller
@RequiredArgsConstructor
public class EmailVerificationController {

    private final EmailVerificationService emailVerificationService;
    private final UserService userService;

    // ── GET /auth/verify-email?token={token} ────────────────────────────────

    @GetMapping("/auth/verify-email")
    public String verifyEmail(@RequestParam String token, RedirectAttributes ra) {
        try {
            emailVerificationService.verifyEmail(token);
            ra.addFlashAttribute("successMessage",
                    "✅ Email verified successfully! You can now access all features.");
            return "redirect:/auth/login";
        } catch (TokenExpiredException e) {
            ra.addFlashAttribute("errorMessage",
                    "Verification link expired. Please request a new one from your dashboard.");
            return "redirect:/user/dashboard";
        } catch (BusinessException e) {
            ra.addFlashAttribute("successMessage", "Your email is already verified.");
            return "redirect:/user/dashboard";
        } catch (ResourceNotFoundException e) {
            ra.addFlashAttribute("errorMessage", "Invalid verification link.");
            return "redirect:/auth/login";
        } catch (Exception e) {
            log.warn("Email verification error: {}", e.getMessage());
            ra.addFlashAttribute("errorMessage",
                    "Something went wrong. Please try again or contact support.");
            return "redirect:/user/dashboard";
        }
    }

    // ── POST /user/resend-verification ──────────────────────────────────────

    @PostMapping("/user/resend-verification")
    public String resendVerification(
            @AuthenticationPrincipal UserDetails userDetails,
            RedirectAttributes ra) {
        try {
            User user = userService.findByEmail(userDetails.getUsername())
                    .orElseThrow(() -> new ResourceNotFoundException("User not found"));
            emailVerificationService.resendVerification(user.getId());
            ra.addFlashAttribute("successMessage",
                    "📧 Verification email sent. Please check your inbox.");
        } catch (Exception e) {
            log.warn("Resend verification error: {}", e.getMessage());
            ra.addFlashAttribute("errorMessage",
                    "Could not send verification email. Please try again.");
        }
        return "redirect:/user/dashboard";
    }
}
