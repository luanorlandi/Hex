Hexagon = {}
Hexagon.__index = Hexagon

function Hexagon:new(pos, row, column)
	local H = {}
	setmetatable(H, Hexagon)
	
	-- these 2 attributes aid the input
	H.name = "hexagon"
	H.selected = false
	
	H.sprite = MOAIProp2D.new()
	changePriority(H.sprite, "hexagon")
	H.sprite:setDeck(window.deckManager.hexagon)
	
	H.defaultColor = Color:new(1, 1, 1)
	H.color = Color:new(1, 1, 1)
	H.hold = 0					-- indicate which player player own the hexagon (1 or 2, or 0 if is free)
	
	H.visited = false			-- aid the AI
	
	H.pos = Vector:new(pos.x, pos.y)
	H.row = row
	H.column = column
	
	H.available = true
	
	H.sprite:setLoc(pos.x, pos.y)
	window.layer:insertProp(H.sprite)
	
	return H
end

function Hexagon:clear()
	window.layer:removeProp(self.sprite)
end

function Hexagon:setHex(color, playerPath)
	-- define who own the hexagon
	self:changeColor(color)
	self.hold = playerPath
	self.available = false
end

function Hexagon:setTemporaryHex(playerPath)
	-- define who own the hexagon, without color
	self.hold = playerPath
	self.available = false
end

function Hexagon:resetHex()
	-- reset the hexagon, define that it doesn't belong to anyone
	self:changeColor(self.defaultColor)
	self.hold = 0
	self.available = true
end

function Hexagon:changeColor(color)
	self.sprite:setColor(color:getColor())
	self.color = color
end

function Hexagon:move(pos)
	-- move the hexagon to position "pos"
	
	self.pos = Vector:new(pos.x, pos.y)
	self.sprite:setLoc(pos.x, pos.y)
end

function Hexagon:showSelect()
	if not self.select then
		self.select = true
		
		local red, green, blue, alpha = self.color:getColor()
		
		self.sprite:seekColor(0.6 * red, 0.6 * green, 0.6 * blue, alpha, 0)
	end
end

function Hexagon:showDeselect()
	if self.select then
		self.select = false
		
		local red, green, blue, alpha = self.color:getColor()
		
		self.sprite:seekColor(red, green, blue, 1, 0)
	end
end