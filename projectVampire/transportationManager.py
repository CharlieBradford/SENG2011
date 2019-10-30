class transportationManager():

    def __init__(self, destinations, location):
        self.locale = location # location of this transport manager
        self.destinations = destinations
        self.toSend = [] # blood that is to be sent

    # Get blood
    def receive(self, blood):
        self.toSend.append(blood)

    def addRoute(self, location, route):
        # add route to destinations
        destinations[location] = route;

    def dispatchBlood(self, blood, location):
        #location.recieveBlood(blood)
        self.toSend.remove(blood)
        print('Blood has been dispatched')

