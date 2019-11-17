from donor import donor
from time_sec import time_sec
from clinic import clinic
from hospital import hospital
from transportationManager import transportationManager
from transportationRoute import transportNode, transportationRoute
from blood import blood
from pathology import pathology
from storage import storage

class system:
	# clinic1 = clinic("A",1,2)
	# hospital1 = hospital("A",1,2)
	donordb = {}
	routes = {}
	transportationManager = transportationManager("china","everywhere")
	pathology = pathology(transportationManager)
	storage = storage("storage","somewhere")


	# Transport nodes
	node0 = transportNode(0,1,5,None)
	node1 = transportNode(1,5,6,None)
	node2 = transportNode(2,5,1,None)
	node3 = transportNode(3,8,1,None)
	node4 = transportNode(4,8,6,None)
	node5 = transportNode(5,5,9,None)

	# Node connections
	node0.addConnection(node5)
	node0.addConnection(node1)

	node1.addConnection(node0)
	node1.addConnection(node4)
	node1.addConnection(node2)

	node2.addConnection(node1)
	node2.addConnection(node3)

	node3.addConnection(node2)
	node3.addConnection(node4)

	node4.addConnection(node3)
	node4.addConnection(node1)
	node4.addConnection(node5)

	node5.addConnection(node4)
	node5.addConnection(node0)

	# Users
	clinic = clinic("Clinic_Name",6,0)
	clinicTransportManager = transportationManager(clinic)
	clinicNode = transportNode(7, clinic.Xcoordinate, clinic.Ycoordinate,clinicTransportManager)
	clinicNode.addConnection(node2)
	node2.addConnection(clinicNode)

	hosp = hospital("Hospital_Name",0,6)
	hospitalTransportManager = transportationManager(hosp)
	hospitalNode = transportNode(6,hosp.Xcoordinate,hosp.Ycoordinate,hospitalTransportManager)
	hospitalNode.addConnection(node0)
	node0.addConnection(hospitalNode)

	recipientHospital = hospital("Recipient_name",6,12)
	recipientransportManager = transportationManager(recipientHospital)
	recipientNode = transportNode(8, recipientHospital.Xcoordinate, recipientHospital.Ycoordinate,recipientransportManager)
	recipientNode.addConnection(node5)
	node5.addConnection(recipientNode)

	world = [node0,node1,node2,node3,node4,node5,clinicNode,hospitalNode,recipientNode]
	routingSystem = transportationRoute(world)

	# example of sending blood to a hosptal node from clinic node
	bld = [blood(50), hospitalNode]
	routingSystem.sendBlood(bld, clinicNode)

	donordb = {}

	def clinic_donation(self,donor_id):
		blood = self.clinic.collect_blood(self.donordb,donor_id,time_sec.get_now())

	def hospital_donation(self,donor_id):
		blood = self.hosp.collect_blood(self.donordb,donor_id,time_sec.get_now())


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
