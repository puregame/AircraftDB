##### Tables:
	Aircraft
	Messages
	Sessions (flights)

##### Functions:
	NOTE: most related functions begin with flight!
	Import message: (flight_new_message)
		1. Check if aircraft exsists, if not create it in Aircraft table
		2. Check if a session is open for this aircraft, if not create a new one
		3. Update latest session for this aircraft in aircraft table
		4. Import message into messages table (regardless of above)
	Add data to session:
		1. Get session UUID from fn call
		2. update table
	Funciton list:
		nuke() -- delete all spotted data in the database
		nuke_aircraft('icao_hex') -- delete all data relating to this aircraft

		flight_new_message(lots of parameters) -- insert new message into database
		flight_new_flight(lots of parameters) -- insert a new row into aircraft_spotted table
		flight_update_aircraft(lots of parameters) -- update a row in aircraft_spotted table
		flight_update_flight(lots of parameters) -- update a row in the flights_seen table


##### Aircraft:(aircraft_spotted)
	list of all aircraft we have seen

	Should include: 
		ICAO HEX
		latest session UUID
		Last flight number
		Last Seen at
		Avg altitude
		Avg speed
		Last position
		Total messages received
		Number of sessions recorded

##### Messages: (messages_seen)
	List of all messages ever received

	Should Include:
		Session UUID
		Aircraft UUID
		Timestamp
		Position
		Altitude
		Speed
		Heading
		Signal strength

##### Sessions (flights_seen):
	List of each flight (group of messages) seen from a single aircraft

	Definition: A group of messages separated by no more than 10 minutes. After 10 minutes a new session is created

	Should include: 
		Session UUID
		FLight number (could change for commercial airliners)
		Aircraft UUID (or HEX code, unique to each aircraft)
		Initial time & location
		Final time & location
		Distance Travelled in this session
		avg track
		Num messages
		avg signal strength
		Mode
		Sqk code