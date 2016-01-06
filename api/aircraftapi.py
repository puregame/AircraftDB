from bottle import Bottle, route, post, get, run, request, static_file, response
from json import dumps
import logging

# # Internal py files
from backend.database_connection import DB
from apiexception import *
from apilogic import *

# # Configure bottle
app = Bottle()
checker = aircraftChecker()
connection = DB()

# # Configure logging
logFile="../apiLog.log"
logging.basicConfig(filename=logFile, format='%(asctime)s - %(name)s\t- %(levelname)s\t- %(message)s',level=logging.DEBUG)
apiLog = logging.getLogger("apiLog")

@app.route('/')
def main_page():
    return static_file('index.html', root='html')

######## setup for static pages ############
@app.route('/addNote')
@app.route('/addNote/')
def addNoteGet():
    return static_file('addNote.html', root='html')

@app.route('/getStations/')
@app.route('/getStations')
def getSationsStatic():
    return static_file('getStations.html', root='html')

@app.route('/setStation/')
@app.route('/setStation')
def getSationsStatic():
    return static_file('setStation.html', root='html')

@app.route("/newMessage")
@app.route("/newMessage/")
def newMessageGet():
    return static_file('newMessage.html', root='html')

######## end setup  for static pages ############
# data input functions
@app.post('/addNote')
@app.post('/addNote/')
def addNote():
    query=request.query
    try:
        icao_hex = query["id"]
        description = query["description"]
        connection.updateAircraftDescription(icao_hex, description)
    except ValueError, e:
        return "request must include id and message"
    return "worked"

@app.post('/getStations/')
@app.post('/getStations')
def getStations():
    response.content_type = 'application/json'
    return dumps(connection.getStations())

@app.post('/getAircraft/')
@app.post('/getAircraft')
def getAircraft():
    query = request.query
    response.content_type = 'application/json'
    return dumps(connection.getAircraft(int(query["id"], 16)));

@app.post('/setStation/')
@app.post('/setStation')
def setStation():
    # set parameters of a station
    query = request.query
    data  = {}
    try:
        data["station_id"] = int(query["station_id"])
        data["description"] = query["description"]
        data["lat"] = float(query["lat"])
        data["lon"] = float(query["lon"])
    except Exception, e:
        print e
        apiLog.error("Error in parsing request: " + str(data))
        return "Error"
    print "connectig!"
    a = connection.newStation(data)
    if a:
        return "station updated"
    else:
        return "Station not update, ID probably in use!"
 

@app.post('/newMessage')
@app.post('/newMessage/')
def newMessage():
    ip = request.environ.get('REMOTE_ADDR')
    query=request.query
    data = {}
    try: 
        # try to parse request 
        try:
            data["id"] = int(query["id"], 16)#int(query["id"], 16)
                # opposite of this is str(hex(number))[2:]
            data["signal"] = query["signal"]
            data["time"] = query["time"]
            data["station"] = query["station"]
            data["mode"] = query["mode"]
        except KeyError, e:
            return "Request must include aircraft ID, signal, time, mode and station"
        try:
            # convert squawk code to hex
            data["sqk"] = hex(int(query["sqk"]))[2:]
        except KeyError, e:
            data["sqk"] = 0
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
            data["flight"] = ""
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
        apiLog.debug("Recieved valid message from: " + ip)
        return "Data accepted"

    # maybe get rid of logging the too soon messages?
    return "Message not put in DB, too soon"
    

# listen on all network adapters on port 8090
run(app, host="0.0.0.0", port="8090")
