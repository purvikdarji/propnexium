package com.propnexium.service.impl;

import com.propnexium.entity.Inquiry;
import com.propnexium.entity.Property;
import com.propnexium.entity.User;
import com.propnexium.repository.SubscriberRepository;
import com.propnexium.service.EmailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import jakarta.mail.internet.MimeMessage;

/**
 * Email service implementation.
 * Sends emails asynchronously using premium HTML templates.
 */
@Slf4j
@Service
public class EmailServiceImpl implements EmailService {

  @Autowired
  private JavaMailSender mailSender;

  @Autowired(required = false)
  private SubscriberRepository subscriberRepository;

  @Autowired
  private com.propnexium.repository.BookingRepository bookingRepository;

  @Value("${spring.mail.username:noreply@propnexium.com}")
  private String fromEmail;

  @Value("${propnexium.app.base-url:http://localhost:8080}")
  private String baseUrl;

  // ── Welcome & Auth Emails ──────────────────────────────────────────────────

  @Override
  @Async
  public void sendWelcomeEmail(User user) {
    String roleBadgeColor = switch (user.getRole()) {
      case ADMIN -> "#dc2626";
      case AGENT -> "#1A73E8";
      default -> "#16a34a";
    };
    String body = buildBaseTemplate("Welcome to PropNexium", "#1A73E8", """
        <h2 style="color:#1e293b;margin-top:0;">Welcome, %s!</h2>
        <div style="margin:16px 0;">
          <span style="background:%s;color:white;padding:4px 14px;border-radius:999px;font-size:12px;font-weight:700;">%s</span>
        </div>
        <p style="color:#374151;line-height:1.7;">We are thrilled to have you on board! PropNexium connects you with the best real estate listings across the country.</p>
        <div style="text-align:center;margin-top:28px;">
          <a href="%s" style="display:inline-block;padding:14px 32px;background:#1A73E8;color:white;text-decoration:none;border-radius:8px;font-weight:700;">Explore Properties</a>
        </div>
        """.formatted(user.getName(), roleBadgeColor, user.getRole().name(), baseUrl + "/properties"));
    sendEmail(user.getEmail(), "Welcome to PropNexium!", body);
  }

  @Override
  @Async
  public void sendWelcomeEmail(String toEmail, String userName) {
    String body = buildBaseTemplate("Welcome!", "#1A73E8", "Hi " + userName + ", welcome to PropNexium!");
    sendEmail(toEmail, "Welcome to PropNexium!", body);
  }

  @Override
  @Async
  public void sendPasswordResetEmail(User user, String resetLink) {
    String content = """
        <h2 style="color:#1e293b;">Password Reset Request</h2>
        <p>Hi %s, click the button below to reset your password. This link expires in 1 hour.</p>
        <div style="text-align:center;margin:28px 0;">
          <a href="%s" style="display:inline-block;padding:14px 32px;background:#1A73E8;color:white;text-decoration:none;border-radius:8px;font-weight:700;">Reset Password</a>
        </div>
        """.formatted(user.getName(), resetLink);
    sendEmail(user.getEmail(), "Reset Your PropNexium Password", buildBaseTemplate("Password Reset", "#1A73E8", content));
  }

  @Override
  @Async
  public void sendVerificationEmail(User user, String verifyLink) {
    String content = """
        <h2 style="color:#1e293b;">Verify Your Email</h2>
        <p>Hi %s, please verify your email to unlock all features.</p>
        <div style="text-align:center;margin:28px 0;">
          <a href="%s" style="display:inline-block;padding:14px 32px;background:#16a34a;color:white;text-decoration:none;border-radius:8px;font-weight:700;">Verify Email</a>
        </div>
        """.formatted(user.getName(), verifyLink);
    sendEmail(user.getEmail(), "Verify Your PropNexium Email Address", buildBaseTemplate("Email Verification", "#16a34a", content));
  }

  // ── Inquiry Emails ──────────────────────────────────────────────────────────

  @Override
  @Async
  public void sendAgentReplyToUser(Inquiry inquiry) {
    String content = """
        <p>Hi <strong>%s</strong>, the agent has replied to your inquiry about <strong>%s</strong>:</p>
        <div style="background:#f1f5f9;border-left:4px solid #1A73E8;padding:15px;margin:20px 0;">
          <p style="margin:0;font-style:italic;">"%s"</p>
        </div>
        """.formatted(inquiry.getInquirerName(), inquiry.getProperty().getTitle(), inquiry.getAgentReply());
    sendEmail(inquiry.getInquirerEmail(), "Agent Replied to Your Inquiry", buildBaseTemplate("Inquiry Update", "#1A73E8", content));
  }

  @Override
  @Async
  public void sendListingUnderReviewEmail(User agent, Property property) {
    String content = "Hi " + agent.getName() + ", your listing '" + property.getTitle() + "' is under review.";
    sendEmail(agent.getEmail(), "Listing Under Review", buildBaseTemplate("Listing Notice", "#f59e0b", content));
  }

  // ── Site Visit Booking Emails ──────────────────────────────────────────────

  @Override
  @Async
  public void sendBookingConfirmationEmail(Long bookingId) {
    try {
      com.propnexium.entity.PropertyBooking booking = bookingRepository.findByIdWithDetails(bookingId).orElse(null);
      if (booking == null) return;

      String content = """
          <h2 style="color:#1e293b;margin:0 0 12px;font-size:22px;">Site Visit Scheduled! 🚗</h2>
          <p style="color:#475569;font-size:16px;line-height:1.6;margin-bottom:24px;">Hi %s, your visit for <strong>%s</strong> has been successfully scheduled. Here are your booking details:</p>
          
          <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:24px;margin-bottom:24px;">
            <div style="margin-bottom:16px;">
              <p style="text-transform:uppercase;font-size:11px;font-weight:700;color:#64748b;margin:0 0 4px;letter-spacing:0.05em;">Property</p>
              <p style="margin:0;font-size:17px;font-weight:600;color:#1e293b;">%s</p>
              <p style="margin:2px 0 0;font-size:14px;color:#64748b;">📍 %s</p>
            </div>
            
            <div style="display:flex;gap:24px;border-top:1px solid #edf2f7;padding-top:16px;">
              <div style="flex:1;">
                <p style="text-transform:uppercase;font-size:11px;font-weight:700;color:#64748b;margin:0 0 4px;letter-spacing:0.05em;">Date</p>
                <p style="margin:0;font-size:16px;font-weight:600;color:#1A73E8;">📅 %s</p>
              </div>
              <div style="flex:1;">
                <p style="text-transform:uppercase;font-size:11px;font-weight:700;color:#64748b;margin:0 0 4px;letter-spacing:0.05em;">Time</p>
                <p style="margin:0;font-size:16px;font-weight:600;color:#1A73E8;">⏰ %s</p>
              </div>
            </div>
          </div>

          <p style="color:#475569;font-size:14px;line-height:1.6;margin-bottom:24px;">The agent will verify this request shortly. You can manage your visits anytime from your dashboard.</p>
          
          <div style="text-align:center;">
            <a href="%s/user/bookings" style="display:inline-block;padding:14px 32px;background:#1A73E8;color:white;text-decoration:none;border-radius:8px;font-weight:700;box-shadow:0 4px 6px -1px rgba(0, 0, 0, 0.1);">View My Visits</a>
          </div>
          """.formatted(booking.getVisitorName(), booking.getProperty().getTitle(), booking.getProperty().getTitle(), booking.getProperty().getCity(), booking.getVisitDate(), booking.getTimeSlot(), baseUrl);

      sendEmail(booking.getVisitorEmail(), "Site Visit Scheduled: " + booking.getProperty().getTitle(), buildBaseTemplate("Visit Scheduled", "#10b981", content));
    } catch (Exception e) { log.error("Error in confirmation email: {}", e.getMessage()); }
  }

  @Override
  @Async
  public void sendBookingAlertToAgent(Long bookingId) {
    try {
      com.propnexium.entity.PropertyBooking booking = bookingRepository.findByIdWithDetails(bookingId).orElse(null);
      if (booking == null) {
        log.warn("Booking {} not found for agent alert", bookingId);
        return;
      }

      String content = """
          <h2 style="color:#1e293b;margin:0 0 12px;font-size:22px;">New Site Visit Request! ✨</h2>
          <p style="color:#475569;font-size:16px;line-height:1.6;margin-bottom:24px;">Hi %s, you have received a new visit request for your property <strong>%s</strong>.</p>
          
          <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:24px;margin-bottom:24px;">
            <div style="margin-bottom:20px;">
              <p style="text-transform:uppercase;font-size:11px;font-weight:700;color:#64748b;margin:0 0 4px;letter-spacing:0.05em;">Visitor Details</p>
              <p style="margin:0;font-size:17px;font-weight:600;color:#1e293b;">%s</p>
              <p style="margin:2px 0 0;font-size:14px;color:#1A73E8;">📧 %s</p>
            </div>
            
            <div style="border-top:1px solid #edf2f7;padding-top:16px;">
              <p style="text-transform:uppercase;font-size:11px;font-weight:700;color:#64748b;margin:0 0 4px;letter-spacing:0.05em;">Proposed Schedule</p>
              <p style="margin:0;font-size:16px;font-weight:600;color:#1e293b;">📅 %s at %s</p>
            </div>
          </div>

          <div style="text-align:center;">
            <a href="%s/agent/bookings" style="display:inline-block;padding:14px 32px;background:#1A73E8;color:white;text-decoration:none;border-radius:8px;font-weight:700;box-shadow:0 4px 6px -1px rgba(0, 0, 0, 0.1);">Confirm or Decline Request</a>
          </div>
          """.formatted(booking.getProperty().getAgent().getName(), booking.getProperty().getTitle(), booking.getVisitorName(), booking.getVisitorEmail(), booking.getVisitDate(), booking.getTimeSlot(), baseUrl);

      sendEmail(booking.getProperty().getAgent().getEmail(), "New Visit Request: " + booking.getProperty().getTitle(), buildBaseTemplate("New Request", "#1A73E8", content));
    } catch (Exception e) { log.error("Error in agent alert: {}", e.getMessage()); }
  }

  @Override
  @Async
  public void sendBookingStatusEmailToUser(Long bookingId, String statusMessage) {
    try {
      com.propnexium.entity.PropertyBooking booking = bookingRepository.findByIdWithDetails(bookingId).orElse(null);
      if (booking == null) return;

      boolean isConfirmed = statusMessage.toLowerCase().contains("confirm");
      String color = isConfirmed ? "#10b981" : "#ef4444";
      String statusIcon = isConfirmed ? "✅" : "⚠️";
      
      String content = """
          <h2 style="color:#1e293b;margin:0 0 12px;font-size:22px;">Visit Status Update %s</h2>
          <p style="color:#475569;font-size:16px;line-height:1.6;margin-bottom:24px;">Hi %s, there has been an update regarding your site visit for <strong>%s</strong>:</p>
          
          <div style="background:#fcfcfc;border:1px solid #e2e8f0;border-left:5px solid %s;padding:24px;border-radius:4px 12px 12px 4px;margin-bottom:24px;">
            <p style="text-transform:uppercase;font-size:11px;font-weight:700;color:#64748b;margin:0 0 8px;letter-spacing:0.05em;">New Status</p>
            <p style="margin:0;font-size:20px;font-weight:700;color:%s;">%s</p>
          </div>

          %s
          
          <div style="text-align:center;margin-top:12px;">
            <a href="%s/user/bookings" style="display:inline-block;padding:12px 28px;background:#f1f5f9;color:#475569;text-decoration:none;border-radius:8px;font-weight:600;font-size:14px;border:1px solid #e2e8f0;">View Booking History</a>
          </div>
          """.formatted(statusIcon, booking.getVisitorName(), booking.getProperty().getTitle(), color, color, statusMessage, 
            isConfirmed ? "<p style='color:#475569;font-size:14px;'>Great! We look forward to seeing you at the property. Please arrive 10 minutes early.</p>" : "<p style='color:#475569;font-size:14px;'>We apologize for the inconvenience. Please feel free to reschedule for another available time slot.</p>",
            baseUrl);

      sendEmail(booking.getVisitorEmail(), "Site Visit Update: " + booking.getProperty().getTitle(), buildBaseTemplate("Status Update", color, content));
    } catch (Exception e) { log.error("Error in status update email: {}", e.getMessage()); }
  }

  @Override
  @Async
  public void sendBookingCancellationAlertToAgent(Long bookingId) {
    try {
      com.propnexium.entity.PropertyBooking booking = bookingRepository.findByIdWithDetails(bookingId).orElse(null);
      if (booking == null) return;

      String content = """
          <h2 style="color:#1e293b;margin:0 0 12px;font-size:22px;">Visit Cancelled ❌</h2>
          <p style="color:#475569;font-size:16px;line-height:1.6;margin-bottom:24px;">The scheduled visit for <strong>%s</strong> has been cancelled by the visitor.</p>
          
          <div style="background:#fef2f2;border:1px solid #fee2e2;border-radius:12px;padding:24px;margin-bottom:24px;">
            <p style="text-transform:uppercase;font-size:11px;font-weight:700;color:#ef4444;margin:0 0 4px;letter-spacing:0.05em;">Cancelled Appointment</p>
            <p style="margin:0;font-size:16px;font-weight:600;color:#1e293b;">📅 %s at %s</p>
            <p style="margin:10px 0 0;font-size:14px;color:#64748b;">This slot has now been released and is available for other visitors.</p>
          </div>

          <div style="text-align:center;">
            <a href="%s/agent/bookings" style="display:inline-block;padding:12px 28px;background:#f1f5f9;color:#475569;text-decoration:none;border-radius:8px;font-weight:600;font-size:14px;border:1px solid #e2e8f0;">View Recent Bookings</a>
          </div>
          """.formatted(booking.getProperty().getTitle(), booking.getVisitDate(), booking.getTimeSlot(), baseUrl);

      sendEmail(booking.getProperty().getAgent().getEmail(), "Visitor Cancelled Visit: " + booking.getProperty().getTitle(), buildBaseTemplate("Cancellation", "#ef4444", content));
    } catch (Exception e) { log.error("Error in cancellation alert: {}", e.getMessage()); }
  }

  // ── Infrastructure & Helpers ───────────────────────────────────────────────

  @Override
  @Async
  public void sendContactFormEmail(String name, String email, String subject, String message) {
    String content = "New message from " + name + " (" + email + "):<br><br>" + message;
    sendEmail(fromEmail, "Contact Form: " + subject, buildBaseTemplate("New Message", "#1A73E8", content));
  }

  @Override
  @Async
  public void sendEmail(String to, String subject, String htmlBody) {
    try {
      MimeMessage message = mailSender.createMimeMessage();
      MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
      helper.setFrom(fromEmail, "PropNexium");
      helper.setTo(to);
      helper.setSubject(subject);
      helper.setText(htmlBody, true);
      mailSender.send(message);
      log.info("Email sent to {} | subject: {}", to, subject);
    } catch (Exception e) {
      log.warn("Failed to send email to {} | reason: {}", to, e.getMessage());
    }
  }

  /**
   * Builds the Premium HTML Wrapper for all emails.
   */
  private String buildBaseTemplate(String headerTitle, String headerColor, String innerContent) {
    return """
        <html><body style="font-family:'Segoe UI',Arial,sans-serif;background:#f5f5f5;padding:20px;margin:0;">
          <div style="max-width:600px;margin:0 auto;background:white;border-radius:12px;overflow:hidden;box-shadow:0 4px 25px rgba(0,0,0,0.08);">
            <div style="background:%s;padding:32px;text-align:center;">
              <h1 style="color:white;margin:0;font-size:26px;font-weight:700;letter-spacing:-0.5px;">PropNexium</h1>
              <p style="color:rgba(255,255,255,0.8);margin:6px 0 0;font-size:14px;font-weight:500;">%s</p>
            </div>
            <div style="padding:32px;">
              %s
            </div>
            <div style="background:#f8fafc;padding:24px;text-align:center;border-top:1px solid #e2e8f0;">
              <p style="color:#94a3b8;font-size:12px;margin:0;line-height:1.6;">
                PropNexium - Connecting People with Properties<br>
                This is an automated notification. Please do not reply directly.
              </p>
            </div>
          </div>
        </body></html>
        """.formatted(headerColor, headerTitle, innerContent);
  }
}
