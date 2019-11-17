class transportationManager:

	def __init__(self, location):
		self.locale = location # location of this transport manager
		self.toSend = [] # blood that is to be sent

	# Get blood
	def receive(self, blood, dest):
		if dest == None:
			# blood is arriving at this location
			locale.accept()
		else:
			# blood is to be sent
			self.toSend.append([blood,dest])

	# Add route to destinations
	#def addRoute(self, location, route):
	#    self.destinations[location] = route;

	# Send blood to transportationRoute
	def dispatchBlood(self, blood, tRoute):
		for tup in toSend:
			if tup[0] == blood:
				#router = transportationRoute(self.locale, blood[1])
				tRoute.sendBlood(tup, locale)
				self.toSend.remove(tup)
				print('Blood has been dispatched')
		return blood

