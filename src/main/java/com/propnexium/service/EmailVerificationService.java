package com.propnexium.service;

import com.propnexium.entity.User;

public interface EmailVerificationService {

    void sendVerificationEmail(User user);

    boolean verifyEmail(String token);

    void resendVerification(Long userId);
}
