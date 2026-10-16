-- Лаба 1. Схема базы: таблицы, ключи, ограничения.
-- Скрипты из db/ выполняются по порядку имён при первом docker compose up.
-- Следующие лабы добавляют новые файлы (02_seed.sql, 03_..., 10_views.sql и так далее), этот файл остаётся.


CREATE TABLE clients (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name text NOT NULL,
    phone text NOT NULL,
    email text UNIQUE
);

CREATE TABLE points (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE,
    address text NOT NULL,
    phone text NOT NULL
);

CREATE TABLE equipment (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    category text NOT NULL,
    price_day numeric(10, 2) NOT NULL CHECK (price_day > 0),
    status text NOT NULL CHECK (status IN ('available', 'rented', 'repair')),
    point_id integer NOT NULL REFERENCES points (id)
);

CREATE TABLE rentals (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id integer NOT NULL REFERENCES clients (id),
    point_id integer NOT NULL REFERENCES points (id),
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL,
    status text NOT NULL CHECK (status IN ('active', 'returned', 'cancelled')),
    total_price numeric(10, 2) NOT NULL CHECK (total_price >= 0),
    created_at timestamptz NOT NULL DEFAULT now(),
    CHECK (ends_at > starts_at)
);

CREATE TABLE rental_items (
    rental_id integer NOT NULL REFERENCES rentals (id),
    equipment_id integer NOT NULL REFERENCES equipment (id),
    price numeric(10, 2) NOT NULL CHECK (price >= 0),
    PRIMARY KEY (rental_id, equipment_id)
);

CREATE TABLE deposits (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rental_id integer NOT NULL REFERENCES rentals (id),
    amount numeric(10, 2) NOT NULL,
    status text NOT NULL CHECK (status IN ('active', 'returned', 'forfeited')),
    created_at timestamptz NOT NULL DEFAULT now()
)



