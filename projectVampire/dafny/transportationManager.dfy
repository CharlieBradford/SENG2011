class transportationManager {
	
	var locale: int; // give each location an int value?
	var destinations: array<int>; //:= new int[10]; // routes to destinations
	var toSend: array<Blood>;// := new Blood[10]; // may need to have another array that matches the blood destinations to each index or create a class that can hold blood and its dest
    	var toDest: array<int>;// := new int[10]; // routes (match with toSend array)

    	

	// Blood always has a destination, ie every blood in array is matched by a route
	predicate method Valid()
	//requires toDest != null;
	//requires toSend != null
	reads this;
	//reads toDest[0],toDest[1], toDest[2],toDest[3],toDest[4],toDest[5],toDest[6],toDest[7],toDest[8],toDest[9];
	// requires toDest != null;
	// requires toSend != null;
	{
        	//forall x,y:: 0 <= x < toDest.Length && 0 <= y < toSend.Length && x == y ==> toDest[x]!=-1 && toSend[y] != null
    		toDest !=null && toSend != null
	}


	method Init(src: int)
	modifies this;
	modifies toDest;
	modifies toSend;
	modifies `locale;
	requires src >= 0
	ensures toDest != null;
	ensures toSend != null;
	ensures Valid()
	{
		locale := src;
		toDest := new int[10];
		toSend := new Blood[10];
		//var i := 0;
		//assert toSend != null;
		//while (i < toSend.Length) 
		//invariant 0 <= i < toSend.Length
		//{	
		//	toSend[i] := null;
		//	i := i + 1;
		//}
		//i := 0;
		//while (i < toDest.Length)
		//invariant 0 <= i < toDest.Length
		//{
		//	toDest[i] := -1;
		//	i := i + 1;
		//}
	}

		
	method receive(bld:Blood, dst:int)
	modifies this.toDest
	modifies this.toSend 
	requires toSend != null
	requires toDest != null
	requires forall x :: 0 <= x < toSend.Length ==> bld != toSend[x] // blood is not already in toSend
	requires bld != null;
	requires toSend.Length == toDest.Length
	requires dst >= 0;
	requires Valid(); ensures Valid();
	//ensures forall x, y:: 0 <= x < toSend.Length && 0 <= y < toDest.Length && x == y ==> toSend[x] == bld && toDest[y] == dst -> need to fix
	{
       		var cDest := -1;
		if (dst == -1) {
			cDest := 3; // need to grab the dest that system spits out
		} else {
			cDest := -1;
		}
		//var index := 0;
		//var i := 0;
		//while (index < toSend.Length) 
		//invariant 0 <= i <= toSend.Length
		//{
		//	if (toSend[i] == null) {
		//		index := i;
		//		i := toSend.Length -1;		
		//	}
		//	i :=  i + 1;
		//}
		//toSend[i] := bld;
		//toDest[i] := cDest;

		var i := 0;
		var j := 0;
		while (i < toSend.Length && j < toDest.Length)
		invariant 0 <= i <= toSend.Length
		invariant 0 <= j <= toDest.Length
		//invariant forall x,y :: 0 <= x < toSend.Length && 0 <= y < toDest.Length && toDest[y] == cDest && toSend[x] == bld ==> (x==y) -> need to fix
		//invariant forall x :: 0 <= x < (j-1) ==> toDest[x] != 0
		//invariant forall x, y :: 0 <= x < i && 0 <= y < j && x == y ==> toSend[x] == bl
		invariant i == j
		{
			if (toSend[i] == null && toDest[j] == 0) {
				toSend[i] := bld;
				toDest[j] := cDest;
				//i := toSend.Length -1;
				//j := toDest.Length -1;
			}
			i := i + 1;
			j := j + 1;
		}
    	}


	method dispatchBlood()
	modifies toSend;
	modifies toDest;
	requires toSend != null;
	requires toDest != null;
	requires exists x :: 0 <= x < toSend.Length && toSend[x] != null // blood is to be sent
	requires Valid();ensures Valid();
    	ensures forall x, y:: 0 <= x < toSend.Length && 0 <= y < toDest.Length  && x == y ==> (toSend[x] == null && toDest[y] == 0) // toSend and toRoute are empty
	{
		var i := 0;
		var j := 0;
		while (i < toSend.Length && j < toDest.Length)
		invariant 0 <= i <= toSend.Length
		invariant 0 <= j <= toDest.Length
		invariant forall x :: 0 <= x < i ==> toSend[x] == null
		invariant forall x :: 0 <= x < j ==> toDest[x] == 0
		invariant i == j
		{
			toDest[j] := 0;
			toSend[i] := null;
			i := i + 1;
			j := j + 1;
		}
		
    	}
    
}