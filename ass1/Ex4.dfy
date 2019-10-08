method IncDec(x: int, y: int) returns (sum: int)
ensures sum == x + y
{
	sum := x;
	if y == 0 {
		return;
	}
	var inc := if y < 0 then -1 else 1;

	while ( if inc == 1 then sum < (x + y) else sum > (x + y) )
	invariant inc == 1 ==> (sum + inc) <= (x + y + 1)
	invariant inc == -1 ==> (sum + inc) >= (x + y - 1)
	decreases ( if inc == 1 then x + y - (sum + inc) else sum + inc - (x + y) ) 
	{
		sum := sum + inc;
	}
} 

method Test () {
	var i;
	i := IncDec(5, 15);
	assert i == 20;
	i := IncDec(5, -15);
	assert i == -10;
	i := IncDec(5, 0);
	assert i == 5;
	i := IncDec(-5, 15);
	assert i == 10;
	i := IncDec(-5, -15);
	assert i == -20;
	i := IncDec(-5, 0);
	assert i == -5;
}

