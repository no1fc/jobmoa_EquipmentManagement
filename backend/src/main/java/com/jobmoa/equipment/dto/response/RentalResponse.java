package com.jobmoa.equipment.dto.response;

import com.jobmoa.equipment.domain.rental.Rental;

import java.time.LocalDateTime;

public record RentalResponse(
    Long rentalId,
    Long assetId,
    String assetName,
    String assetCode,
    Long borrowerId,
    String borrowerEmail,
    String borrowerName,
    String rentalReason,
    LocalDateTime rentalDate,
    LocalDateTime dueDate,
    LocalDateTime returnDate,
    String status,
    Integer extensionCount,
    String returnCondition
) {
    public static RentalResponse from(Rental rental) {
        return new RentalResponse(
            rental.getRentalId(),
            rental.getAsset().getAssetId(),
            rental.getAsset().getAssetName(),
            rental.getAsset().getAssetCode(),
            rental.getBorrower().getUserId(),
            rental.getBorrower().getEmail(),
            rental.getBorrowerName() != null ? rental.getBorrowerName() : rental.getBorrower().getName(),
            rental.getRentalReason(),
            rental.getRentalDate(),
            rental.getDueDate(),
            rental.getReturnDate(),
            rental.getStatus().name(),
            rental.getExtensionCount(),
            rental.getReturnCondition()
        );
    }
}
