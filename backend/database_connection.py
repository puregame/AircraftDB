import psycopg2
from psycopg2 import IntegrityError
from password import * # file for storing database connection properties

print db_address

connection = psycopg2.connect(host=db_address, port=db_port, database=db_name, user=db_user, password=db_password)
cursor = connection.cursor()


class DB:
    """docstring for DB"""
    def __init__(self):
        self.connection = psycopg2.connect(host=db_address, port=db_port, database=db_name, user=db_user, password=db_password)
        self.cursor = self.connection.cursor()

    def newUserMessage(self, data):
        try:
            self.cursor.execute("select flight_new_message(%(id)s::text, %(flight)s::text, %(altitude)s, "
                                "%(speed)s::smallint, %(heading)s::smallint, %(signal)s::smallint, %(mode)s, "
                                "%(lat)s::double precision, %(lon)s::double precision, %(sqk)s::smallint, "
                                "%(station)s, %(time)s::timestamp with time zone)", data)
            self.connection.commit()
        except Exception,e :# should check for IntegrityError but that doesn't seem to work
            # if an exception happens here we just need to rollback the current transaction and restart it
            self.connection.rollback()
            self.cursor.execute("select flight_new_message(%(id)s::text, %(flight)s::text, %(altitude)s, "
                                "%(speed)s::smallint, %(heading)s::smallint, %(signal)s::smallint, %(mode)s, "
                                "%(lat)s::double precision, %(lon)s::double precision, %(sqk)s::smallint, "
                                "%(station)s, %(time)s::timestamp with time zone)", data)
            self.connection.commit()

    def updateAircraftDescription(self, icao_hex, description):
        self.cursor.execute("UPDATE aircraft_spotted set user_notes=%(note)s where icao_hex=%(id)s", {'note':description, 'id':icao_hex})
        self.connection.commit()
        # cursor.execute("UPDATE aircraft_spotted set user_notes=%(note)s where icao_hex=%(id)s", {'note':description, 'id':icao_hex})