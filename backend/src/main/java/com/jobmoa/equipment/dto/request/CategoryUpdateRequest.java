package com.jobmoa.equipment.dto.request;

import jakarta.validation.constraints.NotBlank;

public record CategoryUpdateRequest(
    @NotBlank(message = "카테고리명을 입력해주세요.")
    String categoryName,

    String description
) {}
