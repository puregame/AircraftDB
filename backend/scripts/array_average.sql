-- Function: array_avg(integer[])

-- DROP FUNCTION array_avg(integer[]);

CREATE OR REPLACE FUNCTION array_avg(integer[])
  RETURNS numeric AS
$BODY$ 
SELECT avg(v) FROM unnest($1) g(v) 
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION array_avg(integer[])
  OWNER TO postgres;
