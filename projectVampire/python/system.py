from donor import donor
from time_sec import time_sec
from clinic import clinic
from hospital import hospital

class system:
    clinic = clinic("A",1,2)
    hospital = hospital("A",1,2)
    donordb = {}

    def clinic_donation(self,donor_id):
        blood = self.clinic.collect_blood(self.donordb,donor_id,time_sec.get_now())

    def hospital_donation(self,donor_id):
        blood = self.hospital.collect_blood(self.donordb,donor_id,time_sec.get_now())

