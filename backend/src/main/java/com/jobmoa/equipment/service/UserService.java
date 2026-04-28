package com.jobmoa.equipment.service;

import com.jobmoa.equipment.domain.user.Role;
import com.jobmoa.equipment.domain.user.User;
import com.jobmoa.equipment.dto.request.PasswordChangeRequest;
import com.jobmoa.equipment.dto.request.ProfileUpdateRequest;
import com.jobmoa.equipment.dto.request.UserCreateRequest;
import com.jobmoa.equipment.dto.request.UserUpdateRequest;
import com.jobmoa.equipment.dto.response.UserResponse;
import com.jobmoa.equipment.exception.BusinessException;
import com.jobmoa.equipment.exception.DuplicateException;
import com.jobmoa.equipment.exception.ErrorCode;
import com.jobmoa.equipment.exception.NotFoundException;
import com.jobmoa.equipment.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public Page<UserResponse> getUsers(Role role, String search, Pageable pageable) {
        return userRepository.findAllWithFilters(role, search, pageable)
            .map(UserResponse::from);
    }

    public UserResponse getUser(Long userId) {
        User user = findUserById(userId);
        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse createUser(UserCreateRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new DuplicateException(ErrorCode.DUPLICATE_EMAIL);
        }

        User user = User.builder()
            .email(request.email())
            .passwordHash(passwordEncoder.encode(request.password()))
            .name(request.name())
            .role(Role.valueOf(request.role()))
            .branchName(request.branchName())
            .phone(request.phone())
            .build();

        User saved = userRepository.save(user);
        return UserResponse.from(saved);
    }

    @Transactional
    public UserResponse updateUser(Long userId, UserUpdateRequest request) {
        User user = findUserById(userId);
        user.updateProfile(request.name(), request.phone());

        if (request.role() != null) {
            user.updateRole(Role.valueOf(request.role()));
        }

        return UserResponse.from(user);
    }

    @Transactional
    public void deleteUser(Long userId) {
        User user = findUserById(userId);
        user.deactivate();
    }

    public UserResponse getMyProfile(Long userId) {
        return getUser(userId);
    }

    @Transactional
    public UserResponse updateMyProfile(Long userId, ProfileUpdateRequest request) {
        User user = findUserById(userId);
        user.updateProfile(request.name(), request.phone());
        return UserResponse.from(user);
    }

    @Transactional
    public void changePassword(Long userId, PasswordChangeRequest request) {
        User user = findUserById(userId);

        if (!passwordEncoder.matches(request.currentPassword(), user.getPasswordHash())) {
            throw new BusinessException(ErrorCode.PASSWORD_MISMATCH);
        }

        user.updatePassword(passwordEncoder.encode(request.newPassword()));
    }

    private User findUserById(Long userId) {
        return userRepository.findById(userId)
            .orElseThrow(() -> new NotFoundException(ErrorCode.USER_NOT_FOUND));
    }
}
