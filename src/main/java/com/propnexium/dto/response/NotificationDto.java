package com.propnexium.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO returned by the Notification REST API.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDto {
    private Long id;
    private String title;
    private String message;
    private String linkUrl;   // maps to Notification.link
    private boolean read;     // maps to Notification.isRead
    private LocalDateTime createdAt;
}
