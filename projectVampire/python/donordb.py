from blood import blood

class donor_db:

    def __init__(self):
        self._last_donation=0

    def donation_allowed(self,curr_time):
        return ((curr_time-self._last_donation)/86400)>=7

    def collect_blood(self,curr_time):
        if (self.donation_allowed(curr_time)):
            self._last_donation=curr_time
            return blood(curr_time)


    
