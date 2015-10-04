import psycopg2
import password # file for storing database connection properties

connection = psycopg2.connect(host = db_address, port = db_port, database=db_name, user=db_user, password=db_password)
cursor = connection.cursor()

class DB():
	"""docstring for DB"""
	def __init__():
		self.connection = psycopg2.connect(host = db_address, port = db_port, database=db_name, user=db_user, password=db_password)
		self.cursor = connection.cursor()

	def newUserMessage(self, data):
		cursor.execute("PERFORM flight_new_message(%(id)s, %(flight)s, %(altitude)s, %(speed)s, %(heading)s, %(signal)s, %(mode)s, %(lat)s, %(lon)s, %(sqk)s, %(station)s, %(time)s)"
					, data)
