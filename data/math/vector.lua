Vector = {}
Vector.__index = Vector

function Vector:new(a, b)
	local V = {}
	setmetatable(V, Vector)
	
	V.x = a
	V.y = b
	
	return V
end

function Vector:sum(b)
	self.x = self.x + b.x
	self.y = self.y + b.y
end

function Vector:equal(b)
	self.x = b.x
	self.y = b.y
end