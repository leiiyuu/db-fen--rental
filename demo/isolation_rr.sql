-- [setup]
UPDATE deposits SET amount = 500 WHERE id = 1;

-- [A] первое чтение, REPEATABLE READ
BEGIN ISOLATION LEVEL REPEATABLE READ;
-- expect: value 500.00
SELECT amount FROM deposits WHERE id = 1;

-- [B] окно B меняет и коммитит
BEGIN;
UPDATE deposits SET amount = 700 WHERE id = 1;
COMMIT;

-- [A] второе чтение на REPEATABLE READ — прежнее значение
-- expect: value 500.00
SELECT amount FROM deposits WHERE id = 1;
COMMIT;