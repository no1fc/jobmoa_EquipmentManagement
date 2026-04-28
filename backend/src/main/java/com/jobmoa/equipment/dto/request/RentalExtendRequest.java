package com.jobmoa.equipment.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record RentalExtendRequest(
    @NotNull(message = "연장 기간을 입력해주세요.")
    @Min(value = 1, message = "연장 기간은 최소 1일입니다.")
    @Max(value = 14, message = "연장 기간은 최대 14일입니다.")
    Integer extensionDays
) {}
