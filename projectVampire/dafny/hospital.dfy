class hospital {

	var x : int;
	var y : int;
	var name : string;
	var tMan : transportationManager;
	var blood : array<Blood>;	
	var size: int;
	var available: int;	
	var patho : pathology;
	

	predicate method Valid()
	reads this;
	reads this.blood;
	requires blood != null;
	{
		blood != null &&
		size > 0 &&
		size == blood.Length &&
		-1 < available <= size -1
	}

	method init(nm:string, xVal:int, yVal:int) 
	modifies this
	modifies this`x
	modifies this`y
	modifies this`name
	modifies this.blood
	modifies this`size
	modifies this`available
	{
		name := nm;
		x := xVal;
		y := yVal;
		size := 10;
		available := 0;	
		blood := new Blood[size];
	}

	method collect_blood(donordb: map<int,int>, donor_id: int, curr_time: int) 
	modifies this.blood
	modifies this`available
	requires patho != null
	requires blood != null
	requires forall x :: 0 <= x < blood.Length && blood[x] != null ==> blood[x].state == verified
	requires Valid();ensures Valid();
	ensures blood[available] != null ==> blood[available].state == verified
	ensures 0 <= available < blood.Length
	{
		if donor_id in donordb {
			// do something
		}
		var allowed := true; // determined by value in donor class
		if (allowed) {
			var bld := new Blood(1); // blood as collected from donor class
			patho.verify(bld);
			if bld.state == verified {
				available := if available == size -1 then 0 else available + 1;
				blood[available] := bld;
			}

		} else {
			// Can't take blood, too soon since last donation time
		}
	}

	method obtainBlood()
	modifies this.blood
	requires blood != null
	requires Valid();
	ensures blood != null
	ensures Valid()
	ensures forall x :: 0 <= x < blood.Length ==> blood[x] == null
	{	
		var toSend := blood;
		// toSend is sent to transport on dispatch request
		var i := 0;
		while (i < blood.Length) 
		invariant 0 <= i <= blood.Length
		invariant forall x :: 0 <= x < i ==> blood[x] == null;
		{
			blood[i] := null;
			i := i + 1;
		}
	}

}
