BEGIN;

-- ============================================================
-- 1. MATERIAL MASTER
-- ============================================================

-- ------------------------------------------------------------
-- CABLE - UNDERGROUND
-- ------------------------------------------------------------

INSERT INTO material
    (material_code, material_name, material_group, unit, description)
VALUES
    ('CABLE_UNDERGROUND_6FO',
     'CABLE UNDERGROUND 6FO',
     'CABLE',
     'm',
     'Cáp ngầm 6FO'),

    ('CABLE_UNDERGROUND_12FO',
     'CABLE UNDERGROUND 12FO',
     'CABLE',
     'm',
     'Cáp ngầm 12FO'),

    ('CABLE_UNDERGROUND_24FO',
     'CABLE UNDERGROUND 24FO',
     'CABLE',
     'm',
     'Cáp ngầm 24FO');


-- ------------------------------------------------------------
-- CABLE - F8
-- ------------------------------------------------------------

INSERT INTO material
    (material_code, material_name, material_group, unit, description)
VALUES
    ('CABLE_F8_KV100_6FO',
     'CABLE F8 KV100 6FO',
     'CABLE',
     'm',
     'Cáp F8, khoảng vượt 100m, 6FO'),

    ('CABLE_F8_KV100_12FO',
     'CABLE F8 KV100 12FO',
     'CABLE',
     'm',
     'Cáp F8, khoảng vượt 100m, 12FO'),

    ('CABLE_F8_KV100_24FO',
     'CABLE F8 KV100 24FO',
     'CABLE',
     'm',
     'Cáp F8, khoảng vượt 100m, 24FO');


-- ------------------------------------------------------------
-- CABLE - ADSS
-- ------------------------------------------------------------

INSERT INTO material
    (material_code, material_name, material_group, unit, description)
VALUES
    ('CABLE_ADSS_KV100_6FO',
     'CABLE ADSS KV100 6FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 100m, 6FO'),

    ('CABLE_ADSS_KV100_12FO',
     'CABLE ADSS KV100 12FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 100m, 12FO'),

    ('CABLE_ADSS_KV100_24FO',
     'CABLE ADSS KV100 24FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 100m, 24FO'),

    ('CABLE_ADSS_KV200_6FO',
     'CABLE ADSS KV200 6FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 200m, 6FO'),

    ('CABLE_ADSS_KV200_12FO',
     'CABLE ADSS KV200 12FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 200m, 12FO'),

    ('CABLE_ADSS_KV200_24FO',
     'CABLE ADSS KV200 24FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 200m, 24FO'),

    ('CABLE_ADSS_KV300_6FO',
     'CABLE ADSS KV300 6FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 300m, 6FO'),

    ('CABLE_ADSS_KV300_12FO',
     'CABLE ADSS KV300 12FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 300m, 12FO'),

    ('CABLE_ADSS_KV300_24FO',
     'CABLE ADSS KV300 24FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 300m, 24FO'),

    ('CABLE_ADSS_KV400_6FO',
     'CABLE ADSS KV400 6FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 400m, 6FO'),

    ('CABLE_ADSS_KV400_12FO',
     'CABLE ADSS KV400 12FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 400m, 12FO'),

    ('CABLE_ADSS_KV400_24FO',
     'CABLE ADSS KV400 24FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 400m, 24FO'),

    ('CABLE_ADSS_KV500_6FO',
     'CABLE ADSS KV500 6FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 500m, 6FO'),

    ('CABLE_ADSS_KV500_12FO',
     'CABLE ADSS KV500 12FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 500m, 12FO'),

    ('CABLE_ADSS_KV500_24FO',
     'CABLE ADSS KV500 24FO',
     'CABLE',
     'm',
     'Cáp ADSS, khoảng vượt 500m, 24FO');


-- ------------------------------------------------------------
-- SPLICE CLOSURE
-- ------------------------------------------------------------

INSERT INTO material
    (material_code, material_name, material_group, unit, description)
VALUES
    ('SPLICE_CLOSURE_6FO',
     'SPLICE_CLOSURE 6FO',
     'SPLICE_CLOSURE',
     'bộ',
     'Măng xông cáp quang 6FO'),

    ('SPLICE_CLOSURE_12FO',
     'SPLICE_CLOSURE 12FO',
     'SPLICE_CLOSURE',
     'bộ',
     'Măng xông cáp quang 12FO'),

    ('SPLICE_CLOSURE_24FO',
     'SPLICE_CLOSURE 24FO',
     'SPLICE_CLOSURE',
     'bộ',
     'Măng xông cáp quang 24FO');


-- ------------------------------------------------------------
-- HANGER - ADSS
-- ------------------------------------------------------------

INSERT INTO material
    (material_code, material_name, material_group, unit, description)
VALUES
    ('HANGER_KV100',
     'HANGER KV100',
     'HANGER',
     'bộ',
     'Bộ treo cáp ADSS khoảng vượt 100m'),

    ('HANGER_KV200',
     'HANGER KV200',
     'HANGER',
     'bộ',
     'Bộ treo cáp ADSS khoảng vượt 200m'),

    ('HANGER_KV300',
     'HANGER KV300',
     'HANGER',
     'bộ',
     'Bộ treo cáp ADSS khoảng vượt 300m'),

    ('HANGER_KV400',
     'HANGER KV400',
     'HANGER',
     'bộ',
     'Bộ treo cáp ADSS khoảng vượt 400m'),

    ('HANGER_KV500',
     'HANGER KV500',
     'HANGER',
     'bộ',
     'Bộ treo cáp ADSS khoảng vượt 500m');


-- ------------------------------------------------------------
-- ANCHOR - ADSS
-- ------------------------------------------------------------

INSERT INTO material
    (material_code, material_name, material_group, unit, description)
VALUES
    ('ANCHOR_KV100',
     'ANCHOR KV100',
     'ANCHOR',
     'bộ',
     'Bộ néo cáp ADSS khoảng vượt 100m'),

    ('ANCHOR_KV200',
     'ANCHOR KV200',
     'ANCHOR',
     'bộ',
     'Bộ néo cáp ADSS khoảng vượt 200m'),

    ('ANCHOR_KV300',
     'ANCHOR KV300',
     'ANCHOR',
     'bộ',
     'Bộ néo cáp ADSS khoảng vượt 300m'),

    ('ANCHOR_KV400',
     'ANCHOR KV400',
     'ANCHOR',
     'bộ',
     'Bộ néo cáp ADSS khoảng vượt 400m'),

    ('ANCHOR_KV500',
     'ANCHOR KV500',
     'ANCHOR',
     'bộ',
     'Bộ néo cáp ADSS khoảng vượt 500m');


-- ------------------------------------------------------------
-- MANUAL MATERIAL GROUPS
--
-- Các nhóm này chưa có quy tắc phân loại tự động.
-- Có thể bổ sung vật tư cụ thể sau.
-- ------------------------------------------------------------

INSERT INTO material
    (material_code, material_name, material_group, unit, description)
VALUES
    ('CLAMP_GENERIC',
     'CLAMP',
     'CLAMP',
     'bộ',
     'Vật tư kẹp cáp - lựa chọn thủ công'),

    ('PIPE_GENERIC',
     'PIPE',
     'PIPE',
     'm',
     'Ống bảo vệ cáp - lựa chọn thủ công'),

    ('POLE_BAND_GENERIC',
     'POLE_BAND',
     'POLE_BAND',
     'bộ',
     'Đai cột - lựa chọn thủ công'),

    ('OTHERS_GENERIC',
     'OTHERS',
     'OTHERS',
     'bộ',
     'Vật tư khác - lựa chọn thủ công');


-- ============================================================
-- 2. MATERIAL RULE
-- ============================================================

-- ------------------------------------------------------------
-- CABLE - UNDERGROUND
--
-- Không phụ thuộc cable_type.
-- Chỉ phụ thuộc fiber_count.
-- ------------------------------------------------------------

INSERT INTO material_rule
    (material_id, cable_type, fiber_count, repair_span_type_id)
SELECT
    m.material_id,
    NULL,
    f.fiber_count,
    rst.repair_span_type_id
FROM material m
JOIN (
    VALUES (6), (12), (24)
) AS f(fiber_count)
    ON m.material_code =
       'CABLE_UNDERGROUND_' || f.fiber_count || 'FO'
JOIN repair_span_type rst
    ON rst.span_code = 'UNDERGROUND';


-- ------------------------------------------------------------
-- CABLE - F8 - KV100
-- ------------------------------------------------------------

INSERT INTO material_rule
    (material_id, cable_type, fiber_count, repair_span_type_id)
SELECT
    m.material_id,
    'F8',
    f.fiber_count,
    rst.repair_span_type_id
FROM material m
JOIN (
    VALUES (6), (12), (24)
) AS f(fiber_count)
    ON m.material_code =
       'CABLE_F8_KV100_' || f.fiber_count || 'FO'
JOIN repair_span_type rst
    ON rst.span_code = 'KV100';


-- ------------------------------------------------------------
-- CABLE - ADSS
-- KV100/KV200/KV300/KV400/KV500
-- ------------------------------------------------------------

INSERT INTO material_rule
    (material_id, cable_type, fiber_count, repair_span_type_id)
SELECT
    m.material_id,
    'ADSS',
    f.fiber_count,
    rst.repair_span_type_id
FROM material m
JOIN (
    VALUES (100), (200), (300), (400), (500)
) AS s(span)
    ON m.material_code LIKE
       'CABLE_ADSS_KV' || s.span || '_%FO'
JOIN (
    VALUES (6), (12), (24)
) AS f(fiber_count)
    ON m.material_code =
       'CABLE_ADSS_KV' || s.span || '_' ||
       f.fiber_count || 'FO'
JOIN repair_span_type rst
    ON rst.span_code = 'KV' || s.span;


-- ------------------------------------------------------------
-- SPLICE_CLOSURE
--
-- Chỉ có 12FO và 24FO.
-- Không tạo rule cho 6FO.
-- ------------------------------------------------------------

INSERT INTO material_rule
    (material_id, cable_type, fiber_count, repair_span_type_id)
SELECT
    m.material_id,
    NULL,
    f.fiber_count,
    rst.repair_span_type_id
FROM material m
JOIN (
    VALUES (12), (24)
) AS f(fiber_count)
    ON m.material_code =
       'SPLICE_CLOSURE_' || f.fiber_count || 'FO'
JOIN repair_span_type rst
    ON TRUE;


-- ------------------------------------------------------------
-- HANGER
--
-- Chỉ ADSS.
-- Không áp dụng UNDERGROUND.
-- ------------------------------------------------------------

INSERT INTO material_rule
    (material_id, cable_type, fiber_count, repair_span_type_id)
SELECT
    m.material_id,
    'ADSS',
    NULL,
    rst.repair_span_type_id
FROM material m
JOIN repair_span_type rst
    ON rst.span_code IN ('KV100', 'KV200', 'KV300', 'KV400', 'KV500')
WHERE m.material_code =
      'HANGER_' || rst.span_code;


-- ------------------------------------------------------------
-- ANCHOR
--
-- Chỉ ADSS.
-- Không áp dụng UNDERGROUND.
-- ------------------------------------------------------------

INSERT INTO material_rule
    (material_id, cable_type, fiber_count, repair_span_type_id)
SELECT
    m.material_id,
    'ADSS',
    NULL,
    rst.repair_span_type_id
FROM material m
JOIN repair_span_type rst
    ON rst.span_code IN ('KV100', 'KV200', 'KV300', 'KV400', 'KV500')
WHERE m.material_code =
      'ANCHOR_' || rst.span_code;


COMMIT;