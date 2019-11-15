
#include blood.dfy

class transportationManager {
	
	var locale: int; // give each location an int value?
	var destinations: array<int> := new int[10]; // routes to destinations
	var toSend: array<Blood> := new Blood[10]; // may need to have another array that matches the blood destinations to each index or create a class that can hold blood and its dest
    var toRoute: array<Route> := new Route[10] // routes (match with toSend array)

    // Blood always has a destination, ie every blood in array is matched by a route
	predicate method Valid()
	reads this
	{
        forall x,y :: 0 <= x < destinations.Length ==> toRoute[x] && toSend[x];
    }
    
	method receive(bld:Blood, dst:int) 
	requires forall x :: 0 <= x < toSend.Length ==> bld != toSend[x] // blood is not already in toSend
	{
        var route := destinations[dst];
        var toAdd := findAvailable(toSend);
        if (route) { 
            toSend[i] := bld;
            toRoute[i] := route;
        } else { // if a route is not stored
            route := 0; // get new route from system
            destinatiions[dst] = route; // store new route
            toSend[i] := bld;
            toRoute[i] := route;
        }
    }

	method addRoute(loc:int, route:Route)
	requires forall x :: 0 <= x < destinations ==> route != destinations[x] // route not already in (do we want to change existing routes?)
	{
        destinations[loc] := route; // add a route for a location
    }

	method dispatchBlood(bld:Blood, tRoute:transporationRoute)
	requires exists x :: 0 <= x < toSend.Length && toSend[x] == bld // blood is to be sent
    ensures forall x:: 0 <= x < toSend.Length ==> (!toSend[x] && !toRoute[x]) // toSend and toRoute are empty
	{
        var i := 0;
        while (i < toSend.Length) {
            // send blood
            toSend[i] = null;
            toRoute[i] = null;
            i := i + 1;
        }
    }
    
    // find available array index to add new incomming blood
    method findAvailable(a:<array>) {
        var i := 0;
        while (i < a.Length) {
            if (!a[i]) {
                return i;
            }
            i := i + 1;
        }
        return (a.Length-1); // no space left, take top spot (perhaps increase array size?)

    }

}
