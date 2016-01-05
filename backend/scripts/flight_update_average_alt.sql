-- Function: flight_update_avg_alt()

-- DROP FUNCTION flight_update_avg_alt();

CREATE OR REPLACE FUNCTION flight_update_avg_alt()
  RETURNS integer AS
$BODY$
DECLARE
BEGIN
  update test_table as tt
  set avg_alt = array_avg(tt.alt_values);
  return 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION flight_update_avg_alt()
  OWNER TO postgres;
