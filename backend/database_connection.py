import psycopg2
import logging
from psycopg2 import IntegrityError
from password import * # file for storing database connection properties
import logging
import json
import datetime
localLog = logging.getLogger("database")

class DB:
    """docstring for DB"""
    def __init__(self):
        self.connection = psycopg2.connect(host=db_address, port=db_port, database=db_name, user=db_user, password=db_password)
        self.cursor = self.connection.cursor()
        self.apiLog = logging.getLogger("databasConn")

    def newStation(self, data):
        self.apiLog.debug("select flight_add_station(%(station_id)s::integer, %(description)s::text, %(lat)s::double precision, %(lon)s::double precision);", data)
        self.cursor.execute("select flight_add_station(%(station_id)s, %(description)s::text, %(lat)s::double precision, %(lon)s::double precision);"
            , data)
        self.connection.commit()
        if self.cursor.fetchone()[0] == 0:
            return False
        else:
            return True 

    def default(self, obj):
            if isinstance(obj, datetime.datetime):
                return obj.isoformat()
            else:
                return self.default(obj)

    def asiso(self, obj):
        return obj.isoformat() if hasattr(obj, 'isoformat') else obj
        
    def getStations(self):
        self.cursor.execute("select station_id, description, st_asgeojson(position), added_on from stations")
        # jsonify response
        data = self.cursor.fetchall();
        response = []
        for i in data:
            response.append({"id":i[0], "description":i[1], "position":i[2], "date_added":self.asiso(i[3])})
        return response;

    def getAircraft(self, icao_id):
        #icao ID as integer
        self.cursor.execute("select last_flight_number, last_seen_at, avg_alt, avg_speed, st_asgeojson(last_position), last_station, total_flights, user_notes from aircrafts WHERE icao_id = %s", [icao_id])
        self.apiLog.debug("select last_flight_number, last_seen_at, avg_alt, avg_speed, st_asgeojson(last_position), last_station, total_flights, user_notes from aircrafts WHERE icao_id = %s", [icao_id])
        # jsonify response
        data = self.cursor.fetchall();
        response = []
        for i in data:
            response.append({"icao_id":str(hex(icao_id))[2:], "last_flight_number":i[0], "last_seen_at":self.asiso(i[1]), "avg_alt":i[2], "avg_speed":i[3], "last_position":i[4], "last_station":i[5], "total_flights":i[6], "user_notes":i[7]})
        return response;

    def getFlights(self, icao_id):
        self.cursor.execute("select flight_number, initial_time, final_time, avg_heading, num_messages, st_asgeojson(path), avg_alt, avg_speed, sqk, station_id from flights WHERE icao_id = %s", [icao_id])
        self.apiLog.debug("select flight_number, initial_time, final_time, avg_heading, num_messages, st_asgeojson(path), avg_alt, avg_speed, sqk, station_id from flights WHERE icao_id = %s", [icao_id])
        # jsonify response
        data = self.cursor.fetchall();
        response = []
        for i in data:
            response.append({"flight_number":i[0]), "initial_time":self.asiso(i[1]), "final_time":self.asiso(i[2]), "avg_heading":i[3], "num_messages":i[4], "path":i[5], "avg_altitude":i[6], "avg_speed":i[7], "sqk":i[8], "station_id":i[9])
        return response;

    def newUserMessage(self, data):
        try:
            self.cursor.execute("select flight_new_message(%(id)s::integer, %(flight)s::text, %(altitude)s, %(speed)s::smallint, %(heading)s::smallint, %(signal)s::smallint, %(mode)s, %(lat)s::double precision, %(lon)s::double precision, %(sqk)s::smallint, %(station)s, %(time)s::timestamp with time zone)"
                        , data)
            self.connection.commit()
        except Exception,e :# should check for IntegrityError but that doesn't seem to work
            # if an exception happens here we just need to rollback the current transaction and restart it
            self.apiLog.debug("select flight_new_message(%(id)s::integer, %(flight)s::text, %(altitude)s, %(speed)s::smallint, %(heading)s::smallint, %(signal)s::smallint, %(mode)s, %(lat)s::double precision, %(lon)s::double precision, %(sqk)s::smallint, %(station)s, %(time)s::timestamp with time zone)")
            self.connection.rollback()
            self.cursor.execute("select flight_new_message(%(id)s::integer, %(flight)s::text, %(altitude)s, %(speed)s::smallint, %(heading)s::smallint, %(signal)s::smallint, %(mode)s, %(lat)s::double precision, %(lon)s::double precision, %(sqk)s::smallint, %(station)s, %(time)s::timestamp with time zone)"
                        , data)
            self.connection.commit()

    def updateAircraftDescription(self, icao_id, description):
        self.cursor.execute("UPDATE aircraft_spotted set user_notes=%(note)s where icao_id=%(id)s", {'note':description, 'id':icao_id})
        self.connection.commit()
        # cursor.execute("UPDATE aircraft_spotted set user_notes=%(note)s where icao_id=%(id)s", {'note':description, 'id':icao_id})