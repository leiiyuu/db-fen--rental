\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD

CREATE ROLE app_reader LOGIN PASSWORD :'reader_password';
CREATE ROLE app_writer LOGIN PASSWORD :'writer_password' IN ROLE app_reader;

GRANT CONNECT ON DATABASE app TO app_reader, app_writer;
GRANT USAGE ON SCHEMA public TO app_reader, app_writer;

-- снимает права на табл и вызов функций
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM app_reader, app_writer;
REVOKE ALL ON ALL ROUTINES IN SCHEMA public FROM PUBLIC;

-- выдача прав
GRANT SELECT ON v_rental_details, v_available_equipment TO app_reader;

GRANT EXECUTE ON FUNCTION create_rental_safe(integer, integer, integer, integer) TO app_writer;