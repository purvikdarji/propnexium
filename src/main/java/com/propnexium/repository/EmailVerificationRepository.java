package com.propnexium.repository;

import com.propnexium.entity.EmailVerification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EmailVerificationRepository extends JpaRepository<EmailVerification, Long> {

    Optional<EmailVerification> findByToken(String token);

    Optional<EmailVerification> findByUserId(Long userId);
}
