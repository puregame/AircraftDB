-- Function: flight_insert_message(text, integer, smallint, smallint, smallint, double precision, double precision)

-- DROP FUNCTION flight_insert_message(text, integer, smallint, smallint, smallint, double precision, double precision);

CREATE OR REPLACE FUNCTION flight_insert_message(
    _icao_hex text,
    _alt integer,
    _speed smallint,
    _heading smallint,
    _signal_strength smallint,
    _lat double precision,
    _long double precision,
    _stationID integer)
  RETURNS integer AS
$BODY$
DECLARE
	envelop geometry(Polygon,4326);
	newuuid uuid;
BEGIN
	
	INSERT INTO messages_seen VALUES (_icao_hex, newuuid, now(), st_makepoint(_long, _lat),
						_alt, _heading, _speed, _signal_strength, _stationID);
	return 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION flight_insert_message(text, integer, smallint, smallint, smallint, double precision, double precision)
  OWNER TO postgres;
