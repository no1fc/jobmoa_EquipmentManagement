-- V009: 테스트 데이터 시드
-- 웹 UI 테스트를 위한 임시 데이터 (사용자, 장비, 대여, 알림)
-- 모든 테스트 계정 비밀번호: test1234!

-- ============================================================
-- 1. 사용자 (Users) — 5명 추가
-- ============================================================
-- BCrypt hash of 'test1234!' (strength 10)
-- 해시값: $2a$10$ZYtP8/bxMMqYISqQn17i1uryu.U8nuD1OQLSSVZOk119h6gC.6tE.
-- (Spring Security BCryptPasswordEncoder strength=10으로 생성)

INSERT INTO users (email, password_hash, name, role, branch_name, phone, is_active)
VALUES
    (N'manager.kim@jobmoa.com',
     '$2a$10$ZYtP8/bxMMqYISqQn17i1uryu.U8nuD1OQLSSVZOk119h6gC.6tE.',
     N'김지점장', 'MANAGER', N'강남지점', '010-1234-5678', 1),

    (N'counselor.lee@jobmoa.com',
     '$2a$10$ZYtP8/bxMMqYISqQn17i1uryu.U8nuD1OQLSSVZOk119h6gC.6tE.',
     N'이상담', 'COUNSELOR', N'강남지점', '010-2345-6789', 1),

    (N'counselor.park@jobmoa.com',
     '$2a$10$ZYtP8/bxMMqYISqQn17i1uryu.U8nuD1OQLSSVZOk119h6gC.6tE.',
     N'박상담', 'COUNSELOR', N'서초지점', '010-3456-7890', 1),

    (N'counselor.choi@jobmoa.com',
     '$2a$10$ZYtP8/bxMMqYISqQn17i1uryu.U8nuD1OQLSSVZOk119h6gC.6tE.',
     N'최상담', 'COUNSELOR', N'강남지점', '010-4567-8901', 1),

    (N'counselor.jung@jobmoa.com',
     '$2a$10$ZYtP8/bxMMqYISqQn17i1uryu.U8nuD1OQLSSVZOk119h6gC.6tE.',
     N'정상담', 'COUNSELOR', N'서초지점', '010-5678-9012', 1);

-- 사용자 ID 참조 (V007 관리자 = 1, 김지점장 = 2, 이상담 = 3, 박상담 = 4, 최상담 = 5, 정상담 = 6)

-- ============================================================
-- 2. 장비 (Assets) — 20개
-- ============================================================
-- 카테고리 ID 참조:
--   4=컴퓨터, 5=모니터, 6=프린터, 7=핸드폰, 8=네트워크장비
--   10=책상, 11=의자, 12=데스크탑, 13=노트북, 14=5단장, 15=3단장, 16=복합기

-- IT 장비 - 데스크탑 (카테고리 12)
INSERT INTO assets (asset_code, category_id, asset_name, serial_number, manufacturer, model_number, purchase_date, location, managing_department, using_department, status, condition_rating, technical_specs, ai_classified, notes, registered_by)
VALUES
    (N'AST-202604-001', 12, N'델 데스크탑 PC-01', N'DSK-2024-A001', N'Dell', N'OptiPlex 7020', '2024-03-15', N'강남지점 1층', N'IT관리팀', N'상담1팀', 'IN_USE', 5,
     N'{"cpu":"Intel i7-14700","ram":"32GB DDR5","storage":"512GB NVMe SSD","os":"Windows 11 Pro"}', 0, N'신규 구매 장비', 1),

    (N'AST-202604-002', 12, N'델 데스크탑 PC-02', N'DSK-2024-A002', N'Dell', N'OptiPlex 7020', '2024-03-15', N'강남지점 1층', N'IT관리팀', N'상담2팀', 'RENTED', 4,
     N'{"cpu":"Intel i7-14700","ram":"32GB DDR5","storage":"512GB NVMe SSD","os":"Windows 11 Pro"}', 0, N'이상담에게 대여중', 1);

-- IT 장비 - 노트북 (카테고리 13)
INSERT INTO assets (asset_code, category_id, asset_name, serial_number, manufacturer, model_number, purchase_date, location, managing_department, using_department, status, condition_rating, technical_specs, ai_classified, notes, registered_by)
VALUES
    (N'AST-202604-003', 13, N'LG 노트북 그램-01', N'NBK-2024-B001', N'LG', N'16Z90S-G.AA7BK', '2024-06-01', N'강남지점 2층', N'IT관리팀', N'상담1팀', 'IN_USE', 5,
     N'{"cpu":"Intel Ultra 7 155H","ram":"16GB LPDDR5x","storage":"512GB NVMe","display":"16인치 WQXGA","weight":"1.19kg"}', 0, NULL, 2),

    (N'AST-202604-004', 13, N'LG 노트북 그램-02', N'NBK-2024-B002', N'LG', N'16Z90S-G.AA7BK', '2024-06-01', N'서초지점 1층', N'IT관리팀', N'상담3팀', 'RENTED', 4,
     N'{"cpu":"Intel Ultra 7 155H","ram":"16GB LPDDR5x","storage":"512GB NVMe","display":"16인치 WQXGA","weight":"1.19kg"}', 0, N'박상담에게 대여중', 2),

    (N'AST-202604-005', 13, N'삼성 노트북 갤럭시북-01', N'NBK-2023-C001', N'Samsung', N'NT960XFH-XD72G', '2023-09-20', N'서초지점 1층', N'IT관리팀', N'상담4팀', 'BROKEN', 2,
     N'{"cpu":"Intel i7-13700H","ram":"16GB DDR5","storage":"512GB NVMe","display":"16인치 AMOLED"}', 0, N'화면 깨짐 - 수리 필요', 2);

-- IT 장비 - 모니터 (카테고리 5)
INSERT INTO assets (asset_code, category_id, asset_name, serial_number, manufacturer, model_number, purchase_date, location, managing_department, using_department, status, condition_rating, technical_specs, ai_classified, notes, registered_by)
VALUES
    (N'AST-202604-006', 5, N'LG 모니터 27인치-01', N'MON-2024-D001', N'LG', N'27UP850N', '2024-01-10', N'강남지점 1층', N'IT관리팀', N'상담1팀', 'IN_USE', 5,
     N'{"size":"27인치","resolution":"4K UHD","panel":"IPS","port":"USB-C, HDMI, DP"}', 0, NULL, 1),

    (N'AST-202604-007', 5, N'LG 모니터 27인치-02', N'MON-2024-D002', N'LG', N'27UP850N', '2024-01-10', N'강남지점 창고', N'IT관리팀', NULL, 'IN_STORAGE', 5,
     N'{"size":"27인치","resolution":"4K UHD","panel":"IPS","port":"USB-C, HDMI, DP"}', 0, N'여분 모니터 - 창고 보관중', 1),

    (N'AST-202604-008', 5, N'삼성 모니터 32인치-01', N'MON-2023-E001', N'Samsung', N'S32B800PXK', '2023-07-05', N'서초지점 2층', N'IT관리팀', N'상담3팀', 'RENTED', 4,
     N'{"size":"32인치","resolution":"4K UHD","panel":"VA","port":"HDMI, DP, USB-C"}', 0, N'최상담에게 대여중', 2);

-- IT 장비 - 프린터/복합기 (카테고리 6, 16)
INSERT INTO assets (asset_code, category_id, asset_name, serial_number, manufacturer, model_number, purchase_date, location, managing_department, using_department, status, condition_rating, technical_specs, ai_classified, notes, registered_by)
VALUES
    (N'AST-202604-009', 16, N'HP 복합기-01', N'PRT-2024-F001', N'HP', N'LaserJet Pro M283fdw', '2024-02-20', N'강남지점 1층', N'총무팀', N'공용', 'IN_USE', 4,
     N'{"type":"컬러 레이저 복합기","speed":"22ppm","duplex":"자동 양면","scan":"ADF 50매"}', 0, N'1층 공용 복합기', 1),

    (N'AST-202604-010', 6, N'Canon 프린터-01', N'PRT-2022-G001', N'Canon', N'LBP226dw', '2022-11-15', N'서초지점 1층', N'총무팀', N'공용', 'BROKEN', 1,
     N'{"type":"흑백 레이저","speed":"38ppm","duplex":"자동 양면"}', 0, N'용지 걸림 반복 - 교체 검토', 2);

-- IT 장비 - 핸드폰 (카테고리 7)
INSERT INTO assets (asset_code, category_id, asset_name, serial_number, manufacturer, model_number, purchase_date, location, managing_department, using_department, status, condition_rating, technical_specs, ai_classified, notes, registered_by)
VALUES
    (N'AST-202604-011', 7, N'삼성 갤럭시 S25-01', N'PHN-2025-H001', N'Samsung', N'SM-S931N', '2025-02-07', N'강남지점', N'IT관리팀', N'상담1팀', 'IN_USE', 5,
     N'{"storage":"256GB","color":"아이시 블루","carrier":"SKT"}', 0, N'업무용 단말기', 1),

    (N'AST-202604-012', 7, N'아이폰 16-01', N'PHN-2024-I001', N'Apple', N'MYE63KH/A', '2024-09-20', N'서초지점', N'IT관리팀', N'상담4팀', 'RENTED', 4,
     N'{"storage":"128GB","color":"블루","carrier":"KT"}', 0, N'정상담에게 대여중', 2);

-- IT 장비 - 네트워크 (카테고리 8)
INSERT INTO assets (asset_code, category_id, asset_name, serial_number, manufacturer, model_number, purchase_date, location, managing_department, using_department, status, condition_rating, technical_specs, ai_classified, notes, registered_by)
VALUES
    (N'AST-202604-013', 8, N'ipTIME 공유기-01', N'NET-2024-J001', N'ipTIME', N'AX8004BCM', '2024-04-01', N'강남지점 서버실', N'IT관리팀', N'공용', 'IN_USE', 5,
     N'{"type":"WiFi 6E","speed":"AX8400","port":"기가비트 4포트"}', 0, N'강남지점 메인 공유기', 1),

    (N'AST-202604-020', 8, N'Cisco 스위치-01', N'NET-2023-K001', N'Cisco', N'SG350-28', '2023-05-10', N'서초지점 서버실', N'IT관리팀', N'공용', 'IN_USE', 4,
     N'{"type":"L3 스위치","port":"28포트 기가비트","management":"웹 관리"}', 0, N'서초지점 메인 스위치', 2);

-- 사무용 가구 - 올문장 (카테고리 14, 15)
INSERT INTO assets (asset_code, category_id, asset_name, serial_number, manufacturer, model_number, purchase_date, location, managing_department, using_department, status, condition_rating, technical_specs, ai_classified, notes, registered_by)
VALUES
    (N'AST-202604-014', 14, N'5단 올문장-01', NULL, N'한샘', N'HO-5D-001', '2023-01-15', N'강남지점 2층', N'총무팀', N'상담2팀', 'IN_USE', 4,
     N'{"material":"스틸","color":"그레이","size":"900x450x1800mm"}', 0, NULL, 1),

    (N'AST-202604-015', 15, N'3단 올문장-01', NULL, N'한샘', N'HO-3D-001', '2023-01-15', N'강남지점 창고', N'총무팀', NULL, 'IN_STORAGE', 3,
     N'{"material":"스틸","color":"그레이","size":"900x450x1100mm"}', 0, N'사용하지 않아 창고 보관', 1);

-- 사무용 가구 - 책상 (카테고리 10)
INSERT INTO assets (asset_code, category_id, asset_name, serial_number, manufacturer, model_number, purchase_date, location, managing_department, using_department, status, condition_rating, technical_specs, ai_classified, notes, registered_by)
VALUES
    (N'AST-202604-016', 10, N'사무용 책상-01', NULL, N'퍼시스', N'CH1600L', '2022-06-01', N'강남지점 1층', N'총무팀', N'상담1팀', 'IN_USE', 3,
     N'{"material":"MDF","color":"월넛","size":"1600x800x730mm"}', 0, NULL, 2),

    (N'AST-202604-017', 10, N'사무용 책상-02', NULL, N'퍼시스', N'CH1400L', '2020-03-10', N'서초지점', N'총무팀', NULL, 'DISPOSED', 1,
     N'{"material":"MDF","color":"화이트","size":"1400x700x730mm"}', 0, N'노후화로 폐기 처리', 2);

-- 사무용 가구 - 의자 (카테고리 11)
INSERT INTO assets (asset_code, category_id, asset_name, serial_number, manufacturer, model_number, purchase_date, location, managing_department, using_department, status, condition_rating, technical_specs, ai_classified, notes, registered_by)
VALUES
    (N'AST-202604-018', 11, N'사무용 의자-01', NULL, N'시디즈', N'T50 AIR', '2023-08-01', N'강남지점 1층', N'총무팀', N'상담1팀', 'IN_USE', 4,
     N'{"type":"메쉬 의자","color":"블랙","armrest":"4D 팔걸이"}', 0, NULL, 1),

    (N'AST-202604-019', 11, N'사무용 의자-02', NULL, N'시디즈', N'T50 AIR', '2023-08-01', N'서초지점 1층', N'총무팀', N'상담3팀', 'IN_USE', 4,
     N'{"type":"메쉬 의자","color":"블랙","armrest":"4D 팔걸이"}', 0, NULL, 2);

-- ============================================================
-- 3. 대여 (Rentals) — 10건
-- ============================================================
-- 장비 ID는 INSERT 순서 기준 (asset_id = 1~20)
-- 사용자 ID: 관리자=1, 김지점장=2, 이상담=3, 박상담=4, 최상담=5, 정상담=6

-- RENTED: 4건 (활성 대여)
INSERT INTO rentals (asset_id, borrower_id, approver_id, rental_reason, borrower_name, rental_date, due_date, return_date, status, extension_count, return_condition)
VALUES
    -- 대여 1: 오늘 마감 (dueSoon)
    (2, 3, 1, N'상담 업무용 PC 필요', N'이상담',
     '2026-04-15 09:00:00', '2026-04-29 18:00:00', NULL, 'RENTED', 0, NULL),

    -- 대여 2: 정상 대여중
    (4, 4, 2, N'외부 미팅용 노트북', N'박상담',
     '2026-04-10 10:00:00', '2026-05-10 18:00:00', NULL, 'RENTED', 0, NULL),

    -- 대여 3: 곧 마감 (dueSoon)
    (8, 5, 2, N'프레젠테이션용 대형 모니터', N'최상담',
     '2026-04-20 09:00:00', '2026-05-04 18:00:00', NULL, 'RENTED', 0, NULL),

    -- 대여 4: 정상 대여중
    (12, 6, 2, N'업무용 핸드폰 임시 사용', N'정상담',
     '2026-04-22 14:00:00', '2026-05-06 18:00:00', NULL, 'RENTED', 0, NULL);

-- RETURNED: 4건 (반납 완료)
INSERT INTO rentals (asset_id, borrower_id, approver_id, rental_reason, borrower_name, rental_date, due_date, return_date, status, extension_count, return_condition)
VALUES
    -- 대여 5: 반납완료
    (3, 3, 1, N'교육 참석용', N'이상담',
     '2026-03-01 09:00:00', '2026-03-15 18:00:00', '2026-03-14 16:30:00', 'RETURNED', 0, N'양호'),

    -- 대여 6: 반납완료
    (6, 4, 1, N'듀얼 모니터 세팅', N'박상담',
     '2026-03-10 09:00:00', '2026-03-24 18:00:00', '2026-03-22 17:00:00', 'RETURNED', 0, N'양호'),

    -- 대여 7: 반납완료 (오래전)
    (11, 6, 2, N'업무용 단말기 테스트', N'정상담',
     '2026-02-01 09:00:00', '2026-02-15 18:00:00', '2026-02-14 15:00:00', 'RETURNED', 0, N'정상 상태'),

    -- 대여 8: 오늘 반납 (returnedToday)
    (7, 4, 1, N'임시 모니터 사용', N'박상담',
     '2026-04-25 09:00:00', '2026-05-09 18:00:00', '2026-04-29 10:00:00', 'RETURNED', 0, N'양호');

-- CANCELLED: 1건
INSERT INTO rentals (asset_id, borrower_id, approver_id, rental_reason, borrower_name, rental_date, due_date, return_date, status, extension_count, return_condition)
VALUES
    (9, 5, 1, N'복합기 임시 이동', N'최상담',
     '2026-04-01 09:00:00', '2026-04-15 18:00:00', NULL, 'CANCELLED', 0, NULL);

-- OVERDUE: 1건
INSERT INTO rentals (asset_id, borrower_id, approver_id, rental_reason, borrower_name, rental_date, due_date, return_date, status, extension_count, return_condition)
VALUES
    (14, 3, 1, N'서류 정리용 캐비닛', N'이상담',
     '2026-04-01 09:00:00', '2026-04-15 18:00:00', NULL, 'OVERDUE', 0, NULL);

-- ============================================================
-- 4. 알림 (Notifications) — 12건
-- ============================================================

INSERT INTO notifications (user_id, type, title, message, is_read, channel, reference_id, sent_at, read_at)
VALUES
    -- 이상담 알림 (3건)
    (3, 'RENTAL_DUE', N'장비 반납일이 다가옵니다',
     N'[델 데스크탑 PC-02] 장비의 반납 예정일이 2026-04-29입니다. 기한 내 반납해주세요.',
     0, 'IN_APP', 1, '2026-04-27 09:00:00', NULL),

    (3, 'RENTAL_OVERDUE', N'장비 반납이 연체되었습니다',
     N'[5단 올문장-01] 장비가 반납 예정일(2026-04-15)을 경과했습니다. 즉시 반납해주세요.',
     0, 'IN_APP', 10, '2026-04-16 09:00:00', NULL),

    (3, 'SYSTEM', N'비밀번호 변경을 권장합니다',
     N'보안을 위해 비밀번호를 정기적으로 변경해주세요. 마지막 변경일로부터 90일이 경과했습니다.',
     1, 'IN_APP', NULL, '2026-04-20 09:00:00', '2026-04-20 10:30:00'),

    -- 박상담 알림 (2건)
    (4, 'RENTAL_DUE', N'장비 반납일이 다가옵니다',
     N'[LG 노트북 그램-02] 장비의 반납 예정일이 2026-05-10입니다. 기한 내 반납해주세요.',
     1, 'IN_APP', 2, '2026-04-28 09:00:00', '2026-04-28 11:00:00'),

    (4, 'SYSTEM', N'장비 상태가 변경되었습니다',
     N'[LG 모니터 27인치-02] 장비 상태가 IN_STORAGE로 변경되었습니다.',
     0, 'IN_APP', NULL, '2026-04-25 14:00:00', NULL),

    -- 최상담 알림 (2건)
    (5, 'RENTAL_DUE', N'장비 반납일이 다가옵니다',
     N'[삼성 모니터 32인치-01] 장비의 반납 예정일이 2026-05-04입니다. 기한 내 반납해주세요.',
     0, 'IN_APP', 3, '2026-04-28 09:00:00', NULL),

    (5, 'SYSTEM', N'환영합니다! 잡모아 장비관리 시스템입니다',
     N'잡모아 장비관리 시스템에 오신 것을 환영합니다. 장비 대여/반납 기능을 이용해보세요.',
     1, 'IN_APP', NULL, '2026-04-01 09:00:00', '2026-04-01 09:30:00'),

    -- 정상담 알림 (2건)
    (6, 'SYSTEM', N'시스템 점검 안내',
     N'2026년 5월 3일(토) 02:00~06:00 시스템 정기 점검이 예정되어 있습니다.',
     0, 'IN_APP', NULL, '2026-04-28 09:00:00', NULL),

    (6, 'RENTAL_DUE', N'장비 반납일이 다가옵니다',
     N'[아이폰 16-01] 장비의 반납 예정일이 2026-05-06입니다. 기한 내 반납해주세요.',
     0, 'IN_APP', 4, '2026-04-29 09:00:00', NULL),

    -- 관리자 알림 (2건)
    (1, 'RENTAL_OVERDUE', N'연체 장비가 발생했습니다',
     N'[5단 올문장-01] 장비가 이상담에 의해 연체되었습니다. 반납 독촉이 필요합니다.',
     0, 'IN_APP', 10, '2026-04-16 09:00:00', NULL),

    (1, 'SYSTEM', N'신규 사용자가 등록되었습니다',
     N'정상담(counselor.jung@jobmoa.com) 사용자가 신규 등록되었습니다.',
     1, 'IN_APP', NULL, '2026-04-10 09:00:00', '2026-04-10 10:00:00'),

    -- 김지점장 알림 (1건)
    (2, 'RENTAL_OVERDUE', N'연체 장비가 발생했습니다',
     N'[5단 올문장-01] 장비가 이상담에 의해 연체되었습니다. 반납 독촉이 필요합니다.',
     0, 'IN_APP', 10, '2026-04-16 09:00:00', NULL);
