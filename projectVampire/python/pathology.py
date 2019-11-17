from blood import blood
from random import random
from time_sec import time_sec

class pathology:
    def setTransportManager(self,transport_manager):
        self.transport_manager=transport_manager
    
    def addStorage(self,storage):
        self.storage = storage

    def accept(self,blood):
        print("Blood arrived")
        blud = self.verify(blood)
        # TODO -> Send blood back to transport
        
        
        #self.transport_manager.receive(blud) # Destination storage
        #self.transport_manager.dispatch()

    def verify(self,blood):
        if (blood.get_state==0):
            randint = random.randint(0,3)
            blood_types = ['O','A','B','AB']
            blood_type = blood_types[randint]
            rhesus = bool(random.randint(0,1))
            blood.verify_blood(time_sec.get_now(),blood_type,rhesus)
            return blood

    def setNode(self, node):
        self.node = node