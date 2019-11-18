from blood import blood
from time_sec import time_sec

class recipient:

	def __init__(self, name, x, y):
		self.name = name
		self.Xcoordinate = x
		self.Ycoordinate = y
		self.transportManager = None
		self.node = None

	def accept(self,blood):
		if(blood.deliver_blood(time_sec.get_now())):
			print("**Recipient has recieved blood**")
		else:
			print("Expired blood arrived at recipient. Discarding")

	def setTransportManager(self, tman):
		self.setTransportManager = tman

	def setNode(self, node):
		self.node = node