
-- join collected data with aircraft registration and type data in database
select a.icao_hex, a.last_seen_at, a.avg_speed, a.total_sessions, i.hex, i.registration, i.type from aircrafts as a inner join icao24plus as i on a.icao_hex = i.hex
    order by a.total_sessions desc

-- export flights data to csv file
COPY (

select * from flights where avg_alt > 0 and mode != 'a' and final_time > '2015-11-23 16:30:00.000000-5' order by final_time desc 

) TO '/home/postgres/test.csv' with csv;

