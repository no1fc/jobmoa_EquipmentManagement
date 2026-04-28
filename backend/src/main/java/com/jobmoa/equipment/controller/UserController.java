package com.jobmoa.equipment.controller;

import com.jobmoa.equipment.domain.user.Role;
import com.jobmoa.equipment.dto.request.PasswordChangeRequest;
import com.jobmoa.equipment.dto.request.ProfileUpdateRequest;
import com.jobmoa.equipment.dto.request.UserCreateRequest;
import com.jobmoa.equipment.dto.request.UserUpdateRequest;
import com.jobmoa.equipment.dto.response.ApiResponse;
import com.jobmoa.equipment.dto.response.PageResponse;
import com.jobmoa.equipment.dto.response.UserResponse;
import com.jobmoa.equipment.security.CustomUserDetails;
import com.jobmoa.equipment.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "User", description = "사용자 관리 API")
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @Operation(summary = "사용자 목록 조회")
    @PreAuthorize("hasRole('MANAGER')")
    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<UserResponse>>> getUsers(
        @RequestParam(required = false) Role role,
        @RequestParam(required = false) String search,
        @PageableDefault(size = 20) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            PageResponse.from(userService.getUsers(role, search, pageable))));
    }

    @Operation(summary = "사용자 상세 조회")
    @PreAuthorize("hasRole('MANAGER')")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(userService.getUser(id)));
    }

    @Operation(summary = "사용자 생성")
    @PreAuthorize("hasRole('MANAGER')")
    @PostMapping
    public ResponseEntity<ApiResponse<UserResponse>> createUser(
        @Valid @RequestBody UserCreateRequest request
    ) {
        UserResponse response = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(response));
    }

    @Operation(summary = "사용자 수정")
    @PreAuthorize("hasRole('MANAGER')")
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> updateUser(
        @PathVariable Long id,
        @Valid @RequestBody UserUpdateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.ok(userService.updateUser(id, request)));
    }

    @Operation(summary = "사용자 비활성화")
    @PreAuthorize("hasRole('MANAGER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.ok(ApiResponse.ok(null, "사용자가 비활성화되었습니다."));
    }

    @Operation(summary = "내 프로필 조회")
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getMyProfile(
        @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        return ResponseEntity.ok(ApiResponse.ok(userService.getMyProfile(userDetails.getUserId())));
    }

    @Operation(summary = "내 프로필 수정")
    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> updateMyProfile(
        @AuthenticationPrincipal CustomUserDetails userDetails,
        @Valid @RequestBody ProfileUpdateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            userService.updateMyProfile(userDetails.getUserId(), request)));
    }

    @Operation(summary = "비밀번호 변경")
    @PutMapping("/me/password")
    public ResponseEntity<ApiResponse<Void>> changePassword(
        @AuthenticationPrincipal CustomUserDetails userDetails,
        @Valid @RequestBody PasswordChangeRequest request
    ) {
        userService.changePassword(userDetails.getUserId(), request);
        return ResponseEntity.ok(ApiResponse.ok(null, "비밀번호가 변경되었습니다."));
    }
}
