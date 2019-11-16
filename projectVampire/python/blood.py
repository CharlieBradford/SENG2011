# from datetime import datetime,timedelta
# from time_sec import time_sec
from enum import Enum

# unsafe = -1
# unverified = 0
# verified = 1
# storage = 2
# dispatch = 3
# delivered = 4


# Approximation to Enums in python
class blood_types(Enum):
    O = 1
    A = 2
    B = 3
    AB= 4

class blood_state(Enum):
    unsafe = -1
    unverified = 0
    verified = 1
    storage = 2
    dispatched = 3
    delivered = 4

# Magic number in expiry time 86400(seconds in day) * 7 =  604800

class blood:
    # Default values
    state = None
    collection_time = None
    expiry_time = None
    blood_type = None
    rhesus = None
    


    def __init__(self,seconds_in):
        assert(seconds_in>0)

        self.collection_time=seconds_in
        self.expiry_time=seconds_in + 604800
        self.state = blood_state.unverified

        assert(self.collection_time>=0 and self.collection_time==seconds_in)
        assert(self.state == blood_state.unverified)
        



    def getExpiryTime(self):
        return self._expiry_time

    # All transition methods accept curr_time as an int
    def verify_blood(self,curr_time,accepted,determined_type,rhesus_in):
        assert(self.state==blood_state.unverified)
        assert(self.valid())

        if (safe(curr_time) and accepted):
            self.state = blood_state.verified
        else:
            self.state=blood_state.unsafe

        self.type=determined_type
        self.rhesus = rhesus_in

        assert (state == blood_state.verified if (self.safe(curr_time) and accepted) else state==blood_state.unsafe)
        assert(self.blood_type==determined_type)
        assert(self.rhesus==rhesus_in)

    def store_blood(self,curr_time):
        assert(self.Valid())
        assert(self.state==blood_state.verified)

        if (safe(curr_time)):
            self.state = blood_state.storage
        else:
            self.state=blood_state.unsafe

        assert (self.state == blood_state.storage if safe(curr_time) else state==blood_state.unsafe)

    def dispatch_blood(self,curr_time):
        assert(self.Valid())
        assert(self.state==blood_state.storage)

        if (safe(curr_time)):
            self.state = blood_state.dispatched
        else:
            self.state=blood_state.unsafe

        assert(state == blood_state.dispatched if safe(curr_time) else state == blood_state.unsafe)

    def deliver_blood(self,curr_time):
        assert (self.Valid())
        assert (self.state == blood_state.dispatched)
        if (safe(curr_time)):
            self.state = blood_state.delivered
        else:
            self.state = blood_state.unsafe

        assert(self.state == blood_state.delivered if safe(curr_time) else self.state==blood_state.unsafe)
    
    # Rejection of blood for any reason - rejected by pathology, lost, expired
    def reject_blood(self):
        self.state = blood_state.unsafe

        assert(self.state==blood_state.unsafe)

    def get_blood_type(self):
        if self.state>=1 and self.state<=4:
            return (self.type,self.rhesus)


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