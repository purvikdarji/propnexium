package com.propnexium.service.impl;

import com.propnexium.entity.PasswordResetToken;
import com.propnexium.entity.User;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.exception.TokenExpiredException;
import com.propnexium.repository.PasswordResetTokenRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.EmailService;
import com.propnexium.service.PasswordResetService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PasswordResetServiceImpl implements PasswordResetService {

    private final PasswordResetTokenRepository tokenRepository;
    private final UserRepository              userRepository;
    private final EmailService                emailService;
    private final PasswordEncoder             passwordEncoder;

    @Value("${propnexium.app.base-url:http://localhost:8080}")
    private String baseUrl;

    // ── initiatePasswordReset ────────────────────────────────────────────────

    @Override
    @Transactional
    public void initiatePasswordReset(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "No account found with email: " + email));

        // Remove any old tokens for this user (idempotent)
        tokenRepository.deleteAllByUserId(user.getId());

        // Issue new token valid for 1 hour
        String rawToken = UUID.randomUUID().toString();
        PasswordResetToken prt = PasswordResetToken.builder()
                .token(rawToken)
                .user(user)
                .expiryAt(LocalDateTime.now().plusHours(1))
                .used(false)
                .build();
        tokenRepository.save(prt);

        String resetLink = baseUrl + "/auth/reset-password?token=" + rawToken;
        emailService.sendPasswordResetEmail(user, resetLink);

        log.info("Password reset initiated for user id={}", user.getId());
    }

    // ── resetPassword ────────────────────────────────────────────────────────

    @Override
    @Transactional
    public void resetPassword(String token, String newPassword) {
        PasswordResetToken prt = tokenRepository.findByTokenAndUsedFalse(token)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Reset token not found or already used"));

        if (prt.isExpired()) {
            throw new TokenExpiredException("Password reset link has expired. Please request a new one.");
        }

        User user = prt.getUser();
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        prt.setUsed(true);
        tokenRepository.save(prt);

        log.info("Password reset successfully for user id={}", user.getId());
    }

    // ── validateToken ────────────────────────────────────────────────────────

    @Override
    @Transactional(readOnly = true)
    public boolean validateToken(String token) {
        return tokenRepository.findByTokenAndUsedFalse(token)
                .map(prt -> !prt.isExpired())
                .orElse(false);
    }
}
