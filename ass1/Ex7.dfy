method Just1 (a: array<int>, key: int) returns (clean: bool)
	requires a != null;
{
	clean := (exists j :: 0 <= j < a.Length && a[j] == key) &&
		forall j :: (0 <= j < a.Length && a[j] == key)
		 ==> (forall k :: (0 <= k < a.Length && a[k] == key) ==> k == j);
}

method Main() 
{
	var a, i;
	a := new int[4];
	a[0], a[1], a[2], a[3] := 1, 1, 2, 1;
	
	i := Just1(a, 1);
	print(i);
	print("\n");
	i := Just1(a, 2);
	print(i);
	print("\n");
	i := Just1(a, 3);
	print(i);
	print("\n");

	a := new int[1];
	a[0] := 1;
	
	i := Just1(a, 1);
	print(i);
	print("\n");
	i := Just1(a, 2);
	print(i);
	print("\n");

	a := new int[0];
	
	i := Just1(a, 1);
	print(i);
	print("\n");
}
