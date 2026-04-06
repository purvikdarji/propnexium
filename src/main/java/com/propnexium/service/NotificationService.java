package com.propnexium.service;

import com.propnexium.entity.Notification;
import com.propnexium.entity.enums.NotificationType;

import java.util.List;

/**
 * Service interface for Notification operations.
 */
public interface NotificationService {

    /**
     * Create and persist a notification for the given user.
     *
     * @param userId  target user
     * @param title   short notification title
     * @param message full notification body
     * @param type    {@link NotificationType}
     * @param link    optional deep-link URL (may be null)
     */
    void createNotification(Long userId, String title, String message,
            NotificationType type, String link);

    /**
     * Retrieve all notifications for a user, newest first.
     */
    List<Notification> getByUser(Long userId);

    /**
     * Count unread notifications for a user.
     */
    long countUnread(Long userId);

    /**
     * Mark a single notification as read.
     */
    void markAsRead(Long notificationId);

    /**
     * Mark all notifications for a user as read.
     */
    void markAllRead(Long userId);
}
