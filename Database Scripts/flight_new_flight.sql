-- Function: flight_new_flight(uuid, text, text, integer, smallint, smallint, smallint, double precision, double precision, text, smallint)

-- DROP FUNCTION flight_new_flight(uuid, text, text, integer, smallint, smallint, smallint, double precision, double precision, text, smallint);

CREATE OR REPLACE FUNCTION flight_new_flight(
    new_uuid uuid,
    _icao_hex text,
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
BEGIN
  
   INSERT INTO flights_seen VALUES( new_uuid, _flight_num, _icao_hex,
          _time, _time, -- inital and final times
          0, -- dist travelled
          _heading,
          1, -- num messages
          _signal_strength,
          st_makepoint(_lat, _long),
          _mode,
          _alt,
          _speed, _sqk, _stationID);
  return 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION flight_new_flight(uuid, text, text, integer, smallint, smallint, smallint, double precision, double precision, text, smallint)
  OWNER TO postgres;
