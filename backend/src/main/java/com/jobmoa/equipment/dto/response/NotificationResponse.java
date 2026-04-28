package com.jobmoa.equipment.dto.response;

import com.jobmoa.equipment.domain.notification.Notification;

import java.time.LocalDateTime;

public record NotificationResponse(
    Long notificationId,
    String type,
    String title,
    String message,
    Boolean isRead,
    String channel,
    Long referenceId,
    LocalDateTime sentAt,
    LocalDateTime readAt
) {
    public static NotificationResponse from(Notification notification) {
        return new NotificationResponse(
            notification.getNotificationId(),
            notification.getType().name(),
            notification.getTitle(),
            notification.getMessage(),
            notification.getIsRead(),
            notification.getChannel().name(),
            notification.getReferenceId(),
            notification.getSentAt(),
            notification.getReadAt()
        );
    }
}
