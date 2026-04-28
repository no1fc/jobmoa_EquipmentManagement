package com.jobmoa.equipment.dto.response;

public record LoginResponse(
    String accessToken,
    String refreshToken,
    UserSummary user
) {
    public record UserSummary(
        Long userId,
        String email,
        String name,
        String role,
        String branchName
    ) {}
}
