package com.propnexium.controller.api;

import com.propnexium.dto.response.ApiResponse;
import com.propnexium.dto.response.NotificationDto;
import com.propnexium.entity.Notification;
import com.propnexium.entity.User;
import com.propnexium.repository.NotificationRepository;
import com.propnexium.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * REST controller for real-time notification polling.
 * Base path: /api/v1/notifications
 */
@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
@Slf4j
public class NotificationApiController {

    private final NotificationRepository notificationRepository;
    private final UserService userService;

    // ─────────────────────────────────────────────────────────────────────────
    // GET /api/v1/notifications/unread-count  →  { "count": 3 }
    // ─────────────────────────────────────────────────────────────────────────
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(
            @AuthenticationPrincipal UserDetails userDetails) {

        if (userDetails == null) {
            return ResponseEntity.ok(Map.of("count", 0L));
        }
        try {
            User user = userService.findByEmail(userDetails.getUsername())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            long count = notificationRepository.countByUserIdAndIsReadFalse(user.getId());
            return ResponseEntity.ok(Map.of("count", count));
        } catch (Exception e) {
            log.debug("Could not fetch unread count: {}", e.getMessage());
            return ResponseEntity.ok(Map.of("count", 0L));
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET /api/v1/notifications/recent  →  last 5 notifications
    // ─────────────────────────────────────────────────────────────────────────
    @GetMapping("/recent")
    public ResponseEntity<ApiResponse<List<NotificationDto>>> getRecentNotifications(
            @AuthenticationPrincipal UserDetails userDetails) {

        if (userDetails == null) {
            return ResponseEntity.ok(ApiResponse.success(List.of(), "Not authenticated"));
        }
        try {
            User user = userService.findByEmail(userDetails.getUsername())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            List<Notification> notifications =
                    notificationRepository.findTop5ByUserIdOrderByCreatedAtDesc(user.getId());

            List<NotificationDto> dtos = notifications.stream()
                    .map(n -> new NotificationDto(
                            n.getId(),
                            n.getTitle(),
                            n.getMessage(),
                            n.getLink(),
                            Boolean.TRUE.equals(n.getIsRead()),
                            n.getCreatedAt()))
                    .collect(Collectors.toList());

            return ResponseEntity.ok(ApiResponse.success(dtos, "OK"));
        } catch (Exception e) {
            log.debug("Could not fetch recent notifications: {}", e.getMessage());
            return ResponseEntity.ok(ApiResponse.success(List.of(), "Error"));
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /api/v1/notifications/{id}/read
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/{id}/read")
    @Transactional
    public ResponseEntity<ApiResponse<Void>> markAsRead(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {

        if (userDetails == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }
        User user = userService.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
        notificationRepository.markAsReadForUser(id, user.getId());
        return ResponseEntity.ok(ApiResponse.success(null, "Marked as read"));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /api/v1/notifications/mark-all-read
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/mark-all-read")
    @Transactional
    public ResponseEntity<ApiResponse<Void>> markAllAsRead(
            @AuthenticationPrincipal UserDetails userDetails) {

        if (userDetails == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }
        User user = userService.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
        notificationRepository.markAllAsRead(user.getId());
        return ResponseEntity.ok(ApiResponse.success(null, "All marked as read"));
    }
}
