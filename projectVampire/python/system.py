from donor import donor
from time_sec import time_sec
from clinic import clinic
from hospital import hospital

class system:
    self.clinic = clinic("A",1,2)
    self.hospital = hospital("A",1,2)
    self.donordb = {}

    def clinic_donation(self,donor_id):
        blood = self.clinic.collect_blood(donor_id,time_sec.time_sec.get_now())

    def hospital_donation(self,donor_id):
        blood = self.clinic.collect_blood(donor_id,time_sec.time_sec.get_now())

