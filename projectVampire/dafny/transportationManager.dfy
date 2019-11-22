
class transportationManager {
	
	var locale: int; // each location represented as an int
	var available: int; // place in buffer to add new blood
	var size : int; // size of blood/dests to store in manager (realistically will be a fairly large number)
	var toSend: array<Blood>;// := new Blood[10]; // blood to send 
    var toDest: array<int>;// := new int[10]; // des of blood to send (index matches with toSend)

    	

	// Blood always has a destination, ie every blood in array is matched by a route
	predicate method Valid()
	reads this;
	reads this.toDest;
	reads this.toSend;
	requires toDest != null;
	requires toSend != null;
	{
		toDest != null && 
		toSend != null && 
		size > 0       && 
		size == toSend.Length && 
		size == toDest.Length && 
		-1 <= available <= size -1 &&
		forall x :: 0 <= x < size && toSend[x] != null ==> toDest[x] != -1
	}


	method Init(src: int)
	modifies this;
	modifies toDest;
	modifies toSend;
	modifies `locale;
	modifies `available;
	modifies `size;
	requires src >= 0
	ensures toDest != null;
	ensures toSend != null;
	ensures Valid()
	{
		locale := src;
		size := 10; // An example amount
		toDest := new int[size]; 
		forall x | 0 <= x < toDest.Length {toDest[x] := -1;}
		toSend := new Blood[size];
		forall x | 0 <= x < toSend.Length {toSend[x] := null;}
		available := -1;
		assert toDest != null;
		assert toSend != null;
		var i := 0;
        var j := 0;
	}

	// Blood is recieved, store in available location
	method receive(bld:Blood, dst:int)
	modifies this.toDest
	modifies this.toSend 
	modifies this`available
	requires toSend != null;
	requires toDest != null;
	requires forall x :: 0 <= x < toSend.Length ==> bld != toSend[x] // blood is not already in toSend
	requires bld != null;
	requires dst >= 0;
	requires Valid(); ensures Valid();
	ensures 0 <= available < toSend.Length && 0 <= available < toDest.Length
	ensures toSend[available] == bld
	ensures toDest[available] == dst
	ensures forall x :: 0 <=x < size && x != available ==> toDest[x] == old(toDest)[x]
	ensures forall x :: 0 <= x < size && x != available ==> toSend[x] == old(toSend)[x]
	{
		
		available := if available == size -1 then 0 else available + 1; // If buffer is full, overwrite last stored value. Only send latest n blood objects
		toSend[available] := bld;
		toDest[available] := dst;
		
	}

	// Blood is dispatched, toSend and toDest are emptied and available is adjusted
	method dispatchBlood()
	modifies this.toSend;
	modifies this.toDest;
	modifies this`available;
	requires toSend != null;
	requires toDest != null;
	requires exists x :: 0 <= x < toSend.Length && toSend[x] != null // blood is to be sent
	requires Valid();
	ensures Valid();
    	ensures forall x, y:: 0 <= x < toSend.Length && 0 <= y < toDest.Length  && x == y ==> (toSend[x] == null && toDest[y] == -1) // toSend and toRoute are empty
	{
		var i := 0;
		var j := 0;
		while (i < toSend.Length && j < toDest.Length)
		invariant 0 <= i <= toSend.Length
		invariant 0 <= j <= toDest.Length
		invariant forall x :: 0 <= x < i ==> toSend[x] == null
		invariant forall x :: 0 <= x < j ==> toDest[x] == -1
		invariant i == j
		{
			// dispatch
			toDest[j] := -1;
			toSend[i] := null;
			i := i + 1;
			j := j + 1;
		}
		available := toSend.Length -1;	
    	}
    
}
