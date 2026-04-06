package com.propnexium.service.impl;

import com.propnexium.entity.EmailVerification;
import com.propnexium.entity.User;
import com.propnexium.exception.BusinessException;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.exception.TokenExpiredException;
import com.propnexium.repository.EmailVerificationRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.EmailService;
import com.propnexium.service.EmailVerificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class EmailVerificationServiceImpl implements EmailVerificationService {

    private final EmailVerificationRepository verificationRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;

    @Value("${propnexium.app.base-url:http://localhost:8080}")
    private String baseUrl;

    @Override
    public void sendVerificationEmail(User user) {
        // Delete any existing token for this user
        verificationRepository.findByUserId(user.getId())
                .ifPresent(verificationRepository::delete);

        // Generate unique token
        String token = UUID.randomUUID().toString();

        // Build and save verification record
        EmailVerification verification = EmailVerification.builder()
                .user(user)
                .token(token)
                .expiryAt(LocalDateTime.now().plusHours(24))
                .build();
        verificationRepository.save(verification);

        String verifyLink = baseUrl + "/auth/verify-email?token=" + token;
        emailService.sendVerificationEmail(user, verifyLink);
        log.info("Verification email queued for user {}", user.getEmail());
    }

    @Override
    public boolean verifyEmail(String token) {
        EmailVerification verification = verificationRepository.findByToken(token)
                .orElseThrow(() -> new ResourceNotFoundException("Invalid verification token"));

        if (verification.isExpired()) {
            throw new TokenExpiredException("Verification link has expired. Please request a new one.");
        }
        if (verification.isVerified()) {
            throw new BusinessException("Email has already been verified.");
        }

        verification.setVerifiedAt(LocalDateTime.now());
        verificationRepository.save(verification);

        User user = verification.getUser();
        user.setIsEmailVerified(true);
        userRepository.save(user);

        log.info("Email verified for user {}", user.getEmail());
        return true;
    }

    @Override
    public void resendVerification(Long userId) {
        verificationRepository.findByUserId(userId)
                .ifPresent(verificationRepository::delete);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        sendVerificationEmail(user);
    }
}
