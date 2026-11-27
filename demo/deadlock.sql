-- [A] окно A: захватывает строку 1
BEGIN;
-- expect: rows 1
SELECT * FROM deposits WHERE id = 1 FOR UPDATE;

-- [B] окно B: захватывает строку 2
BEGIN;
-- expect: rows 1
SELECT * FROM deposits WHERE id = 2 FOR UPDATE;

-- [A] окно A: пытается захватить строку 2, ждёт B
SELECT * FROM deposits WHERE id = 2 FOR UPDATE;

-- [B] окно B: пытается захватить строку 1, deadlock detected
-- expect: error deadlock
SELECT * FROM deposits WHERE id = 1 FOR UPDATE;