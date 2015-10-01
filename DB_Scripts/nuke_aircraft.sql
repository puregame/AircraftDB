-- Function: nuke()

-- DROP FUNCTION nuke_aircraft();

CREATE OR REPLACE FUNCTION nuke_aircraft(_icao_hex text)
  RETURNS integer AS
$BODY$
DECLARE
BEGIN
	delete from aircraft_spotted * where icao_hex=_icao_hex;
	delete from messages_seen * where icao_hex=_icao_hex;
	delete from flights_seen* where icao_hex=_icao_hex;
	return 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION nuke_aircraft(text)
  OWNER TO postgres;
