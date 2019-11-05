
#include blood.dfy

class transportationManager {
	
	var locale: int // give each location an int value?
	var destinations: array<int> := new int[10]
	var toSend: array<Blood> := new Blood[10]; // may need to have another array that matches the blood destinations to each index or create a class that can hold blood and its dest


	//predicate method Valid()
	//reads this
	//{}

	method receive(bld:Blood, dst:int) 
	requires forall x :: 0 <= x < toSend.Length ==> bld != toSend[x] // blood is not already in toSend
	requires exists x :: (0 <= x < destinations.Length) && (toSend[x] == dst) // the dest has a route
	{}

	method addRoute(loc:int, route:Route)
	requires forall x :: 0 <= x < destinations ==> route != destinations[x] // route not already in 
	{}

	method dispatchBlood(bld:Blood, tRoute:transporationRoute)
	requires exists x :: 0 <= x < toSend.Length && toSend[x] == bld // blood is to be sent
	{}






}