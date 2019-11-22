
// state:
// unsafe = -1
// unverified = 0
// verified = 1
// storage = 2
// dispatched = 3
// delivered = 4


datatype Blood_types = O | A | B | AB
datatype blood_state = unsafe | unverified | verified | storage | dispatched | delivered


// Magic number in expiry time 86400(seconds in day) * 7 =  604800
class Blood{
    var state: blood_state;
    var collection_time: int; //Seconds since Unix Epoch
    var expiry_time:int
    var blood_type: Blood_types;
    var rhesus: bool;

    predicate method Valid()
    reads this
    {state== unsafe || state==unverified || state==verified || state==storage || state==dispatched || state==delivered}

    predicate method expired(curr_time:int)
    reads this
    {curr_time>expiry_time}

    predicate method safe(curr_time:int)
    reads this
    {(state==unverified || state==verified || state==storage || state==dispatched || state==delivered) && !expired(curr_time)}

    function method getExpiryTime(): int
    reads this;
    {
        expiry_time
    }

    method reject_blood()
    modifies this;
    ensures state == unsafe
    ensures Valid()
    {
        state := unsafe;
    }

    method get_blood_type() returns (b_type:Blood_types,rh:bool)
    ensures b_type==blood_type
    ensures rh==rhesus
    {
        b_type := blood_type;
        rh := rhesus;
    }

    function method get_state(): blood_state
	reads this
    {
        state
    }

    constructor (secondsin:int)
    modifies this
    requires secondsin>=0
    ensures collection_time>=0 && collection_time==secondsin
    ensures state == unverified;
    {
        collection_time := secondsin;
        expiry_time:=secondsin + 604800;
        state := unverified;
    }

    method verify_blood(curr_time:int,accepted:bool,determined_type:Blood_types,rhesus_in:bool) returns (success:bool)
    modifies this;
    requires state==unverified
    requires Valid()
    ensures if (safe(curr_time) && accepted) then state == verified else state==unsafe
    ensures blood_type==determined_type
    ensures rhesus == rhesus_in
    ensures Valid()
	ensures if success then state==verified else state==unsafe
    ensures expiry_time==old(expiry_time)
    {
        if safe(curr_time) && accepted {
            state:=verified;
			success:=true;
        } else {
            state:=unsafe;
			success:=false;
        }

        blood_type:=determined_type;
        rhesus:=rhesus_in;
    }

    method store_blood(curr_time:int) returns (success:bool)
    modifies this
    requires Valid()
    requires state==verified;
    ensures if safe(curr_time) then state == storage else state==unsafe;
    ensures Valid()
	ensures if success then state==storage else state==unsafe
	ensures safe(curr_time) == success
	ensures blood_type==old(blood_type)
	ensures rhesus == old(rhesus)
    ensures expiry_time==old(expiry_time)
    {
        if safe(curr_time) {
            state:=storage;
			success:=true;
        } else {
            state:=unsafe;
			success:=false;
        }  
    }

    method dispatch_blood(curr_time:int) returns (success:bool)
    modifies this
    requires Valid()
    requires state==storage;
    ensures if safe(curr_time) then state == dispatched else state==unsafe;
    ensures Valid()
	ensures if success then state==dispatched else state==unsafe
	ensures blood_type==old(blood_type)
	ensures rhesus == old(rhesus)
    ensures expiry_time==old(expiry_time)
    {
        if safe(curr_time) {
            state:=dispatched;
			success:=true;
        } else {
            state:=unsafe;
			success:=false;
        }
    }

    method deliver_blood(curr_time:int) returns (success:bool)
    modifies this
    requires Valid()
    requires state==dispatched;
    ensures if safe(curr_time) then state ==delivered else state==unsafe;
    ensures Valid()
	ensures if success then state==delivered else state==unsafe
	ensures blood_type==old(blood_type)
	ensures rhesus == old(rhesus)
    ensures expiry_time==old(expiry_time)
    {
        if safe(curr_time) {
            state:=delivered;
			success:=true;
        } else {
            state:=unsafe;
			success:=false;
        }           
    }

    method reject()
    modifies this
    ensures state ==unsafe;
    ensures Valid()
    {state:=unsafe;}
}