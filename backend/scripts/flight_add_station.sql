CREATE OR REPLACE FUNCTION flight_add_station(
    _id integer,
    _description text,
    _lat double precision,
    _long double precision)
  RETURNS integer AS
$BODY$
DECLARE
  flight_uuid uuid;
BEGIN
  IF NOT exists(SELECT * from stations where station_id = _id) THEN
    INSERT INTO stations VALUES (_id, _description, st_makepoint(_long, _lat), now());
    return 1;
  END IF;
  return 0;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION flight_add_station(integer, text, double precision, double precision)
  OWNER TO postgres;
