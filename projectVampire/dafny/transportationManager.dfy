
// state:
// unsafe = -1
// unverified = 0
// verified = 1
// storage = 2
// dispatched = 3
// delivered = 4


datatype Blood_types = O | A | B | AB
datatype blood_state = unsafe | unverified | verified | storage | dispatched | delivered


// Magic number in expiry time 86400(seconds in day) * 7 =  604800
class Blood{
    var state: blood_state;
    var collection_time: int; //Seconds since Unix Epoch
    var expiry_time:int
    var blood_type: Blood_types;
    var rhesus: bool;

    predicate method Valid()
    reads this
    {state== unsafe || state==unverified || state==verified || state==storage || state==dispatched || state==delivered}

    predicate method expired(curr_time:int)
    reads this
    {curr_time>expiry_time}

    predicate method safe(curr_time:int)
    reads this
    {(state==unverified || state==verified || state==storage || state==dispatched || state==delivered) && !expired(curr_time)}

    method getExpiryTime() returns (expiry : int)
    // reads this;
    ensures expiry == expiry_time
    {
        expiry := expiry_time;
        return;
    }

    method reject_blood()
    modifies this;
    ensures state == unsafe
    ensures Valid()
    {
        state := unsafe;
    }

    method get_blood_type() returns (b_type:Blood_types,rh:bool)
    ensures b_type==blood_type
    ensures rh==rhesus
    {
        b_type := blood_type;
        rh := rhesus;
    }

    method get_state() returns (bl_state:blood_state)
    ensures bl_state == state
    {
        bl_state := state;
    }

    constructor (secondsin:int)
    modifies this
    requires secondsin>=0
    ensures collection_time>=0 && collection_time==secondsin
    ensures state == unverified;
    {
        collection_time := secondsin;
        expiry_time:=secondsin + 604800;
        state := unverified;
    }

    method verify_blood(curr_time:int,accepted:bool,determined_type:Blood_types,rhesus_in:bool)
    modifies this;
    requires state==unverified
    requires Valid()
    ensures if (safe(curr_time) && accepted) then state == verified else state==unsafe
    ensures blood_type==determined_type
    ensures rhesus == rhesus_in
    ensures Valid()
    {
        if safe(curr_time) && accepted {
            state:=verified;
        } else {
            state:=unsafe;
        }

        blood_type:=determined_type;
        rhesus:=rhesus_in;
    }

    method store_blood(curr_time:int)
    modifies this
    requires Valid()
    requires state==verified;
    ensures if safe(curr_time) then state == storage else state==unsafe;
    ensures Valid()
    {
        if safe(curr_time) {
            state:=storage;
        } else {
            state:=unsafe;
        }  
    }

    method dispatch_blood(curr_time:int)
    modifies this
    requires Valid()
    requires state==storage;
    ensures if safe(curr_time) then state == dispatched else state==unsafe;
    ensures Valid()
    {
        if safe(curr_time) {
            state:=dispatched;
        } else {
            state:=unsafe;
        }         
    }

    method deliver_blood(curr_time:int)
    modifies this
    requires Valid()
    requires state==dispatched;
    ensures if safe(curr_time) then state ==delivered else state==unsafe;
    ensures Valid()
    {
        if safe(curr_time) {
            state:=delivered;
        } else {
            state:=unsafe;
        }           
    }

    method reject()
    modifies this
    ensures state ==unsafe;
    ensures Valid()
    {state:=unsafe;}
}



class transportationManager {
	
	var locale: int; // give each location an int value?
	var available: int;
	var destinations: array<int>; //:= new int[10]; // routes to destinations
	var toSend: array<Blood>;// := new Blood[10]; // may need to have another array that matches the blood destinations to each index or create a class that can hold blood and its dest
    	var toDest: array<int>;// := new int[10]; // routes (match with toSend array)
	var size : int;
    	

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
		size := 10;
		toDest := new int[size]; // An example amount, could be a different size if required as long as size matches toSend
		forall x | 0 <= x < toDest.Length {toDest[x] := -1;}
		toSend := new Blood[size];
		forall x | 0 <= x < toSend.Length {toSend[x] := null;}
		available := -1;
		assert toDest != null;
		assert toSend != null;
		var i := 0;
                var j := 0;
	}

		
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
		
		available := if available == size -1 then 0 else available + 1;
		toSend[available] := bld;
		toDest[available] := dst;
		
	}

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
