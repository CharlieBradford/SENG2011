from blood import blood

class recipient:

	def __init__(self, name, x, y):
		self.name = name
		self.Xcoordinate = x
		self.Ycoordinate = y
		self.transportManager = None
		self.node = None

	def accept(self,blood):
		print("Recieved blood")
		#print("Recieved blood with type",blood.get_blood_type())

	def setTransportManager(self, tman):
		self.setTransportManager = tman
		
	def setNode(self, node):
		self.node = node