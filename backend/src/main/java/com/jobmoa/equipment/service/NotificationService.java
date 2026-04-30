package com.jobmoa.equipment.service;

import com.jobmoa.equipment.domain.notification.Notification;
import com.jobmoa.equipment.domain.notification.NotificationChannel;
import com.jobmoa.equipment.domain.notification.NotificationType;
import com.jobmoa.equipment.domain.user.User;
import com.jobmoa.equipment.dto.response.NotificationResponse;
import com.jobmoa.equipment.dto.response.UnreadCountResponse;
import com.jobmoa.equipment.exception.ErrorCode;
import com.jobmoa.equipment.exception.NotFoundException;
import com.jobmoa.equipment.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final FcmService fcmService;

    public Page<NotificationResponse> getNotifications(Long userId, Boolean isRead, Pageable pageable) {
        Page<Notification> notifications = (isRead != null)
            ? notificationRepository.findByUserUserIdAndIsRead(userId, isRead, pageable)
            : notificationRepository.findByUserUserId(userId, pageable);

        return notifications.map(NotificationResponse::from);
    }

    public UnreadCountResponse getUnreadCount(Long userId) {
        long count = notificationRepository.countUnreadByUserId(userId);
        return new UnreadCountResponse(count);
    }

    @Transactional
    public void markAsRead(Long notificationId, Long userId) {
        Notification notification = notificationRepository.findById(notificationId)
            .orElseThrow(() -> new NotFoundException(ErrorCode.NOTIFICATION_NOT_FOUND));

        if (!notification.getUser().getUserId().equals(userId)) {
            throw new NotFoundException(ErrorCode.NOTIFICATION_NOT_FOUND);
        }

        notification.markAsRead();
    }

    @Transactional
    public void markAllAsRead(Long userId) {
        notificationRepository.markAllAsRead(userId);
    }

    @Transactional
    public void createNotification(User user, NotificationType type, String title,
                                    String message, NotificationChannel channel, Long referenceId) {
        Notification notification = Notification.builder()
            .user(user)
            .type(type)
            .title(title)
            .message(message)
            .channel(channel)
            .referenceId(referenceId)
            .build();

        notificationRepository.save(notification);
        log.info("알림 생성: userId={}, type={}, title={}", user.getUserId(), type, title);

        // PUSH 채널이거나 IN_APP일 때도 FCM 토큰이 있으면 푸시 전송
        if (user.getFcmToken() != null && !user.getFcmToken().isBlank()) {
            fcmService.sendPushNotification(user.getFcmToken(), title, message);
        }
    }
}
