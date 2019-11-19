from blood import blood
from pathology import pathology
from donor import donor

class hospital: 

    def __init__(self, name, x, y):
        self.name = name
        self.pathology = pathology()
        self.Xcoordinate = x
        self.Ycoordinate = y
        self.transportManager = None
        self.node = None
        self.blood = []


    def collect_blood(self,donordb,donor_id,curr_time, pathology):
        if donor_id not in donordb:
            donordb[donor_id] = donor(donor_id)

        doner = donordb[donor_id]
        if doner.donation_allowed(curr_time):
            blood = doner.collect_blood(curr_time)
            blood = pathology.verify(blood)
            print("Blood collected and verified")
            self.blood.append(blood)
            return blood
        else:
            print("Cannot collect blood. Too close to previous collection")
            print(int(doner.time_remaining(curr_time)),"seconds until you can donate again")



    def setTransportManager(self, tman):
        self.transportManager = tman

    def setNode(self, node):
        self.node = node

    def obtainBlood(self):
        toSend = self.blood.copy()
        self.blood = []
        return toSend