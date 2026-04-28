package com.jobmoa.equipment.service;

import com.jobmoa.equipment.domain.asset.Asset;
import com.jobmoa.equipment.domain.asset.AssetStatus;
import com.jobmoa.equipment.domain.rental.Rental;
import com.jobmoa.equipment.domain.rental.RentalStatus;
import com.jobmoa.equipment.domain.user.User;
import com.jobmoa.equipment.dto.request.RentalCreateRequest;
import com.jobmoa.equipment.dto.request.RentalExtendRequest;
import com.jobmoa.equipment.dto.request.RentalReturnRequest;
import com.jobmoa.equipment.dto.response.RentalDashboardResponse;
import com.jobmoa.equipment.dto.response.RentalResponse;
import com.jobmoa.equipment.exception.BusinessException;
import com.jobmoa.equipment.exception.ErrorCode;
import com.jobmoa.equipment.exception.NotFoundException;
import com.jobmoa.equipment.repository.AssetRepository;
import com.jobmoa.equipment.repository.RentalRepository;
import com.jobmoa.equipment.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RentalService {

    private final RentalRepository rentalRepository;
    private final AssetRepository assetRepository;
    private final UserRepository userRepository;

    public Page<RentalResponse> getRentals(RentalStatus status, Long borrowerId,
                                            Long assetId, Pageable pageable) {
        return rentalRepository.findAllWithFilters(status, borrowerId, assetId, pageable)
            .map(RentalResponse::from);
    }

    public RentalResponse getRental(Long rentalId) {
        Rental rental = findRentalById(rentalId);
        return RentalResponse.from(rental);
    }

    @Transactional
    public RentalResponse createRental(RentalCreateRequest request, Long currentUserId) {
        Asset asset = assetRepository.findById(request.assetId())
            .orElseThrow(() -> new NotFoundException(ErrorCode.ASSET_NOT_FOUND));

        if (!asset.isAvailableForRental()) {
            throw new BusinessException(ErrorCode.ASSET_NOT_AVAILABLE);
        }

        Long borrowerId = request.borrowerId() != null ? request.borrowerId() : currentUserId;
        User borrower = userRepository.findById(borrowerId)
            .orElseThrow(() -> new NotFoundException(ErrorCode.USER_NOT_FOUND));

        LocalDateTime dueDate = LocalDateTime.now().plusDays(request.dueDays());

        Rental rental = Rental.builder()
            .asset(asset)
            .borrower(borrower)
            .rentalReason(request.rentalReason())
            .borrowerName(request.borrowerName())
            .dueDate(dueDate)
            .build();

        asset.changeStatus(AssetStatus.RENTED);
        Rental saved = rentalRepository.save(rental);

        return RentalResponse.from(saved);
    }

    @Transactional
    public RentalResponse returnRental(Long rentalId, RentalReturnRequest request) {
        Rental rental = findRentalById(rentalId);

        if (!rental.isActive()) {
            throw new BusinessException(ErrorCode.RENTAL_ALREADY_RETURNED);
        }

        rental.returnAsset(request != null ? request.returnCondition() : null);
        rental.getAsset().changeStatus(AssetStatus.IN_USE);

        return RentalResponse.from(rental);
    }

    @Transactional
    public RentalResponse extendRental(Long rentalId, RentalExtendRequest request) {
        Rental rental = findRentalById(rentalId);

        if (!rental.canExtend()) {
            throw new BusinessException(ErrorCode.RENTAL_EXTENSION_EXCEEDED);
        }

        rental.extend(request.extensionDays());
        return RentalResponse.from(rental);
    }

    @Transactional
    public RentalResponse cancelRental(Long rentalId) {
        Rental rental = findRentalById(rentalId);

        if (rental.getStatus() == RentalStatus.RETURNED) {
            throw new BusinessException(ErrorCode.RENTAL_ALREADY_RETURNED);
        }
        if (rental.getStatus() == RentalStatus.CANCELLED) {
            throw new BusinessException(ErrorCode.RENTAL_CANCELLED);
        }

        rental.cancel();
        rental.getAsset().changeStatus(AssetStatus.IN_USE);

        return RentalResponse.from(rental);
    }

    public RentalDashboardResponse getDashboard() {
        long totalActive = rentalRepository.countByStatus(RentalStatus.RENTED)
            + rentalRepository.countByStatus(RentalStatus.OVERDUE);
        long overdueCount = rentalRepository.countByStatus(RentalStatus.OVERDUE);

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime threeDaysLater = now.plusDays(3);
        long dueSoon = rentalRepository.countDueSoon(now, threeDaysLater);

        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        long returnedToday = rentalRepository.countReturnedToday(todayStart);

        return new RentalDashboardResponse(totalActive, overdueCount, dueSoon, returnedToday);
    }

    public List<RentalResponse> getOverdueRentals() {
        return rentalRepository.findAllOverdue().stream()
            .map(RentalResponse::from)
            .toList();
    }

    public List<RentalResponse> getAssetRentalHistory(Long assetId) {
        return rentalRepository.findByAssetId(assetId).stream()
            .map(RentalResponse::from)
            .toList();
    }

    private Rental findRentalById(Long rentalId) {
        return rentalRepository.findById(rentalId)
            .orElseThrow(() -> new NotFoundException(ErrorCode.RENTAL_NOT_FOUND));
    }
}
