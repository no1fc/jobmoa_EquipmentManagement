package com.jobmoa.equipment.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class FcmService {

    public void sendPushNotification(String fcmToken, String title, String body) {
        // TODO: Phase C6에서 Firebase Admin SDK�� 구현
        log.info("FCM 푸시 알림 (stub): token={}, title={}, body={}", fcmToken, title, body);
    }
}
