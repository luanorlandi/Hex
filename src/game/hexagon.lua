Hexagon = {}
Hexagon.__index = Hexagon

function Hexagon:new(pos, row, column)
	local H = {}
	setmetatable(H, Hexagon)
	
	-- esses 2 atributos auxiliam no input
	H.name = "hexagon"
	H.selected = false
	
	H.sprite = MOAIProp2D.new()
	changePriority(H.sprite, "hexagon")
	H.sprite:setDeck(window.deckManager.hexagon)
	
	H.defaultColor = Color:new(1, 1, 1)
	H.color = Color:new(1, 1, 1)
	H.hold = 0						-- inidica a qual jogador pertence (1 ou 2, ou 0 se de ninguem)
	
	H.visited = false				-- auxliar da IA
	
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
-- define a quem pertence o hexagono
	self:changeColor(color)
	self.hold = playerPath
	self.available = false
end

function Hexagon:setTemporaryHex(playerPath)
-- defini temporariamente, sem cor, a quem pertence o hexagono
	self.hold = playerPath
	self.available = false
end

function Hexagon:resetHex()
-- reseta o hexagono, definindo que pertence a ninguem
	self:changeColor(self.defaultColor)
	self.hold = 0
	self.available = true
end

function Hexagon:changeColor(color)
	self.sprite:setColor(color:getColor())
	self.color = color
end

function Hexagon:move(pos)
	-- move o hexagono para a posicao "pos"
	
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