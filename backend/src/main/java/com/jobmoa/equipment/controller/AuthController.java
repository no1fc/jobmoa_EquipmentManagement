package com.jobmoa.equipment.controller;

import com.jobmoa.equipment.dto.request.LoginRequest;
import com.jobmoa.equipment.dto.request.TokenRefreshRequest;
import com.jobmoa.equipment.dto.response.ApiResponse;
import com.jobmoa.equipment.dto.response.LoginResponse;
import com.jobmoa.equipment.dto.response.TokenResponse;
import com.jobmoa.equipment.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Auth", description = "인증 API")
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "로그인")
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "토큰 갱신")
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<TokenResponse>> refresh(@Valid @RequestBody TokenRefreshRequest request) {
        TokenResponse response = authService.refresh(request);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "로그아웃")
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout() {
        return ResponseEntity.ok(ApiResponse.ok(null, "로그아웃되었습니다."));
    }
}
