package com.jobmoa.equipment.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CategoryCreateRequest(
    Long parentId,

    @NotBlank(message = "카테고리명을 입력해주세요.")
    String categoryName,

    @NotNull(message = "카테고리 레벨을 입력해주세요.")
    @Min(value = 1, message = "카테고리 레벨은 1~3입니다.")
    @Max(value = 3, message = "카테고리 레벨은 1~3입니다.")
    Integer categoryLevel,

    String description
) {}
