function getMin(A, B)
	if A < B then
		return A
	else
		return B
	end
end

function getMax(A, B)
	if A > B then
		return A
	else
		return B
	end
end

function swap(A, i, j)
	local tmp = A[i]
	A[i] = A[j]
	A[j] = tmp
end