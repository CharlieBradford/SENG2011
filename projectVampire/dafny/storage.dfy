#include blood.dfy
#include transportationManager.dfy
#include insertionSort.dfy

class storage {

    // Index for bloodStorage
    // AP_blood = 0
    // AN_blood = 1
    // BP_blood = 2
    // BN_blood = 3
    // ABP_blood = 4
    // ABN_blood = 5
    // OP_blood = 6
    // ON_blood = 7

    // Attributes
    var name: string;
    var location: string;
    var bloodStorage: array<array<blood>>;
    var transManager: transportationManager;

    // Constructor
    constructor (n: string, l: string) {
        name := n;
        location := l;
        bloodStorage := new array[8];
        i := 0;
        while (i < bloodStorage.length) {
            bloodStorage[i] := new blood[100];
            i := i + 1;
        }
        transManager := null;
    }

    // Adds a transportation manager
    method addTransportationManager(manager: transportationManager) {
        transManager := manager;
    }

    // Stores blood and sorts according to expiry
    method storeBlood(b: blood) {
        index := findIndex(blood.blood_type, blood.rhesus);
        var prevSize := bloodStorage[index].length;
        var newArray := new array[newSize+1];
        var i := 0;
        while (i < prevSize) {
            newArray[i] := bloodStorage[index][i];
            i := i + 1;
        }
        newArray[prevSize] := blood;
        bloodStorage[index] := newArray;
        insertionSort(bloodStorage[index]);
    }

    // Discard expired blood
    method discardBlood(currTime: int) {
        i := 0;
        while (i < bloodStorage.length) {
            numToDiscard := 0;
            j := 0;
            while (j < bloodStorage[i].length) {
                if (currTime - bloodStorage[i][j].expiry_time < 60*60*24*2) {
                    numToDiscard := numToDiscard + 1;
                }
                j := j + 1;
            }
            removeN(i, numToDiscard);
            i := i + 1;
        }
    }

    // Gets appropriate blood packet from storage and notifies transport to send it to destination
    method serviceRequest(t: blood_type, rh: bool, dest: string) {
        index := findIndex(t, rh);
        blood := pop(index);
        notifyTransport(blood, dest);
    }

    // Gives blood to transport so that they can prepare to dispatch it to the destination
    method notifyTransport(b: blood, dest: string) {
        transManager.receive(b, dest);
    }

    // Helper: Remove head of array and return it
    method pop(index: int) returns (b: blood) {
        a := bloodStorage[index];
        b := a[0];
        newArray := new array[a.length-1];
        i := 0;
        while (i + 1 < a.length) {
            newArray[i] := a[i + 1];
        }
        bloodStorage[index] := newArray;
    }

    // Helper: Remove n elements from head of array
    method removeN(index: int, numToDiscard: int) {
        a := bloodStorage[index];
        newArray := new array[a.length-numToDiscard];
        i := 0;
        while (i + numToDiscard < a.length) {
            newArray[i] := a[i + numToDiscard];
        }
        bloodStorage[index] := newArray;
    }

    // Helper: Returns the index that is storing the required blood type
    method findIndex(t: blood_type, rh: bool) returns (index: int) {
        if (t == A & rh) {
            index := 0;
        }
        else if (t == A & !rh) {
            index := 1;
        }
        else if (t == B & rh) {
            index := 2;
        }
        else if (t == B & !rh) {
            index := 3;
        }
        else if (t == AB & rh) {
            index := 4;
        }
        else if (t == AB & !rh) {
            index := 5;
        }
        else if (t == O & rh) {
            index := 6;
        }
        else if (t == O & !rh) {
            index := 7;
        }
    }



}