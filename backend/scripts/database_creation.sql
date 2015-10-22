CREATE DATABASE aviation;

CREATE EXTENSION postgis;
CREATE SCHEMA aviation;
CREATE USER aviator WITH PASSWORD 'aviationp123';

--*******AIRCRAFT SPOTTED TABLE*******--
-- Table: aircraft_spotted

-- DROP TABLE aircraft_spotted;

CREATE TABLE aviation.aircraft_spotted
(
  icao_hex text NOT NULL, -- unique ICAO hex value found in each transponder
  latest_session uuid, -- UUID of the latest flight this aircraft was spotted on
  last_flight_number text,
  last_seen_at timestamp with time zone, -- when did we last see this aircraft?
  avg_alt integer, -- average altitude this aircraft has been observed to fly
  avg_speed integer, -- avg speed seen by this plane
  last_position geometry, -- last seen position of this aircraft
  total_msg_recieved bigint,
  total_sessions integer,
  user_notes text,
  CONSTRAINT aircraft_spotted_pkey PRIMARY KEY (icao_hex)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE aircraft_spotted
  OWNER TO postgres;
GRANT ALL ON TABLE aircraft_spotted TO postgres;
GRANT SELECT ON TABLE aircraft_spotted TO public;
COMMENT ON TABLE aircraft_spotted
  IS 'Table of aircraft that have been spotted with the rpi system';
COMMENT ON COLUMN aircraft_spotted.icao_hex IS 'unique ICAO hex value found in each transponder';
COMMENT ON COLUMN aircraft_spotted.latest_session IS 'UUID of the latest flight this aircraft was spotted on
';
COMMENT ON COLUMN aircraft_spotted.last_seen_at IS 'when did we last see this aircraft?';
COMMENT ON COLUMN aircraft_spotted.avg_alt IS 'average altitude this aircraft has been observed to fly';
COMMENT ON COLUMN aircraft_spotted.avg_speed IS 'avg speed seen by this plane';
COMMENT ON COLUMN aircraft_spotted.last_position IS 'last seen position of this aircraft';




--*******Messages seen TABLE*******--
-- Table: messages_seen

-- DROP TABLE messages_seen;

CREATE TABLE aviation.messages_seen
(
  icao_hex text NOT NULL, -- aircraft icao hex
  session_uuid uuid, -- uuid of the session that this message belongs to
  "timestamp" timestamp with time zone NOT NULL, -- time this message was recieved
  "position" geometry, -- position of aircraft at this message
  altitude integer, -- alt of aircraft at this message
  heading smallint,
  speed smallint,
  signal_strength smallint,
  station_id integer,
  CONSTRAINT messages_pkey PRIMARY KEY (icao_hex, "timestamp")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE aviation.messages_seen
  OWNER TO postgres;
COMMENT ON COLUMN aviation.messages_seen.icao_hex IS 'aircraft icao hex';
COMMENT ON COLUMN aviation.messages_seen.session_uuid IS 'uuid of the session that this message belongs to';
COMMENT ON COLUMN aviation.messages_seen."timestamp" IS 'time this message was recieved';
COMMENT ON COLUMN aviation.messages_seen."position" IS 'position of aircraft at this message';
COMMENT ON COLUMN aviation.messages_seen.altitude IS 'alt of aircraft at this message';

--*******flights seen TABLE*******--
-- Table: flights_seen

-- DROP TABLE flights_seen;

CREATE TABLE aviation.flights_seen
(
  session_uuid uuid NOT NULL,
  flight_number text,
  icao_hex text,
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
  CONSTRAINT flights_seen_pkey PRIMARY KEY (session_uuid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE aviation.flights_seen
  OWNER TO postgres;
COMMENT ON TABLE aviation.flights_seen
  IS 'log of all flights seen by this server';
COMMENT ON COLUMN aviation.flights_seen.distance_travelled IS 'dist in m?';
COMMENT ON COLUMN aviation.flights_seen.avg_heading IS 'avg heading on this leg';
COMMENT ON COLUMN aviation.flights_seen.num_messages IS 'messages in this session';
COMMENT ON COLUMN aviation.flights_seen.path IS 'geographical path of flight (based on points recorded)';

-- Table: base_stations

-- DROP TABLE base_stations;

CREATE TABLE aviation.base_stations
(
  station_id integer NOT NULL,
  description text,
  "position" geometry,
  "added ON" date,
  CONSTRAINT station_pkey PRIMARY KEY (station_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE aviation.base_stations
  OWNER TO postgres;
GRANT ALL ON TABLE aviation.base_stations TO postgres;
