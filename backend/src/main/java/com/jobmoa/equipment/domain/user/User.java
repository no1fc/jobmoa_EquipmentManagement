package com.jobmoa.equipment.domain.user;

import com.jobmoa.equipment.domain.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;

    @Column(name = "email", nullable = false, unique = true, length = 255)
    private String email;

    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false, length = 20)
    private Role role;

    @Column(name = "branch_name", length = 100)
    private String branchName;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "fcm_token", length = 500)
    private String fcmToken;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive;

    @Builder
    private User(String email, String passwordHash, String name, Role role,
                 String branchName, String phone) {
        this.email = email;
        this.passwordHash = passwordHash;
        this.name = name;
        this.role = role;
        this.branchName = branchName;
        this.phone = phone;
        this.isActive = true;
    }

    public void updateProfile(String name, String phone) {
        this.name = name;
        this.phone = phone;
    }

    public void updatePassword(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public void updateRole(Role role) {
        this.role = role;
    }

    public void updateFcmToken(String fcmToken) {
        this.fcmToken = fcmToken;
    }

    public void deactivate() {
        this.isActive = false;
    }

    public void activate() {
        this.isActive = true;
    }
}
