-- Исправленная бизнес-операция: блокируем строку equipment до конца транзакции
CREATE OR REPLACE FUNCTION create_rental_safe(
    p_client_id integer,
    p_point_id integer,
    p_equipment_id integer,
    p_days integer
) RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public, pg_temp
AS $$
DECLARE
    v_rental_id integer;
    v_price numeric(10,2);
    v_status text;
BEGIN
    -- блок строки до конца транзакции: вторая сессия ждёт
    SELECT status, price_day INTO v_status, v_price
    FROM equipment WHERE id = p_equipment_id
    FOR UPDATE;

    IF v_status IS DISTINCT FROM 'available' THEN
        RAISE EXCEPTION 'Снаряжение % уже на руках или в ремонте', p_equipment_id;
    END IF;

    INSERT INTO rentals (client_id, point_id, starts_at, ends_at, status, total_price)
    VALUES (p_client_id, p_point_id, now(), now() + (p_days || ' days')::interval,
            'active', v_price * p_days)
    RETURNING id INTO v_rental_id;

    INSERT INTO rental_items (rental_id, equipment_id, price)
    VALUES (v_rental_id, p_equipment_id, v_price);

    UPDATE equipment SET status = 'rented' WHERE id = p_equipment_id;

    RETURN v_rental_id;
END;
$$;