-- algoritmo de ordenacao quicksort em lua
-- com impletacoes para 1 e 2 arrays
-- ordena em ordem DECRESCENTE

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
-- ordena dois vetores ao mesmo tempo, priorizando
-- o primeiro para a comparacao. Assume que tem o
-- mesmo tamanho

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