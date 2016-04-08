CREATE OR REPLACE FUNCTION aviation.flight_update_aircraft(
    _icao_hex integer,
    _flight_num text,
    _alt integer,
    _speed smallint,
    _lat double precision,
    _long double precision,
    _station integer,
    _time timestamp with time zone)
  RETURNS integer AS
$BODY$
DECLARE
  flight_uuid uuid;
BEGIN
  flight_uuid = (SELECT session_uuid from aviation.flights
        WHERE icao_id=_icao_hex AND final_time=(SELECT max(final_time) FROM aviation.flights WHERE icao_id=_icao_hex));
        
  UPDATE aviation.aircrafts SET total_msg_recieved=total_msg_recieved+1, last_seen_at=_time, last_station=_station
          WHERE icao_id=_icao_hex;

  IF NOT _flight_num = '' THEN
  UPDATE aviation.aircrafts SET last_flight_number=_flight_num
          WHERE icao_id=_icao_hex;
  END IF;
  -- check and update lat/long
  IF _lat != 0 AND _long != 0 THEN
   UPDATE aviation.aircrafts SET last_position=st_makepoint(_long, _lat)
      WHERE icao_id=_icao_hex;
  END IF;
   -- check and update avg speed
  IF _speed > 0 THEN
    UPDATE aviation.aircrafts SET avg_speed=((_speed+avg_speed)/2)
      WHERE icao_id=_icao_hex;
  END IF;

  -- check and update avg alt
  IF _alt > 0 THEN
    UPDATE aviation.aircrafts SET avg_alt=((_alt+avg_alt)/2)
      WHERE icao_id=_icao_hex;
  END IF;
  return 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION aviation.flight_update_aircraft(integer, text, integer, smallint, double precision, double precision, integer, timestamp with time zone)
  OWNER TO postgres;
