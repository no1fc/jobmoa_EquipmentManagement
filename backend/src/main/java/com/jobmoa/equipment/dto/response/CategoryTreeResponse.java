package com.jobmoa.equipment.dto.response;

import com.jobmoa.equipment.domain.category.AssetCategory;

import java.util.List;

public record CategoryTreeResponse(
    Long categoryId,
    String categoryName,
    Integer categoryLevel,
    String description,
    List<CategoryTreeResponse> children
) {
    public static CategoryTreeResponse from(AssetCategory category) {
        List<CategoryTreeResponse> childResponses = category.getChildren().stream()
            .map(CategoryTreeResponse::from)
            .toList();

        return new CategoryTreeResponse(
            category.getCategoryId(),
            category.getCategoryName(),
            category.getCategoryLevel(),
            category.getDescription(),
            childResponses
        );
    }
}
