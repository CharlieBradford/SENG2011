

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
    var doner := new donor();

    var blud_1 := doner.collect_Blood(1000000);
    assert !doner.donation_allowed(1000060);
    assert doner.donation_allowed(2000000);
    // doner.collectBlood(2,2,2);
}


// Insertion sort verification as per lecture notes
// adapted to sort the blood objects for our system

predicate Sorted(arr: array<int>, start:int, end:int)
requires arr != null;
requires 0<=start<=arr.Length;
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

method insertionSort(toSort: array<int>, toMatch: array<Blood>)
requires toSort != null;
requires toMatch != null;
requires forall x :: 0<=x<toMatch.Length ==> toMatch[x]!=null
requires toSort.Length == toMatch.Length;
requires forall x,y ::0 <= x < toSort.Length && 0 <= y < toMatch.Length && x == y  && toMatch[y] != null ==> toMatch[y].expiry_time == toSort[x];

ensures Sorted(toSort,0,toSort.Length-1);
ensures multiset(toSort[..]) == multiset(old(toSort[..]));
ensures multiset(toMatch[..])==multiset(old(toMatch[..]))
ensures forall x, y :: 0 <= x < toSort.Length && 0 <= y < toMatch.Length && x == y && toMatch[y] != null ==> toMatch[y].expiry_time == toSort[x];
ensures forall x :: 0<=x<toMatch.Length ==> toMatch[x]!=null
modifies toSort;
modifies toMatch;
{
    if (toSort.Length<2)
    {
        // A length 0 or 1 array is already sorted
        return;
    }
    var start := 1;
    while (start < toSort.Length)
    invariant 1 <= start <= toSort.Length;
    invariant Sorted(toSort, 0, start); // array is sorted up to start
    invariant multiset(toSort[..]) == multiset(old(toSort[..])); // keep array the same
    invariant multiset(toMatch[..]) == multiset(old(toMatch[..]));
    invariant forall x :: 0<=x<toMatch.Length==>toMatch[x]!=null
    invariant forall x, y :: 0 <= x < toMatch.Length && 0 <= toSort.Length && x == y && toMatch[x] != null ==> toSort[y] == toMatch[x].expiry_time; // 1-1 correspondence
    {
        var end := start;
        while (end >= 1 && toSort[end-1] > toSort[end])
        invariant 0 <= end <= start; // end is within limits

        invariant multiset(toSort[..]) == multiset(old(toSort[..])); // arrays stay the same
	    invariant multiset(toMatch[..]) == multiset(old(toMatch[..]));
        invariant forall i, j :: (0 <= i <= j <= start && j != end) ==> toSort[i] <= toSort[j]; // all values less than start are sorted
        invariant forall x, y :: 0 <= x < toMatch.Length && 0 <= toSort.Length && x == y && toMatch[x] != null ==> toSort[y] == toMatch[x].expiry_time; // 1-1 correspondence
        invariant forall x :: 0<=x<toMatch.Length==>toMatch[x]!=null
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


method TestInsertionSort()
{
    var nums := new int[3];
  
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

class Storage {

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
    var bloodStorage: seq<array<Blood>>;
    var transportManager: transportationManager;

    // Constructor
    constructor (name_in: string, x: int, y: int)
    modifies this
    ensures name == name_in && Xcoordinate == x && Ycoordinate == y && transportManager == null

    ensures Valid()
    {
        name := name_in;
        Xcoordinate := x;
        Ycoordinate := y;

        var a : array<Blood> := new Blood[0];
        var b : array<Blood> := new Blood[0];
        var c : array<Blood> := new Blood[0];
        var d : array<Blood> := new Blood[0];
        var e : array<Blood> := new Blood[0];
        var f : array<Blood> := new Blood[0];
        var g : array<Blood> := new Blood[0];
        var h : array<Blood> := new Blood[0];

        bloodStorage := [a,b,c,d,e,f,g,h];
        transportManager := null;
    }


    predicate Valid()
    reads this
    reads this.bloodStorage
    // reads this.shadowblood
    {|bloodStorage|==8 && forall x :: 0<=x<|bloodStorage| ==> bloodStorage[x]!=null && (forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]!=null)}





    // Adds a transportation manager
    method setTransportationManager(manager: transportationManager)
    modifies this
    ensures transportManager == manager
    {
        transportManager := manager;
    }

    
    // Stores blood and sorts according to expiry
    method storeBlood(curr_time:int,b: Blood)
    requires b != null
    requires Valid()
    modifies this
    ensures Valid()
    // Ensures other blood arrays haven't been altered
    ensures forall x :: 0<=x<|bloodStorage| && x!=findIndex(b.blood_type, b.rhesus) ==> bloodStorage[x]==old(bloodStorage[x])
    ensures forall x :: 0<=x<|bloodStorage| && x!=findIndex(b.blood_type, b.rhesus) ==> multiset(bloodStorage[x][..])==multiset(old(bloodStorage[x][..]))
    // Ensures specified blood array has only had element added
    ensures multiset(bloodStorage[findIndex(b.blood_type, b.rhesus)][..])==(multiset(old(bloodStorage[findIndex(b.blood_type, b.rhesus)][..]+[b])))

    {
        // if (b)
        var index := findIndex(b.blood_type, b.rhesus);
        // assert 0<=index<|bloodStorage|;
        // Update real array

        var prevSize := bloodStorage[index].Length;
        var newArray := new Blood[prevSize+1];
        var valuearray := new int[newArray.Length];
        var i := 0;

        assert forall x :: 0<=x<bloodStorage[index].Length ==> bloodStorage[index][x] !=null;

        while i < prevSize
        decreases prevSize - i
        invariant i - 1 < prevSize
        invariant bloodStorage==old(bloodStorage)
        invariant forall x ::  0<=x<i ==> newArray[x]!=null
        invariant forall x ::  0<=x<i ==> valuearray[x]==newArray[x].getExpiryTime()
        invariant  newArray[..i] == bloodStorage[index][..i]
        {
            newArray[i] := bloodStorage[index][i];
            valuearray[i] := newArray[i].getExpiryTime();
            i := i + 1;
        }

        newArray[newArray.Length-1]:=b;
        valuearray[newArray.Length-1]:=b.getExpiryTime();

        assert newArray[..prevSize] == bloodStorage[index][..];
        assert newArray[..] == bloodStorage[index][..] + [b];

        insertionSort(valuearray, newArray);
        bloodStorage := bloodStorage[index:= newArray];
    }

    // ISSUE: There are extra requires clauses in transportationManager's receive()
    //        that storage cannot supply. Storage can only require the below successfully,
    //        is it possible to change receive() so that it can be called from here?

    // Gives blood to transport so that they can prepare to dispatch it to the destination
    method notifyTransport(b: Blood, dest: int)
    requires b != null
    requires transportManager != null
    {
        //transManager.receive(b, dest);
        //transManager.dispatchBlood();
    }




    // Helper: Remove head of array and return it
    method pop(index: int) returns (b: Blood)
    requires 0 <= index <= 7
    requires Valid()
    modifies this
    modifies bloodStorage
    ensures Valid()
    // Ensures other blood storage arrays haven't been altered
    ensures forall x :: 0<=x<|bloodStorage| && x!=index ==> bloodStorage[x]==old(bloodStorage[x])
    ensures forall x :: 0<=x<|bloodStorage| && x!=index ==> multiset(bloodStorage[x][..])==multiset(old(bloodStorage[x][..]))

    // If target array has length>0 ensures changes, else, ensure no change
    // Ensure the altered array has the first element missing, but otherwise identical. Same elements and order
    ensures if old(bloodStorage[index].Length)>0 then old(bloodStorage[index].Length)==bloodStorage[index].Length+1 else old(bloodStorage[index].Length)==bloodStorage[index].Length
    ensures if old(bloodStorage[index].Length)>0 then forall x :: 0<=x<bloodStorage[index].Length ==> bloodStorage[index][x]==old(bloodStorage[index][x+1]) else forall x :: 0<=x<bloodStorage[index].Length ==> bloodStorage[index][x]==old(bloodStorage[index][x])
    ensures if old(bloodStorage[index].Length)>0 then multiset(bloodStorage[index][..])==multiset(old(bloodStorage[index][1..])) else multiset(bloodStorage[index][..])==multiset(old(bloodStorage[index][..]))
    ensures if old(bloodStorage[index].Length)>0 then b==old(bloodStorage[index][0]) else b==null
    {

        
        var a := bloodStorage[index];

        if (a.Length == 0) {
            b := null;
            return;
        }
        else 
        {

            
            b := a[0];
            var newArray := new Blood[a.Length-1];
            var i := 0;

            while i + 1 < a.Length
            decreases a.Length - (i + 1)
            invariant i < a.Length

            invariant forall k :: 0<=k<i ==> newArray[k]==a[k+1]
            invariant forall j :: 0<=j<a.Length ==> a[j]==old(bloodStorage[index][j])
            invariant bloodStorage==old(bloodStorage)
            invariant forall x :: 0<=x<|bloodStorage| ==> (forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]!=null)
            invariant forall x :: 0<=x<|bloodStorage| ==> multiset(bloodStorage[x][..])==multiset(old(bloodStorage[x][..]))
            invariant multiset(newArray[..i])==multiset(old(bloodStorage[index][1..i+1]))
            invariant newArray!=null
            {
                newArray[i] := a[i + 1];
                i := i + 1;
            }

            assert newArray[..a.Length-1]==newArray[..];
            assert old(bloodStorage[index][1..a.Length])==old(bloodStorage[index][1..]);
            bloodStorage := bloodStorage[index:=newArray];
        }
    }

    // Ensures that a certain blood type and rhesus corresponds to the correct index
    predicate correctIndex(t: Blood_types, rh: bool, index: int)
    reads this
    {
        (t == A && rh ==> index == 0) &&
        (t == A && !rh ==> index == 1) &&
        (t == B && rh ==> index == 2) &&
        (t == B && !rh ==> index == 3) &&
        (t == AB && rh ==> index == 4) &&
        (t == AB && !rh ==> index == 5) &&
        (t == O && rh ==> index == 6) &&
        (t == O && !rh ==> index == 7) &&
        (0 <= index <= 7)
    }

    // Helper: Returns the index that is storing the required blood type
    function method findIndex(t: Blood_types, rh: bool): int
    {
        if (t == A && rh) then 0 else
        if (t == A && !rh) then 1 else
        if (t == B && rh) then 2 else
        if (t == B && !rh) then 3 else
        if (t == AB && rh) then 4 else
        if (t == AB && !rh) then 5 else
        if (t == O && rh) then 6 else 7
        // if (t == O && !rh) then 7
    }


}


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
