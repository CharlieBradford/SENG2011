import math
import sys
MAX_DIST=20

class transportNode:
    
    def __init__(self, x, y, name):
       self._x = x
       self._y = y
       self.name = name
       self._connected = []

    def getX(self):
        return self._x

    def getY(self):
        return self._y

    def getConnected(self):
        return self._connected

    def addConnection(self, node):
        self._connected.append(node)

class transportationRoute:

    def __init__(self, src, dest, world):
        self._world = world
        self._src = src
        self._dest = dest

    def getX(self):
       return self._src.getX()

    def getY(self):
       return self._src.getY()               

    def getConnected(self):
       return self._src.getConnected()

    def atDest(self, node):
        if node.getX() == self._dest.getX() and node.getY() == self._dest.getY():
            return True
        return False 

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
    def generatePath(self):
        pred = [list() for i in range(len(self._world))]
        dist = [-1] * len(self._world)

        dist[self._src.name] = 0
        toCheck = [self._src]

        while len(toCheck) > 0:
            par = toCheck[0]
            toCheck.remove(toCheck[0])
            for node in par.getConnected():
                if dist[node.name] < 0:
                    pred[node.name].append(par)
                    dist[node.name] = dist[par.name] + 1 #set this val
                    toCheck.append(node)
                elif dist[node.name] == dist[par.name] + 1:
                    pred[node.name].append(par)
        return pred, dist

    # gives distance to destination
    def getDist():
        return 3
    # gives the time taken to arrive at dest
    def getTime():
        return 3


#testing

node1 = transportNode(1,5, 0)

node2 = transportNode(5,1, 1)

node3 = transportNode(5,6, 2)

node4 = transportNode(8,6, 3)

node5 = transportNode(5,2, 4)

dest = transportNode(5,9, 5)

src = transportNode(8,1, 6)

node1.addConnection(node3)
node1.addConnection(dest)

node2.addConnection(src)
node2.addConnection(node3)
#node2.addConnection(node5)

node3.addConnection(node1)
node3.addConnection(node2)
node3.addConnection(node4)

node4.addConnection(node3)
node4.addConnection(dest)


src.addConnection(node2)
src.addConnection(node4)

dest.addConnection(node1)
dest.addConnection(node4)

world = [src, dest, node1, node2, node3, node4, node5]


r = route(src, dest, world)
path, dist = r.generatePath()
counter = 0

curr = dest
while curr.name != src.name:
    curr = path[curr.name][0]
    print(curr.name)

#print(path[5][0].name, path[3][0].name)
#print(dist[3])
#r.displayPath(path)