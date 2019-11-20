
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

    function method getExpiryTime(): int
    reads this;
    {
        expiry_time
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

//#include blood.dfy

class transportationManager {
	
	var locale: int; // give each location an int value?
	var destinations: array<int>; //:= new int[10]; // routes to destinations
	var toSend: array<Blood>;// := new Blood[10]; // may need to have another array that matches the blood destinations to each index or create a class that can hold blood and its dest
    	var toDest: array<int>;// := new int[10]; // routes (match with toSend array)

    	

	// Blood always has a destination, ie every blood in array is matched by a route
	predicate method Valid()
	//requires toDest != null;
	//requires toSend != null
	reads this;
	//reads toDest[0],toDest[1], toDest[2],toDest[3],toDest[4],toDest[5],toDest[6],toDest[7],toDest[8],toDest[9];
	requires toDest != null;
	requires toSend != null;
	{
        	//forall x,y:: 0 <= x < toDest.Length && 0 <= y < toSend.Length && x == y ==> toDest[x]!=-1 && toSend[y] != null
    		toDest !=null && toSend != null
	}


	method Init(src: int)
	modifies this;
	modifies toDest;
	modifies toSend;
	modifies `locale;
	requires src >= 0
	ensures toDest != null;
	ensures toSend != null;
	ensures Valid()
	{
		locale := src;
		toDest := new int[10];
		toSend := new Blood[10];
		//var i := 0;
		//assert toSend != null;
		//while (i < toSend.Length) 
		//invariant 0 <= i < toSend.Length
		//{	
		//	toSend[i] := null;
		//	i := i + 1;
		//}
		//i := 0;
		//while (i < toDest.Length)
		//invariant 0 <= i < toDest.Length
		//{
		//	toDest[i] := -1;
		//	i := i + 1;
		//}
	}

		
	method receive(bld:Blood, dst:int)
	modifies this.toDest
	modifies this.toSend 
	requires toSend != null
	requires toDest != null
	requires forall x :: 0 <= x < toSend.Length ==> bld != toSend[x] // blood is not already in toSend
	requires bld != null;
	requires toSend.Length == toDest.Length
	requires dst >= 0;
	requires Valid(); ensures Valid();
	//ensures forall x, y:: 0 <= x < toSend.Length && 0 <= y < toDest.Length && x == y ==> toSend[x] == bld && toDest[y] == dst -> need to fix
	{
       		var cDest := -1;
		if (dst == -1) {
			cDest := 3; // need to grab the dest that system spits out
		} else {
			cDest := -1;
		}
		//var index := 0;
		//var i := 0;
		//while (index < toSend.Length) 
		//invariant 0 <= i <= toSend.Length
		//{
		//	if (toSend[i] == null) {
		//		index := i;
		//		i := toSend.Length -1;		
		//	}
		//	i :=  i + 1;
		//}
		//toSend[i] := bld;
		//toDest[i] := cDest;

		var i := 0;
		var j := 0;
		while (i < toSend.Length && j < toDest.Length)
		invariant 0 <= i <= toSend.Length
		invariant 0 <= j <= toDest.Length
		//invariant forall x,y :: 0 <= x < toSend.Length && 0 <= y < toDest.Length && toDest[y] == cDest && toSend[x] == bld ==> (x==y) -> need to fix
		//invariant forall x :: 0 <= x < (j-1) ==> toDest[x] != 0
		//invariant forall x, y :: 0 <= x < i && 0 <= y < j && x == y ==> toSend[x] == bl
		invariant i == j
		{
			if (toSend[i] == null && toDest[j] == 0) {
				toSend[i] := bld;
				toDest[j] := cDest;
				//i := toSend.Length -1;
				//j := toDest.Length -1;
			}
			i := i + 1;
			j := j + 1;
		}
    	}


	method dispatchBlood()
	modifies toSend;
	modifies toDest;
	requires toSend != null;
	requires toDest != null;
	requires exists x :: 0 <= x < toSend.Length && toSend[x] != null // blood is to be sent
	requires Valid();ensures Valid();
    	ensures forall x, y:: 0 <= x < toSend.Length && 0 <= y < toDest.Length  && x == y ==> (toSend[x] == null && toDest[y] == 0) // toSend and toRoute are empty
	{
		var i := 0;
		var j := 0;
		while (i < toSend.Length && j < toDest.Length)
		invariant 0 <= i <= toSend.Length
		invariant 0 <= j <= toDest.Length
		invariant forall x :: 0 <= x < i ==> toSend[x] == null
		invariant forall x :: 0 <= x < j ==> toDest[x] == 0
		invariant i == j
		{
			toDest[j] := 0;
			toSend[i] := null;
			i := i + 1;
			j := j + 1;
		}
		
    	}
    
}

