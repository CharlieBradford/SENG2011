# Used to deal with time
from datetime import datetime

# Own queue in dafny, verify that queues are sorted

class storage :

    # Index for bloodStorage
    # AP_blood = 0
    # AN_blood = 1
    # BP_blood = 2
    # BN_blood = 3
    # ABP_blood = 4
    # ABN_blood = 5
    # OP_blood = 6
    # ON_blood = 7

    # Constructor
    def __init__(self, name, location):
        self._name = name
        self._location = location
        self._bloodStorage = []
        i = 0
        while i < 8:
            self._bloodStorage[i] = []
            i = i + 1
        self._transManager = None

    # Adds a transportation manager
    def addTransportationManager(self, manager):
        self._transManager = manager

    # Stores blood and sorts according to expiry
    def storeBlood(self, blood):
        index = self.findIndex(blood.type, blood.rhesus)
        prevSize = len(self._bloodStorage[index])
        newArray = []
        i = 0
        while i < prevSize:
            newArray[i] = self._bloodStorage[index][i]
            i = i + 1
        newArray[prevSize] = blood
        self._bloodStorage[index] = newArray
        insertionSort(self._bloodStorage[index])

    def accept(self,blood):
        self.storeBlood(blood)

    # Discard expired blood
    def discardBlood(self, currTime):
        # Do some ongoing loop to check for 00:00
        i = 0
        while i < len(self._bloodStorage):
            numToDiscard = 0
            j = 0
            while j < len(self._bloodStorage[i]):
                if currTime - self._bloodStorage[i][j].expiry_time < 60*60*24*2:
                    numToDiscard = numToDiscard + 1
                j = j + 1
            self.removeN(i, numToDiscard)
            i = i + 1
        
    # Gets appropriate blood packet from storage and notifies transport to send it to destination
    def serviceRequest(self, type, rh, dest):
        index = self.findIndex(type, rh)
        blood = self.pop(index)
        self.notifyTransport(blood, dest)

    # Gives blood to transport so that they can prepare to dispatch it to the destination
    def notifyTransport(self, blood, dest):
        self._transManager.receive(blood, dest)

    # Helper: Remove head of array and return it
    def pop(self, index):
        a = self._bloodStorage[index]
        b = a[0]
        newArray = []
        i = 0
        while i + 1 < len(a):
            newArray[i] = a[i + 1]
        self._bloodStorage[index] = newArray
        return b

    # Helper: Remove n elements from head of array
    def removeN(self, index, numToDiscard):
        a = self._bloodStorage[index]
        newArray = []
        i = 0
        while i + numToDiscard < len(a):
            newArray[i] = a[i + numToDiscard]
        self._bloodStorage[index] = newArray

    # Helper: Returns the index that is storing the required blood type
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