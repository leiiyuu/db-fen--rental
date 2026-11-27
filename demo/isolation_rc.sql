-- [setup]
UPDATE deposits SET amount = 500 WHERE id = 1;

-- [A] первое чтение
BEGIN;
-- expect: value 500.00
SELECT amount FROM deposits WHERE id = 1;

-- [B] окно B меняет и коммитит
BEGIN;
UPDATE deposits SET amount = 700 WHERE id = 1;
COMMIT;

-- [A] второе чтение на READ COMMITTED — видит новое значение
-- expect: value 700.00
SELECT amount FROM deposits WHERE id = 1;
COMMIT;