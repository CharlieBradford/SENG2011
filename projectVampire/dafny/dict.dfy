#include donor.dfy

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
