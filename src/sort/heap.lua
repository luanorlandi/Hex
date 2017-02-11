Heap = {}
Heap.__index = Heap

-- used for priority queue
function Heap:new()
	local H = {}
	setmetatable(H, Heap)
	
	-- both has the same size
	-- for each key, there is a respective priority
	H.key = {}
	H.priority = {}
	
	return H
end

function Heap:isEmpty()
	if table.getn(self.key) > 0 then
		return false
	else
		return true
	end
end

function Heap:siftDown(i)
	local j = 2 * i					-- left child

	if j <= table.getn(self.key) then
        if j + 1 <= table.getn(self.key) then
            if self.priority[j+1] < self.priority[j] then
                j = j + 1;
			end
		end

        if self.priority[j] < self.priority[i] then
            swap(self.key, i, j);
            swap(self.priority, i, j);
			
            self:siftDown(j);
        end
	end
end

function Heap:siftUp(i)
	local j = math.floor(i / 2)		-- parent

	if j > 0 and self.priority[i] < self.priority[j] then
		swap(self.key, i, j)
		swap(self.priority, i, j)
		self:siftUp(j)
	end
end

function Heap:minHeapify()
	local i = math.ceil(table.getn(self.key) / 2)

	while i > 0 do
		self:siftDown(i)
		i = i - 1
	end
end

function Heap:insert(key, priority)
	table.insert(self.key, key)
	table.insert(self.priority, priority)
	
	self:siftUp(table.getn(self.key))
end

function Heap:extractMin()
	local key = self:getKey(1)
	local priority = self.priority[1]
	
	-- put the last position first
	-- avoid remove elements that may cause displacement on the array
	
	self.key[1] = self.key[table.getn(self.key)]
	self.priority[1] = self.priority[table.getn(self.priority)]
	
	table.remove(self.key, table.getn(self.key))
	table.remove(self.priority, table.getn(self.priority))
	
	self:siftDown(1)

	return key, priority
end

function Heap:getKey(i)
	-- return the key in a proper way for the game without the valor
	local key = Vector:new(self.key[i].x, self.key[i].y)
	
	return key
end

--[[ exemplo de uso:
local keys = {1, 2, 3, 4, 5, 6, 7}
local priority = {6, 7, 2, 9, 3, 0, 4}

local heap = Heap:new()

for i = 1, table.getn(keys) do
	heap:insert(keys[i], priority[i])
end

print(unpack(heap.key))
print(unpack(heap.priority))

local k, p = heap:extractMin()

print("removido:", k, p)

print(unpack(heap.key))
print(unpack(heap.priority))
]]