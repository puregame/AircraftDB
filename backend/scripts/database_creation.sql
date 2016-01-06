CREATE DATABASE aviation;

CREATE EXTENSION postgis;
CREATE SCHEMA aviation;
CREATE USER aviator WITH PASSWORD 'aviationp123';

--*******AIRCRAFT SPOTTED TABLE*******--
-- Table: aircrafts

-- DROP TABLE aircrafts;

CREATE TABLE aviation.aircrafts
(
  icao_id integer NOT NULL, -- unique ICAO hex value found in each transponder
  latest_session uuid, -- UUID of the latest flight this aircraft was spotted on
  last_flight_number text,
  last_seen_at timestamp with time zone, -- when did we last see this aircraft?
  last_station integer,
  avg_alt integer, -- average altitude this aircraft has been observed to fly
  avg_speed integer, -- avg speed seen by this plane
  last_position geometry, -- last seen position of this aircraft
  total_msg_recieved bigint,
  total_flights integer,
  user_notes text,
  CONSTRAINT aircrafts_pkey PRIMARY KEY (icao_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE aviation.aircrafts
  OWNER TO postgres;
GRANT ALL ON TABLE aviation.aircrafts TO postgres;
GRANT SELECT ON TABLE aviation.aircrafts TO public;
COMMENT ON TABLE aviation.aircrafts
  IS 'Table of aircraft that have been spotted with the rpi system';
COMMENT ON COLUMN aviation.aircrafts.icao_id IS 'unique ICAO hex value found in each transponder';
COMMENT ON COLUMN aviation.aircrafts.latest_session IS 'UUID of the latest flight this aircraft was spotted on
';
COMMENT ON COLUMN aviation.aircrafts.last_seen_at IS 'when did we last see this aircraft?';
COMMENT ON COLUMN aviation.aircrafts.avg_alt IS 'average altitude this aircraft has been observed to fly';
COMMENT ON COLUMN aviation.aircrafts.avg_speed IS 'avg speed seen by this plane';
COMMENT ON COLUMN aviation.aircrafts.last_position IS 'last seen position of this aircraft';




--*******Messages seen TABLE*******--
-- Table: messages

-- DROP TABLE messages;

CREATE TABLE aviation.messages
(
  icao_id integer NOT NULL, -- aircraft icao hex
  session_uuid uuid, -- uuid of the session that this message belongs to
  "timestamp" timestamp with time zone NOT NULL, -- time this message was recieved
  "position" geometry, -- position of aircraft at this message
  altitude integer, -- alt of aircraft at this message
  heading smallint,
  speed smallint,
  signal_strength smallint,
  station_id integer,
  CONSTRAINT messages_pkey PRIMARY KEY (icao_id, "timestamp")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE aviation.messages
  OWNER TO postgres;
COMMENT ON COLUMN aviation.messages.icao_id IS 'aircraft icao hex';
COMMENT ON COLUMN aviation.messages.session_uuid IS 'uuid of the session that this message belongs to';
COMMENT ON COLUMN aviation.messages."timestamp" IS 'time this message was recieved';
COMMENT ON COLUMN aviation.messages."position" IS 'position of aircraft at this message';
COMMENT ON COLUMN aviation.messages.altitude IS 'alt of aircraft at this message';

--*******flights seen TABLE*******--
-- Table: flights

-- DROP TABLE flights;

CREATE TABLE aviation.flights
(
  session_uuid uuid NOT NULL,
  flight_number text,
  icao_id integer NOT NULL,
  initial_time timestamp with time zone,
  final_time timestamp with time zone,
  distance_travelled bigint, -- dist in m?
  avg_heading smallint, -- avg heading on this leg
  num_messages integer, -- messages in this session
  avg_sig smallint,
  path geometry, -- geographical path of flight (based on points recorded)
  mode text,
  avg_alt integer,
  avg_speed smallint,
  sqk smallint,
  station_id smallint,
  alt_values integer[],
  CONSTRAINT flights_pkey PRIMARY KEY (session_uuid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE aviation.flights
  OWNER TO postgres;
COMMENT ON TABLE aviation.flights
  IS 'log of all flights seen by this server';
COMMENT ON COLUMN aviation.flights.distance_travelled IS 'dist in m?';
COMMENT ON COLUMN aviation.flights.avg_heading IS 'avg heading on this leg';
COMMENT ON COLUMN aviation.flights.num_messages IS 'messages in this session';
COMMENT ON COLUMN aviation.flights.path IS 'geographical path of flight (based on points recorded)';

-- Table: stations

-- DROP TABLE stations;

CREATE TABLE aviation.stations
(
  station_id integer NOT NULL,
  description text,
  "position" geometry,
  added_on date,
  CONSTRAINT station_pkey PRIMARY KEY (station_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE aviation.stations
  OWNER TO postgres;
GRANT ALL ON TABLE aviation.stations TO postgres;
