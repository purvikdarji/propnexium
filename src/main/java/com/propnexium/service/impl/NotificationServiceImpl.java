package com.propnexium.service.impl;

import com.propnexium.entity.Notification;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.NotificationType;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.repository.NotificationRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    @Override
    public void createNotification(Long userId, String title, String message,
            NotificationType type, String link) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));

        Notification notification = Notification.builder()
                .user(user)
                .title(title)
                .message(message)
                .type(type)
                .link(link)
                .isRead(false)
                .build();
        notificationRepository.save(notification);    }

    @Override
    @Transactional(readOnly = true)
    public List<Notification> getByUser(Long userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Override
    @Transactional(readOnly = true)
    public long countUnread(Long userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    @Override
    public void markAsRead(Long notificationId) {
        notificationRepository.markAsRead(notificationId);
    }

    @Override
    public void markAllRead(Long userId) {
        notificationRepository.markAllAsReadByUserId(userId);
    }
}
