from donor import donor
from time_sec import time_sec
from clinic import clinic
from hospital import hospital
from transportationManager import transportationManager
from transportationRoute import transportNode, transportationRoute
from blood import blood
from blood import blood_state
from pathology import pathology
from storage import storage
from recipient import recipient


class system:
	# clinic1 = clinic("A",1,2)
	# hospital1 = hospital("A",1,2)
	donordb = {}
	routes = {}
	# transportationManager = transportationManager("china","everywhere")
	# pathology = pathology(transportationManager)
	# storage = storage("storage","somewhere")


	def initSys(self):
		# Transport nodes
		self.node0 = transportNode(0,1,5,None)
		self.node1 = transportNode(1,5,6,None)
		self.node2 = transportNode(2,5,1,None)
		self.node3 = transportNode(3,8,1,None)
		self.node4 = transportNode(4,8,6,None)
		self.node5 = transportNode(5,5,9,None)

		# Node connections
		self.node0.addConnection(self.node5)
		self.node0.addConnection(self.node1)

		self.node1.addConnection(self.node0)
		self.node1.addConnection(self.node4)
		self.node1.addConnection(self.node2)

		self.node2.addConnection(self.node1)
		self.node2.addConnection(self.node3)

		self.node3.addConnection(self.node2)
		self.node3.addConnection(self.node4)

		self.node4.addConnection(self.node3)
		self.node4.addConnection(self.node1)
		self.node4.addConnection(self.node5)

		self.node5.addConnection(self.node4)
		self.node5.addConnection(self.node0)

		# Users
		self.clinic = clinic("Clinic_Name",6,0)
		self.clinicTransportManager = transportationManager(self.clinic, self)
		self.clinic.setTransportManager(self.clinicTransportManager)
		self.clinicNode = transportNode(7, self.clinic.Xcoordinate, self.clinic.Ycoordinate,self.clinicTransportManager)
		self.clinicTransportManager.setNode(self.clinicNode)
		self.clinicNode.addConnection(self.node2)
		self.node2.addConnection(self.clinicNode)

		self.hosp = hospital("Hospital_Name",0,6)
		self.hospitalTransportManager = transportationManager(self.hosp,self)
		self.hosp.setTransportManager(self.hospitalTransportManager)
		self.hospitalNode = transportNode(6,self.hosp.Xcoordinate,self.hosp.Ycoordinate,self.hospitalTransportManager)
		self.hospitalTransportManager.setNode(self.hospitalNode)
		self.hospitalNode.addConnection(self.node0)
		self.node0.addConnection(self.hospitalNode)

		self.recipientHospital = recipient("Recipient_name", 6,12)
		self.recipientHospital.setTransportManager(self.recipientHospital)
		self.recipientTransportManager = transportationManager(self.recipientHospital,self)
		self.recipientNode = transportNode(8, self.recipientHospital.Xcoordinate, self.recipientHospital.Ycoordinate,self.recipientTransportManager)
		self.recipientTransportManager.setNode(self.recipientNode)
		self.recipientNode.addConnection(self.node5)
		self.node5.addConnection(self.recipientNode)

		self.store = storage("Storage",6,1)
		self.storeTransportManager = transportationManager(self.store,self)
		self.store.setTransportManager(self.storeTransportManager)
		self.storeNode = transportNode(9,6,1,self.storeTransportManager)
		self.storeTransportManager.setNode(self.storeNode)
		self.storeNode.addConnection(self.node2)
		self.node2.addConnection(self.storeNode)


		self.patho = pathology()
		self.pathoTransportManager = transportationManager(self.patho,self)
		self.patho.setTransportManager(self.pathoTransportManager)
		self.patho.addStorage(self.store)
		self.pathoNode = transportNode(10,5,8,self.pathoTransportManager)
		self.pathoTransportManager.setNode(self.pathoNode)
		self.pathoNode.addConnection(self.node5)
		self.node5.addConnection(self.pathoNode)

		self.world = [self.node0,self.node1,self.node2,self.node3,self.node4,self.node5,self.clinicNode,self.hospitalNode,self.recipientNode,self.storeNode,self.pathoNode]
		self.routingSystem = transportationRoute(self.world)

	# example of sending blood to a hosptal node from clinic node
	#bld = [blood(50), recipientNode]
	#routingSystem.sendBlood(bld, clinicNode)


	def clinic_donation(self,donor_id):
		blood = self.clinic.collect_blood(self.donordb,donor_id,time_sec.get_now())
		return blood

	def hospital_donation(self,donor_id):
		blood = self.hosp.collect_blood(self.donordb,donor_id,time_sec.get_now())

		# TODO Call transport to pathology
		clinicTransportManager.receive(blood) # Dest pathology
		clinicTransportManager.dispatch()
	

	def hospital_donation(self,donor_id):
		blood = self.hospital.collect_blood(self.donordb,donor_id,time_sec.get_now())
		return blood

	#TODO: going to need to init some stuff like dest routes


	def HospitalRoute(self):
		#TODO: sort out storage tings
		self.transportationManager.receive(self.hospital_donation(), "str8 to storage")


	def getClinic(self):
		return self.clinic

	def ClinicRoute(self, clinic):
		toRoute = self.clinic.obtainBlood()
		#print(toRoute)
		if len(toRoute) == 0:
			print("No blood to send")
		else:
			for blood in toRoute:
				#print("Routing", blood)
				self.clinic.transportManager.receive(blood)
				self.clinic.transportManager.dispatchBlood()
		#TODO: fix transportationmanager dispatch thingy across multiple parts

		#pathology.accept_blood(self.transportationManager.dispatch(blood,troute))
		
		#TODO : patho send to storage to finalise user journey

	def RequestBlood(self,recipient,blood_type,rhesus):
		self.storage.serviceRequest(self, blood_type, rhesus, recipient)
		#TODO/TO ASK: storage and recv


	def getRequiredNode(self, blood):
		tNode = None
		#print("State", blood.state)
		if blood.state == blood_state.unverified:
			# needs to be verified
			tNode = self.pathoNode # need to dynamically choose 'best' node of destination type, do this in transportationRoute
		elif blood.state == blood_state.storage:
			# needs to be sent to recipient
			tNode = self.recipientNode
		else:
			# needs to be stored
			tNode = self.storeNode
		return tNode

	def getRoutingSys(self):
		return self.routingSystem
