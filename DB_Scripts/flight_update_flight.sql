-- Function: flight_update_flight(text, text, integer, smallint, smallint, smallint, double precision, double precision, text, smallint)

-- DROP FUNCTION flight_update_flight(text, text, integer, smallint, smallint, smallint, double precision, double precision, text, smallint);

CREATE OR REPLACE FUNCTION flight_update_flight(
    _icao_hex text,
    _flight_num text,
    _alt integer,
    _speed smallint,
    _heading smallint,
    _signal_strength smallint,
    _lat double precision,
    _long double precision,
    _mode text,
    _sqk smallint)
  RETURNS integer AS
$BODY$
DECLARE
  flight_uuid uuid;
BEGIN
  flight_uuid = (SELECT session_uuid from flights_seen
        WHERE icao_hex=_icao_hex AND final_time=(SELECT max(final_time) FROM flights_seen WHERE icao_hex=_icao_hex));

  UPDATE flights_seen SET final_time = now(), num_messages=num_messages+1 WHERE session_uuid=flight_uuid;

  -- check and update position 
  IF _lat != 0 AND _long != 0 THEN
   UPDATE flights_seen SET path= st_addpoint(st_makeline(ARRAY [path]), st_makepoint(_long, _lat))
      WHERE session_uuid=flight_uuid;
  END IF;

  -- some sort of fucked up representation of the averages
    --couldn't think of a quick and dirty way of computing this properly
  -- check and update heading
  IF _heading > 0 THEN
   UPDATE flights_seen SET avg_heading=((_heading+avg_heading)/2)
      WHERE session_uuid=flight_uuid;
  END IF;
  -- check and update sqk code
  IF _sqk > 0 THEN
   UPDATE flights_seen SET sqk=_sqk
      WHERE session_uuid=flight_uuid;
  END IF;

  -- check and update signal strength
  IF _signal_strength > 0 THEN
    UPDATE flights_seen SET avg_sig=((_signal_strength+avg_sig)/2)
      WHERE session_uuid=flight_uuid;
  END IF;

  -- check and update avg speed
  IF _speed > 0 THEN
    UPDATE flights_seen SET avg_speed=((_speed+avg_speed)/2)
      WHERE session_uuid=flight_uuid;
  END IF;

  -- check and update avg alt
  IF _alt > 0 THEN
    UPDATE flights_seen SET avg_alt=((_alt+avg_alt)/2)
      WHERE session_uuid=flight_uuid;
  END IF;

  -- update flight number if it doesn't exsist
  IF NOT exists(SELECT flight_number FROM flights_seen WHERE icao_hex = _icao_hex) THEN
    UPDATE flights_seen SET flight_number=_flight_num
      WHERE session_uuid=flight_uuid;
  END IF;
  return 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION flight_update_flight(text, text, integer, smallint, smallint, smallint, double precision, double precision, text, smallint)
  OWNER TO postgres;
