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
    def __init__(self, name, coord):
        self.name = name
        self.coord = coord
        OP_blood = deque()
        AP_blood = deque()
        BP_blood = deque()
        ABP_blood = deque()
        ON_blood = deque()
        AN_blood = deque()
        BN_blood = deque()
        ABN_blood = deque()
        self.bloodStorage = [OP_blood, AP_blood, BP_blood, ABP_blood, ON_blood, AN_blood, BN_blood, ABN_blood]

    # Discards blood at 00:00 everyday
    def discardBlood(self):
        # Do some ongoing loop to check for 00:00
        for li in self.bloodStorage:
            if li:
                if self.daysTillExpiry(li[0]) < 2:
                    li.popleft()
                else:
                    break

    # Stores blood in the appropriate queue
    def storeBlood(self, blood):
        index = self.findIndex(blood.type, blood.rh)
        self.bloodStorage[index].append(blood)
        
    # Gets appropriate blood packet from storage and notifies transport to send it to destination
    def serviceRequest(self, type, rh, dest):
        index = self.findIndex(type, rh)
        blood = self.bloodStorage[index].popleft()
        self.notifyTransport(blood, dest)

    # Notifies transport so that they can prepare to transport the blood packet
    def notifyTransport(self, blood, dest):
        pass



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








