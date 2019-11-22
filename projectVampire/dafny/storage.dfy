// Storage class

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

