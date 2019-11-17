from blood import blood
from donor import donor


class clinic: 

    def __init__(self, name, x, y):
        self.name = name
        self.Xcoordinate = x
        self.Ycoordinate = y
        self.blood = []
        self.transportManager = None

    def collect_blood(self,donordb,donor_id,curr_time):
        if donor_id not in donordb:
            donordb[donor_id] = donor(donor_id)

        doner = donordb[donor_id]
        if doner.donation_allowed(curr_time):
            blud = doner.collect_blood(curr_time)
            print("Blood collected")
            self.blood.append(blud)
            return blud
        else:
            print("Cannot collect blood. Too close to previous collection")
            print(int(doner.time_remaining(curr_time)),"seconds until you can donate again")

    def obtainBlood(self):
        toSend = self.blood.copy()
        self.blood = []
        return toSend
        
    def setTransportManager(self, tman):
        self.transportManager = tman
