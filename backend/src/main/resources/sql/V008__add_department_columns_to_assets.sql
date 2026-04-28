-- V008: 장비 관리부서/사용부서 컬럼 추가
ALTER TABLE assets ADD managing_department NVARCHAR(100);
ALTER TABLE assets ADD using_department NVARCHAR(100);

CREATE INDEX IX_assets_managing_dept ON assets(managing_department);
CREATE INDEX IX_assets_using_dept ON assets(using_department);
