
predicate Sorted(arr: array<int>)
reads a
{
    forall i, j :: 0 <= i < j < arr.Length ==> arr[i] <= arr[j]
}


method insertionSort(toSort: array<int>)
requires toSort != null
requires toSort.Length > 1
ensures Sorted(toSort,0,toSort.Length);
ensures multiset(toSort[..]) == multiset(old(toSort[..]));
modifies toSort;
{
    var start := 1;
    while (start < toSort.Length)
    invariant 1 <= start <= toSort.Length;
    invariant Sorted(toSort, 0, start); // array is sorted up to start
    invarinat multiset(toSort[..]) == multiset(old(toSort[..])) // keep array the same
    {
        var end := start;
        while (end >= 1 && toSort[end-1] > toSort[end])
        invariant 0 <= end <= start; // end is within limits
        invariant multiset(toSort[..]) == multiset(old(toSort[..])); // array stays the same
        invariant forall i, j :: (0 <= i <= j <= start && j != down) ==> a[i] <= a[j]; // all values less 
                                                                                       // than start are sorted
        {
            var temp := toSort[end-1]
            toSort[end-1] = toSort[end]
            toSort[end] = temp
            end = end - 1
        }
        start = start + 1
    }
}



