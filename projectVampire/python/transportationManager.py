class transportationManager:

	def __init__(self, location, sys):
		self.locale = location # location of this transport manager
		self.toSend = [] # blood that is to be sent
		self.node = None
		self._sys = sys

	# Get blood

	def arrivalAccept(self, blood):
		self.locale.accept(blood)
		#self.locale.accept(blood)

	def receive(self, blood, dest):
		#print("Sending blood to ", dest.name)
		if dest == None:
			dest = self.getBloodDest(blood) 
		# blood is to be sent
		self.toSend.append([blood,dest])

	# Add route to destinations
	#def addRoute(self, location, route):
	#    self.destinations[location] = route;

	# Send blood to transportationRoute
	def dispatchBlood(self):
		#for tup in self.toSend:
		for i in range(len(self.toSend)):
			print('**Blood has been dispatched**')
			self._sys.getRoutingSys().sendBlood(self.toSend.pop(i), self.node)
			

	def setNode(self, node):
		self.node = node

	def getBloodDest(self, blood):
		return self._sys.getRequiredNode(blood)