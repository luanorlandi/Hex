require "math/vector"

Circle = {}
Circle.__index = Circle

function Circle:new(c, r)
	-- create a circle with center in position "c", and radius size "r"
	local C = {}
	setmetatable(C, Circle)
	
	C.center = Vector:new(c.x, c.y)
	
	C.radius = r
	
	return C
end

function Circle:equal(b)
	self.center:equal(b.center)
	self.radius = b.radius
end

function Circle:pointInside(p)
	-- check if there is a point "p" inside the circle
	
	-- calculate the distance from the center to point "p"
	local distanceX = math.abs(self.center.x - p.x)
	local distanceY = math.abs(self.center.y - p.y)
	
	local distance = math.sqrt(distanceX * distanceX + distanceY * distanceY)
	
	return distance < self.radius
end