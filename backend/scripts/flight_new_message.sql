-- Function: flight_new_message(text, text, integer, smallint, smallint, smallint, text, double precision, double precision, smallint)

-- DROP FUNCTION flight_new_message(text, text, integer, smallint, smallint, smallint, text, double precision, double precision, smallint);

CREATE OR REPLACE FUNCTION flight_new_message(
    _icao_hex text,
    _flight_num text,
    _alt integer,
    _speed smallint,
    _heading smallint,
    _signal_strength smallint,
    _mode text,
    _lat double precision,
    _long double precision,
    _sqk smallint,
    _stationID integer,
    _time timestamp with time zone)
  RETURNS integer AS
$BODY$
DECLARE
	envelop geometry(Polygon,4326);
	newuuid uuid;
BEGIN
	newuuid = md5(random()::text || clock_timestamp()::text)::uuid;
	IF NOT exists(SELECT 1 FROM aircraft_spotted WHERE aircraft_spotted.icao_hex = _icao_hex) THEN
		-- Aircraft does not exsist in DB, must make flight for it aswell
		INSERT INTO aircraft_spotted VALUES (_icao_hex,
							newuuid, _flight_num, _time, _alt, _speed, 
							st_makepoint(_long, _lat), 1, -- messages recieved
							1 -- total sessions
							);
		perform flight_new_flight(newuuid, _icao_hex, _flight_num, _alt, _speed, _heading, _signal_strength, _lat, _long, _mode, _sqk, _stationID, _time);
	ELSIF exists(SELECT 1 from flights_seen WHERE flights_seen.icao_hex = _icao_hex AND final_time=(SELECT max(final_time) FROM flights_seen WHERE icao_hex=_icao_hex)) AND
							(age(_time, final_time) < '10 minutes'::interval) from flights_seen where final_time = (SELECT max(final_time)
								FROM flights_seen WHERE icao_hex=_icao_hex)THEN
		-- this message is part of a current flight
		perform flight_update_flight(_icao_hex, _flight_num, _alt, _speed, _heading, _signal_strength, _lat, _long,_mode, _sqk, _time);
		perform flight_update_aircraft(_icao_hex, _flight_num, _alt, _speed, _lat, _long, _time);
	-- if none of these a new flight needs to be created
	ELSE 
		UPDATE aircraft_spotted SET total_sessions=total_sessions+1
			WHERE icao_hex=_icao_hex;
		perform flight_update_aircraft(_icao_hex, _flight_num, _alt, _speed, _lat, _long, _time);
		perform flight_new_flight(newuuid, _icao_hex, _flight_num, _alt, _speed, _heading, _signal_strength, _lat, _long, _mode, _sqk, _stationID, _time);
	END IF;
	IF _alt=0 AND _speed=0 AND _heading=0 AND _lat=0.0 AND _long=0.0 THEN
		-- if this packet has nothing useful in it don't put it into the db, just update the aircraft and flight for last seen time
		return 1;
	END IF;
	perform flight_insert_message(_icao_hex, _alt, _speed, _heading, _signal_strength, _lat, _long, _stationID, _time);
	return 1;
	-- we always want to insert a new message

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION flight_new_message(text, text, integer, smallint, smallint, smallint, text, double precision, double precision, smallint)
  OWNER TO postgres;
