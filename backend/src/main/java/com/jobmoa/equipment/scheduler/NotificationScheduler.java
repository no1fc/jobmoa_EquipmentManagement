package com.jobmoa.equipment.scheduler;

import com.jobmoa.equipment.domain.notification.NotificationChannel;
import com.jobmoa.equipment.domain.notification.NotificationType;
import com.jobmoa.equipment.domain.rental.Rental;
import com.jobmoa.equipment.domain.rental.RentalStatus;
import com.jobmoa.equipment.repository.RentalRepository;
import com.jobmoa.equipment.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationScheduler {

    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private final RentalRepository rentalRepository;
    private final NotificationService notificationService;

    @Scheduled(cron = "0 0 8 * * *")
    @Transactional
    public void sendRentalDueNotifications() {
        LocalDateTime now = LocalDateTime.now();

        // D-3 반납 예정 알림
        sendDueSoonNotifications(now, 3);
        // D-1 반납 예정 알림
        sendDueSoonNotifications(now, 1);
        // 연체 알림
        sendOverdueNotifications();

        log.info("반납 예정/연체 알림 스케줄러 실행 완료");
    }

    private void sendDueSoonNotifications(LocalDateTime now, int daysBeforeDue) {
        LocalDateTime start = now.plusDays(daysBeforeDue).toLocalDate().atStartOfDay();
        LocalDateTime end = start.plusDays(1);

        List<Rental> dueSoonRentals = rentalRepository.findAllWithFilters(
            RentalStatus.RENTED, null, null,
            org.springframework.data.domain.Pageable.unpaged()
        ).getContent().stream()
            .filter(r -> r.getDueDate().isAfter(start) && r.getDueDate().isBefore(end))
            .toList();

        for (Rental rental : dueSoonRentals) {
            String title = String.format("반납 D-%d: %s", daysBeforeDue, rental.getAsset().getAssetName());
            String message = String.format("%s 장비의 반납 예정일이 %s입니다.",
                rental.getAsset().getAssetName(),
                rental.getDueDate().format(DATE_FORMAT));

            notificationService.createNotification(
                rental.getBorrower(),
                NotificationType.RENTAL_DUE,
                title, message,
                NotificationChannel.IN_APP,
                rental.getRentalId()
            );
        }

        if (!dueSoonRentals.isEmpty()) {
            log.info("D-{} 반납 예정 알림 {}건 생성", daysBeforeDue, dueSoonRentals.size());
        }
    }

    private void sendOverdueNotifications() {
        List<Rental> overdueRentals = rentalRepository.findAllOverdue();

        for (Rental rental : overdueRentals) {
            String title = String.format("연체: %s", rental.getAsset().getAssetName());
            String message = String.format("%s 장비가 연체 상태입니다. 반납 예정일: %s. 즉시 반납해 주세요.",
                rental.getAsset().getAssetName(),
                rental.getDueDate().format(DATE_FORMAT));

            notificationService.createNotification(
                rental.getBorrower(),
                NotificationType.RENTAL_OVERDUE,
                title, message,
                NotificationChannel.IN_APP,
                rental.getRentalId()
            );
        }

        if (!overdueRentals.isEmpty()) {
            log.info("연체 알림 {}건 생성", overdueRentals.size());
        }
    }
}
