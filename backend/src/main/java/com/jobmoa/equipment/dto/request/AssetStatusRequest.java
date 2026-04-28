package com.jobmoa.equipment.dto.request;

import jakarta.validation.constraints.NotBlank;

public record AssetStatusRequest(
    @NotBlank(message = "상태를 선택해주세요.")
    String status
) {}
