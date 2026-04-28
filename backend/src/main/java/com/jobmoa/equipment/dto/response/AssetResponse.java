package com.jobmoa.equipment.dto.response;

import com.jobmoa.equipment.domain.asset.Asset;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record AssetResponse(
    Long assetId,
    String assetCode,
    String assetName,
    String status,
    String categoryName,
    Long categoryId,
    String location,
    String managingDepartment,
    String usingDepartment,
    String manufacturer,
    String modelNumber,
    LocalDate purchaseDate,
    String imagePath,
    Boolean aiClassified,
    LocalDateTime createdAt
) {
    public static AssetResponse from(Asset asset) {
        return new AssetResponse(
            asset.getAssetId(),
            asset.getAssetCode(),
            asset.getAssetName(),
            asset.getStatus().name(),
            asset.getCategory().getCategoryName(),
            asset.getCategory().getCategoryId(),
            asset.getLocation(),
            asset.getManagingDepartment(),
            asset.getUsingDepartment(),
            asset.getManufacturer(),
            asset.getModelNumber(),
            asset.getPurchaseDate(),
            asset.getImagePath(),
            asset.getAiClassified(),
            asset.getCreatedAt()
        );
    }
}
