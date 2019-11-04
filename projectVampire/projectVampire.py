#!/bin/bash/python3

from time import time

from . import *

from time import time

PLANET_CIRCUMFRENCE = 2 * 3.14 * 6.317E3

class system:
    hospitals = {}
    storages = {}
    pathologies = {}
    clinics = {}
    donors = {}

    def __init__(self):
        pass

    def isDonorOkay(self, donor):
        if donor in donors:
            if donors[donor] <= time() - 7 * 24 * 60 * 60: 
                donors[donor] = time()
                return True
            else:
                return False
        else:
            donors[donor] = time()
            return True

    def routeBlood(self, source, dest, blood):
        if dest == 'Pathology':
            destPathology = ''
            pathologyDist = 0
            for pathology in pathologies:
                if destPathology == '' or pathologyDist > pathologies[pathology].getDist(source):
                    destPathology = pathology
                    pathologyDist = pathologies[destPathology].getDist(source)
            return pathology
        elif dest == 'Storage':
            destStorage = ''
            storageSuit = 0
            for storage in storages:
                if destStorage == '':
                    destStorage = storage
                    storageSuit = storages[storage].getDist(source) / PLANET_CIRCUMFRENCE + storages[storage].needFactor(blood)
                else:
                    thisStorageSuit = storages[storage].getDist(source) / PLANET_CIRCUMFRENCE + storages[storage].needFactor(blood)
                    if thisStorageSuit > storageSuit:
                        destStorage = storage
                        storageSuit = thisStorageSuit
                    
            
    def serviceRequest(self):
        pass
        
    def run(self):
        i = input()
        while true:
            i = i.lower()
            comm, *args = i.split()
            if com == "q":
                break
            elif com == "hospital":
                pass
            elif com == "clinic":
                pass

