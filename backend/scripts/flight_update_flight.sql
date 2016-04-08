CREATE OR REPLACE FUNCTION aviation.flight_update_flight(
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
    _time timestamp with time zone)
  RETURNS integer AS
$BODY$
DECLARE
  flight_uuid uuid;
BEGIN
  flight_uuid = (SELECT session_uuid from aviation.flights
        WHERE icao_id = _icao_hex AND final_time = (SELECT max(final_time) FROM aviation.flights WHERE icao_id = _icao_hex));

  UPDATE aviation.flights SET final_time = _time, num_messages = num_messages+1 WHERE session_uuid=flight_uuid;

  -- check and update position 
  IF _lat != 0 AND _long != 0 THEN
    IF (SELECT path from aviation.flights where session_uuid = flight_uuid) IS NULL THEN
      -- create new geometry, no old geometry to update
      UPDATE aviation.flights SET path = st_makepoint(_long, _lat) WHERE session_uuid = flight_uuid;
    ELSE
      UPDATE aviation.flights SET path = st_addpoint(st_makeline(ARRAY [path]), st_makepoint(_long, _lat))
        WHERE session_uuid = flight_uuid;
    END IF;
  END IF;

  -- some sort of fucked up representation of the averages
    --couldn't think of a quick and dirty way of computing this properly
  -- check and update heading
  IF _heading > 0 THEN
   UPDATE aviation.flights SET avg_heading = ((_heading+avg_heading)/2)
      WHERE session_uuid = flight_uuid;
  END IF;
  -- check and update sqk code
  IF _sqk > 0 THEN
   UPDATE aviation.flights SET sqk = _sqk
      WHERE session_uuid = flight_uuid;
  END IF;

  -- check and update signal strength
  IF _signal_strength > 0 THEN
    UPDATE aviation.flights SET avg_sig = ((_signal_strength+avg_sig)/2)
      WHERE session_uuid = flight_uuid;
  END IF;

  -- check and update avg speed
  IF _speed > 0 THEN
    UPDATE aviation.flights SET avg_speed = ((_speed+avg_speed)/2)
      WHERE session_uuid = flight_uuid;
  END IF;

  -- check and update avg alt
  IF _alt > 0 THEN
    UPDATE aviation.flights SET alt_values = array_append(alt_values, _alt) 
      WHERE session_uuid = flight_uuid;
    UPDATE aviation.flights SET avg_alt = ((_alt+avg_alt)/2)
      WHERE session_uuid = flight_uuid;
  END IF;

  -- update flight number if it doesn't exsist
  IF (SELECT flight_number FROM aviation.flights WHERE session_uuid = flight_uuid) = '' THEN
    UPDATE aviation.flights SET flight_number = _flight_num
      WHERE session_uuid = flight_uuid;
  END IF;
  return 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION aviation.flight_update_flight(integer, text, integer, smallint, smallint, smallint, double precision, double precision, text, smallint, timestamp with time zone)
  OWNER TO postgres;
