from bottle import Bottle, route, run, request
import json
from Database_Connection import DB
from APIException import *
app = Bottle()

import datetime
import logging

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
	return "Hello World"

@app.route('/addNote')
def addNote():
	print json.dumps(request.query)
	try:
		icao_hex = query["id"]
		message = query["message"]
	except ValueError, e:
		return "request must include id and message"

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
			data["time_stamp"] = query["time"]
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
			data["mode"] = 0
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
			data["flight"] = 0
			pass
		try: # try to parse fligt number
			data["altitude"] = query["altitude"]
			recievedFlags[5] = 1
		except KeyError, e:
			data["altitude"] = 0
			pass

		# Upload to database

	except APIException, e:
		return e.__str__()
	except Exception, e:
		return e.Value

	print data

run(app, host="localhost", port="8080")