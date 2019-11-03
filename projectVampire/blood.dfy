// state:
// unverified = 0
// verified = 1
// storage = 2
// dispatch = 3
// delivered = 4
// unsafe = 5
datatype Blood_types = A | B | AB

class Blood{
    var state: int;
    var hour: int;
    var minute:int;
    var day:int;
    var blood_type: Blood_types;

    predicate Valid()
    reads this
    {0<=state<=5}

    constructor (dayin:int,hourin:int,minutein:int)
    modifies this
    requires 0<=dayin && 0<=hourin<=23 && 0<=minutein<=59
    ensures 0<=day && 0<=hour<=23 && 0<=minute<=59
    ensures Valid();
    ensures state == 0;
    {
        hour:=hourin;
        day:=dayin;
        minute:=minutein;
        state := 0;
    }

    method verify(determined_type:Blood_types)
    modifies this
    requires Valid();
    requires state==0;
    ensures Valid();
    ensures state ==1;
    ensures blood_type==determined_type
    {state:=1; blood_type:=determined_type;}

    method store()
    modifies this
    requires Valid();
    requires state==1;
    ensures Valid();
    ensures state ==2;
    {state:=2;}

    method dispatch()
    modifies this
    requires Valid();
    requires state==2;
    ensures Valid();
    ensures state ==3;
    {state:=3;}

    method delivered()
    modifies this
    requires Valid();
    requires state==3;
    ensures Valid();
    ensures state ==4;
    {state:=4;}

    method reject()
    modifies this
    ensures Valid();
    ensures state ==5;
    {state:=5;}
}