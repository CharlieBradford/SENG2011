
toSort = [10,9,7,23,3,4,1]
#print(toSort)
#j = 1
#while j < (len(toSort)):
#    key = toSort[j]
#    i = j - 1
#    while i >= 0 and toSort[i] > key:
#        toSort[i+1] = toSort[i]
#        i = i - 1
#    toSort[i+1] = key
#    j += 1
#print(toSort)

print(toSort)
start = 1
while (start < len(toSort)):
    end = start
    while (end >= 1 and toSort[end-1] > toSort[end]):
        temp = toSort[end-1]
        toSort[end-1] = toSort[end]
        toSort[end] = temp
        end = end - 1
    start = start + 1

print(toSort)
