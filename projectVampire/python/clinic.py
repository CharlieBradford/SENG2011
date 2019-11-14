from blood import blood


class clinic: 

    def __init__(self, name, x, y):
        self.name = name
        self.Xcoordinate = x
        self.Ycoordinate = y


    def collect_blood(self,donor_id,curr_time):
        if donor_id not in self.donordb:
            self.donordb[donor_id] = donor(donor_id)

        doner = self.donordb[donor_id]
        if doner.donation_allowed(time_sec.get_now()):
            blud = doner.collect_blood(time_sec.get_now())
            return blud
            print("Blood collected")
        else:
            print("Cannot collect blood. Too close to previous collection")
            print(int(doner.time_remaining(time_sec.get_now())),"seconds until you can donate again")



    # def GenerateUnverifiedBlood(self,curr_time):
    #     return blood(curr_time)

    # def donation(self, donerName):
    #     #does correct checking
    #     #if verified that donor is safe then call GenerateUnverifiedBlood
    #     if (self.VerifyDonorSafety(donerName)):
    #         return self.GenerateUnverifiedBlood()


    # def VerifyDonorSafety(self, donerName):
    #     return True
