package com.jobmoa.equipment.repository;

import com.jobmoa.equipment.domain.notification.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    Page<Notification> findByUserUserIdAndIsRead(Long userId, Boolean isRead, Pageable pageable);

    Page<Notification> findByUserUserId(Long userId, Pageable pageable);

    @Query("SELECT COUNT(n) FROM Notification n WHERE n.user.userId = :userId AND n.isRead = false")
    long countUnreadByUserId(@Param("userId") Long userId);

    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = CURRENT_TIMESTAMP WHERE n.user.userId = :userId AND n.isRead = false")
    void markAllAsRead(@Param("userId") Long userId);
}
