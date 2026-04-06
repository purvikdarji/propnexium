package com.propnexium.controller.web;

import com.propnexium.dto.request.UserRegistrationDto;
import com.propnexium.exception.BusinessException;
import com.propnexium.exception.DuplicateResourceException;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.exception.TokenExpiredException;
import com.propnexium.service.PasswordResetService;
import com.propnexium.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;
    private final PasswordResetService passwordResetService;

    // ─────────────────────────────────────────────────────────────────────────
    // Register
    // ─────────────────────────────────────────────────────────────────────────

    @GetMapping("/register")
    public String showRegisterForm(Model model) {
        if (isAuthenticated())
            return "redirect:/";
        model.addAttribute("registrationDto", new UserRegistrationDto());
        return "auth/register";
    }

    @PostMapping("/register")
    public String processRegistration(
            @ModelAttribute("registrationDto") @Valid UserRegistrationDto dto,
            BindingResult bindingResult,
            RedirectAttributes redirectAttributes,
            Model model) {

        if (bindingResult.hasErrors()) {
            return "auth/register";
        }

        if (!dto.isPasswordMatching()) {
            bindingResult.rejectValue("confirmPassword", "error.confirmPassword",
                    "Passwords do not match");
            return "auth/register";
        }
        try {
            userService.registerUser(dto);
            redirectAttributes.addFlashAttribute("successMessage",
                    "Account created successfully! Please login.");
            return "redirect:/auth/login";
        } catch (DuplicateResourceException e) {
            bindingResult.rejectValue("email", "error.email", e.getMessage());
            return "auth/register";
        } catch (BusinessException e) {
            model.addAttribute("errorMessage", e.getMessage());
            return "auth/register";
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Login
    // ─────────────────────────────────────────────────────────────────────────

    @GetMapping("/login")
    public String loginPage(
            @RequestParam(required = false) String error,
            @RequestParam(required = false) String logout,
            Model model) {

        if (isAuthenticated())
            return "redirect:/";

        if (error != null) {
            model.addAttribute("errorMessage", "Invalid email or password. Please try again.");
        }
        if (logout != null) {
            model.addAttribute("logoutMessage", "You have been logged out successfully.");
        }

        return "auth/login";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Forgot Password
    // ─────────────────────────────────────────────────────────────────────────

    @GetMapping("/forgot-password")
    public String showForgotPasswordPage() {
        return "auth/forgot-password";
    }

    @PostMapping("/forgot-password")
    public String processForgotPassword(
            @RequestParam String email,
            RedirectAttributes redirectAttrs) {
        try {
            passwordResetService.initiatePasswordReset(email);
            redirectAttrs.addFlashAttribute("successMessage",
                    "Password reset link sent to your email. Please check your inbox.");
        } catch (ResourceNotFoundException e) {
            redirectAttrs.addFlashAttribute("errorMessage",
                    "No account found with this email address.");
        }
        return "redirect:/auth/forgot-password";
    }

    @GetMapping("/reset-password")
    public String showResetPasswordPage(
            @RequestParam String token,
            Model model) {
        if (!passwordResetService.validateToken(token)) {
            model.addAttribute("error",
                    "This reset link is invalid or has expired.");
            return "auth/reset-password-invalid";
        }
        model.addAttribute("token", token);
        return "auth/reset-password";
    }

    @PostMapping("/reset-password")
    public String processResetPassword(
            @RequestParam String token,
            @RequestParam String newPassword,
            @RequestParam String confirmPassword,
            RedirectAttributes redirectAttrs) {

        if (!newPassword.equals(confirmPassword)) {
            redirectAttrs.addFlashAttribute("errorMessage", "Passwords do not match.");
            return "redirect:/auth/reset-password?token=" + token;
        }
        try {
            passwordResetService.resetPassword(token, newPassword);
            redirectAttrs.addFlashAttribute("successMessage",
                    "Password reset successfully. Please log in with your new password.");
            return "redirect:/auth/login";
        } catch (TokenExpiredException e) {
            redirectAttrs.addFlashAttribute("errorMessage",
                    "Reset link has expired. Please request a new one.");
            return "redirect:/auth/forgot-password";
        } catch (ResourceNotFoundException e) {
            redirectAttrs.addFlashAttribute("errorMessage",
                    "Invalid reset link. Please request a new one.");
            return "redirect:/auth/forgot-password";
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper
    // ─────────────────────────────────────────────────────────────────────────

    private boolean isAuthenticated() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null
                && auth.isAuthenticated()
                && !(auth instanceof AnonymousAuthenticationToken);
    }
}
