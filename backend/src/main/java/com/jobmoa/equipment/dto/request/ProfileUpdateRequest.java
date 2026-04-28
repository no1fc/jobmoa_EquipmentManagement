package com.jobmoa.equipment.dto.request;

import jakarta.validation.constraints.NotBlank;

public record ProfileUpdateRequest(
    @NotBlank(message = "이름을 입력해주세요.")
    String name,

    String phone
) {}
