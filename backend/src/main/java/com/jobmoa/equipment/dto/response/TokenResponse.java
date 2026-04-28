package com.jobmoa.equipment.dto.response;

public record TokenResponse(
    String accessToken,
    String refreshToken
) {}
