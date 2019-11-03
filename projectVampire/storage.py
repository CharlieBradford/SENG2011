# Used for FIFO queues
from collections import deque
# Used to deal with time
from datetime import datetime

class storage :

    # Index for bloodStorage
    # OP_blood = 0
    # AP_blood = 1
    # BP_blood = 2
    # ABP_blood = 3
    # ON_blood = 4
    # AN_blood = 5
    # BN_blood = 6
    # ABN_blood = 7

    # Constructor
    def __init__(self, name, location):
        self._name = name
        self._location = location
        OP_blood = deque()
        AP_blood = deque()
        BP_blood = deque()
        ABP_blood = deque()
        ON_blood = deque()
        AN_blood = deque()
        BN_blood = deque()
        ABN_blood = deque()
        self._bloodStorage = [OP_blood, AP_blood, BP_blood, ABP_blood, ON_blood, AN_blood, BN_blood, ABN_blood]
        self._transportationManager = None

    # Adds a transportation manager
    def addTransportationManager(self, tManager):
        self._transportationManager = tManager

    # Discards blood at 00:00 everyday
    def discardBlood(self):
        # Do some ongoing loop to check for 00:00
        for li in self._bloodStorage:
            discarding = True
            while discarding:
                if li:
                    if self.daysTillExpiry(li[0]) < 2:
                        li.popleft()
                    else:
                        discarding = False

    # Stores blood in the appropriate queue
    def storeBlood(self, blood):
        index = self.findIndex(blood.type, blood.rhesus)
        self._bloodStorage[index].append(blood)
        
    # Gets appropriate blood packet from storage and notifies transport to send it to destination
    def serviceRequest(self, type, rh, dest):
        index = self.findIndex(type, rh)
        blood = self._bloodStorage[index].popleft()
        self.notifyTransport(blood, dest)

    # Notifies transport so that they can transport the blood packet
    def notifyTransport(self, blood, dest):
        self._transportationManager.prepareRequest(blood, dest)
        self._transportationManager.dispatchBlood()



    # HELPER FUNCTION - Finds correct index for corresponding blood type
    def findIndex(self, type, rh):
        if type == "O" and rh == True:
            return 0
        elif type == "A" and rh == True:
            return 1
        elif type == "B" and rh == True:
            return 2
        elif type == "AB" and rh == True:
            return 3
        elif type == "O" and rh == False:
            return 4
        elif type == "A" and rh == False:
            return 5
        elif type == "B" and rh == False:
            return 6
        elif type == "AB" and rh == False:
            return 7

    # HELPER FUNCTION - Finds correct index for corresponding blood type
    def daysTillExpiry(self, blood):
        curr_time = datetime.datetime.now()
        blood_expiry = blood.getExpiry()
        time_diff = curr_time - blood_expiry

        return time_diff.days

class transportationManager():

    def __init__(self, location):
        self.location = location
        self.requests = []

    def prepareRequest(self, blood, dest):
        route = self.createRoute(dest)
        request = transportationRequest(blood, route)
        self.requests.append(request)

    def createRoute(self, dest):
        route = transportationRoute(self.location, dest)
        route.calculateDuration()
        return route

    def dispatchBlood(self, blood, location):
        for req in self.requests:
            self.requests.remove(req)
            # Do something to let the system know that something is dispatched
            # and should arrive at the destination after route.duration
        print('All reuests have been dispatched')

class transportationRoute:

    def __init__(self, source, destination):
        self.source = source
        self.destination = destination
        self.duration = 0
    
    def calculateDuration(self):
        # (by coords, just use linear journey - calculate hypotenuse)
        pass

class transportationRequest:

    def __init__(self, blood, route):
        self._blood = blood
        self._route = route
