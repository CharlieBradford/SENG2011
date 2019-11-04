from datetime import datetime,timedelta
from time_sec import time_sec
class blood:
    # unsafe = -1
    # unverified = 0
    # verified = 1
    # storage = 2
    # dispatch = 3
    # delivered = 4
    
    SECS_IN_DAY = 86400
    BLOOD_LIFETIME = 42 * SECS_IN_DAY

    def __init__(self,seconds_in):
        self._state = 0
        self._collection_time=seconds_in
        self._expiry_time=self._collection_time+(BLOOD_LIFETIME)

    def get_state(self):
        return self._state

    # Functions like a predicate.
    # Returns false if the state is invalid. (Something has gone wrong somewhere so don't trust the blood
    def valid(self):
        if not -1<= self._state <=4:
            return False
        
    def expired(self,curr_time):
        return curr_time>self._expiry_time

    def safe(self,curr_time):
        return 0<=self._state<=4 and not self.expired(curr_time)

    # All transition methods accept curr_time as an int
    def verify_blood(self,curr_time,blood_type,rhesus):
        if (valid() and safe(curr_time)):
            if self._state == 0:
                self._state = 1
                self._type=blood_type
                self._rhesus = rhesus
        else:
            self._state=-1

    def store_blood(self,curr_time):
        if (valid() and safe(curr_time)):
            if self._state == 1:
                self._state = 2
        else:
            self._state=-1

    def dispatch_blood(self,curr_time):
        if (valid() and safe(curr_time)):
            if self._state == 2:
                self._state = 3
        else:
            self._state=-1

    def deliver_blood(self,curr_time):
        if (valid() and safe(curr_time)):
            if self._state == 3:
                self._state = 4
        else:
            self._state=-1
    
    def get_blood_type(self):
        if self._state>=1 and self._state<=4:
            return (self._type,self._rhesus)

    # Rejection of blood for any reason - rejected by pathology, lost, expired
    def reject_blood(self):
        self._state = -1
