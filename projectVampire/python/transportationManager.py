class transportationManager:

	def __init__(self, location, sys):
		self.locale = location # location of this transport manager
		self._available = 0 # currently available accept spot
		self._size = 10 # size of transportBuffer
		self.toSend = [None for x in range(self._size)] # initialise to null
		self.toDest = [-1 for x in range(self._size)] # initialise to non-valid dests
		self.node = None
		self._sys = sys

	def _valid(self):
		dstNull = (self.toDest != None)
		sndNull = (self.toSend != None)
		size    = (self._size > 0)
		sizeDst = (self._size == len(self.toDest))
		sizeSnd = (self._size == len(self.toSend))
		avRange = (-1 <= self._available <= (self._size-1))
		matchin = True
		for i in range(self._size):
			if (self.toSend[i] and (self.toDest[i] == -1)):
				matchin = False
		#print(dstNull,sndNull,size, sizeDst,sizeSnd,avRange,matchin)
		return dstNull and sndNull and size and sizeDst and sizeSnd and avRange and matchin

	def arrivalAccept(self, blood):
		self.locale.accept(blood)

	def receive(self, blood, dest):
		old_DEST = self.toDest.copy()
		old_SEND = self.toSend.copy()
		assert self.toSend != None
		assert self.toDest != None
		for i in range(len(self.toSend)):
			assert self.toSend[i] != blood
		assert blood != None
		assert self._valid()
		if dest == None: # linking to dynamic routing
			dest = self.getBloodDest(blood) 
		assert dest != None

		if self._available == self._size -1:
			self._available = 0 
		else:
			self._available = self._available + 1
		self.toSend[self._available] = blood
		self.toDest[self._available] = dest

		assert self._valid
		assert 0 <= self._available < len(self.toSend)
		assert 0 <= self._available < len(self.toDest)
		for i in range(len(self.toSend)):
			if i != self._available:
				assert old_SEND[i] == self.toSend[i] 
		for i in range(len(self.toDest)):
			if i != self._available:
				assert old_DEST[i] == self.toDest[i]

	# Dispatch all blood stored in this manager
	def dispatchBlood(self):
		assert self._valid()
		assert self.toSend != None
		assert self.toDest != None
		hasSendVals = False
		for i in range(self._size):
			if (self.toSend[i]):
				hasSendVals = True
		assert hasSendVals


		i = 0
		j = 0
		while (i < len(self.toSend) and j < len(self.toDest)):

			assert i == j
			assert 0 <= i < len(self.toSend)
			assert 0 <= j < len(self.toDest)
			for x in range(i):
				assert self.toSend[x] == None
			for x in range(j):
				assert self.toDest[x] == -1


			if self.toSend[i] != None:
				print('**Blood has been dispatched**')
				self._sys.getRoutingSys().sendBlood([self.toSend[i],self.toDest[j]], self.node)
				self.toSend[i] = None
				self.toDest[j] = -1


			i = i +1
			j = j + 1
		self._available = len(self.toSend) -1

		assert self._valid()
		for i in range(self._size):
			assert self.toSend[i] == None
			assert self.toDest[i] == -1
			

	def setNode(self, node):
		self.node = node

	def getBloodDest(self, blood):
		return self._sys.getRequiredNode(blood)