--- триггер бизнес-правила
CREATE OR REPLACE FUNCTION check_equipment_available()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF (SELECT status FROM equipment WHERE id = NEW.equipment_id) != 'available' THEN
        RAISE EXCEPTION 'Снаряжение % нельзя выдать: оно не доступно', NEW.equipment_id;
    END IF;
    RETURN NEW;
END;
$$;

-- триггер на вставку в позиции аренды
CREATE TRIGGER trg_check_equipment_available
BEFORE INSERT ON rental_items
FOR EACH ROW EXECUTE FUNCTION check_equipment_available();

--- служебный триггер
ALTER TABLE rentals ADD COLUMN updated_at timestamptz NOT NULL DEFAULT now();
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_rentals_updated_at
BEFORE UPDATE ON rentals
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
