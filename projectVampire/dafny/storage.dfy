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
//requires forall x :: 0 <= x < toSort.Length ==> toSort[x] != null
requires forall x,y ::0 <= x < toSort.Length && 0 <= y < toMatch.Length && x == y  && toMatch[y] != null ==> toMatch[y].expiry_time == toSort[x];

ensures Sorted(toSort,0,toSort.Length-1);
ensures multiset(toSort[..]) == multiset(old(toSort[..]));
ensures multiset(toMatch[..]) == multiset(old(toMatch[..]))
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
    invariant forall x, y :: 0 <= x < toMatch.Length && 0 <= toSort.Length && x == y && toMatch[x] != null ==> toSort[y] == toMatch[x].expiry_time;
    invariant forall x :: 0<=x<toMatch.Length ==> toMatch[x]!=null
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
        invariant forall x :: 0<=x<toMatch.Length ==> toMatch[x]!=null
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
    ghost var shadowblood : seq<seq<Blood>>
    var transManager: transportationManager;


    predicate Valid()
    reads this
    reads this.bloodStorage
    // reads this.shadowblood
    {|bloodStorage|==8 && forall x :: 0<=x<|bloodStorage| ==> bloodStorage[x]!=null && (forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]!=null)}



    // {|bloodStorage|==|shadowblood| && 
    //     forall x :: 0<=x<|bloodStorage| ==> (bloodStorage[x] !=null && bloodStorage[x].Length==|shadowblood[x]| && 
    //         forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]==shadowblood[x][y])
    // }

    // predicate eightBloodTypes(a: seq<array<Blood>>)
    // // requires a != null
    // reads a
    // {
    //     |a| == 8
    // }

    // Constructor
    constructor (n: string, x: int, y: int)
    modifies this
    ensures name == n && Xcoordinate == x && Ycoordinate == y && transManager == null
    // ensures eightBloodTypes(bloodStorage)
    // ensures storageInitialised(bloodStorage)
    ensures Valid()
    {
        name := n;
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
        var a1: seq<Blood> := [];
        var a2: seq<Blood> := [];
        var a3: seq<Blood> := [];
        var a4: seq<Blood> := [];
        var a5: seq<Blood> := [];
        var a6: seq<Blood> := [];
        var a7: seq<Blood> := [];
        var a8: seq<Blood> := [];
        shadowblood := [a1,a2,a3,a4,a5,a6,a7,a8];

        transManager := null;
    }

    // predicate storageInitialised(a: seq<array<Blood>>)
    // reads a
    // {
    //     forall k :: 0 <= k < |a| ==> a[k] != null && forall j :: 0<=j<a[k].Length ==> a[k][j] != null
    // }


    // Adds a transportation manager
    method setTransportationManager(manager: transportationManager)
    modifies this
    ensures transManager == manager
    {
        transManager := manager;
    }

    // ISSUE: For some reason the error is that bloodStorage might be null,
    //        despite my requires bloodStorage != null
    
    // Stores blood and sorts according to expiry
    method storeBlood(b: Blood)
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

        

        var index := findIndex(b.blood_type, b.rhesus);
        assert 0<=index<|bloodStorage|;
        // Update real array

        var prevSize := bloodStorage[index].Length;
        var newArray := new Blood[prevSize+1];
        var i := 0;

        assert forall x :: 0<=x<bloodStorage[index].Length ==> bloodStorage[index][x] !=null;

        while i < prevSize
        decreases prevSize - i
        invariant i - 1 < prevSize
        invariant bloodStorage==old(bloodStorage)
        invariant forall x :: 0<=x <|bloodStorage| ==> bloodStorage[x]!=null
        invariant 0<=index<|bloodStorage| && bloodStorage[index]!=null
        invariant forall k :: 0 <= k < i<=bloodStorage[index].Length ==> newArray[k] == bloodStorage[index][k]
        invariant forall k :: 0<=k<i<=bloodStorage[index].Length ==> newArray[k]==bloodStorage[index][k]
        // invariant forall x :: 0<=x<|bloodStorage| ==> (forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]!=null)
        invariant |bloodStorage|==old(|bloodStorage|)
        invariant forall x :: 0<=x<old(|bloodStorage|) ==> bloodStorage[x]==old(bloodStorage[x])
        invariant forall x :: 0<=x<bloodStorage[index].Length ==> bloodStorage[index][x] !=null;

        {
            newArray[i] := bloodStorage[index][i];
            i := i + 1;
        }




        newArray[newArray.Length-1]:=b;
        // assert multiset(newArray[..newArray.Length-1])==(multiset(old(bloodStorage[index][..]+[b])));
        
        assert forall x :: 0<=x<newArray.Length-1 ==> newArray[x]==bloodStorage[index][x];
        assert forall x :: 0<=x<newArray.Length ==> newArray[x] !=null;

        // assert 0<=index<|bloodStorage|;

        var valuearray := new int[newArray.Length];
        i := 0;
        while (i < newArray.Length)
        invariant valuearray.Length == newArray.Length
        invariant i < newArray.Length+1
        invariant bloodStorage==old(bloodStorage)
        invariant |bloodStorage|==old(|bloodStorage|)
        invariant 0<=index<|bloodStorage|
        // invariant forall x :: 0<=x<|bloodStorage| ==> (forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]!=null)
        invariant forall x :: 0<=x <|bloodStorage| ==> bloodStorage[x]!=null
        invariant forall x :: 0<=x<newArray.Length ==> newArray[x] !=null
        invariant forall x ::  0<=x<i ==> valuearray[x]==newArray[x].getExpiryTime()
        {
            valuearray[i] := newArray[i].getExpiryTime();
            i:=i+1;
        }

        // assert multiset(newArray[..])==(multiset(old(bloodStorage[index][..]+[b])));

        insertionSort(valuearray, newArray);
        // assert (forall x :: 0<=x<|bloodStorage| ==> (forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]!=null));
        bloodStorage := bloodStorage[index:= newArray];


        // assert multiset(bloodStorage[index][..])==(multiset(old(bloodStorage[index][..]+[b])));

        assert (forall x :: 0<=x<|bloodStorage| && x!=index ==> (forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]!=null));
        assert forall y :: 0<=y<newArray.Length ==>newArray[y]!=null;

        assert |bloodStorage|==8;
        assert (forall x :: 0<=x<|bloodStorage| ==> bloodStorage[x]!=null);
        assert (forall x :: 0<=x<|bloodStorage| ==> (forall y :: 0<=y<bloodStorage[x].Length ==> bloodStorage[x][y]!=null));
    }

    // ISSUE: There are extra requires clauses in transportationManager's receive()
    //        that storage cannot supply. Storage can only require the below successfully,
    //        is it possible to change receive() so that it can be called from here?

    // Gives blood to transport so that they can prepare to dispatch it to the destination
    method notifyTransport(b: Blood, dest: int)
    requires b != null
    requires transManager != null
    {
        //transManager.receive(b, dest);
        //transManager.dispatchBlood();
    }

    // ISSUE: Verification not completed, need ensures clause

    // Helper: Remove head of array and return it
    // method pop(index: int) returns (b: Blood)
    // requires 0 <= index <= 7
    // requires storageInitialised(bloodStorage)
    // requires eightBloodTypes(bloodStorage)
    // requires bloodStorage[index].Length>2

    // modifies this
    // modifies bloodStorage

    // ensures eightBloodTypes(bloodStorage)
    // ensures storageInitialised(bloodStorage)
    // ensures if old(bloodStorage[index].Length==0) then b==null else b==old(bloodStorage[index][0])

    // ensures forall x :: 0<=x<|bloodStorage| && x!=index ==> bloodStorage[x]==old(bloodStorage[x])
    // ensures if old(bloodStorage[index].Length==0) then bloodStorage[index]==old(bloodStorage[index]) else bloodStorage[index].Length==old(bloodStorage[index].Length)-1
    // ensures if old(bloodStorage[index].Length==0) then bloodStorage[index]==old(bloodStorage[index]) else forall x :: 0<= x < bloodStorage[index].Length ==>bloodStorage[index][x]==old(bloodStorage[index][x+1])
    // {
    //     // var a1: array<Blood> :=bloodStorage[0];
    //     // var b1: array<Blood> :=bloodStorage[1];
    //     // var c1: array<Blood> :=bloodStorage[2];
    //     // var d1: array<Blood> :=bloodStorage[3];
    //     // var e1: array<Blood> :=bloodStorage[4];
    //     // var f1: array<Blood> :=bloodStorage[5];
    //     // var g1: array<Blood> :=bloodStorage[6];
    //     // var h1: array<Blood> :=bloodStorage[7];

    //     var a := bloodStorage[index];

    //     if (a.Length == 0) {
    //         b := null;
    //         return;
    //     }
    //     else 
    //     {
    //         b := a[0];
    //         var newArray := new Blood[a.Length-1];
    //         var i := 0;
    //         while i + 1 < a.Length
    //         decreases a.Length - (i + 1)
    //         invariant i < a.Length
    //         invariant forall k :: 0<=k<i ==> newArray[k]==a[k+1]
    //         invariant forall j :: 0<=j<a.Length ==> a[j]==old(bloodStorage[index][j])
    //         invariant |bloodStorage|==old(|bloodStorage|)
    //         invariant forall x :: 0<=x<old(|bloodStorage|) ==> bloodStorage[x]==old(bloodStorage[x])
    //         {
    //             newArray[i] := a[i + 1];
    //             i := i + 1;
    //         }
    //         change_blood_storage(index,newArray);
    //         // assert()
    //         // if index==0 {
    //         //     a1:=newArray;
    //         // }
    //         // if index==1 {
    //         //     b1:=newArray;
    //         // }
    //         // if index==2 {
    //         //     c1:=newArray;
    //         // }
    //         // if index==3 {
    //         //     d1:=newArray;
    //         // }
    //         // if index==4 {
    //         //     e1:=newArray;
    //         // }
    //         // if index==5 {
    //         //     f1:=newArray;
    //         // }
    //         // if index==6 {
    //         //     g1:=newArray;
    //         // }
    //         // if index==7 {
    //         //     h1:=newArray;
    //         // }
    //         // bloodStorage := [a1,b1,c1,d1,e1,f1,g1,h1];
    //     }
    // }



    // method change_blood_storage(index:int,newArray:array<Blood>)
    // requires 0<=index<=7
    // requires |bloodStorage|==8
    // modifies this.bloodStorage
    // ensures |bloodStorage|==old(|bloodStorage|)
    // ensures forall i :: 0<=i<|bloodStorage| && i!=index ==> bloodStorage[i]==old(bloodStorage[i])
    // ensures bloodStorage[index]==newArray
    // {
    //     var a1: array<Blood> :=bloodStorage[0];
    //     var b1: array<Blood> :=bloodStorage[1];
    //     var c1: array<Blood> :=bloodStorage[2];
    //     var d1: array<Blood> :=bloodStorage[3];
    //     var e1: array<Blood> :=bloodStorage[4];
    //     var f1: array<Blood> :=bloodStorage[5];
    //     var g1: array<Blood> :=bloodStorage[6];
    //     var h1: array<Blood> :=bloodStorage[7];

    //     if index==0 {
    //         a1:=newArray;
    //     }
    //     if index==1 {
    //         b1:=newArray;
    //     }
    //     if index==2 {
    //         c1:=newArray;
    //     }
    //     if index==3 {
    //         d1:=newArray;
    //     }
    //     if index==4 {
    //         e1:=newArray;
    //     }
    //     if index==5 {
    //         f1:=newArray;
    //     }
    //     if index==6 {
    //         g1:=newArray;
    //     }
    //     if index==7 {
    //         h1:=newArray;
    //     }
        
    // }



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

    // function method findIndex(t: Blood_types, rh: bool) returns (index: int)
    // ensures correctIndex(t, rh, index)
    // {
    //     if (t == A && rh) {
    //         index := 0;
    //     }
    //     else if (t == A && !rh) {
    //         index := 1;
    //     }
    //     else if (t == B && rh) {
    //         index := 2;
    //     }
    //     else if (t == B && !rh) {
    //         index := 3;
    //     }
    //     else if (t == AB && rh) {
    //         index := 4;
    //     }
    //     else if (t == AB && !rh) {
    //         index := 5;
    //     }
    //     else if (t == O && rh) {
    //         index := 6;
    //     }
    //     else if (t == O && !rh) {
    //         index := 7;
    //     }
    // }

}

