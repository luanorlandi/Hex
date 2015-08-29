--[[
- essa classe cria um grid do MOAI para realizar
o pathfinding

- nela o tabuleiro esta girado 90 graus

- ha uma borda que possui elementos preenchidos dos 
jogadores para facilitar o pathfinding

- a cada turno o grid deve ser atualizado tambem

- cada jogador tem seu grid, pois o caminho somente
depende se o valor eh nulo ou nao
]]

HexGrid = {}
HexGrid.__index = HexGrid

function HexGrid:new(size, direction)
	-- direction eh os lados que devem seguir o caminho
	local H = {}
	setmetatable(H, HexGrid)
	
	-- inclui a borda de cada lado
	H.size = Vector:new(size.x + 2, size.y + 2)
	H.width = math.ceil(H.size.y / 2)
	H.height = H.size.x * 2 + (H.size.y / 2 - 1) * 2
	
	H.direction = direction
	
	H.grid = MOAIGrid.new()
	
	H:reset()
	
	return H
end

function HexGrid:reset()
	self.grid = MOAIGrid.new()
	self.grid:initHexGrid(self.width, self.height)
	
	--[[for i = 1, self.size.x, 1 do	
		for j = 1, self.size.y, 1 do
			self:setElementNoEdge(i, j, 0)
		end
	end]]
	
	if self.direction == victoryPath["horizontal"] then
		-- borda da esquerda e direita
		for i = 1, self.size.y, 1 do
			self:setElementNoEdge(i, 1)
			self:setElementNoEdge(i, self.size.y)
		end
	else
		-- borda de cima e baixo
		for i = 1, self.size.y, 1 do
			self:setElementNoEdge(1, i)
			self:setElementNoEdge(self.size.x, i)
		end
	end
end

function HexGrid:matrixToGrid(row, column)
-- coverte as coordenadas da matriz para grid

	-- inclui a borda
	row = row + 1
	column = column + 1
	
	local gridRow = row + 2 * (column - 1)
	local gridColumn = math.floor((row + 1) / 2)
	
	return gridColumn, gridRow
end

function HexGrid:gridToMatrix(column, row)
-- converte as coordenadas de grid para matriz
	local matrixRow = 2 * column - (row % 2)
	local matrixColumn = math.ceil(row / 2) - column + 1
	
	-- inclui a borda
	matrixRow = matrixRow + 1
	matrixColumn = matrixColumn + 1
	
	return matrixRow, matrixColumn
end

function HexGrid:setElement(row, column)
-- atribui um elemento recebendo coordenada de matriz
	column, row = self:matrixToGrid(row, column)
	
	self.grid:setTile(column, row, 1)
end

function HexGrid:getElement(row, column)
-- pega o valor de um elemento recebido com coordenada de matriz
	column, row = self:matrixToGrid(row, column)
	
	return self.grid:getTile(column, row)
end

function HexGrid:resetElement(row, column)
-- atribui um elemento com 0 recebendo coordenada de matriz
	column, row = self:matrixToGrid(row, column)
	
	self.grid:setTile(column, row, 0)
end

-- sem borda ----------------------------------------
function HexGrid:matrixToGridNoEdge(row, column)
-- coverte as coordenadas da matriz para grid
	local gridRow = row + 2 * (column - 1)
	local gridColumn = math.floor((row + 1) / 2)
	
	return gridColumn, gridRow
end

function HexGrid:gridToMatrixNoEdge(column, row)
-- converte as coordenadas de grid para matriz
	local matrixRow = 2 * column - (row % 2)
	local matrixColumn = math.ceil(row / 2) - column + 1
	
	return matrixRow, matrixColumn
end

function HexGrid:setElementNoEdge(row, column)
-- atribui um elemento recebendo coordenada de matriz
	column, row = self:matrixToGridNoEdge(row, column)
	
	self.grid:setTile(column, row, 1)
end

function HexGrid:getElementNoEdge(row, column)
-- pega o valor de um elemento recebido com coordenada de matriz
	column, row = self:matrixToGridNoEdge(row, column)
	
	return self.grid:getTile(column, row)
end

-----------------------------------------------------

function HexGrid:printGrid()
-- usado para debug
	for i = 1, self.size.x, 1 do
		for j = 1, self.size.y, 1 do
			io.write(self:getElementNoEdge(i, j) .. " ")
		end
		
		io.write("\n")
		
		for k = 1, i, 1 do
			io.write("  ")
		end
	end
	
	io.write("\n")
end

function HexGrid:findPath()
	-- tenta encontrar um caminho, se houver retorna true
	local startNode = self.grid:getCellAddr(self:matrixToGridNoEdge(1, 1))
	local endNode = self.grid:getCellAddr(self:matrixToGridNoEdge(self.size.x, self.size.y))

	local pathFinder = MOAIPathFinder.new()
	pathFinder:setGraph(self.grid)
	pathFinder:setHeuristic(MOAIGridPathGraph.EUCLIDEAN_DISTANCE)
	pathFinder:init(startNode, endNode)

	pathFinder:findPath()

	pathSize = pathFinder:getPathSize()
	
	--[[
	for i = 1, pathSize do
		local entry = pathFinder:getPathEntry(i)
		local row, column = self.grid:cellAddrToCoord(entry)
		self.grid:setTile (row, column, 3)
	end
	
	local tempX, tempY = self:matrixToGridNoEdge(self.size.x, self.size.y)
	self.grid:setTile(1, 1, 3)
	self.grid:setTile(tempX, tempY, 3)
	]]
	
	if pathSize == 0 then
		return false
	else
		return true
	end
end

function HexGrid:copyGrid()
-- retorna uma copia do grid atual
	local grid = MOAIGrid.new()
	grid = MOAIGrid.new()
	grid:initHexGrid(self.width, self.height)
	
	for i = 1, self.width, 1 do
		for j = 1, self.height, 1 do
			local value = self.grid:getTile(i, j)
			
			grid:setTile(i, j, value)
		end
	end
	
	return grid
end