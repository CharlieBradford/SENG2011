

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


method Test()
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

