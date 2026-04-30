package com.jobmoa.equipment.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class FcmService {

    private final FirebaseMessaging firebaseMessaging;

    @Async
    public void sendPushNotification(String fcmToken, String title, String body) {
        if (firebaseMessaging == null) {
            log.warn("FirebaseMessaging 미초기화 — 푸시 알림 전송 생략: title={}", title);
            return;
        }

        if (fcmToken == null || fcmToken.isBlank()) {
            log.debug("FCM 토큰 미등록 — 푸시 알림 전송 생략: title={}", title);
            return;
        }

        try {
            Message message = Message.builder()
                .setToken(fcmToken)
                .setNotification(Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build())
                .build();

            String messageId = firebaseMessaging.send(message);
            log.info("FCM 푸시 알림 전송 성공: messageId={}, title={}", messageId, title);
        } catch (FirebaseMessagingException e) {
            log.error("FCM 푸시 알림 전송 실패: token={}, title={}, error={}",
                fcmToken, title, e.getMessage());
        }
    }
}
