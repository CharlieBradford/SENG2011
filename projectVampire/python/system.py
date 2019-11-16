from donor import donor
from time_sec import time_sec
from clinic import clinic
from hospital import hospital
from tansportationManager import tansportationManager
from pathology import pathology;

class system:
    clinic = clinic("A",1,2)
    hospital = hospital("A",1,2)
    donordb = {}
    tansportationManager = tansportationManager("china","everywhere")
    pathology = pathology(tansportationManager);

    def clinic_donation(self,donor_id):
        blood = self.clinic.collect_blood(self.donordb,donor_id,time_sec.get_now())
        return blood;
    def hospital_donation(self,donor_id):
        blood = self.hospital.collect_blood(self.donordb,donor_id,time_sec.get_now())
        return blood;

    #TODO: going to need to init some stuff like dest routes


    def HospitalRoute(self):
        #TODO: sort out storage tings
        self.tansportationManager.receive(self.hospital_donation(), "str8 to storage");


    def ClinicRoute(self):
        self.tansportationManager.receive(self.clinic_donation(), "Pathology");
        #TODO: fix transportationmanager dispatch thingy across multiple parts

        pathology.accept_blood(self.tansportationManager.dispatch(blood,troute));
        #TODO : patho send to storage to finalise user journey

    def RequestBlood(self):
        #TODO/TO ASK: storage and recv
