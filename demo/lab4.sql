-- 1. до транзакции
-- expect: rows
SELECT count(*) AS rentals_count, sum(total_price) AS total
FROM rentals;

-- 2. транзакция падает на середине
BEGIN;
UPDATE rentals SET total_price = total_price + 100 WHERE id = 1;

-- expect: error fk
INSERT INTO rentals (client_id, point_id, starts_at, ends_at, status, total_price)
VALUES (99999, 1, '2025-01-01 10:00+03', '2025-01-02 10:00+03', 'active', 100);
COMMIT;

-- 3. данные не изменились
-- expect: same 1
SELECT count(*) AS rentals_count, sum(total_price) AS total
FROM rentals;