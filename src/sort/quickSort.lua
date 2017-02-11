-- sorting algorithm in Lua
-- implemented for 1 and 2 arrays
-- sorted in descending order

function quickSort(A, start, ending)
	if start < ending then
		local pivot = math.floor((start + ending) / 2)
		local pos = partition(A, start, ending, pivot)
		
		quickSort(A, start, pos - 1)
		quickSort(A, pos + 1, ending)
	end
end

function partition(A, start, ending, pivot)
	local pos = start
	swap(A, pivot, ending)
	
	for i = start, ending do
		if A[i] > A[ending] then
			swap(A, i, pos)
			pos = pos + 1
		end
	end
	
	swap(A, ending, pos)
	
	return pos
end

function quickSortTwoArrays(A, B, start, ending)
-- sort 2 arrays at the same time, prio
-- ordena dois vetores ao mesmo tempo, prioritizing
-- the first one to compare
-- assume that they both have the same size

	if start < ending then
		local pivot = math.floor((start + ending) / 2)
		local pos = partitionTwoArrays(A, B, start, ending, pivot)
		
		quickSortTwoArrays(A, B, start, pos - 1)
		quickSortTwoArrays(A, B, pos + 1, ending)
	end
end

function partitionTwoArrays(A, B, start, ending, pivot)
	local pos = start
	swap(A, pivot, ending)
	swap(B, pivot, ending)
	
	for i = start, ending do
		if A[i] > A[ending] then
			swap(A, i, pos)
			swap(B, i, pos)
			pos = pos + 1
		end
	end
	
	swap(A, ending, pos)
	swap(B, ending, pos)
	
	return pos
end