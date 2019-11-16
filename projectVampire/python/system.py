from donor import donor
from time_sec import time_sec
from clinic import clinic
from hospital import hospital
from transportationManager import transportationManager
from pathology import pathology
from storage import storage

class system:
    clinic1 = clinic("A",1,2)
    hospital1 = hospital("A",1,2)
    donordb = {}
    routes = {}
    transportationManager = transportationManager("china","everywhere")
    pathology = pathology(transportationManager)
    storage = storage("storage","somewhere")

    # clinic_transp_mgr = transportationManager(,clinic1)
    

    def clinic_donation(self,donor_id):
        blood = self.clinic.collect_blood(self.donordb,donor_id,time_sec.get_now())

        # TODO Call transport to pathology
        clinic_transport_mgr.receive(blood) # Dest pathology
        clinc_transport_mgr.dispatch()
    

    def hospital_donation(self,donor_id):
        blood = self.hospital.collect_blood(self.donordb,donor_id,time_sec.get_now())
        return blood

    #TODO: going to need to init some stuff like dest routes


    def HospitalRoute(self):
        #TODO: sort out storage tings
        self.transportationManager.receive(self.hospital_donation(), "str8 to storage")


    def ClinicRoute(self):
        self.transportationManager.receive(self.clinic_donation(), "Pathology")
        #TODO: fix transportationmanager dispatch thingy across multiple parts

        pathology.accept_blood(self.transportationManager.dispatch(blood,troute))
        #TODO : patho send to storage to finalise user journey

    def RequestBlood(self,recipient,blood_type,rhesus):
        self.storage.serviceRequest(self, blood_type, rhesus, recipient)
        #TODO/TO ASK: storage and recv
