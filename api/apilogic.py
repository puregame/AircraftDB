from datetime import datetime, timedelta


ignoreDelay = 1 # time delay to ignore messages, in seconds
cleanupDelay = 1 # time delay to celan up hex codes to ignore, in seconds

class aircraftChecker():
    """Class to ensure all aircraft data is unique"""
    def __init__(self):
        self.toIgnore = [] # array of aircraft to ignore
        self.lastCleanup = datetime.now()

    def cleanupToIgnore(self):
        for i in self.toIgnore:
            # if this aircraft was set to be ignored more than 10 seconds ago
            if i[0] < (datetime.now()-timedelta(seconds=ignoreDelay)): 
                self.toIgnore.remove(i)

    def souldDBInsert(self, data):
        # DO NOT ignore messages that have a flight number, since this could be rare
        if data["flight"] != "":
            return True
        if self.lastCleanup < (datetime.now()-timedelta(seconds=cleanupDelay)):
            self.cleanupToIgnore()
            self.lastCleanup = datetime.now()
        # check each toIgnore aircraft against data, if aircraft is in list return false
        for i in self.toIgnore:
            if i[1] == data["id"]:
                return False
        # if aircraft is not in toIgnore return true
        return True
        
    def performDBInsert(self, data):
        # IF this message has a lat&lon or altitude
        if data["lat"] != 0 or data["altitude"] != 0:
            # add icao hex to toIgnore list, along with timestamp
            self.toIgnore.append([datetime.now(), data["id"]]);

    def printDebug(self):
        print "toIgnore: " 
        print self.toIgnore
        print "lastCleanup: " 
        print self.lastCleanup