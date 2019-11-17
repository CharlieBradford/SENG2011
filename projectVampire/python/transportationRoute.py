import math
import sys
import time
from recipient import recipient
MAX_DIST=20


# locations to help simulate the path the blood will take
class transportNode:
	def __init__(self, name, x, y, locale):
	   self._x = x
	   self._y = y
	   self.name = name
	   self._connected = []
	   self.locale = locale

	def getX(self):
		return self._x

	def getY(self):
		return self._y

	def getConnected(self):
		return self._connected

	def addConnection(self, node):
		self._connected.append(node)

class transportationRoute:

	def __init__(self, world):
		self._world = world            

	def getConnected(self):
	   return self._src.getConnected()

	def displayPath(self, path):
		for node in path:
			print("(",node.getX(), node.getY(),") -> ",end='')
		print("X")

	# gives a list of nodes to arrive at dest (requires a connected graph to work)
	def generatePath2(self, nodes):
		curr = self
		path = [src]
		visited = [src]
		while not self.atDest(curr):
			currDist = MAX_DIST
			chosen = None
			for node in curr.getConnected():
				if node not in path and node != curr:
					print(curr.getX(),curr.getY(), "->",node.getX(),node.getY())
					if node == dest:
						chosen = dest
						break
					# Use node with least weight
					cDist = math.sqrt((curr.getX() - node.getX())**2 + ((curr.getY() - node.getY()))**2)
					if (cDist < currDist):
						chosen = node
						currDist = cDist
			path.append(chosen)
			curr = chosen
		return path


	# BFS traversal
	def generatePath(self, src):
		pred = [list() for i in range(len(self._world))]
		dist = [-1] * len(self._world)
		print(src.name)
		dist[src.name] = 0
		toCheck = [src]

		while len(toCheck) > 0:
			par = toCheck[0]
			toCheck.remove(toCheck[0])
			for node in par.getConnected():
				if dist[node.name] < 0:
					pred[node.name].append(par)
					dist[node.name] = dist[par.name] + math.sqrt((par.getX() - node.getX())**2 + ((par.getY() - node.getY()))**2) #set this val
					toCheck.append(node)
				#elif dist[node.name] == dist[par.name] + 1:
					#pred[node.name].append(par)
		return pred, dist

	def sendBlood(self, bloodTup, source):
		blood = bloodTup[0]
		dest = bloodTup[1]
		#assert isinstance(dest, recipient)
		print(type(dest.locale.locale).__name__)
		path, dist = self.generatePath(source)

		curr = dest
		final = []
		final.insert(0,curr)

		# reorder path
		while curr.name != source.name:
			curr = path[curr.name][0]
			final.insert(0,curr)

		prevTime = 0
		for node in final[1::]:
			print("Sending blood to", node.name, ", will take", round(dist[node.name]-prevTime,1),"seconds")
			time.sleep(round(dist[node.name]-prevTime,1))
			prevTime = dist[node.name]
			#print(node.name, dist[node.name])
		

		#dest.recieve(blood)
		dest.locale.arrivalAccept(blood)
		#print(type(dest.local).__name__)
		#if (type(dest.locale.locale).__name__ == "storage"):
	#		dest.locale.recieve(blood)
	#		dest.locale.locale.storeBlood(blood)
	#		print("Blood arrived at storage")
	#	elif (type(dest.locale.locale).__name__ == "recipient"):
	#		dest.locale.locale.accept(blood)
	#		print("Blood arrived at recipient")
	#	elif (type(dest.locale.locale).__name__ == "pathology"):
	#		dest.locale.locale.accept(blood)
	#		print("Blood arrived at pathology")
	##	elif (type(dest.locale.locale).__name__ == "hospital"):
	#		dest.locale.locale.accept(blood)
	#		print("Blood arrived at pathology")
# Testing

# Creating nodes with transportNode(name of node, x value, y value)
"""
node0 = transportNode(0,1,5)

node1 = transportNode(1,5,6)

node2 = transportNode(2,5,1)

node3 = transportNode(3,8,1)

node4 = transportNode(4,8,6)

node5 = transportNode(5,5,9)

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

world = [node0,node1,node2,node3,node4,node5]


r = transportationRoute(world)

# blood tup[Blood, dest]
bld = [None, node1]
# tup, src
r.sendBlood(bld, node5)

#path, dist = r.generatePath(src)
#counter = 0

#curr = dest
#print(curr.name, dist[curr.name])
#final = []
#final.insert(0,curr)
#while curr.name != src.name:
#	curr = path[curr.name][0]
#	final.insert(0,curr)
	#print(curr.name, dist[curr.name])

#for node in final:
#	print(node.name, dist[node.name])

#print(path[5][0].name, path[3][0].name)
#print(dist[3])
#r.displayPath(path)
"""