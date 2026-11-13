-- 1. список аренд: имя клиента, дата начала и общая сумма
-- expect: rows
SELECT c.full_name, r.starts_at, r.total_price
FROM rentals r
JOIN clients c ON c.id = r.client_id;

-- 2. какие единицы снаряжения брал каждый клиент
-- expect: rows
SELECT c.full_name, e.name AS equipment_name, ri.price
FROM rental_items ri
JOIN rentals r ON r.id = ri.rental_id
JOIN clients c ON c.id = r.client_id
JOIN equipment e ON e.id = ri.equipment_id;

-- 3. все снаряжения и названия пунктов, где они находятся
-- expect: rows
SELECT e.name AS equipment_name, p.name AS point_name
FROM equipment e
JOIN points p ON p.id = e.point_id;

-- 4. сколько аренд оформил каждый клиент
-- expect: rows
SELECT c.full_name, count(r.id) AS rentals_count
FROM clients c
JOIN rentals r ON r.client_id = c.id
GROUP BY c.id, c.full_name
ORDER BY rentals_count DESC;

-- 5. клиенты, чья общая сумма по всем арендам превышает 2000
-- expect: rows
SELECT c.full_name, sum(r.total_price) AS total_spent
FROM clients c
JOIN rentals r ON r.client_id = c.id
GROUP BY c.id, c.full_name
HAVING sum(r.total_price) > 2000;

-- 6. клиенты, которые ни разу ничего не арендовали
-- expect: rows
SELECT c.full_name
FROM clients c
LEFT JOIN rentals r ON r.client_id = c.id
WHERE r.id IS NULL;

-- 7. снаряжения, цена аренды которых выше средней
-- expect: rows
SELECT name, price_day
FROM equipment
WHERE price_day > (SELECT avg(price_day) FROM equipment);

-- 8. клиенты, которые брали снаряжение категории 'tent' (палатки)
-- expect: rows
SELECT full_name
FROM clients
WHERE id IN (
    SELECT r.client_id
    FROM rentals r
    JOIN rental_items ri ON ri.rental_id = r.id
    JOIN equipment e ON e.id = ri.equipment_id
    WHERE e.category = 'tent'
);


-- 9. Добавить новый пункт проката
BEGIN;
-- expect: rows
SELECT count(*) FROM points;
INSERT INTO points (name, address, phone) 
VALUES ('Новый пункт', 'ул. Тестовая, 1', '+7-900-000-00-00'); -- expect: rows 1
SELECT count(*) FROM points;
ROLLBACK;

-- 10. Поднять цену аренды на 10% для всех палаток
BEGIN;
-- expect: rows 
SELECT name, price_day FROM equipment WHERE category = 'tent';
UPDATE equipment SET price_day = price_day * 1.1 WHERE category = 'tent';
SELECT name, price_day FROM equipment WHERE category = 'tent';
ROLLBACK;

-- 11. Удалить залоги со статусом 'returned'
BEGIN;
SELECT count(*) FROM deposits WHERE status = 'returned';
DELETE FROM deposits WHERE status = 'returned';
SELECT count(*) FROM deposits WHERE status = 'returned';
ROLLBACK;

-- 12. Вывести всё снаряжение, которое сейчас доступно
-- expect: rows
SELECT name, category, price_day
FROM equipment
WHERE status = 'available'
ORDER BY price_day;




-- 13. три самых дорогих единиц снаряжения в каждой категории
-- expect: rows
WITH ranked_equipment AS (
    SELECT name, category, price_day,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY price_day DESC) as rn
    FROM equipment
)
SELECT category, name, price_day
FROM ranked_equipment
WHERE rn <= 3;

-- 14. аренды по датам с накопительной суммой (сколько всего заработано на текущий день)
-- expect: rows
SELECT 
    starts_at::date AS rental_date,
    total_price,
    SUM(total_price) OVER (ORDER BY starts_at) AS running_total
FROM rentals
ORDER BY starts_at
LIMIT 20; 

