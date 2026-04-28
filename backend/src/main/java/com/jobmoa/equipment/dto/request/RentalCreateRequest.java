package com.jobmoa.equipment.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record RentalCreateRequest(
    @NotNull(message = "장비를 선택해주세요.")
    Long assetId,

    Long borrowerId,

    String rentalReason,
    String borrowerName,

    @NotNull(message = "대여 기간을 입력해주세요.")
    @Min(value = 1, message = "대여 기간은 ���소 1일입니다.")
    @Max(value = 30, message = "대여 기간은 최대 30일입니다.")
    Integer dueDays
) {}
