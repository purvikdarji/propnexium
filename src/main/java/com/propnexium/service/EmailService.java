package com.propnexium.service;

import com.propnexium.entity.Inquiry;
import com.propnexium.entity.User;

/**
 * Service for sending transactional emails.
 * Implementations should be @Async to avoid blocking request threads.
 */
public interface EmailService {

    /**
     * Send a rich HTML welcome email to a newly registered user (User object).
     */
    void sendWelcomeEmail(User user);

    /**
     * Legacy: send a simple welcome email using just email address and name.
     */
    void sendWelcomeEmail(String toEmail, String userName);

    /**
     * Send a password-reset link email to the given user.
     *
     * @param user      the user requesting a password reset
     * @param resetLink the full URL containing the one-time token
     */
    void sendPasswordResetEmail(User user, String resetLink);

    /**
     * Send the agent's reply to the inquirer's email.
     */
    void sendAgentReplyToUser(Inquiry inquiry);

    /**
     * Generic plain/HTML email helper.
     */
    void sendEmail(String to, String subject, String htmlBody);

    /**
     * Send email to admin from Contact Us page.
     */
    void sendContactFormEmail(String name, String email, String subject, String message);

    /**
     * Notify the agent that their listing has been put under review due to a user report.
     */
    void sendListingUnderReviewEmail(com.propnexium.entity.User agent, com.propnexium.entity.Property property);

    /**
     * Send email-verification link to a newly registered or updating user.
     */
    void sendVerificationEmail(com.propnexium.entity.User user, String verifyLink);

    /**
     * Send site visit booking confirmation to the user.
     */
    void sendBookingConfirmationEmail(Long bookingId);
    
    /**
     * Send new site visit booking alert to the agent.
     */
    void sendBookingAlertToAgent(Long bookingId);
    
    /**
     * Send booking status update to the user (e.g., when agent accepts/declines).
     */
    void sendBookingStatusEmailToUser(Long bookingId, String statusMessage);

    /**
     * Notify the agent when a user cancels their planned site visit.
     */
    void sendBookingCancellationAlertToAgent(Long bookingId);
}
