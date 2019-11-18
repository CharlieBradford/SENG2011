import sys
from donor import donor
from time_sec import time_sec
from system import system

donor_db = {}
system = system()
system.initSys()

print("Welcome to the Project Vampire system")
print("Enter \"help\" for assistance on the available commands")

while True:
    command = input(">")
    splitlist = command.split()
    # Usage: clinic collect "donor_name"
    # Function: collects blood from donor at clinic
    if len(splitlist)==3 and splitlist[0]=='clinic' and splitlist[1]=='collect':
        system.clinic_donation(splitlist[2])

    # Usage: hospital collect "donor_name"
    # Function: collects blood from donor at hospital
    elif len(splitlist)==3 and splitlist[0]=='hospital' and splitlist[1]=='collect':
        system.hospital_donation(splitlist[2])

    # Usage: clinic send
    # Function: dispatches all blood collected at clinic -> pathology -> storage
    elif len(splitlist)==2 and splitlist[0]=='clinic' and splitlist[1]=='send':
        system.ClinicRoute(system.getClinic()) # need to make dynamic

    # Usage: hospital send
    # Function: dispatches all blood collected at hospital -> pathology -> storage
    elif len(splitlist)==2 and splitlist[0]=='hospital' and splitlist[1]=='send':
        system.HospitalRoute(system.getHospital()) # need to make dynamic

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

    elif len(splitlist) == 1 and splitlist[0] == 'help':
        print("")
        print("Commands:")
        print("")
        print("clinic collect [donor_name]                     - Collect blood from [donor_name] at a clinic")
        print("clinic send                                     - Dispatches all blood from clinic to pathology for verification, then to storage")

        print("hospital collect [donor_name]                   - Collect blood from [donor_name] at a hospital (has its own pathology)")
        print("hospital send                                   - Dispatches all blood from hospital to storage")

        print("request [recipient] [blood_type] [blood_rhesus] - Make a request for a certain type of blood and have it delivered if available")

        print("")

    else:
        print("Command not recognised")
        print("Enter \"help\" for assistance on the available commands")

