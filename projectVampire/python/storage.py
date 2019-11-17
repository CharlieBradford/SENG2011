# Used to deal with time
from datetime import datetime
from insertionSort import *
from blood import blood 
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
    def __init__(self, name, x, y):
        self._name = name
        self.Xcoordinate = x
        self.Ycoordinate = y
        self._bloodStorage = []
        i = 0
        while i < 8:
            self._bloodStorage.append([])
            i = i + 1
        self.transportManager = None
        self.node = None

    def setNode(self, node):
        self.node = node

    # Adds a transportation manager
    def setTransportManager(self, tman):
        self.transportManager = tman

    # Stores blood and sorts according to expiry
    def storeBlood(self, blood):
        print("Blood has been stored")
        # return # seems to be some issues here that need fixing #TODO
        index = self.findIndex(blood.blood_type, blood.rhesus)
        prevSize = len(self._bloodStorage[index])
        newArray = []
        i = 0
        while i < prevSize:
            newArray.append(self._bloodStorage[index][i])
            i = i + 1
        newArray.append(blood)
        self._bloodStorage[index] = newArray


        # Generate list of blood times
        valuearray = []
        for i in range(0,len(self._bloodStorage[index])):
            valuearray.append(self._bloodStorage[index][i].getExpiryTime())
        insertionSort(valuearray,self._bloodStorage[index])

    def accept(self,blood):
        print("**Blood arrived at storage**")
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
        if (blood==None):
            print("No blood of requested type available")
        else:
            self.notifyTransport(blood, dest)


    # Gives blood to transport so that they can prepare to dispatch it to the destination
    def notifyTransport(self, blood, dest):
        self.transportManager.receive(blood, dest)
        self.transportManager.dispatchBlood()

    # Helper: Remove head of array and return it
    def pop(self, index):
        a = self._bloodStorage[index]
        if len(a)<1:
            return None
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