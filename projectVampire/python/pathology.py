from blood import blood
from random import random
from time_sec import time_sec

class pathology:
    def __init__(self,transport_manager):
        self.transport = transport_manager

        
    def accept_blood(self,blood):
        blood = self.verify(blood)
        # TODO -> Send blood back to transport
        # self.transport.send(blood) # Syntax not exact


    def verify(self,blood):
        if (blood.get_state==0):
            randint = random.randint(0,3)
            blood_types = ['O','A','B','AB']
            blood_type = blood_types[randint]
            rhesus = bool(random.randint(0,1))
            blood.verify_blood(time_sec.get_now(),blood_type,rhesus)
            return blood
            