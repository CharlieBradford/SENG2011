from blood import blood

class Clinic: 

    def __init__(self, name, isHospital, x, y):
        self.name = name
        self.isHospital = isHospital
        self.Xcoordinate = x
        self.Ycoordinate = y

    def GenerateUnverifiedBlood(self):
        return blood()

    def Donation(self, donerName):
        #does correct checking
        #if verified that donor is safe then call GenerateUnverifiedBlood
        if (self.VerifyDonorSafety(donerName)):
            return self.GenerateUnverifiedBlood()


    def VerifyDonorSafety(self, donerName):
        return True
