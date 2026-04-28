package com.jobmoa.equipment.dto.response;

import com.jobmoa.equipment.domain.asset.Asset;
import com.jobmoa.equipment.domain.category.AssetCategory;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public record AssetDetailResponse(
    Long assetId,
    String assetCode,
    String assetName,
    String status,
    Long categoryId,
    String categoryName,
    List<String> categoryPath,
    String serialNumber,
    String manufacturer,
    String modelNumber,
    LocalDate purchaseDate,
    String location,
    String managingDepartment,
    String usingDepartment,
    Integer conditionRating,
    String technicalSpecs,
    String imagePath,
    Boolean aiClassified,
    String notes,
    String registeredByName,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
    public static AssetDetailResponse from(Asset asset) {
        return new AssetDetailResponse(
            asset.getAssetId(),
            asset.getAssetCode(),
            asset.getAssetName(),
            asset.getStatus().name(),
            asset.getCategory().getCategoryId(),
            asset.getCategory().getCategoryName(),
            buildCategoryPath(asset.getCategory()),
            asset.getSerialNumber(),
            asset.getManufacturer(),
            asset.getModelNumber(),
            asset.getPurchaseDate(),
            asset.getLocation(),
            asset.getManagingDepartment(),
            asset.getUsingDepartment(),
            asset.getConditionRating(),
            asset.getTechnicalSpecs(),
            asset.getImagePath(),
            asset.getAiClassified(),
            asset.getNotes(),
            asset.getRegisteredBy().getName(),
            asset.getCreatedAt(),
            asset.getUpdatedAt()
        );
    }

    private static List<String> buildCategoryPath(AssetCategory category) {
        List<String> path = new ArrayList<>();
        AssetCategory current = category;
        while (current != null) {
            path.add(current.getCategoryName());
            current = current.getParent();
        }
        Collections.reverse(path);
        return path;
    }
}
