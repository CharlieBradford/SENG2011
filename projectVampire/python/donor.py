from blood import blood

class donor:

    def __init__(self,id):
        self._last_donation=0
        self._id = id

    def donation_allowed(self,curr_time):
        return ((curr_time-self._last_donation)/86400)>=7

    def collect_blood(self,curr_time):
        if (self.donation_allowed(curr_time)):
            self._last_donation=curr_time
            return blood(curr_time)

    def time_remaining(self,curr_time):
        return self._last_donation+86400*7-curr_time


    
