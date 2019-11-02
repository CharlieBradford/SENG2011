from datetime import datetime,timedelta

class blood:
    # unverified = 0
    # verified = 1
    # storage = 2
    # dispatch
    # delivered = 4
    # unsafe = 5

    def __init__(self):
        self._state = 0
        self._collection_time=datetime.now() #=Current system time

    def get_state(self):
        return self._state

    # Functions like a predicate.
    # Returns false if either the state is invalid. (Something has gone wrong somewhere so don't trust the blood)
    # OR the blood is due to expire in the next 25 hours.
    def valid(self):
        if not 0<= self._state <=5:
            return False
        if (self._collection_time+datetime.timedelta(days=40,hours=23)>datetime.now()):
            return False
        

    def verify_blood(self,blood_type,rhesus):
        if (valid()):
            if self._state == 0:
                self._state = 1
                self._type=blood_type
                self._rhesus = rhesus
        else:
            self._state=5

    def store_blood(self):
        if (valid()):
            if self._state == 1:
                self._state = 2
        else:
            self._state=5

    def dispatch_blood(self):
        if (valid()):
            if self._state == 2:
                self._state = 3
        else:
            self._state=5

    def deliver_blood(self):
        if (valid()):
            if self._state == 3:
                self._state = 4
        else:
            self._state=5
    
    def get_blood_type(self):
        if self._state>=1 and self._state<=4:
            return (self._type,self._rhesus)

    # Rejection of blood for any reason - rejected by pathology, lost, expired
    def reject_blood(self):
        self._state = 5
