
-- 1. карточка аренды
CREATE OR REPLACE VIEW v_rental_details AS
SELECT 
    r.id AS rental_id,
    c.full_name AS client_name,
    p.name AS point_name,
    e.name AS equipment_name,
    r.starts_at,
    r.ends_at,
    r.status AS rental_status
FROM rentals r
JOIN clients c ON c.id = r.client_id
JOIN points p ON p.id = r.point_id
JOIN rental_items ri ON ri.rental_id = r.id
JOIN equipment e ON e.id = ri.equipment_id;

-- 2. Свободное снаряжение
CREATE OR REPLACE VIEW v_available_equipment AS
SELECT e.id, e.name, e.category, e.price_day, p.name AS point_name
FROM equipment e
JOIN points p ON p.id = e.point_id
WHERE e.status = 'available';



-- Материализованное представление: выручка по месяцам
CREATE MATERIALIZED VIEW mv_monthly_revenue AS
SELECT 
    date_trunc('month', starts_at)::date AS month,
    sum(total_price) AS revenue
FROM rentals
GROUP BY date_trunc('month', starts_at);