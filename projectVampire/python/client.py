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



