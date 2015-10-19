from bottle import Bottle, route, run, request, static_file
import json
import datetime
import logging


# Internal py files
from backend.database_connection import DB
from apiexception import *
from apilogic import *

# Configure bottle
app = Bottle()
checker = aircraftChecker()
connection = DB()

# Configure logging
logFile="./apiLog.log"
logging.basicConfig(filename=logFile, format='%(asctime)s - %(name)s\t- %(levelname)s\t- %(message)s',level=logging.DEBUG)
apiLog = logging.getLogger("apiLog")

@app.route('/')
def main_page():
    return static_file('index.html', root='html/')

@app.route('/hello/')
def hello():
    return "hello world"

@app.route('/apiTest')
def apiTest():
    return "works"

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
    ip = request.environ.get('REMOTE_ADDR')
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
            return "Request must include aircraft ID, signal, time, and station"
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
    except APIException, e: 
        return e.__str__()
    except Exception, e:
        print e
        apiLog.error("Error in parsing request: " + str(data))
        return "Error"
    if checker.souldDBInsert(data):
        # Upload to database
        checker.performDBInsert(data)
        connection.newUserMessage(data)
        print "Recieved valid message from: " + ip
        apiLog.debug("Recieved valid message from: " + ip)
        return "Data accepted"

    # maybe get rid of logging the too soon messages?
    apiLog.debug("Recieved message too soon from: " + ip)
    return "Message not put in DB, too soon"
    

# listen on all network adapters on port 8090
run(app, host="0.0.0.0", port="8090")
