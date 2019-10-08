method Skippy(limit: nat) 
{
	var skip := 7;
	var index := 0;
	while index <= limit
	invariant index - skip <= limit
	{
		index := index + skip;
	}
	assert (index >= 0) && (index - skip <= limit);
}
