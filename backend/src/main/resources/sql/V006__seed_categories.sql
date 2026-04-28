-- V006: 초기 카테고리 데이터 (3대분류 + 8중분류 + 5소분류 = 16개)

-- 대분류 (Level 1)
SET IDENTITY_INSERT asset_categories ON;

INSERT INTO asset_categories (category_id, category_name, category_level, parent_id, description)
VALUES
    (1, N'IT 장비',     1, NULL, N'컴퓨터, 모니터, 프린터 등 IT 관련 장비'),
    (2, N'사무용 가구', 1, NULL, N'올문장, 책상, 의자, 파티션 등'),
    (3, N'소모품',      1, NULL, N'용지, 토너, 필기구 등 소모성 물품');

-- 중분류 (Level 2) - IT 장비 하위
INSERT INTO asset_categories (category_id, category_name, category_level, parent_id, description)
VALUES
    (4,  N'컴퓨터',       2, 1, N'데스크탑, 노트북 등'),
    (5,  N'모니터',       2, 1, N'LCD, LED 모니터'),
    (6,  N'프린터',       2, 1, N'레이저, 잉크젯, 복합기'),
    (7,  N'핸드폰',       2, 1, N'업무용 휴대전화'),
    (8,  N'네트워크 장비', 2, 1, N'공유기, 스위치, AP 등');

-- 중분류 (Level 2) - 사무용 가구 하위
INSERT INTO asset_categories (category_id, category_name, category_level, parent_id, description)
VALUES
    (9,  N'올문장',  2, 2, N'사무용 캐비닛/장'),
    (10, N'책상',    2, 2, N'사무용 책상'),
    (11, N'의자',    2, 2, N'사무용 의자');

-- 소분류 (Level 3) - 컴퓨터 하위
INSERT INTO asset_categories (category_id, category_name, category_level, parent_id, description)
VALUES
    (12, N'데스크탑', 3, 4,  N'데스크탑 PC'),
    (13, N'노트북',   3, 4,  N'노트북 PC');

-- 소분류 (Level 3) - 올문장 하위
INSERT INTO asset_categories (category_id, category_name, category_level, parent_id, description)
VALUES
    (14, N'5단장', 3, 9, N'5단 올문장'),
    (15, N'3단장', 3, 9, N'3단 올문장');

-- 소분류 (Level 3) - 프린터 하위
INSERT INTO asset_categories (category_id, category_name, category_level, parent_id, description)
VALUES
    (16, N'복합기', 3, 6, N'프린터/스캐너/복사 복합기');

SET IDENTITY_INSERT asset_categories OFF;
