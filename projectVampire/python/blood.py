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
    
    # Functions like a predicate.
    # Returns false if the state is invalid. (Something has gone wrong somewhere so don't trust the blood
    def valid(self):
        return (self.state == blood_state.unsafe or self.state ==  blood_state.unverified or self.state == blood_state.verified or self.state == blood_state.storage or self.state == blood_state.dispatched or self.state == blood_state.delivered)

    def expired(self,curr_time):
        return curr_time>self.expiry_time
    
    def safe(self,curr_time):
        return ((self.state ==  blood_state.unverified or self.state == blood_state.verified or self.state == blood_state.storage or self.state == blood_state.dispatched or self.state == blood_state.delivered) and not self.expired(curr_time))

    def getExpiryTime(self):
        expiry = self.expiry_time
        assert(expiry == self.expiry_time)
        return expiry


    def get_blood_type(self):
        if self.state>=1 and self.state<=4:
            return (self.type,self.rhesus)

    def get_state(self):
        return self.state

    def __init__(self,seconds_in):
        assert(seconds_in>0)

        self.collection_time=seconds_in
        self.expiry_time=seconds_in + 604800
        self.state = blood_state.unverified

        assert(self.collection_time>=0 and self.collection_time==seconds_in)
        assert(self.state == blood_state.unverified)



    # All transition methods accept curr_time as an int
    def verify_blood(self,curr_time,accepted,determined_type,rhesus_in):
        assert(self.state==blood_state.unverified)
        assert(self.valid())
        return_val=None

        if (self.safe(curr_time) and accepted):
            self.state = blood_state.verified
            return_val=True
        else:
            self.state=blood_state.unsafe
            return_val=False

        self.blood_type=determined_type
        self.rhesus = rhesus_in

        
        assert (return_val==True if (self.safe(curr_time) and accepted) else return_val==False)
        assert (self.state == blood_state.verified if (self.safe(curr_time) and accepted) else self.state==blood_state.unsafe)
        assert(self.blood_type==determined_type)
        assert(self.rhesus==rhesus_in)
        assert(self.valid())
        return return_val

    def store_blood(self,curr_time):
        #print(self.state)
        assert(self.valid())
        assert(self.state==blood_state.verified)

        return_val=None

        if (self.safe(curr_time)):
            self.state = blood_state.storage
            return_val=True
        else:
            self.state=blood_state.unsafe
            return_val=False

        assert (return_val==True if (self.safe(curr_time)) else return_val==False)
        assert (self.state == blood_state.storage if self.safe(curr_time) else self.state==blood_state.unsafe)
        assert(self.valid())
        return return_val

    def dispatch_blood(self,curr_time):
        assert(self.valid())
        assert(self.state==blood_state.storage)

        return_val=None

        if (self.safe(curr_time)):
            self.state = blood_state.dispatched
            return_val=True
        else:
            self.state=blood_state.unsafe
            return_val=False

        assert (return_val==True if (self.safe(curr_time)) else return_val==False)
        assert (self.state == blood_state.dispatched if self.safe(curr_time) else self.state == blood_state.unsafe)
        assert(self.valid())
        return return_val

    def deliver_blood(self,curr_time):
        assert (self.valid())
        assert (self.state == blood_state.dispatched)

        return_val=None

        if (self.safe(curr_time)):
            self.state = blood_state.delivered
            return_val=True
        else:
            self.state = blood_state.unsafe
            return_val=False


        assert (return_val==True if (self.safe(curr_time)) else return_val==False)
        assert(self.state == blood_state.delivered if self.safe(curr_time) else self.state==blood_state.unsafe)
        assert(self.valid())
        return return_val
    
    # Rejection of blood for any reason - rejected by pathology, lost, expired

    def reject_blood(self):
        self.state = blood_state.unsafe

        assert(self.state==blood_state.unsafe)
        assert(self.valid())

        


