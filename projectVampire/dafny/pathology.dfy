class pathology {
	

	var tMan: transportationManager;
	
	method Init(t : transportationManager)
	modifies this
	modifies tMan
	//ensures fresh(tMan)
	{
		tMan := t;
	}
	
	
	method accept (bld : Blood)
	modifies tMan
	modifies tMan.toDest
	modifies tMan.toSend
	modifies tMan`locale
	modifies bld
	requires this.tMan != null

	requires tMan.toSend != null
	requires tMan.toDest != null
	requires forall x :: 0 <= x < tMan.toSend.Length ==> tMan.toSend[x] != bld
	requires tMan.Valid()
	requires bld != null
	requires bld.state == unverified
	ensures tMan != null
	{
		verify(bld);
		if (bld.state == verified) {
			// do something
			tMan.receive(bld, 1); // system will find a suitable dest for blood
			tMan.dispatchBlood();
		} else {
			// blood is discarded and not sent further
		}
	

	}

	method verify(bld:Blood) 
	modifies bld
	requires bld != null
	requires bld.state == unverified
	ensures bld.state == verified || bld.state == unsafe 
	ensures bld.blood_type == O || bld.blood_type == A || bld.blood_type == AB || bld.blood_type == B
	ensures bld.rhesus == false || bld.rhesus == true
	ensures bld != null
	{
		var bType := O; // practically will be any blood_type as per blood class limits
		var chosenRhes := false; // practically will be 0 or 1
		var accepted := true;

		bld.verify_blood(1,accepted,bType,chosenRhes);

	}
}
