-- Генерация 1000+ строк 


INSERT INTO clients (full_name, phone, email)
SELECT
    'Клиент ' || g,
    '+7-900-' || lpad(g::text, 3, '0'),
    'client' || g || '@example.com'
FROM generate_series(1, 1000) AS g;


INSERT INTO points (name, address, phone)
SELECT
    'Пункт № ' || g,
    'ул. Генерируемая, ' || g,
    '+7-900-' || lpad(g::text, 3, '0')
FROM generate_series(1, 100) AS g;


INSERT INTO equipment (name, category, price_day, status, point_id)
SELECT
    'Снаряжение ' || g,
    'tent',
    500.00,
    'available',
    1 + (g % 112)
FROM generate_series(1, 1000) AS g;


INSERT INTO rentals (client_id, point_id, starts_at, ends_at, status, total_price)
SELECT
    1 + (g % 1012),
    1 + (g % 112),
    '2025-01-01 10:00+10'::timestamptz,
    '2025-01-05 10:00+10'::timestamptz,
    'returned',
    1000.00
FROM generate_series(1, 1000) AS g;


INSERT INTO rental_items (rental_id, equipment_id, price)
SELECT
    1 + (g % 1012),
    1 + (g % 1012),
    500.00
FROM generate_series(1, 1000) AS g
ON CONFLICT DO NOTHING;


INSERT INTO deposits (rental_id, amount, status)
SELECT
    1 + (g % 1012),
    1000.00,
    'returned'
FROM generate_series(1, 1000) AS g;