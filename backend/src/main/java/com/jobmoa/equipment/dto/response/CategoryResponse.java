package com.jobmoa.equipment.dto.response;

import com.jobmoa.equipment.domain.category.AssetCategory;

import java.time.LocalDateTime;

public record CategoryResponse(
    Long categoryId,
    Long parentId,
    String categoryName,
    Integer categoryLevel,
    String description,
    LocalDateTime createdAt
) {
    public static CategoryResponse from(AssetCategory category) {
        return new CategoryResponse(
            category.getCategoryId(),
            category.getParent() != null ? category.getParent().getCategoryId() : null,
            category.getCategoryName(),
            category.getCategoryLevel(),
            category.getDescription(),
            category.getCreatedAt()
        );
    }
}
