import sys
from donordb import donor
from time_sec import time_sec

donor_db = {}


while True:
    command = input(">")
    splitlist = command.split()
    if len(splitlist)==3 and splitlist[0]=='clinic' and splitlist[1]=='donate':
        
        donor_id = int(splitlist[2])

        if donor_id not in donor_db:
            donor_db[donor_id] = donor(donor_id)

        doner = donor_db[donor_id]
        if doner.donation_allowed(time_sec.get_now()):
            blud = doner.collect_blood(time_sec.get_now())
            print("Blood collected")
        else:
            print("Cannot collect blood. Too close to previous collection")
            print(int(doner.time_remaining(time_sec.get_now())),"seconds until you can donate again")

        



