def generateRoute(self, src):
	pred = [list() for i in range(len(self._world))]
	dist = [-1] * len(self._world)
	#print(src.name)
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



def simplerRoute(self, src, dest, world):
	path = []
	toCheck = [src]
	path.append(src)
	while (len(toCheck) > 0):
		cur = toCheck[len(toCheck)]
		toCheck.remove(cur)
		for node in world:
			if node.connected(cur):
				if node == dest:
					path.append(dest)
					break
				else:
					path.append(node)
					toCheck.append(node)


precondition:
	- all nodes in world are connected (adjacency matrix has a 1 in each row/col)

postcondition:
	- there is a path from src to dest ie, you can follow the final path from the given adj matrix

iterating over a 2d matrix in 1d form:
	IF array N*N, then arr[i][j] == arr[i*N + j]




def getRouteSimpler(src:int, dest:int, world:array<int>, nodes:array<int>):
    requires src != dest
    requires 


