package com.jobmoa.equipment.scheduler;

import com.jobmoa.equipment.domain.rental.Rental;
import com.jobmoa.equipment.repository.RentalRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class OverdueCheckScheduler {

    private final RentalRepository rentalRepository;

    @Scheduled(cron = "0 0 9 * * *")
    @Transactional
    public void checkOverdueRentals() {
        LocalDateTime now = LocalDateTime.now();
        List<Rental> overdueRentals = rentalRepository.findRentedPastDue(now);

        if (overdueRentals.isEmpty()) {
            log.info("연체 대여 없음");
            return;
        }

        for (Rental rental : overdueRentals) {
            rental.markOverdue();
            log.info("연체 처리: rentalId={}, assetName={}, borrower={}",
                rental.getRentalId(),
                rental.getAsset().getAssetName(),
                rental.getBorrower().getName());
        }

        log.info("연체 처리 완료: {}건", overdueRentals.size());
    }
}
