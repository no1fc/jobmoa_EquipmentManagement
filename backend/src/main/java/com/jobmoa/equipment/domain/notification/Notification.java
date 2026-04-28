package com.jobmoa.equipment.domain.notification;

import com.jobmoa.equipment.domain.user.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_id")
    private Long notificationId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, length = 50)
    private NotificationType type;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "message", columnDefinition = "NVARCHAR(MAX)")
    private String message;

    @Column(name = "is_read", nullable = false)
    private Boolean isRead;

    @Enumerated(EnumType.STRING)
    @Column(name = "channel", nullable = false, length = 20)
    private NotificationChannel channel;

    @Column(name = "reference_id")
    private Long referenceId;

    @Column(name = "sent_at", nullable = false)
    private LocalDateTime sentAt;

    @Column(name = "read_at")
    private LocalDateTime readAt;

    @Builder
    private Notification(User user, NotificationType type, String title,
                         String message, NotificationChannel channel, Long referenceId) {
        this.user = user;
        this.type = type;
        this.title = title;
        this.message = message;
        this.isRead = false;
        this.channel = channel != null ? channel : NotificationChannel.IN_APP;
        this.referenceId = referenceId;
        this.sentAt = LocalDateTime.now();
    }

    public void markAsRead() {
        this.isRead = true;
        this.readAt = LocalDateTime.now();
    }
}
