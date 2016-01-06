CREATE OR REPLACE FUNCTION flight_new_flight(
    new_uuid uuid,
    _icao_hex integer,
    _flight_num text,
    _alt integer,
    _speed smallint,
    _heading smallint,
    _signal_strength smallint,
    _lat double precision,
    _long double precision,
    _mode text,
    _sqk smallint,
    _stationID integer,
    _time timestamp with time zone)
  RETURNS integer AS
$BODY$
DECLARE
  arr_alt integer[] = NULL;
BEGIN
  IF _alt > 0 THEN
    arr_alt = ARRAY[_alt];
  END IF;
  IF _lat != 0 AND _long != 0 THEN
   INSERT INTO flights VALUES( new_uuid, _flight_num, _icao_hex,
          _time, _time, -- inital and final times
          0, -- dist travelled
          _heading,
          1, -- num messages
          _signal_strength,
          st_makepoint(_long, _lat),
          _mode,
          _alt,
          _speed, _sqk, _stationID, arr_alt);
  ELSE
    INSERT INTO flights VALUES( new_uuid, _flight_num, _icao_hex,
          _time, _time, -- inital and final times
          0, -- dist travelled
          _heading,
          1, -- num messages
          _signal_strength,
          NULL, -- point is null
          _mode,
          _alt,
          _speed, _sqk, _stationID, arr_alt);
  END IF;
  return 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION flight_new_flight(uuid, integer, text, integer, smallint, smallint, smallint, double precision, double precision, text, smallint, integer, timestamp with time zone)
  OWNER TO postgres;
