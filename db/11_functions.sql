
--- 1. подсчёт аренд клиента
CREATE OR REPLACE FUNCTION get_client_rentals_count(p_client_id integer)
RETURNS integer
LANGUAGE sql
AS $$
    SELECT count(*)::integer FROM rentals WHERE client_id = p_client_id;
$$;

--- 2. бизнес-операция
CREATE OR REPLACE FUNCTION create_rental(
    p_client_id integer,
    p_point_id integer,
    p_equipment_id integer,
    p_days integer
) RETURNS integer 
LANGUAGE plpgsql
AS $$
DECLARE
    v_rental_id integer;
    v_price numeric(10,2);
BEGIN
    -- свободно ли снаряжение
    IF (SELECT status FROM equipment WHERE id = p_equipment_id) != 'available' THEN
        RAISE EXCEPTION 'Снаряжение % уже на руках или в ремонте', p_equipment_id;
    END IF;

    -- цена за день
    SELECT price_day INTO v_price FROM equipment WHERE id = p_equipment_id;

    -- создаётся аренда
    INSERT INTO rentals (client_id, point_id, starts_at, ends_at, status, total_price)
    VALUES (p_client_id, p_point_id, now(), now() + (p_days || ' days')::interval, 'active', v_price * p_days)
    RETURNING id INTO v_rental_id;

    -- добавляется позиция
    INSERT INTO rental_items (rental_id, equipment_id, price)
    VALUES (v_rental_id, p_equipment_id, v_price);

    -- меняется статус снаряжения
    UPDATE equipment SET status = 'rented' WHERE id = p_equipment_id;

    RETURN v_rental_id;
END;
$$;


--- ★ поиск с фильтрами
CREATE OR REPLACE FUNCTION search_equipment(
    p_category text DEFAULT NULL,
    p_status text DEFAULT NULL
) RETURNS TABLE (id integer, name text, category text, price_day numeric) 
LANGUAGE sql
AS $$
    SELECT e.id, e.name, e.category, e.price_day
    FROM equipment e
    WHERE (p_category IS NULL OR e.category = p_category)
      AND (p_status IS NULL OR e.status = p_status)
    LIMIT 10;
$$;