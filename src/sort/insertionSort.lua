-- algoritmo de ordenacao insertionsort em lua
-- com impletacoes para 1 e 2 arrays
-- ordena em ordem DECRESCENTE

function insertionSort(A)
	for i = 2, table.getn(A) do
		local valor = A[i]
		local j = i - 1
		
		while j >= 1 and A[j] < valor do
			A[j+1] = A[j]
			j = j - 1
		end
		
		A[j+1] = valor
	end
end

function insertionSortTwoArrays(A, B)
-- ordena dois vetores, priorizando os valores em A para comparacao

	for i = 2, table.getn(A) do
		local valorA = A[i]
		local valorB = B[i]
		local j = i - 1
		
		while j >= 1 and A[j] < valorA do
			A[j+1] = A[j]
			B[j+1] = B[j]
			j = j - 1
		end
		
		A[j+1] = valorA
		B[j+1] = valorB
	end
end