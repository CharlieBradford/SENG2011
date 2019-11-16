import sys
from donor import donor
from time_sec import time_sec
from system import system

donor_db = {}
system = system()

while True:
    command = input(">")
    splitlist = command.split()
    if len(splitlist)==3 and splitlist[0]=='clinic' and splitlist[1]=='collect':
        system.clinic_donation(splitlist[2])
    elif len(splitlist)==3 and splitlist[0]=='hospital' and splitlist[1]=='collect':
        system.hospital_donation(splitlist[2])

    # Syntax: request <destination> <Bloodtype> <Rhesus>(+/-)
    elif len(splitlist)==4 and splitlist[0]=='request':
        if splitlist[3] == '+':
            rh = True
        elif splitlist[3] == '-':
            rh = False
        else:
            print("Invalid command")
            print("Syntax: request <destination> <Bloodtype>(O,A,B,AB) <Rhesus>(+/-)")
            continue
        
        if not (splitlist[2] == 'O' or splitlist[2] == 'A' or splitlist[2] == 'B' or splitlist[2] == 'AB'):
            print("Invalid command")
            print("Syntax: request <destination> <Bloodtype>(O,A,B,AB) <Rhesus>(+/-)")
            continue  
        system.RequestBlood(splitlist[1],splitlist[2],rh)



