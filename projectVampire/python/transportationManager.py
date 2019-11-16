class transportationManager():

    def __init__(self, destinations, location):
        self.locale = location # location of this transport manager
        self.destinations = destinations
        self.toSend = [] # blood that is to be sent

    # Get blood
    def receive(self, blood, dest):
        route = destinations[dest]
        if route == None:
            print("Don't have a route yet")
            # need to request a route
        self.toSend.append([blood,route])

    # Add route to destinations
    def addRoute(self, location, route):
        self.destinations[location] = route

    # Send blood to transportationRoute
    def dispatchBlood(self, blood, tRoute):
        for tup in toSend:
        	if tup[0] == blood:
        		tRoute.send(tup)
        		self.toSend.remove(tup)
       			print('Blood has been dispatched')

        return blood

