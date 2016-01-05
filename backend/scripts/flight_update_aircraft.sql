-- Function: flight_update_aircraft(uuid, text, text, integer, smallint, smallint, smallint, double precision, double precision, text)

-- DROP FUNCTION flight_update_aircraft(uuid, text, text, integer, smallint, smallint, smallint, double precision, double precision, text);

CREATE OR REPLACE FUNCTION flight_update_aircraft(
    _icao_hex text,
    _flight_num text,
    _alt integer,
    _speed smallint,
    _lat double precision,
    _long double precision,
    _time timestamp with time zone)
  RETURNS integer AS
$BODY$
DECLARE
  flight_uuid uuid;
BEGIN
  flight_uuid = (SELECT session_uuid from flights
        WHERE icao_hex=_icao_hex AND final_time=(SELECT max(final_time) FROM flights WHERE icao_hex=_icao_hex));
        
  UPDATE aircrafts SET total_msg_recieved=total_msg_recieved+1, last_seen_at=_time
          WHERE icao_hex=_icao_hex;

  IF NOT _flight_num = '' THEN
  UPDATE aircrafts SET last_flight_number=_flight_num
          WHERE icao_hex=_icao_hex;
  END IF;
  -- check and update lat/long
  IF _lat != 0 AND _long != 0 THEN
   UPDATE aircrafts SET last_position=st_makepoint(_long, _lat)
      WHERE icao_hex=_icao_hex;
  END IF;
   -- check and update avg speed
  IF _speed > 0 THEN
    UPDATE aircrafts SET avg_speed=((_speed+avg_speed)/2)
      WHERE icao_hex=_icao_hex;
  END IF;

  -- check and update avg alt
  IF _alt > 0 THEN
    UPDATE aircrafts SET avg_alt=((_alt+avg_alt)/2)
      WHERE icao_hex=_icao_hex;
  END IF;
  return 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION flight_update_aircraft( text, text, integer, smallint, double precision, double precision)
  OWNER TO postgres;
