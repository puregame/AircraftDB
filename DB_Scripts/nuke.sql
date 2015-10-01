-- Function: nuke()

-- DROP FUNCTION nuke();

CREATE OR REPLACE FUNCTION nuke()
  RETURNS integer AS
$BODY$
DECLARE
BEGIN
	delete from aircraft_spotted *;
	delete from messages_seen *;
	delete from flights_seen*;
	return 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION nuke()
  OWNER TO postgres;
