-- 1. выборка из первого представления
-- expect: rows
SELECT * FROM v_rental_details LIMIT 5;

-- 2. выборка из второго представления
-- expect: rows
SELECT * FROM v_available_equipment LIMIT 5;

-- 3. вызов простой функции
-- expect: rows
SELECT get_client_rentals_count(1);

-- Подготовка: освобождение снаряжения
-- expect: ok
UPDATE equipment SET status = 'available' WHERE id = 1;

-- 4. бизнес-операция: оформление аренды для клиента 1 (снаряжение 1)
-- expect: rows
SELECT create_rental(1, 1, 1, 3);

-- 5. попытка выдать то же снаряжение ещё раз
-- expect: error "уже на руках"
SELECT create_rental(2, 1, 1, 3);

-- 6. служебный триггер (меняется аренда, updated_at)
-- expect: rows
BEGIN;
UPDATE rentals SET status = 'returned' WHERE id = 1;
SELECT updated_at FROM rentals WHERE id = 1;
ROLLBACK;


-- 7. материализованное представление
-- expect: rows
SELECT * FROM mv_monthly_revenue;

-- 8. обновление
-- expect: ok
REFRESH MATERIALIZED VIEW mv_monthly_revenue;

-- 9. чтение снова
-- expect: rows
SELECT * FROM mv_monthly_revenue;

-- 10. поиск снаряжения (палатки)
-- expect: rows
SELECT * FROM search_equipment('tent');

-- 11. поиск снаряжения (доступное)
-- expect: rows
SELECT * FROM search_equipment(NULL, 'available');