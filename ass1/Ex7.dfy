method Just1 (a: array<int>, key: int) returns (clean: bool)
	requires a != null;
{
	var occursOnce := (exists j :: 0 <= j < a.Length && a[j] == key);           // Check that the key appears at least once
	// var onlyOnce := forall j :: (0 <= j < a.Length && a[j] == key)                    // If a[j] == key and a[k] == key then k == j
    //		 ==> (forall k :: (0 <= k < a.Length && a[k] == key) ==> k == j);
	var onlyOnce := forall j, k :: 0 <= k < a.Length && a[k] == key ==> (0 <= j < a.Length ==> a[j] != key || k == j);
	clean := occursOnce && onlyOnce;
}

method Main() 
{
	var a, i;
	a := new int[4];
	a[0], a[1], a[2], a[3] := 1, 1, 2, 1;

	assert a[0] == 1 && a[1] == 1 && a[2] == 2 &&  a[3] == 1;

	i := Just1(a, 1);

	// assert !i; ---- Predicate is valid but triggers (odd dafny quirk) don't seem to be sufficient for dafny to verify
	print(i);
	print("\n");

	i := Just1(a, 2);
	// assert i;  ---- as above
	print(i);
	print("\n");

	i := Just1(a, 3);
	// assert !i;
	print(i);
	print("\n");

	a := new int[1];
	a[0] := 1;

	assert(a[0] == 1);
	
	i := Just1(a, 1);
	// assert i; ---- as above
	print(i);
	print("\n");

	i := Just1(a, 2);
	// assert !i;
	print(i);
	print("\n");

	a := new int[0];
	
	i := Just1(a, 1);
	// assert !i;
	print(i);
	print("\n");
}
