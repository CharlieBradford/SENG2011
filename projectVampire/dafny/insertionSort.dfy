predicate Sorted(arr: array<int>, start:int, end:int)
requires arr != null;
requires 0<=start<arr.Length;
requires end <= arr.Length;
reads arr;
{
    forall i, j :: start <= i < j < end ==> arr[i] <= arr[j]
}


method insertionSort(toSort: array<int>)
requires toSort != null;
requires toSort.Length > 1;
ensures Sorted(toSort,0,toSort.Length-1);
ensures multiset(toSort[..]) == multiset(old(toSort[..]));
modifies toSort;
{
    var start := 1;
    while (start < toSort.Length)
    invariant 1 <= start <= toSort.Length;
    invariant Sorted(toSort, 0, start); // array is sorted up to start
    invariant multiset(toSort[..]) == multiset(old(toSort[..])); // keep array the same
    {
        var end := start;
        while (end >= 1 && toSort[end-1] > toSort[end])
        invariant 0 <= end <= start; // end is within limits
        invariant multiset(toSort[..]) == multiset(old(toSort[..])); // array stays the same
        invariant forall i, j :: (0 <= i <= j <= start && j != end) ==> toSort[i] <= toSort[j]; // all values less than start are sorted
        {
            var temp := toSort[end-1];
            toSort[end-1] := toSort[end];
            toSort[end] := temp;
            end := end - 1;
        }
        start := start + 1;
    }
}


method Test()
{
    var test1 := new int[4];
    test1[0] := 10;
    test1[1] := 5;
    test1[2] := 12;
    test1[3] := 1;
    
    insertionSort(test1);
    assert Sorted(test1,0,test1.Length-1);    

}