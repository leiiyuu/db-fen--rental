-- Лаба 1. Сценарий для показа. Формат описан в docs/scenarios.md.
-- Запуск: dbcheck run demo/lab1.sql, или в psql: \i /demo/lab1.sql
--
-- Каждый шаг: строка «-- N. что показываем», под ней «-- expect: ответ базы», под ней запрос.
-- Пример, замените своими запросами:
--
-- -- 1. Таблицы на месте: 6 таблиц
-- -- expect: rows 6
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY 1;
--
-- -- 2. Отрицательная цена билета: ошибка CHECK
-- -- expect: error check
-- INSERT INTO tickets (session_id, seat_id, price) VALUES (1, 1, -100);
--
-- -- 3. Несуществующий сеанс: ошибка внешнего ключа
-- -- expect: error fk
-- INSERT INTO tickets (session_id, seat_id, price) VALUES (9999, 1, 300);
--
-- -- 4. То же место на тот же сеанс второй раз: ошибка UNIQUE
-- -- expect: error unique
-- INSERT INTO tickets (session_id, seat_id, price) VALUES (1, 1, 300);

-- Лаба 1. Проверка, что база отклоняет неправильные данные.

-- 1. Таблицы на месте: 6 таблиц
-- expect: rows 6
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY 1;

-- 2. Повтор уникального значения
-- expect: error unique
INSERT INTO clients (full_name, phone, email)
VALUES ('повтор', '+7-000-000-00-00', 'ivan.petrov@example.com');

-- 3. Нарушение CHECK
-- expect: error check
INSERT INTO equipment (name, category, price_day, status, point_id)
VALUES ('отрицательная цена', 'tent', -100.00, 'available', 1);

-- 4. Ссылка на несуществующую строку
-- expect: error fk
INSERT INTO rentals (client_id, point_id, starts_at, ends_at, status, total_price)
VALUES (99999, 1, '2025-01-01 10:00+10', '2025-01-02 10:00+10', 'active', 100.00);
