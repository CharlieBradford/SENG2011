// state:
// unsafe = -1
// unverified = 0
// verified = 1
// storage = 2
// dispatch = 3
// delivered = 4


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

    function method get_state(): blood_state
	reads this
    {
        state
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

    method verify_blood(curr_time:int,accepted:bool,determined_type:Blood_types,rhesus_in:bool) returns (success:bool)
    modifies this;
    requires state==unverified
    requires Valid()
    ensures if (safe(curr_time) && accepted) then state == verified else state==unsafe
    ensures blood_type==determined_type
    ensures rhesus == rhesus_in
    ensures Valid()
	ensures if success then state==verified else state==unsafe
    ensures expiry_time==old(expiry_time)
    {
        if safe(curr_time) && accepted {
            state:=verified;
			success:=true;
        } else {
            state:=unsafe;
			success:=false;
        }

        blood_type:=determined_type;
        rhesus:=rhesus_in;
    }

    method store_blood(curr_time:int) returns (success:bool)
    modifies this
    requires Valid()
    requires state==verified;
    ensures if safe(curr_time) then state == storage else state==unsafe;
    ensures Valid()
	ensures if success then state==storage else state==unsafe
	ensures safe(curr_time) == success
	ensures blood_type==old(blood_type)
	ensures rhesus == old(rhesus)
    ensures expiry_time==old(expiry_time)
    {
        if safe(curr_time) {
            state:=storage;
			success:=true;
        } else {
            state:=unsafe;
			success:=false;
        }  
    }

    method dispatch_blood(curr_time:int) returns (success:bool)
    modifies this
    requires Valid()
    requires state==storage;
    ensures if safe(curr_time) then state == dispatched else state==unsafe;
    ensures Valid()
	ensures if success then state==dispatched else state==unsafe
	ensures blood_type==old(blood_type)
	ensures rhesus == old(rhesus)
    ensures expiry_time==old(expiry_time)
    {
        if safe(curr_time) {
            state:=dispatched;
			success:=true;
        } else {
            state:=unsafe;
			success:=false;
        }
    }

    method deliver_blood(curr_time:int) returns (success:bool)
    modifies this
    requires Valid()
    requires state==dispatched;
    ensures if safe(curr_time) then state ==delivered else state==unsafe;
    ensures Valid()
	ensures if success then state==delivered else state==unsafe
	ensures blood_type==old(blood_type)
	ensures rhesus == old(rhesus)
    ensures expiry_time==old(expiry_time)
    {
        if safe(curr_time) {
            state:=delivered;
			success:=true;
        } else {
            state:=unsafe;
			success:=false;
        }           
    }

    method reject()
    modifies this
    ensures state ==unsafe;
    ensures Valid()
    {state:=unsafe;}
}


/////////////////////////////////////////////////////////////////////////////////////////////

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
	// requires toDest != null;
	// requires toSend != null;
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

/////////////////////////////////////////////////////////////////////////////////////////////

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
requires forall x ::0 <= x < toSort.Length ==> toMatch[x].expiry_time == toSort[x];

ensures Sorted(toSort,0,toSort.Length-1);
ensures forall x :: 0<=x<toMatch.Length ==> toMatch[x]!=null
ensures forall x,z :: 0<=x<z<toSort.Length ==> toSort[x]<=toSort[z]
ensures forall x ::0 <= x < toSort.Length ==> toMatch[x].expiry_time == toSort[x];
ensures forall x,z :: 0<=x<z<toMatch.Length ==> toMatch[x].getExpiryTime()<=toMatch[z].getExpiryTime()
ensures multiset(toSort[..]) == multiset(old(toSort[..]));
ensures multiset(toMatch[..])==multiset(old(toMatch[..]))
ensures forall x, y :: 0 <= x < toSort.Length && 0 <= y < toMatch.Length && x == y && toMatch[y] != null ==> toMatch[y].expiry_time == toSort[x];
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


/////////////////////////////////////////////////////////////////////////////////////////////

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
    {|bloodStorage|==8 && (forall x :: 0<=x<|bloodStorage| ==> bloodStorage[x]!=null && (forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]!=null))}





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
    requires b.get_state()==verified
    requires Valid()
    modifies this
    modifies b
    ensures Valid()
    requires forall x :: 0<=x<|bloodStorage| ==> (forall y,z :: 0<=y<z<bloodStorage[x].Length ==> bloodStorage[x][y].getExpiryTime()<=bloodStorage[x][z].getExpiryTime())
    // Ensures other blood arrays haven't been altered
    ensures forall x :: 0<=x<|bloodStorage| && x!=findIndex(b.blood_type, b.rhesus) ==> bloodStorage[x]==old(bloodStorage[x])
    ensures forall x :: 0<=x<|bloodStorage| && x!=findIndex(b.blood_type, b.rhesus) ==> multiset(bloodStorage[x][..])==multiset(old(bloodStorage[x][..]))
    // Ensures if blood is valid for change then specified blood array has only had element added
    // But if blood is unsafe, do not change anything
    ensures if b.safe(curr_time) then multiset(bloodStorage[findIndex(b.blood_type, b.rhesus)][..])==(multiset(old(bloodStorage[findIndex(b.blood_type, b.rhesus)][..]+[b]))) else multiset(bloodStorage[findIndex(b.blood_type, b.rhesus)][..])==(multiset(old(bloodStorage[findIndex(b.blood_type, b.rhesus)][..])))
    // Ensure if blood is unsafe, then bloodstorage hasn't been changed
    ensures !b.safe(curr_time) ==> bloodStorage==old(bloodStorage)
    // Ensures that all blood arrays are correctly sorted
    ensures forall x :: 0<=x<|bloodStorage| ==> (forall y,z :: 0<=y<z<bloodStorage[x].Length ==> bloodStorage[x][y].getExpiryTime()<=bloodStorage[x][z].getExpiryTime())

    {
        var temp := b.store_blood(curr_time);
        if(!temp) {
            return;
        }


        assert forall x :: 0<=x<|bloodStorage| ==> (forall y,z :: 0<=y<z<bloodStorage[x].Length ==> bloodStorage[x][y].getExpiryTime()<=bloodStorage[x][z].getExpiryTime());

        var index := findIndex(b.blood_type, b.rhesus);

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
        invariant newArray[..i] == bloodStorage[index][..i]
        invariant findIndex(b.blood_type, b.rhesus)==index;
        invariant b.safe(curr_time)
        invariant forall x :: 0<=x<|bloodStorage| ==> (forall y,z :: 0<=y<z<bloodStorage[x].Length ==> bloodStorage[x][y].getExpiryTime()<=bloodStorage[x][z].getExpiryTime())
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






    // method discardBlood(curr_time:int)
    // requires Valid()
    // requires forall x :: 0<=x<|bloodStorage| ==> (forall y,z :: 0<=y<z<bloodStorage[x].Length ==> bloodStorage[x][y].getExpiryTime()<=bloodStorage[x][z].getExpiryTime())
    // modifies this
    // modifies this.bloodStorage
    // modifies set j | 0<=j<|this.bloodStorage| :: this.bloodStorage[j]
    // ensures Valid()
    // {
    //     var bloodsize := |bloodStorage|;
    //     var i:=0;
    //     var x;
    //     while i < bloodsize
    //     modifies this
    //     modifies this.bloodStorage
    //     modifies set j | 0<=j<|this.bloodStorage| :: this.bloodStorage[j]
    //     decreases bloodsize-i
    //     invariant |bloodStorage|==8 && (forall x :: 0<=x<|bloodStorage| ==> bloodStorage[x]!=null && (forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]!=null))
    //     invariant forall x :: 0<=x<|bloodStorage| ==> (forall y,z :: 0<=y<z<bloodStorage[x].Length ==> bloodStorage[x][y].getExpiryTime()<=bloodStorage[x][z].getExpiryTime())
    //     {
    //         while bloodStorage[i].Length>0 && bloodStorage[i][0].getExpiryTime() - curr_time < 60*60*25
    //         modifies this
    //         modifies this.bloodStorage
    //         modifies set j | 0<=j<|this.bloodStorage| :: this.bloodStorage[j]
    //         invariant |bloodStorage|==8 && (forall x :: 0<=x<|bloodStorage| ==> bloodStorage[x]!=null && (forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]!=null))
    //         invariant forall x :: 0<=x<|bloodStorage| ==> (forall y,z :: 0<=y<z<bloodStorage[x].Length ==> bloodStorage[x][y].getExpiryTime()<=bloodStorage[x][z].getExpiryTime())
    //         {
    //             // We want to discard blood, so ignore return value
    //             x:=pop(i); 
    //         }
    //         i:=i+1;
    //     }
    // }
 

    // Helper: Remove head of array and return it
    method pop(index: int) returns (b: Blood)
    requires 0 <= index <= 7
    requires Valid()
    requires forall x :: 0<=x<|bloodStorage| ==> (forall y,z :: 0<=y<z<bloodStorage[x].Length ==> bloodStorage[x][y].getExpiryTime()<=bloodStorage[x][z].getExpiryTime())
    modifies this
    modifies this.bloodStorage
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
    ensures forall x :: 0<=x<|bloodStorage| ==> (forall y,z :: 0<=y<z<bloodStorage[x].Length ==> bloodStorage[x][y].getExpiryTime()<=bloodStorage[x][z].getExpiryTime())
    ensures fresh (bloodStorage)
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
            invariant forall x :: 0<=x<|bloodStorage| ==> (forall y,z :: 0<=y<z<bloodStorage[x].Length ==> bloodStorage[x][y].getExpiryTime()<=bloodStorage[x][z].getExpiryTime())
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

