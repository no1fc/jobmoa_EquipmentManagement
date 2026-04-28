package com.jobmoa.equipment.dto.response;

import com.jobmoa.equipment.domain.user.User;

import java.time.LocalDateTime;

public record UserResponse(
    Long userId,
    String email,
    String name,
    String role,
    String branchName,
    String phone,
    Boolean isActive,
    LocalDateTime createdAt
) {
    public static UserResponse from(User user) {
        return new UserResponse(
            user.getUserId(),
            user.getEmail(),
            user.getName(),
            user.getRole().name(),
            user.getBranchName(),
            user.getPhone(),
            user.getIsActive(),
            user.getCreatedAt()
        );
    }
}
