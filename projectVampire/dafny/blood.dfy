// state:
// unsafe = -1
// unverified = 0
// verified = 1
// storage = 2
// dispatch = 3
// delivered = 4

datatype Blood_types = O | A | B | AB

class Blood{
    var state: int;
    var collection_time: int; //Seconds since Unix Epoch
    var expiry_time:int
    var blood_type: Blood_types;
    var rhesus: bool;

    predicate method Valid()
    reads this
    {-1<=state<=4}



// Every function takes in the current time as an integer(Number of seconds since Unix Epoch time)
// Theres a python class time_sec that lets us get this easily. You can write your function to similarly
// take in curr_time and just work with that
    predicate method expired(curr_time:int)
    reads this
    {curr_time>expiry_time}

    predicate method safe(curr_time:int)
    reads this
    {0<=state<=4 && !expired(curr_time)}

    constructor (secondsin:int)
    modifies this
    requires secondsin>=0
    ensures collection_time>=0 && collection_time==secondsin
    ensures Valid()
    ensures state == 0;
    {
        collection_time := secondsin;
        expiry_time:= (secondsin + 43*86400);
        state := 0;
    }

    method verify(curr_time:int,determined_type:Blood_types,rhesus_in:bool)
    modifies this;
    requires Valid()
    ensures Valid()
    requires state==0;
    ensures if safe(curr_time) then state ==1 else state==-1
    ensures blood_type==determined_type
    ensures rhesus == rhesus_in
    {
        if safe(curr_time) {
            state:=1;
        } else {
            state:=-1;
        }
    blood_type:=determined_type;
    rhesus:=rhesus_in;
    }

    method store(curr_time:int)
    modifies this
    requires Valid()
    ensures Valid()
    requires state==1;
    ensures if safe(curr_time) then state ==2 else state==-1;
    {
        if safe(curr_time) {
            state:=2;
        } else {
            state:=-1;
        }  
    }

    method dispatch(curr_time:int)
    modifies this
    requires state==2;
    requires Valid()
    ensures Valid()
    ensures if safe(curr_time) then state ==3 else state==-1;
    {
        if safe(curr_time) {
            state:=3;
        } else {
            state:=-1;
        }         
    }

    method delivered(curr_time:int)
    modifies this
    requires Valid()
    ensures Valid()
    requires state==3;
    ensures if safe(curr_time) then state ==4 else state==-1;
    {
        if safe(curr_time) {
            state:=4;
        } else {
            state:=-1;
        }           
    }

    method reject()
    modifies this
    ensures Valid()
    ensures state ==-1;
    {state:=-1;}
}