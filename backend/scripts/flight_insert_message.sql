CREATE OR REPLACE FUNCTION flight_insert_message(
    _icao_hex integer,
    _alt integer,
    _speed smallint,
    _heading smallint,
    _signal_strength smallint,
    _lat double precision,
    _long double precision,
    _stationID integer,
    _time timestamp with time zone)
  RETURNS integer AS
$BODY$
DECLARE
  envelop geometry(Polygon,4326);
  newuuid uuid;
BEGIN
  IF _lat != 0 AND _long != 0 THEN
    INSERT INTO messages VALUES (_icao_hex, newuuid, _time, st_makepoint(_long, _lat),
            _alt, _heading, _speed, _signal_strength, _stationID);
  ELSE
    INSERT INTO messages VALUES (_icao_hex, newuuid, _time, NULL,
            _alt, _heading, _speed, _signal_strength, _stationID);
  END IF;
  return 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION flight_insert_message(integer, integer, smallint, smallint, smallint, double precision, double precision, integer, timestamp with time zone)
  OWNER TO postgres;
