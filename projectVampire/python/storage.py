from insertionSort import *
from blood import blood 
from time_sec import time_sec

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

    name = None
    Xcoordinate=None
    Ycoordinate=None
    bloodStorage=None
    transportManager=None



    # Constructor
    def __init__(self, name_in, x, y):
        self.name = name_in
        self.Xcoordinate = x
        self.Ycoordinate = y

        a = []
        b = []
        c = []
        d = []
        e = []
        f = []
        g = []
        h = []


        self.bloodStorage = (a,b,c,d,e,f,g,h)
        # i = 0
        # while i < 8:
        #     self.bloodStorage.append([])
        #     i = i + 1
        self.transportManager = None


    # Requires different formatting as python has no forall logic expression
    def Valid(self):
        result=True
        for x in range(0,len(self.bloodStorage)):
            result2=True
            for y in range(0,len(self.bloodStorage[x])):
                result2=result2 and self.bloodStorage[x][y]!=None
            result = result and self.bloodStorage[x]!=None and result2
        return (len(self.bloodStorage)==8) and result

    # Adds a transportation manager
    def setTransportManager(self, manager):
        self.transportManager = manager

    # Stores blood and sorts according to expiry
    def storeBlood(self,curr_time, b):
        if(not blood.store_blood(curr_time)):
            print("Blood at storage expired. Discarding")
            return
        index = self.findIndex(blood.blood_type, blood.rhesus)
        prevSize = len(self.bloodStorage[index])
        newArray = [None] * (prevSize+1)
        valuearray = [None] * (prevSize+1)
        i = 0


        while i < prevSize:
            newArray[i] = self.bloodStorage[index][i]
            valuearray[i] = self.newArray[index][i].getExpiryTime()
            i = i + 1

        newArray[len(newArray)-1] = b
        valuearray[len(newArray)-1] = b.getExpiryTime()
        
        insertionSort(valuearray,newArray)
        self.bloodStorage[index] = newArray
        print("Blood has been stored")
    

    # Function to insert system time. Not verifiable in dafny
    def accept(self,blood):
        print("**Blood arrived at storage**")
        self.storeBlood(time_sec.get_now(),blood)



    # Discard expired blood
    def discardBlood(self, currTime):
        i = 0
        while i < len(self.bloodStorage):
            numToDiscard = 0
            j = 0
            while j < len(self.bloodStorage[i]):
                if currTime - self.bloodStorage[i][j].expiry_time < 60*60*24*2:
                    numToDiscard = numToDiscard + 1
                j = j + 1
            self.removeN(i, numToDiscard)
            i = i + 1
        
    # Gets appropriate blood packet from storage and notifies transport to send it to destination
    def serviceRequest(self,curr_time, type, rh, dest):
        index = self.findIndex(type, rh)
        blood = self.pop(index)
        if blood == None:
            print("No blood of requested type available")
        else:
            # Set blood to the dispatched state
            if(blood.dispatch_blood(curr_time)):
                self.notifyTransport(blood, dest)
            else:
                print("Blood packet expired. Retrying")
                self.serviceRequest(curr_time, type, rh, dest)


    # Gives blood to transport so that they can prepare to dispatch it to the destination
    def notifyTransport(self, blood, dest):
        self.transportManager.receive(blood, dest)
        self.transportManager.dispatchBlood()

    # Helper: Remove head of array and return it
    def pop(self, index):
        a = self.bloodStorage[index]
        if len(a) < 1:
            return None
        b = a[0]
        newArray = [None] * (len(a)-1)
        i = 0
        while i + 1 < len(a):
            newArray[i] = a[i + 1]
            i = i + 1
        self.bloodStorage[index] = newArray
        return b

    # Helper: Remove n elements from head of array
    def removeN(self, index, numToDiscard):
        a = self.bloodStorage[index]
        newArray = []
        i = 0
        while i + numToDiscard < len(a):
            newArray[i] = a[i + numToDiscard]
        self.bloodStorage[index] = newArray

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