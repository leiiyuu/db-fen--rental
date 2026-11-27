-- [setup]
-- expect: ok
UPDATE equipment SET status = 'available' WHERE id = 1;
DELETE FROM rental_items WHERE equipment_id = 1;

-- [A] окно A: вызов исправленной операции
BEGIN;
-- expect: rows
SELECT create_rental_safe(1, 1, 1, 2);

-- [B] окно B: ждёт блокировку, затем ошибка
BEGIN;
-- expect: error "уже на руках"
SELECT create_rental_safe(2, 1, 1, 2);
COMMIT;

-- [A]
COMMIT;

-- [check]
-- expect: true
SELECT count(*) <= 1 FROM rental_items WHERE equipment_id = 1;