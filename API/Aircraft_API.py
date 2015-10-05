
print "test"
from bottle import Bottle, route, run, request
import json
from Database_Connection import DB
from APIException import *
app = Bottle()

import datetime

connection = DB()


@app.route('/hello/')
def hello():
	try:
		latitude = request.query["lat"]
		longitude = request.query["lon"]
		print latitude
		print longitude
	except KeyError, e:
		print "an error occured"
		pass
	print "test"
	return "Hello World"

@app.route('/addNote')
def addNote():
	print "adding note"
	query=request.query
	print query
	try:
		icao_hex = query["id"]
		print icao_hex
		description = query["description"]
		print description
		print "adding: " + description + " to id: " +icao_hex
		connection.updateAircraftDescription(icao_hex, description)
	except ValueError, e:
		return "request must include id and message"
	return "worked"

@app.route('/newMessage/')
def newMessage():
	print("new message")
	recievedFlags = [0,0,0,0,0,0,0]
	query=request.query
	data = {}

	try: 
		# try to parse request 
		try:
			data["id"] = query["id"]
			data["signal"] = query["signal"]
			data["time"] = query["time"]
			data["station"] = query["station"]
			recievedFlags[0] = 1
		except KeyError, e:
			raise APIException("Request must include aircraft ID, signal signal_strength, time, and station")
		try:
			data["sqk"] = query["sqk"]
			data["mode"] = query["mode"]
			recievedFlags[1]=1
		except KeyError, e:
			data["sqk"] = 0
			data["mode"] = "0"
			pass
		try: # try to parse lat/lon
			data["lat"] = query["lat"]
			data["lon"] = query["lon"]
			recievedFlags[2] = 1
		except KeyError, e:
			data["lat"] = 0
			data["lon"] = 0
			pass
		try: # try to parse speed/heading
			data["speed"] = query["speed"]
			data["heading"] = query["heading"]
			recievedFlags[3] = 1
		except Exception, e:
			data["speed"] = 0
			data["heading"] = 0
			pass
		try: # try to parse fligt number
			data["flight"] = query["flight"]
			recievedFlags[4] = 1
		except KeyError, e:
			data["flight"] = "0"
			pass
		try: # try to parse fligt number
			data["altitude"] = query["altitude"]
			recievedFlags[5] = 1
		except KeyError, e:
			data["altitude"] = 0
			pass

		# Upload to database
		connection.newUserMessage(data)
	except APIException, e:
		return e.__str__()
	except Exception, e:
		print e
		return "ERROR"

	print data
print "test"
run(app, host="localhost", port="8080")