CREATE OR REPLACE FUNCTION aviation.flight_new_message(
    _icao_hex integer,
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
	IF NOT exists(SELECT 1 FROM aviation.aircrafts WHERE icao_id = _icao_hex) THEN
		-- Aircraft does not exsist in DB, must make flight for it aswell
        IF _lat != 0 AND _long != 0 THEN
		    INSERT INTO aviation.aircrafts VALUES (_icao_hex,
							newuuid, _flight_num, _time, _stationID, _alt, _speed, 
							st_makepoint(_long, _lat), 1, -- messages recieved
							1 -- total sessions
							);
        ELSE
            INSERT INTO aviation.aircrafts VALUES (_icao_hex,
                            newuuid, _flight_num, _time, _stationID, _alt, _speed, 
                            NULL, 1, -- messages recieved
                            1 -- total sessions
                            );
        END IF;

		perform aviation.flight_new_flight(newuuid, _icao_hex, _flight_num, _alt, _speed, _heading, _signal_strength, _lat, _long, _mode, _sqk, _stationID, _time);
	ELSIF exists(SELECT 1 from aviation.flights WHERE icao_id = _icao_hex AND final_time=(SELECT max(final_time) FROM aviation.flights WHERE icao_id=_icao_hex) AND
							(age(_time, final_time) < '10 minutes'::interval))THEN
		-- this message is part of a current flight
		perform aviation.flight_update_flight(_icao_hex, _flight_num, _alt, _speed, _heading, _signal_strength, _lat, _long,_mode, _sqk, _time);
		perform aviation.flight_update_aircraft(_icao_hex, _flight_num, _alt, _speed, _lat, _long, _stationID, _time);
	-- if none of these a new flight needs to be created
	ELSE 
		UPDATE aviation.aircrafts SET total_flights=total_flights+1
			WHERE icao_id=_icao_hex;
		perform aviation.flight_update_aircraft(_icao_hex, _flight_num, _alt, _speed, _lat, _long, _stationID, _time);
		perform aviation.flight_new_flight(newuuid, _icao_hex, _flight_num, _alt, _speed, _heading, _signal_strength, _lat, _long, _mode, _sqk, _stationID, _time);
	END IF;
	IF _alt=0 AND _speed=0 AND _heading=0 AND _lat=0.0 AND _long=0.0 THEN
		-- if this packet has nothing useful in it don't put it into the db, just update the aircraft and flight for last seen time
		return 1;
	END IF;
    -- we always want to insert a new message
	perform aviation.flight_insert_message(_icao_hex, _alt, _speed, _heading, _signal_strength, _lat, _long, _stationID, _time);
	return 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION aviation.flight_new_message(integer, text, integer, smallint, smallint, smallint, text, double precision, double precision, smallint, integer, timestamp with time zone)
  OWNER TO postgres;