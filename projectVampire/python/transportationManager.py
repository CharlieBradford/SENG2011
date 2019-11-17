class transportationManager:

	def __init__(self, location):
		self.locale = location # location of this transport manager
		self.toSend = [] # blood that is to be sent
		self.node = None

	# Get blood

	def arrivalAccept(self, blood):
		self.locale.accept(blood)
		#self.locale.accept(blood)

	def receive(self, blood, sys):
		transportNode = None
		if blood.rhesus == None:
			# needs to be verified
			transportNode = sys.getPathoNode() # move this functionilty into this class
		elif blood.state == 2:
			# needs to be sent to recipient
			print("todo")
		else:
			print("todo")
			# needs to be stored
		# blood is to be sent
		self.toSend.append([blood,transportNode])

	# Add route to destinations
	#def addRoute(self, location, route):
	#    self.destinations[location] = route;

	# Send blood to transportationRoute
	def dispatchBlood(self, tRoute):
		for tup in self.toSend:
			print('Blood has been dispatched')
			tRoute.sendBlood(tup, self.node)
			self.toSend.remove(tup)

	def setNode(self, node):
		self.node = node