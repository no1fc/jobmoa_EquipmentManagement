package com.jobmoa.equipment.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {

    // Common
    INVALID_INPUT(HttpStatus.BAD_REQUEST, "잘못된 입력값입니다."),
    INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류가 발생했습니다."),

    // Auth
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "인증이 필요합니다."),
    ACCESS_DENIED(HttpStatus.FORBIDDEN, "접근 권한이 없습니다."),
    INVALID_TOKEN(HttpStatus.UNAUTHORIZED, "유효하지 않은 토큰입니다."),
    EXPIRED_TOKEN(HttpStatus.UNAUTHORIZED, "만료된 토큰���니다."),
    LOGIN_FAILED(HttpStatus.UNAUTHORIZED, "이메일 또는 비밀번호가 올바르지 않습니다."),

    // User
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."),
    DUPLICATE_EMAIL(HttpStatus.CONFLICT, "이미 사용 중인 이메일입���다."),
    PASSWORD_MISMATCH(HttpStatus.BAD_REQUEST, "현재 비밀번호가 올바르지 않습니다."),

    // Category
    CATEGORY_NOT_FOUND(HttpStatus.NOT_FOUND, "카테고리를 찾을 수 ��습니다."),
    CATEGORY_HAS_ASSETS(HttpStatus.CONFLICT, "연결된 자산이 있어 삭제할 수 없습니다."),
    CATEGORY_HAS_CHILDREN(HttpStatus.CONFLICT, "하위 카테고리가 있어 삭제할 수 없습니다."),

    // Asset
    ASSET_NOT_FOUND(HttpStatus.NOT_FOUND, "장비를 찾을 수 없습니��."),
    ASSET_RENTED(HttpStatus.CONFLICT, "대여 중인 장비는 삭제할 수 없습니다."),
    ASSET_NOT_AVAILABLE(HttpStatus.CONFLICT, "대여 가능한 상태가 아닙니다."),

    // Rental
    RENTAL_NOT_FOUND(HttpStatus.NOT_FOUND, "대여 정보를 찾을 수 없습니다."),
    RENTAL_ALREADY_RETURNED(HttpStatus.CONFLICT, "이미 반납된 대여입니다."),
    RENTAL_EXTENSION_EXCEEDED(HttpStatus.CONFLICT, "연장 가능 횟수를 초과했습니다."),
    RENTAL_CANCELLED(HttpStatus.CONFLICT, "취소된 대여입니다."),

    // Notification
    NOTIFICATION_NOT_FOUND(HttpStatus.NOT_FOUND, "알림을 찾을 수 없습니다."),

    // File
    FILE_UPLOAD_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "파일 업로드에 실패했습니다."),
    FILE_INVALID_EXTENSION(HttpStatus.BAD_REQUEST, "허용되지 않는 파일 형식입니다."),
    FILE_SIZE_EXCEEDED(HttpStatus.BAD_REQUEST, "���일 크기가 제한을 초과했습니다.");

    private final HttpStatus httpStatus;
    private final String message;
}
