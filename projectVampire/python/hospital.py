from blood import blood
from pathology import pathology
from donor import donor

class hospital: 

    def __init__(self, name, x, y):
        self.name = name
        self.pathology = pathology()
        self.Xcoordinate = x
        self.Ycoordinate = y


    def collect_blood(self,donordb,donor_id,curr_time):
        if donor_id not in donordb:
            donordb[donor_id] = donor(donor_id)

        doner = donordb[donor_id]
        if doner.donation_allowed(curr_time):
            blood = doner.collect_blood(curr_time)
            blood = self.pathology.verify(blood)
            print("Blood collected and verified")
            return blood
        else:
            print("Cannot collect blood. Too close to previous collection")
            print(int(doner.time_remaining(curr_time)),"seconds until you can donate again")