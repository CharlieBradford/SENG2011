from blood import blood

def noNulls(arr):
	for i in range((len(arr))):
		if arr[i] == None:
			return False
	return True

def sameValues(nums, bloodArr):
	for i in range(len(nums)):
		if nums[i] != bloodArr[i].getExpiryTime():
			return False
	return True

def isSorted(arr, start, end):
	assert arr != None
	assert 0 <= start < len(arr)
	assert end <= len(arr)
	i = start
	while (i < end):
		j = i + 1
		while (j < end):
			if arr[i] > arr[j]:
				return False
			j -= -1
		i -= -1
	return True

def rangeSorted(arr, start, end):
	assert arr != None
	assert 0 <= start < len(arr)
	assert end <= len(arr)
	i = start
	while (i < end):
		j = i
		while (j < end):
			if arr[i] > arr[j]:
				return False
			j -= -1
		i -= -1
	return True	

def insertionSort(toSort, toMatch):
	OLD_toMatch = toMatch
	OLD_toSort = toSort
	assert toSort != None
	assert toMatch != None
	assert len(toSort) == len(toMatch)
	assert noNulls(toMatch) and sameValues(toSort, toMatch)


	start = 1
	while (start < len(toSort)):
		assert 1 <= start <= len(toSort)
		assert isSorted(toSort, 0, start)
		assert toSort == OLD_toSort
		assert toMatch == OLD_toMatch
		assert noNulls(toMatch) and sameValues(toSort, toMatch)

		end = start
		while (end >= 1 and toSort[end-1] > toSort[end]):
			assert 0 <= end <= start
			assert toSort == OLD_toSort
			assert toMatch == OLD_toMatch
			#assert isSorted(toSort, 0, start)
			assert rangeSorted(toSort, start, end)
			assert noNulls(toMatch) and sameValues(toSort, toMatch)

			temp = toSort[end-1]
			toSort[end-1] = toSort[end]
			toSort[end] = temp

			temp2 = toMatch[end-1]
			toMatch[end-1] = toMatch[end]
			toMatch[end] = temp2
			end = end -1
		start = start + 1

	assert isSorted(toSort, 0, len(toSort))
	assert toSort == OLD_toSort
	assert toMatch == OLD_toMatch
	assert noNulls(toMatch) and sameValues(toSort, toMatch)



# Testing
b1 = blood(1)
b2 = blood(2)
b3 = blood(3)
blood = [b1,b2,b3]
nums = [b1.getExpiryTime(),b2.getExpiryTime(),b3.getExpiryTime()]
insertionSort(nums, blood)
print(nums)
