from blood import blood
from blood import blood_state
import random
from time_sec import time_sec
import time

class pathology:

    def __init__(self):
        self.transport_manager = None

    def setTransportManager(self,transport_manager):
        self.transport_manager=transport_manager
    
    def addStorage(self,storage):
        self.storage = storage

    def accept(self,blood):
        print("**Blood arrived at pathology** ", blood.state)
        vblood = self.verify(blood)
        if (vblood != None):
            print("Sending blood from pathology with state", vblood.state)
            self.transport_manager.receive(vblood, None)
            self.transport_manager.dispatchBlood()
        else:
            print("Blood at pathology is expired. Discarding")

    def verify(self,blood):
        #print("verify: ", blood.state)
        if (blood.get_state()==blood_state.unverified):
            print("Blood is being verfied")
            for i in range(random.randint(2,5)):
                print(".")
                time.sleep(1)
            randint = random.randint(0,3)
            blood_types = ['O','A','B','AB']
            blood_type = blood_types[randint]
            rhesus = bool(random.randint(0,1))
            accepted = True # make this fail on occasion
            if (accepted):
                print("Blood has been verified and ACCEPTED, Type: ",blood_type," ",rhesus)
            else:
                print("Blood has been verified and REJECTED")
            if(blood.verify_blood(time_sec.get_now(),accepted,blood_type,rhesus)):
                return blood
            else:
                # Blood is expired
                return None

    def setNode(self, node):
        self.node = node