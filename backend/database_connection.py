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

    def newUserMessage(self, data):
        try:
            self.cursor.execute("select flight_new_message(%(id)s::text, %(flight)s::text, %(altitude)s, %(speed)s::smallint, %(heading)s::smallint, %(signal)s::smallint, %(mode)s, %(lat)s::double precision, %(lon)s::double precision, %(sqk)s::smallint, %(station)s, %(time)s::timestamp with time zone)"
                        , data)
            self.connection.commit()
        except Exception,e :# should check for IntegrityError but that doesn't seem to work
            # if an exception happens here we just need to rollback the current transaction and restart it
            self.apiLog.debug("select flight_new_message(%(id)s::text, %(flight)s::text, %(altitude)s, %(speed)s::smallint, %(heading)s::smallint, %(signal)s::smallint, %(mode)s, %(lat)s::double precision, %(lon)s::double precision, %(sqk)s::smallint, %(station)s, %(time)s::timestamp with time zone)")
            self.connection.rollback()
            self.cursor.execute("select flight_new_message(%(id)s::text, %(flight)s::text, %(altitude)s, %(speed)s::smallint, %(heading)s::smallint, %(signal)s::smallint, %(mode)s, %(lat)s::double precision, %(lon)s::double precision, %(sqk)s::smallint, %(station)s, %(time)s::timestamp with time zone)"
                        , data)
            self.connection.commit()

    def updateAircraftDescription(self, icao_hex, description):
        self.cursor.execute("UPDATE aircraft_spotted set user_notes=%(note)s where icao_hex=%(id)s", {'note':description, 'id':icao_hex})
        self.connection.commit()
        # cursor.execute("UPDATE aircraft_spotted set user_notes=%(note)s where icao_hex=%(id)s", {'note':description, 'id':icao_hex})