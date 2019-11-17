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

	def receive(self, blood):
		transportNode = None

		# blood is to be sent
		self.toSend.append([blood,self.getBloodDest(blood)])

	# Add route to destinations
	#def addRoute(self, location, route):
	#    self.destinations[location] = route;

	# Send blood to transportationRoute
	def dispatchBlood(self):
		for tup in self.toSend:
			print('**Blood has been dispatched and is en route**')
			self._sys.getRoutingSys().sendBlood(tup, self.node)
			self.toSend.remove(tup)

	def setNode(self, node):
		self.node = node

	def getBloodDest(self, blood):
		return self._sys.getRequiredNode(blood)