package com.jobmoa.equipment.service;

import com.jobmoa.equipment.domain.user.User;
import com.jobmoa.equipment.dto.request.LoginRequest;
import com.jobmoa.equipment.dto.request.TokenRefreshRequest;
import com.jobmoa.equipment.dto.response.LoginResponse;
import com.jobmoa.equipment.dto.response.TokenResponse;
import com.jobmoa.equipment.exception.ErrorCode;
import com.jobmoa.equipment.exception.UnauthorizedException;
import com.jobmoa.equipment.repository.UserRepository;
import com.jobmoa.equipment.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.email())
            .orElseThrow(() -> new UnauthorizedException(ErrorCode.LOGIN_FAILED));

        if (!user.getIsActive()) {
            throw new UnauthorizedException(ErrorCode.LOGIN_FAILED);
        }

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new UnauthorizedException(ErrorCode.LOGIN_FAILED);
        }

        String accessToken = jwtTokenProvider.generateAccessToken(
            user.getUserId(), user.getEmail(), user.getRole().name());
        String refreshToken = jwtTokenProvider.generateRefreshToken(
            user.getUserId(), user.getEmail(), user.getRole().name());

        LoginResponse.UserSummary userSummary = new LoginResponse.UserSummary(
            user.getUserId(),
            user.getEmail(),
            user.getName(),
            user.getRole().name(),
            user.getBranchName()
        );

        return new LoginResponse(accessToken, refreshToken, userSummary);
    }

    public TokenResponse refresh(TokenRefreshRequest request) {
        String refreshToken = request.refreshToken();

        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new UnauthorizedException(ErrorCode.INVALID_TOKEN);
        }

        Long userId = jwtTokenProvider.getUserIdFromToken(refreshToken);
        String role = jwtTokenProvider.getRoleFromToken(refreshToken);

        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UnauthorizedException(ErrorCode.USER_NOT_FOUND));

        String newAccessToken = jwtTokenProvider.generateAccessToken(
            user.getUserId(), user.getEmail(), role);
        String newRefreshToken = jwtTokenProvider.generateRefreshToken(
            user.getUserId(), user.getEmail(), role);

        return new TokenResponse(newAccessToken, newRefreshToken);
    }
}
