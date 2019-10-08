predicate EOSorted(a: array<int>)
	requires a != null
	reads a
{
	forall j :: 2 < j < a.Length ==> a[j] >= a[j-2]
}

method Test () 
{
	var a;
	a := new int[6];
	a[0], a[1], a[2], a[3], a[4], a[5] := 2, 1, 4, 2, 6, 3;
	assert EOSorted(a);

	a := new int[0];
	assert EOSorted(a);

	a := new int[2];
	a[0], a[1] := 1, 2;
	assert EOSorted(a);

	a[0], a[1] := 2, 1;
	assert EOSorted(a);

	a:= new int[4];
	a[0], a[1], a[2], a[3] := 1, 2, 3, 1;
	assert !EOSorted(a);
}
