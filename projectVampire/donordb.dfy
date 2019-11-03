#include blood.dfy

class donor
{
    var last_donation: int // Day of last donation as integer since system instantiation

    constructor ()
    modifies this
    ensures last_donation==-7
    {last_donation:=-7;}


    predicate donation_allowed(day:int)
    reads this
    {day - last_donation >= 7}

    method collectBlood(day:int,hour:int,minute:int) returns (blood:Blood)
    modifies this
    requires donation_allowed(day)
    requires 0<=day && 0<=hour<=23 && 0<=minute<=59
    ensures last_donation == day
    {
        last_donation:=day;
        var blud := new Blood(day,hour,minute);
        return blud;
    }
}



// Date in Dafny?
method get_hour() returns (hour:int)
ensures 0<=hour<=23
{
    return 14;
}


method get_day() returns (day:int)
ensures 0<=day
{
    return 10;
}

method get_minute() returns (minute:int)
ensures 0<=minute<=59
{
    return 36;
}

method Test()
{
    var doner := new Donor();

    var blud_1 := doner.collectBlood(1,1,1);
    assert !doner.donation_allowed(2);
    assert doner.donation_allowed(17);
    // doner.collectBlood(2,2,2);
}