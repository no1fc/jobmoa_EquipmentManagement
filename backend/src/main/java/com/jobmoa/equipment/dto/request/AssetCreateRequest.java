package com.jobmoa.equipment.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public record AssetCreateRequest(
    @NotNull(message = "카테고리를 선택해주세요.")
    Long categoryId,

    @NotBlank(message = "장비명을 입력해주세요.")
    String assetName,

    String serialNumber,
    String manufacturer,
    String modelNumber,
    LocalDate purchaseDate,
    String location,
    String managingDepartment,
    String usingDepartment,
    Integer conditionRating,
    String technicalSpecs,
    Boolean aiClassified,
    String notes
) {}
