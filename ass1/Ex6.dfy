method IsClean (a: array<int>, key: int) returns (clean: bool)
	requires a != null;
{
	clean := forall j :: 0 <= j < a.Length ==> a[j] != key;
}

method Main() 
{
	var a, i;
	a := new int[5];
	a[0], a[1], a[2], a[3], a[4] := 1, 2, 2, 2, 3;
	
	i := IsClean(a, 1);
	print(i);
	print("\n");
	i := IsClean(a, 2);
	print(i);
	print("\n");
	i := IsClean(a, 3);
	print(i);
	print("\n");
	i := IsClean(a, 4);
	print(i);
	print("\n");

	a := new int[1];
	a[0] := 1;
	
	i := IsClean(a, 1);
	print(i);
	print("\n");
	i := IsClean(a, 2);
	print(i);
	print("\n");

	a := new int[0];
	
	i := IsClean(a, 1);
	print(i);
	print("\n");
}
