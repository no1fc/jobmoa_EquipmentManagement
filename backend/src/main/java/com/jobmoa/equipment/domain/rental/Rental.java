package com.jobmoa.equipment.domain.rental;

import com.jobmoa.equipment.domain.BaseTimeEntity;
import com.jobmoa.equipment.domain.asset.Asset;
import com.jobmoa.equipment.domain.user.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "rentals")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Rental extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "rental_id")
    private Long rentalId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "asset_id", nullable = false)
    private Asset asset;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "borrower_id", nullable = false)
    private User borrower;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approver_id")
    private User approver;

    @Column(name = "rental_reason", length = 500)
    private String rentalReason;

    @Column(name = "borrower_name", length = 100)
    private String borrowerName;

    @Column(name = "rental_date", nullable = false)
    private LocalDateTime rentalDate;

    @Column(name = "due_date", nullable = false)
    private LocalDateTime dueDate;

    @Column(name = "return_date")
    private LocalDateTime returnDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private RentalStatus status;

    @Column(name = "extension_count", nullable = false)
    private Integer extensionCount;

    @Column(name = "return_condition", length = 500)
    private String returnCondition;

    @Builder
    private Rental(Asset asset, User borrower, User approver,
                   String rentalReason, String borrowerName,
                   LocalDateTime dueDate) {
        this.asset = asset;
        this.borrower = borrower;
        this.approver = approver;
        this.rentalReason = rentalReason;
        this.borrowerName = borrowerName;
        this.rentalDate = LocalDateTime.now();
        this.dueDate = dueDate;
        this.status = RentalStatus.RENTED;
        this.extensionCount = 0;
    }

    public void returnAsset(String returnCondition) {
        this.returnDate = LocalDateTime.now();
        this.returnCondition = returnCondition;
        this.status = RentalStatus.RETURNED;
    }

    public void extend(int extensionDays) {
        this.dueDate = this.dueDate.plusDays(extensionDays);
        this.extensionCount++;
    }

    public void cancel() {
        this.status = RentalStatus.CANCELLED;
    }

    public void markOverdue() {
        this.status = RentalStatus.OVERDUE;
    }

    public boolean canExtend() {
        return this.extensionCount < 1
            && (this.status == RentalStatus.RENTED || this.status == RentalStatus.OVERDUE);
    }

    public boolean isActive() {
        return this.status == RentalStatus.RENTED || this.status == RentalStatus.OVERDUE;
    }
}
