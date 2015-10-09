from bottle import Bottle, run, request
from backend.database_connection import DB
from apiexception import *
app = Bottle()

connection = DB()


@app.route('/hello/')
def hello():
    try:
        latitude = request.query["lat"]
        longitude = request.query["lon"]
        print latitude
        print longitude
    except KeyError, e:
        print "an error occurred"
        pass

@app.route('/addNote')
def addNote():
    query=request.query
    try:
        icao_hex = query["id"]
        description = query["description"]
        connection.updateAircraftDescription(icao_hex, description)
    except ValueError, e:
        return "request must include id and message"
    return "worked"

@app.route('/newMessage/')
def newMessage():
    query=request.query
    data = {}
    try:
        # try to parse request
        try:
            data["id"] = query["id"]
            data["signal"] = query["signal"]
            data["time"] = query["time"]
            data["station"] = query["station"]
        except KeyError, e:
            raise APIException("Request must include aircraft ID, signal signal_strength, time, and station")
        try:
            data["sqk"] = query["sqk"]
            data["mode"] = query["mode"]
        except KeyError, e:
            data["sqk"] = 0
            data["mode"] = "0"
        try: # try to parse lat/lon
            data["lat"] = query["lat"]
            data["lon"] = query["lon"]
        except KeyError, e:
            data["lat"] = 0
            data["lon"] = 0
        try: # try to parse speed/heading
            data["speed"] = query["speed"]
            data["heading"] = query["heading"]
        except Exception, e:
            data["speed"] = 0
            data["heading"] = 0
        try: # try to parse fligt number
            data["flight"] = query["flight"]
        except KeyError, e:
            data["flight"] = "0"
        try: # try to parse fligt number
            data["altitude"] = query["altitude"]
        except KeyError, e:
            data["altitude"] = 0

        # Upload to database
        connection.newUserMessage(data)
    except APIException, e:
        return e.__str__()
    except Exception, e:
        print e
        return "ERROR"

run(app, host="localhost", port="8080")