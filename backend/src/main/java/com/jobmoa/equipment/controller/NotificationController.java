package com.jobmoa.equipment.controller;

import com.jobmoa.equipment.dto.response.ApiResponse;
import com.jobmoa.equipment.dto.response.NotificationResponse;
import com.jobmoa.equipment.dto.response.PageResponse;
import com.jobmoa.equipment.dto.response.UnreadCountResponse;
import com.jobmoa.equipment.security.CustomUserDetails;
import com.jobmoa.equipment.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Notification", description = "알림 API")
@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @Operation(summary = "내 알림 목록")
    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<NotificationResponse>>> getNotifications(
        @AuthenticationPrincipal CustomUserDetails userDetails,
        @RequestParam(required = false) Boolean isRead,
        @PageableDefault(size = 20, sort = "sentAt", direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            PageResponse.from(notificationService.getNotifications(userDetails.getUserId(), isRead, pageable))));
    }

    @Operation(summary = "읽지 않은 알림 수")
    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<UnreadCountResponse>> getUnreadCount(
        @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            notificationService.getUnreadCount(userDetails.getUserId())));
    }

    @Operation(summary = "알림 읽음 처리")
    @PutMapping("/{id}/read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(
        @PathVariable Long id,
        @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        notificationService.markAsRead(id, userDetails.getUserId());
        return ResponseEntity.ok(ApiResponse.ok(null, "알림을 읽음 처리했습니다."));
    }

    @Operation(summary = "전체 읽음 처리")
    @PutMapping("/read-all")
    public ResponseEntity<ApiResponse<Void>> markAllAsRead(
        @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        notificationService.markAllAsRead(userDetails.getUserId());
        return ResponseEntity.ok(ApiResponse.ok(null, "모든 알림을 읽음 처리했습니다."));
    }
}
