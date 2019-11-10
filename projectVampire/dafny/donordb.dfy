#include blood.dfy

class donor
{
    var last_donation: int // last donation as integer second since Unix Epoch

    constructor ()
    modifies this
    ensures last_donation==0
    {last_donation:=0;}


    predicate donation_allowed(curr_time:int)
    reads this
    {(curr_time - last_donation)/86400 >= 7}

    method collect_Blood(curr_time:int) returns (blood:Blood)
    modifies this
    requires donation_allowed(curr_time)
    requires curr_time>=0
    ensures last_donation == curr_time
    {
        last_donation:=curr_time;
        var blud := new Blood(curr_time);
        return blud;
    }

    method time_remaining(curr_time:int) returns (time:int)
    // reads this
    {return ((last_donation+86400*7)-curr_time);}
}

method Test()
{
    var doner := new Donor();

    var blud_1 := doner.collect_Blood(1000000);
    assert !doner.donation_allowed(1000060);
    assert doner.donation_allowed(2000000);
    // doner.collectBlood(2,2,2);
}