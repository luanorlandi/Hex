require "data/pathfinding/graph"

BoardPath = {}
BoardPath.__index = BoardPath

function BoardPath:new(pathDirection, owner)
	local B = {}
	setmetatable(B, BoardPath)
	
	B.pathDirection = pathDirection			-- caminho na vertical ou horizontal
	B.owner = owner							-- caminho do jogador que esta avaliando (a IA)
	
	-- contem os hexagonos que formam o caminho
	B.paths = {}
	
	-- contem um numero que indica a distancia ate o caminho completar
	B.distanceToWin = {}
	
	-- contem os hexagonos que terminam o respectivo caminho
	-- somente eh util se o caminho estiver quase completo,
	-- para a IA jogar onde ha as ligacoes do caminho
	B.pathLinks = {}
	
	B.graph = Graph:new(B.pathDirection)
	
	return B
end

function BoardPath:resetSearch()
	-- reseta o auxiliar de visitado
	for i = 1, board.size.y, 1 do
		for j = 1, board.size.x, 1 do
			board.hexagon[i][j].visited = false
		end
	end
	
	-- limpa os caminhos anteriores encontrados
	self.paths = {}
	
	--limpa as distancias calculadas
	self.distanceToWin = {}
	
	--limpa os hexagonos de ligacao para o caminho
	self.pathLinks = {}
end

function BoardPath:searchBestPath()
-- procura por todos os caminhos existentes para o jogador
-- retorna o melhor caminho e sua respectiva distancia
	self:resetSearch()
	
	for i = 1, board.size.y, 1 do
		for j = 1, board.size.x, 1 do
			local hex = board.hexagon[i][j]
			
			if not hex.visited and hex.hold == self.pathDirection then
				-- marca que o hexagono ja foi visitado
				hex.visited = true
				
				local path = {}
				local pathLink = {}
				
				table.insert(path, hex)
				
				-- inicia uma recursao a procura do caminho nesse hexagono
				self:getPathFromHexagon(path, pathLink, hex)
				
				-- calcula a distancia em hexagonos que faltam para completar o caminho
				local distance = self:calculateDistancePathComplete(path)
				table.insert(self.distanceToWin, distance)
				
				-- inclui o novo caminho encontrado e seus hexagonos de ligacoes com os demais caminhos
				table.insert(self.paths, path)
				table.insert(self.pathLinks, pathLink)
			end
		end
	end
	
	return self:getBestPath()
end

function BoardPath:calculateNewDistance(hexNew, hexSource)
-- "hexNew" eh o hexagono que sera analisado numa jogada simulada

-- a funcao simula a jogada na posicao dada como entrada
-- retornando a nova distancia e a quantidade de hexagono que fazem ligacoes no caminho
	hexNew:setTemporaryHex(self.pathDirection)
	self.graph:update()
	
	if self.owner == self.pathDirection then
		self.graph.move = true
	end
	
	local dist = self.graph:dijkstra(Vector:new(hexSource.column, hexSource.row))
	
	local path = {}
	local pathLink = {}
	
	table.insert(path, hexSource)
	
	for i = 1, board.size.y, 1 do
		for j = 1, board.size.x, 1 do
			board.hexagon[i][j].visited = false
		end
	end
	-- inicia uma recursao a procura do caminho nesse hexagono
	self:getPathFromHexagon(path, pathLink, hexSource)
	
	hexNew:resetHex()
	
	local distTopLeft = dist[1][1]
	local distBottomRight = dist[self.graph.V.x][self.graph.V.y]
	
	return path, distTopLeft + distBottomRight, pathLink
end

function BoardPath:getPathFromHexagon(path, pathLink, hex)
-- funcao recursiva que constroi um caminho formado a partir de um hexagono

	-- hexagonos adjacentes:
	local upperLeft =		board:getUpperLeftHexagon(hex)
	local upperRight =		board:getUpperRightHexagon(hex)
	local right =			board:getRightHexagon(hex)
	local bottomRight =		board:getBottomRightHexagon(hex)
	local bottomLeft =		board:getBottomLeftHexagon(hex)
	local left =			board:getLeftHexagon(hex)
	
	self:getAdjacencyPath(path, pathLink, upperLeft)
	self:getAdjacencyPath(path, pathLink, upperRight)
	self:getAdjacencyPath(path, pathLink, right)
	self:getAdjacencyPath(path, pathLink, bottomRight)
	self:getAdjacencyPath(path, pathLink, bottomLeft)
	self:getAdjacencyPath(path, pathLink, left)
	
	-- hexagonos adjacentes longes:
	local farUpperLeft =	board:getFarUpperLeftHexagon(hex)
	local farUpper =		board:getFarUpperHexagon(hex)
	local farUpperRight =	board:getFarUpperRightHexagon(hex)
	local farBottomRight =	board:getFarBottomRightHexagon(hex)
	local farBottom =		board:getFarBottomHexagon(hex)
	local farBottomLeft =	board:getFarBottomLeftHexagon(hex)
	
	self:getFarAdjacencyPath(path, pathLink, farUpperLeft, left, upperLeft)
	self:getFarAdjacencyPath(path, pathLink, farUpperRight, upperRight, right)
	self:getFarAdjacencyPath(path, pathLink, farBottomRight, right, bottomRight)
	self:getFarAdjacencyPath(path, pathLink, farBottomLeft, bottomLeft, left)
	self:getFarAdjacencyPath(path, pathLink, farUpper, upperLeft, upperRight)
	self:getFarAdjacencyPath(path, pathLink, farBottom, bottomRight, bottomLeft)
end

function BoardPath:getAdjacencyPath(path, pathLink, adjacentHex)
	if adjacentHex ~= nil and not adjacentHex.visited and adjacentHex.hold == self.pathDirection then
		-- marca que o hexagono ja foi visitado
		adjacentHex.visited = true
		
		table.insert(path, adjacentHex)
		
		-- continua recursivamente a procura de um hexagono proximo
		self:getPathFromHexagon(path, pathLink, adjacentHex)
	end
end

function BoardPath:getFarAdjacencyPath(path, pathLink, farHex, adjacentHex1, adjacentHex2)
-- verifica para o caso de um hexagono adjacente distante, em que o caminho
-- pode ser ligado no proximo turno independente da jogada do oponente

	if farHex ~= nil and not farHex.visited and farHex.hold == self.pathDirection then
		if adjacentHex1.available and adjacentHex2.available then
			farHex.visited = true
		
			table.insert(path, farHex)
			
			table.insert(pathLink, adjacentHex1)
			table.insert(pathLink, adjacentHex2)
			
			-- continua recursivamente a procura de um hexagono proximo
			self:getPathFromHexagon(path, pathLink, farHex)
		end
	else
	-- verifica se o adjacente distante esta proximo da borda e existem os adjacentes
		if farHex == nil and adjacentHex1 ~= nil and adjacentHex2 ~= nil then
		
		-- verifica se os adjacentes estao livres
			if adjacentHex1.available and adjacentHex2.available then
			
				-- verifica se os adjacentes sao da borda do jogador (borda vertical ou horizontal)
				-- caso sejam, adiciona eles ao caminho de ligacao
				if self.pathDirection == victoryPath["horizontal"] then
					if adjacentHex1.column == adjacentHex2.column then
						table.insert(pathLink, adjacentHex1)
						table.insert(pathLink, adjacentHex2)
					end
				elseif self.pathDirection == victoryPath["vertical"] then
					if adjacentHex1.row == adjacentHex2.row then
						table.insert(pathLink, adjacentHex1)
						table.insert(pathLink, adjacentHex2)
					end
				end
			end
		end
	end
end

function BoardPath:calculateDistancePathComplete(path)
	self.graph:update()
	self.graph.move = false
	
	local dist = self.graph:dijkstra(Vector:new(path[1].column, path[1].row))
	
	local distTopLeft = dist[1][1]
	local distBottomRight = dist[self.graph.V.x][self.graph.V.y]
	
	return distTopLeft + distBottomRight
end

function BoardPath:getBestPath()
-- procura qual caminho tem a menor distancia
	local shortestDistance = self.distanceToWin[1]
	local path = self.paths[1]
	local pathLink = self.pathLinks[1]
	
	for i = 1, table.getn(self.distanceToWin), 1 do
		if self.distanceToWin[i] < shortestDistance then
			path = self.paths[i]
			shortestDistance = self.distanceToWin[i]
			pathLink = self.pathLinks[i]
		end
	end
	
	return path, shortestDistance, pathLink
end