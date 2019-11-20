
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
}//include donor.dfy

class dict
{
    var len : int;
    var keys:array<int>;
    var values : array<donor>;

    predicate Valid()
    {keys.Length==len && values.Length==len && len>=0}

    constructor ()
    modifies this
    ensures len==0
    ensures keys.Length==0
    ensures values.Length==0
    ensures Valid()
    {len:=0;keys:= new array[0]; values:= new array[0];}

    method insert(key:int, value:donor)
    modifies this
    requires Valid()
    ensures Valid()
    ensures forall x :: 0 <=x < old(len) ==> (keys[x]==old(keys[x]) && values[x]==old(values[x]))
    ensures len == old(len)+1
    ensures keys[len-1]==key
    ensures values[len-1]==value
    {
        len:=len+1;
        var tempkeys := new array[len];
        var tempvalues := new array[len];
        forall i | 0<=i<(len-1) {
            tempkeys[i]:=keys[i];
            tempvalues[i]:=values[i];
        }
        assert(forall i :: 0<=i<(len-1) ==> tempkeys[i]==keys[i] && tempvalues[i]==values[i]);
        tempkeys[len-1]:=key;
        tempvalues[len-1]:=value;
        keys :=tempkeys;
        values:=tempvalues;
    }
   
}
//include blood.dfy

class donor
{
    var last_donation: int // last donation as integer second since Unix Epoch

    constructor ()
    modifies this
    ensures last_donation==0
    {last_donation:=0;}


    predicate donation_allowed(curr_time:int)
    reads this
    {(curr_time - last_donation)/86400 >= 7}

    method collect_Blood(curr_time:int) returns (blood:Blood)
    modifies this
    requires donation_allowed(curr_time)
    requires curr_time>=0
    ensures last_donation == curr_time
    {
        last_donation:=curr_time;
        var blud := new Blood(curr_time);
        return blud;
    }

    method time_remaining(curr_time:int) returns (time:int)
    // reads this
    {return ((last_donation+86400*7)-curr_time);}
}

method Test()
{
    var doner := new Donor();

    var blud_1 := doner.collect_Blood(1000000);
    assert !doner.donation_allowed(1000060);
    assert doner.donation_allowed(2000000);
    // doner.collectBlood(2,2,2);
}// state:
// unsafe = -1
// unverified = 0
// verified = 1
// storage = 2
// dispatch = 3
// delivered = 4

datatype Blood_types = O | A | B | AB

class Blood{
    var state: int;
    var collection_time: int; //Seconds since Unix Epoch
    var expiry_time:int
    var blood_type: Blood_types;
    var rhesus: bool;

    predicate method Valid()
    reads this
    {-1<=state<=4}

    predicate method expired(curr_time:int)
    reads this
    {curr_time>expiry_time}

    predicate method safe(curr_time:int)
    reads this
    {0<=state<=4 && !expired(curr_time)}

    constructor (secondsin:int)
    modifies this
    requires secondsin>=0
    ensures collection_time>=0 && collection_time==secondsin
    ensures state == 0;
    {
        collection_time := secondsin;
        expiry_time:=collection_time;
        state := 0;
    }

    method verify(curr_time:int,determined_type:Blood_types,rhesus_in:bool)
    modifies this;
    requires state==0;
    ensures if safe(curr_time) then state ==1 else state==-1
    ensures blood_type==determined_type
    ensures rhesus == rhesus_in
    {
        if safe(curr_time) {
            state:=1;
        } else {
            state:=-1;
        }
    blood_type:=determined_type;
    rhesus:=rhesus_in;
    }

    method store(curr_time:int)
    modifies this
    requires state==1;
    ensures if safe(curr_time) then state ==2 else state==-1;
    {
        if safe(curr_time) {
            state:=2;
        } else {
            state:=-1;
        }  
    }

    method dispatch(curr_time:int)
    modifies this
    requires state==2;
    ensures if safe(curr_time) then state ==3 else state==-1;
    {
        if safe(curr_time) {
            state:=3;
        } else {
            state:=-1;
        }         
    }

    method delivered(curr_time:int)
    modifies this
    requires state==3;
    ensures if safe(curr_time) then state ==4 else state==-1;
    {
        if safe(curr_time) {
            state:=4;
        } else {
            state:=-1;
        }           
    }

    method reject()
    modifies this
    ensures state ==-1;
    {state:=-1;}
}


predicate Sorted(arr: array<int>, start:int, end:int)
requires arr != null;
requires 0<=start<arr.Length;
requires end <= arr.Length;
//requires forall x :: 0 <= x < arr.Length ==> arr[x] != null;
reads arr;
{
    forall i, j :: start <= i < j < end ==> arr[i] <= arr[j]
}



// Expiry time and values in two arrays match
predicate Matching(arr1: array<int>, arr2: array<Blood>)
requires arr1 != null;
requires arr2 != null;
requires arr1.Length == arr2.Length;
reads arr1;
reads arr2;
reads arr2[..];
{
	forall i :: 0 <= i < arr1.Length && arr2[i] != null ==> arr2[i].expiry_time == arr1[i]
}


//method bloodSort(toSort: array<Blood>, sortedArray: array<int>) returns (sortedBlood: array<Blood>)
//modifies toSort;
//requires toSort != null;
//requires sortedArray != null;
//requires forall x :: exists y :: 0 <= x < toSort.Length && 0 <= y < sortedArray.Length && toSort[x] != null && toSort[x].expiry_time == sortedArray[y] // requires mapping from sorted to toSort
//requires toSort.Length == sortedArray.Length;
//ensures sortedBlood != null;
//ensures toSort.Length == sortedBlood.Length;
//ensures forall x :: 0 <= x < sortedBlood.Length && sortedBlood[x] != null ==> sortedBlood[x].expiry_time == sortedArray[x]; // a mapping between sorted array an blood expiry
//{
//	var x := 0;
//	var y := 0;
//	sortedBlood := new Blood[toSort.Length]; 
//	while x < toSort.Length 
//	invariant 0 <= x <= toSort.Length
//	//invariant forall i :: 0 <= i < x ==> sortedBlood[i] != null
//	//invariant forall i :: 0 <= i < x  && sortedBlood[i] != null==> sortedBlood[i].expiry_time == sortedArray[i]
//	{
//		 
//		y := 0;
//		while y < toSort.Length 
//			invariant 0 <= y <= toSort.Length
//			//invariant forall i :: 0 <= i < y && toSort[i] != null && sortedBlood[i] != null && sortedBlood[i] == toSort[x] ==> i == y
//			//invariant exists i :: 0 <= i < (y-1) && toSort[i] != null && toSort[i].expiry_time == sortedArray[i]
//			{
//			if (toSort[y] != null && sortedArray[x] == toSort[y].expiry_time) {
//				sortedBlood[x] := toSort[x];
//				toSort[y] := null; // so we don't capture this object again
//			}
//			y := y + 1;
//		}	 
//		x := x + 1;
//	}
//}








method insertionSort(toSort: array<int>, toMatch: array<Blood>)
requires toSort != null;
requires toMatch != null;
requires toSort.Length == toMatch.Length;
//requires forall x :: 0 <= x < toSort.Length ==> toSort[x] != null
requires forall x,y ::0 <= x < toSort.Length && 0 <= y < toMatch.Length && x == y  && toMatch[y] != null ==> toMatch[y].expiry_time == toSort[x];

requires toSort.Length > 1;
ensures Sorted(toSort,0,toSort.Length-1);
ensures multiset(toSort[..]) == multiset(old(toSort[..]));
ensures forall x, y :: 0 <= x < toSort.Length && 0 <= y < toMatch.Length && x == y && toMatch[y] != null ==> toMatch[y].expiry_time == toSort[x];
modifies toSort;
modifies toMatch;
{
    var start := 1;
    while (start < toSort.Length)
    invariant 1 <= start <= toSort.Length;
    invariant Sorted(toSort, 0, start); // array is sorted up to start
    invariant multiset(toSort[..]) == multiset(old(toSort[..])); // keep array the same
    invariant multiset(toMatch[..]) == multiset(old(toMatch[..]));
    invariant forall x, y :: 0 <= x < toMatch.Length && 0 <= toSort.Length && x == y && toMatch[x] != null ==> toSort[y] == toMatch[x].expiry_time;
    //invariant Matching(toSort, toMatch);
    //invariant forall x :: 0 <= x < toSort.Length ==> toSort[x] != null
    //invariant forall x :: 0 <= x < toSort.Length 
    {
        var end := start;
        while (end >= 1 && toSort[end-1] > toSort[end])
        invariant 0 <= end <= start; // end is within limits
        invariant multiset(toSort[..]) == multiset(old(toSort[..])); // array stays the same
	invariant multiset(toMatch[..]) == multiset(old(toMatch[..]));
	//invariant Matching(toSort, toMatch);
	//invariant forall i :: 0 <= i < toSort.Length ==> toSort[i] != null;
        invariant forall i, j :: (0 <= i <= j <= start && j != end) ==> toSort[i] <= toSort[j]; // all values less than start are sorted
        //invariant forall i :: (0 <= i <= start && i != end && toMatch[i] != null) ==> toSort[i] == toMatch[i].expiry_time;
        invariant forall x, y :: 0 <= x < toMatch.Length && 0 <= toSort.Length && x == y && toMatch[x] != null ==> toSort[y] == toMatch[x].expiry_time;
	{
           	var temp := toSort[end-1];
           	toSort[end-1] := toSort[end];
            	toSort[end] := temp;
		
	    	var temp2 := toMatch[end-1];
	    	toMatch[end-1] := toMatch[end];
	    	toMatch[end] := temp2;
		
		end := end -1;
		
        }
        start := start + 1;
    }
}


method Test()
{
    var nums := new int[3];
    //nums[0] := 10;
    //nums[1] := 5;
    //nums[2] := 1;
    
    var blood := new Blood[3];
    var temp := new Blood(10);
    blood[0] := temp; 
    temp := new Blood(5);
    blood[1] := temp;
    temp := new Blood(1);
    blood[2] := temp;
   
    nums[0] := blood[0].expiry_time;
    nums[1] := blood[1].expiry_time;
    nums[2] := blood[2].expiry_time; 

    assert nums.Length == blood.Length;
    assert forall x,y ::0 <= x < nums.Length &&  0 <= y < blood.Length && x == y ==> nums[x] == blood[y].expiry_time; 
    insertionSort(nums, blood);
    assert Sorted(nums,0,nums.Length-1); // array is sorted and blood has maintained 1-1 correspondence with the now sorted array
    assert forall x, y :: 0 <= x < nums.Length && 0 <= y < blood.Length && x == y && blood[y] != null ==> nums[x] == blood[y].expiry_time;    
}

//include blood.dfy
//include transportationManager.dfy
//include insertionSort.dfy

class storage {

    // Index for bloodStorage
    // AP_blood = 0
    // AN_blood = 1
    // BP_blood = 2
    // BN_blood = 3
    // ABP_blood = 4
    // ABN_blood = 5
    // OP_blood = 6
    // ON_blood = 7

    // Attributes
    var name: string;
    var Xcoordinate: int;
    var Ycoordinate: int;
    var bloodStorage: array<array<blood>>;
    var transManager: transportationManager;
    var node: Node

    // Constructor
    constructor (n: string, x: int, y: int) {
        name := n;
        Xcoordinate := x;
        Ycoordinate := y;
        bloodStorage := new array[8];
        i := 0;
        while (i < bloodStorage.length) {
            bloodStorage[i] := new blood[100];
            i := i + 1;
        }
        transManager := null;
        node := null;
    }

    method setNode(n: Node) {
        node := n;
    }

    // Adds a transportation manager
    method setTransportationManager(manager: transportationManager) {
        transManager := manager;
    }

    // Stores blood and sorts according to expiry
    method storeBlood(b: blood) {
        index := findIndex(blood.blood_type, blood.rhesus);
        var prevSize := bloodStorage[index].length;
        var newArray := new array[prevSize+1];
        var i := 0;
        while (i < prevSize) {
            newArray[i] := bloodStorage[index][i];
            i := i + 1;
        }
        newArray[prevSize] := blood;
        bloodStorage[index] := newArray;

        // Generate list of blood times
        var valuearray := new array[bloodStorage[index].length];
        i := 0;
        while (i < bloodStorage[index].length) {
            valuearray[i] := bloodStorage[index][i].getExpiryTime();
        }

        insertionSort(valuearray, bloodStorage[index]);
    }

    // Discard expired blood
    method discardBlood(currTime: int) {
        i := 0;
        while (i < bloodStorage.length) {
            numToDiscard := 0;
            j := 0;
            while (j < bloodStorage[i].length) {
                if (currTime - bloodStorage[i][j].expiry_time < 60*60*24*2) {
                    numToDiscard := numToDiscard + 1;
                }
                j := j + 1;
            }
            removeN(i, numToDiscard);
            i := i + 1;
        }
    }

    // Gets appropriate blood packet from storage and notifies transport to send it to destination
    method serviceRequest(t: blood_type, rh: bool, dest: string) {
        index := findIndex(t, rh);
        blood := pop(index);
        if (blood == null) {
            print("No blood of requested type available");
        }
        else {
            notifyTransport(blood, dest);
        }
    }

    // Gives blood to transport so that they can prepare to dispatch it to the destination
    method notifyTransport(b: blood, dest: string) {
        transManager.receive(b, dest);
        transManager.dispatchBlood();
    }

    // Helper: Remove head of array and return it
    method pop(index: int) returns (b: blood) {
        a := bloodStorage[index];
        if (a.length < 1) {
            return null;
        }
        b := a[0];
        newArray := new array[a.length-1];
        i := 0;
        while (i + 1 < a.length) {
            newArray[i] := a[i + 1];
            i := i + 1;
        }
        bloodStorage[index] := newArray;
    }

    // Helper: Remove n elements from head of array
    method removeN(index: int, numToDiscard: int) {
        a := bloodStorage[index];
        newArray := new array[a.length-numToDiscard];
        i := 0;
        while (i + numToDiscard < a.length) {
            newArray[i] := a[i + numToDiscard];
        }
        bloodStorage[index] := newArray;
    }

    // Helper: Returns the index that is storing the required blood type
    method findIndex(t: blood_type, rh: bool) returns (index: int) {
        if (t == O & rh) {
            index := 0;
        }
        else if (t == A & rh) {
            index := 1;
        }
        else if (t == B & rh) {
            index := 2;
        }
        else if (t == AB & rh) {
            index := 3;
        }
        else if (t == O & !rh) {
            index := 4;
        }
        else if (t == A & !rh) {
            index := 5;
        }
        else if (t == B & !rh) {
            index := 6;
        }
        else if (t == AB & !rh) {
            index := 7;
        }
    }



}
//include blood.dfy

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
