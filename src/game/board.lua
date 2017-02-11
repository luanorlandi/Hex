require "game/hexagon"
require "game/lane"
require "pathfinding/hexGrid"

Board = {}
Board.__index = Board

function Board:new(size)
	-- "size" board size (default 11 x 11)
	
	local B = {}
	setmetatable(B, Board)
	
	B.size = size
	
	-- hexagons size, depends on the size of the board and resolution
	B.hexagonSize = nil
	B:calculateHexagonSize()
	
	B.start = Vector:new((-(B.size.x - 1) * 1.5) * (1 / 2 * B.hexagonSize.x),
						  ((B.size.y - 1) * 1.5) * (1 / 4 * B.hexagonSize.y))
	--[[
	B.start = Vector:new((-(B.size.x - 1) * 1.5) * (1 / 2 * B.hexagonSize.x) - 1.00 * B.hexagonSize.x,
						  ((B.size.y - 1) * 1.5) * (1 / 4 * B.hexagonSize.y) + 0.75 * B.hexagonSize.y)
	]]
	local pos = Vector:new(B.start.x, B.start.y)
	
	-- create a new board as if was a matrix, also use this loop to move the hexagons
	B.hexagon = {}
	for i = 1, size.y, 1 do
		B.hexagon[i] = {}
		
		pos.y = pos.y - 0.75 * B.hexagonSize.y
		
		for j = 1, size.x, 1 do
			pos.x = pos.x + B.hexagonSize.x
			
			B.hexagon[i][j] = Hexagon:new(pos, i, j)
		end
		
		pos.x = B.hexagonSize.x * (0.5) * i + B.start.x
	end
	
	B.background = Background:new(window.deckManager.boardBackground)
	
	-- create a grid for each player
	B.hexGrid = {}
	B.hexGrid[1] = HexGrid:new(B.size, victoryPath["horizontal"])
	
	B.hexGrid[2] = HexGrid:new(B.size, victoryPath["vertical"])
	
	-- lane to indicate the path direction
	B.lane = {}
	B.lane[1] = Lane:new(victoryPath["horizontal"])
	B.lane[2] = Lane:new(victoryPath["vertical"])
	
	-- while true the coroutine continues
	-- when set false the game ends
	B.active = true
	
	-- indicate if the game is over, but it's this possible to click/tap
	-- on the screen and do button actions
	B.gameOver = false
	
	return B
end

function Board:clear()
	self.background:clear()
	
	for i = 1, self.size.x, 1 do
		for j = 1, self.size.y, 1 do
			self.hexagon[i][j]:clear()
		end
	end
	
	self.lane[1]:clear()
	self.lane[2]:clear()
end

function Board:calculateHexagonSize()
	self.hexagonSize = Vector:new(math.abs((770 / self.size.x) * window.scale), math.abs((770 / self.size.x) * window.scale))
end

function Board:moveHexagons()
	self:calculateHexagonSize()
	
	self.start = Vector:new((-(self.size.x - 1) * 1.5) * (1 / 2 * self.hexagonSize.x) - 1.00 * self.hexagonSize.x,
							 ((self.size.y - 1) * 1.5) * (1 / 4 * self.hexagonSize.y) + 0.75 * self.hexagonSize.y)
							
	local pos = Vector:new(self.start.x, self.start.y)
	
	for i = 1, self.size.y, 1 do
		pos.y = pos.y - 0.75 * self.hexagonSize.y
		
		for j = 1, self.size.x, 1 do
			pos.x = pos.x + self.hexagonSize.x
			
			self.hexagon[i][j]:move(pos)
		end
		
		pos.x = self.hexagonSize.x * (0.5) * i + self.start.x
	end
end

function Board:getHexagon(pos)
	-- search for a hexagon in position "hex"
	-- return it or nill if wasn't found
	local hex = nil
	
	local hexPos = Vector:new(0, 0)
	local cameraPos = window.camera:getPosition()
	
	-- check if it's board amplified, calculating the position in a different way
	-- double (in case of x2 zoom,, which would be: window.camera.zoom = 0.5) hexagons size
	if window.camera.zoomStatus == "out" then
		hexPos.y = pos.y - window.resolution.y/2 + self.start.y + self.hexagonSize.y/2
		hexPos.y = hexPos.y / (0.75 * self.hexagonSize.y)
	else
		hexPos.y = pos.y - window.resolution.y/2 + (self.start.y + self.hexagonSize.y/2 - cameraPos.y) / window.camera.zoom
		hexPos.y = hexPos.y / (0.75 * self.hexagonSize.y / window.camera.zoom)
	end
	
	local row = math.floor(hexPos.y)
	
	if window.camera.zoomStatus == "out" then
		hexPos.x = pos.x - window.resolution.x/2 - self.start.x + self.hexagonSize.x/2 - ((row - 1) * self.hexagonSize.x/2)
		hexPos.x = hexPos.x / self.hexagonSize.x
	else
		hexPos.x = pos.x - window.resolution.x/2 + (-self.start.x + self.hexagonSize.x/2 - ((row - 1) * self.hexagonSize.x/2) + cameraPos.x) / window.camera.zoom
		hexPos.x = hexPos.x / (self.hexagonSize.x / window.camera.zoom)
	end
	
	local column = math.floor(hexPos.x)
	
	hexPos.y = hexPos.y % 1
	
	if hexPos.y < 1/3 then
		-- y - y0 = m(x - x0)
		local y0 = 1/3
		local x0
		local side			-- aid the angle calculus
		
		hexPos.x = hexPos.x % 1
		
		if hexPos.x > 0.5 then
			-- right side
			hexPos.x = hexPos.x % 0.5
			side = -1
			x0 = 0
		else
			-- left side
			side = 1
			x0 = 0.5
		end
		
		local m = side * ((1/3) / 0.5)
		
		hexPos.y = 1/3 - hexPos.y
		
		-- y >= y0 + m(x - x0)
		if hexPos.y >= y0 + (m * (hexPos.x - x0)) then
			row = row - 1
			
			if side == -1 then
				column = column + 1
			end
		end
	end
	
	if row > 0 and column > 0 then
		if row <= self.size.x and column <= self.size.y then
			hex = self.hexagon[row][column]
		end
	end
	
	return hex
end

-- methods that get the adjacent hexagon in the board
-- aid the analyse of the AI
function Board:getUpperLeftHexagon(hex)
	local adjacentHex
	
	if hex.row - 1 >= 1 then
		adjacentHex = self.hexagon[hex.row - 1][hex.column]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end

function Board:getUpperRightHexagon(hex)
	local adjacentHex
	
	if hex.row - 1 >= 1 and hex.column + 1 <= self.size.x then
		adjacentHex = self.hexagon[hex.row - 1][hex.column + 1]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end

function Board:getRightHexagon(hex)
	local adjacentHex
	
	if hex.column + 1 <= self.size.x then
		adjacentHex = self.hexagon[hex.row][hex.column + 1]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end

function Board:getBottomRightHexagon(hex)
	local adjacentHex
	
	if hex.row + 1 <= self.size.y then
		adjacentHex = self.hexagon[hex.row + 1][hex.column]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end

function Board:getBottomLeftHexagon(hex)
	local adjacentHex
	
	if hex.row + 1 <= self.size.y and hex.column - 1 >= 1 then
		adjacentHex = self.hexagon[hex.row + 1][hex.column - 1]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end

function Board:getLeftHexagon(hex)
	local adjacentHex
	
	if hex.column - 1 >= 1 then
		adjacentHex = self.hexagon[hex.row][hex.column - 1]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end

-- methods that get the FAR adjacent hexagon in the board
-- aid the analyse of the AI
function Board:getFarUpperLeftHexagon(hex)
	local adjacentHex
	
	if hex.row - 1 >= 1 and hex.column - 1 >= 1 then
		adjacentHex = self.hexagon[hex.row - 1][hex.column - 1]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end

function Board:getFarUpperHexagon(hex)
	local adjacentHex
	
	if hex.row - 2 >= 1 and hex.column + 1 <= self.size.x then
		adjacentHex = self.hexagon[hex.row - 2][hex.column + 1]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end

function Board:getFarUpperRightHexagon(hex)
	local adjacentHex
	
	if hex.row - 1 >= 1 and hex.column + 2 <= self.size.x then
		adjacentHex = self.hexagon[hex.row - 1][hex.column + 2]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end

function Board:getFarBottomRightHexagon(hex)
	local adjacentHex
	
	if hex.row + 1 <= self.size.y and hex.column + 1 <= self.size.x then
		adjacentHex = self.hexagon[hex.row + 1][hex.column + 1]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end

function Board:getFarBottomHexagon(hex)
	local adjacentHex
	
	if hex.row + 2 <= self.size.y and hex.column - 1 >= 1 then
		adjacentHex = self.hexagon[hex.row + 2][hex.column - 1]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end

function Board:getFarBottomLeftHexagon(hex)
	local adjacentHex
	
	if hex.row + 1 <= self.size.y and hex.column - 2 >= 1 then
		adjacentHex = self.hexagon[hex.row + 1][hex.column - 2]
	else
		adjacentHex = nil
	end
	
	return adjacentHex
end