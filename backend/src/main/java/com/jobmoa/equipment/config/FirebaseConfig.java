package com.jobmoa.equipment.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.FileInputStream;
import java.io.IOException;

@Slf4j
@Configuration
public class FirebaseConfig {

    @Value("${firebase.service-account-path:}")
    private String serviceAccountPath;

    @PostConstruct
    public void initialize() {
        if (FirebaseApp.getApps().isEmpty()) {
            try {
                FirebaseOptions options;
                if (serviceAccountPath != null && !serviceAccountPath.isBlank()) {
                    options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(
                            new FileInputStream(serviceAccountPath)))
                        .build();
                    log.info("Firebase 초기화 완료 (서비스 계정 파일: {})", serviceAccountPath);
                } else {
                    options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.getApplicationDefault())
                        .build();
                    log.info("Firebase 초기화 완료 (기본 자격 증명)");
                }
                FirebaseApp.initializeApp(options);
            } catch (IOException e) {
                log.warn("Firebase 초기화 실패 — FCM 푸시 알림이 비활성화됩니다: {}", e.getMessage());
            }
        }
    }

    @Bean
    public FirebaseMessaging firebaseMessaging() {
        if (FirebaseApp.getApps().isEmpty()) {
            log.warn("FirebaseApp 미초기화 — FirebaseMessaging Bean 생성 불가");
            return null;
        }
        return FirebaseMessaging.getInstance();
    }
}
