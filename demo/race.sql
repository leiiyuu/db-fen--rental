-- [setup] освобождаем снаряжение
-- expect: ok
UPDATE equipment SET status = 'available' WHERE id = 1;
DELETE FROM rental_items WHERE equipment_id = 1;
DELETE FROM rentals WHERE id NOT IN (SELECT rental_id FROM rental_items);

-- [A] окно A: свободно и вставляем позицию
BEGIN;
-- expect: value available
SELECT status FROM equipment WHERE id = 1;
INSERT INTO rental_items (rental_id, equipment_id, price) VALUES (1, 1, 500);

-- [B] окно B в тот же момент: триггер не видит незафиксированную вставку A
BEGIN;
-- expect: value available
SELECT status FROM equipment WHERE id = 1;
INSERT INTO rental_items (rental_id, equipment_id, price) VALUES (2, 1, 500);

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check] одну единицу выдали дважды?
-- expect: false
SELECT count(*) <= 1 FROM rental_items WHERE equipment_id = 1;