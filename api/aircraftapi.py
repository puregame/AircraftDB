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
@app.route('/help/addNote')
@app.route('/help/addNote/')
def addNoteGet():
    return static_file('addNote.html', root='html')

@app.route('/help/crossRef')
@app.route('/help/crossRef/')
def crossRef():
    return static_file('crossRef.html', root='html')

@app.route('/help/getStations/')
@app.route('/help/getStations')
def getSationsStatic():
    return static_file('getStations.html', root='html')

@app.route('/help/setStation/')
@app.route('/help/setStation')
def getSationsStatic():
    return static_file('setStation.html', root='html')

@app.route('/help/getAircraft/')
@app.route('/help/getAircraft')
def getSationsStatic():
    return static_file('getAircraft.html', root='html')

@app.route('/help/getFlights/')
@app.route('/help/getFlights')
def getSationsStatic():
    return static_file('getFlights.html', root='html')

@app.route('/help/getRecentFlights/')
@app.route('/help/getRecentFlights')
def getSationsStatic():
    return static_file('getRecentFlights.html', root='html')

@app.route("/help/newMessage")
@app.route("/help/newMessage/")
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

@app.get('/getStations/')
@app.get('/getStations')
def getStations():
    response.content_type = 'application/json'
    return dumps(connection.getStations())

@app.get('/lastTimeFromStation/')
@app.get('/lastTimeFromStation')
def lastTimeFromSta():
    query = request.query
    try:
        station_id = query["station_id"]
        return connection.lastTimeFromStation(station_id).isoformat()
    except Exception, e:
        return e.message
       # return "Request must contain a station"

@app.get('/crossRef/')
@app.get('/crossRef')
def crossRef():
    query = request.query
    try:
        icao_id = query["icao_id"]
        apiLog.debug("trying to get icao_id: " + str(icao_id))
        db_response = connection.crossRefID(int(icao_id, 16))
        if db_response != -1:
            response.content_type = 'application/json'
            return dumps(db_response);
        else:
            return "Error: icao ID not found!"
    except Exception, e:
        pass
    try:
        callsign = query["callsign"]
        apiLog.debug("trying to get callsign: " + str(callsign))
        db_response = connection.crossRefCallsign(callsign)
        if db_response != -1:
            response.content_type = 'application/json'
            return dumps(db_response);
        else:
            return "Error: callsign not found!"
    except Exception, e:
        pass
    return "ERROR: request must contain either icao_id or callsign"

@app.get('/getAircraft/')
@app.get('/getAircraft')
def getAircraft():
    query = request.query
    response.content_type = 'application/json'
    return dumps(connection.getAircraft(int(query["id"], 16)));

@app.get('/getFlights/')
@app.get('/getFlights')
def getFlights():
    query = request.query
    response.content_type = 'application/json'
    try:
        max_results = query["max_results"]
    except Exception, e:
        max_results = 0
    return dumps(connection.getFlights(int(query["id"], 16), max_results))

@app.get('/getRecentFlights/')
@app.get('/getRecentFlights')
def getRecentFlights():
    query = request.query
    response.content_type = 'application/json'
    try:
        max_results = query["max_results"]
    except Exception, e:
        max_results = 0
    try:
        station_id = query["station_id"]
    except Exception, e:
        station_id = 0
    try:
        max_time = query["max_time"]
    except Exception, e:
        max_time = 10
    return dumps(connection.getRecentFlights(int(max_results), station_id, max_time))

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
