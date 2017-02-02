require "sort/heap"

Graph = {}
Graph.__index = Graph

function Graph:new(pathDirection)
-- cria um grafo do board
	local G = {}
	setmetatable(G, Graph)
	
	G.V = Vector:new(board.size.y + 2, board.size.x + 2)			-- numero de vertices
	-- soma 2 para incluir as bordas
	
	G.pathDirection = pathDirection -- caminho vertical ou horizontal
	G.bothSides = 3					-- macro para indicar que o hexagono pertence aos 2 jogadores
	G.infinity = 9999				-- macro para indicar uma distancia infinita
	
	G.move = false
	
	-- cria os vertices do grafo
	-- e auxiliares para inidicar vertices ja visitados
	G.vertex = {}
	for i = 1, G.V.y, 1 do
		G.vertex[i] = {}
	end
	
	G:update()
	
	-- auxiliar para indicar se
	
	-- debug
	G.texts = {}
	
	return G
end

function Graph:getValueFromBoard(y, x)
	-- cantos, pertence aos dois jogadores
	if (y == 1 and x == 1) or
	   (y == 1 and x == self.V.x) or
	   (y == self.V.y and x == 1) or
	   (y == self.V.y and x == self.V.x) then
			return self.bothSides
	end
	
	-- borda de cima e de baixo
	if y == 1 or y == self.V.y then
		return victoryPath["vertical"]
	end
	
	-- borda da esquerda e da direita
	if x == 1 or x == self.V.x then
		return victoryPath["horizontal"]
	end
	
	return board.hexagon[y-1][x-1].hold
end

function Graph:update()
-- atualiza os valores de a quem pertencem cada hexagonos
	for i = 1, self.V.y, 1 do
		for j = 1, self.V.x, 1 do
			self.vertex[i][j] = self:getValueFromBoard(i, j)
			
			--io.write(self.vertex[i][j] .. " ")
		end
		
		--[[io.write("\n")
		for k = 1, i, 1 do
			io.write("  ")
		end]]
	end
	--io.write("\n")
end

function Graph:dijkstra(source)
	local s = Vector:new(source.x + 1, source.y + 1)
	
	local distance = {}			-- distancia da origem
	local previous = {}			-- hexagono antecessor

	local queue = Heap:new()	-- fila de prioridade(min heap)
	local visited = {}			-- auxiliar para indicar se um vertice ja foi avaliado
	local inQueue = {}			-- auxiliar para indicar se um vertice esta na fila
	
	for i = 1, self.V.y, 1 do
		distance[i] = {}
		previous[i] = {}
		
		visited[i] = {}
		inQueue[i] = {}
		
		for j = 1, self.V.x, 1 do
			if i == s.y and j == s.x then
				distance[i][j] = 0
			else
				distance[i][j] = self.infinity
			end
			
			previous[i][j] = nil
			
			visited[i][j] = false
			inQueue[i][j] = false
		end
	end
	
	queue:insert(s, 0)
	inQueue[s.y][s.x] = true
	
	local count = 0
	while not (queue:isEmpty()) do
		local u = queue:extractMin()
		inQueue[u.y][u.x] = false
		
		local neighbors = self:getNeighbors(u)
		
		for i = 1, table.getn(neighbors), 1 do
			local v = neighbors[i]
			
			if not visited[v.y][v.x] then
				local alt = distance[u.y][u.x] + self:getWeight(u, v)
				
				if alt < distance[v.y][v.x] then
					distance[v.y][v.x] = alt
					previous[v.y][v.x] = Vector:new(u.x, u.y)
					
					if not inQueue[v.y][v.x] then
						queue:insert(v, distance[v.y][v.x])
						inQueue[v.y][v.x] = true
					end
				end
			end
		end
		
		visited[u.y][u.x] = true
		count = count + 1
	end
	
	return distance, previous
end

function Graph:getLesser(queue, distance)
	local lesser = Vector:new(queue[1].x, queue[1].y)
	local queuePos = 1
	
	for i = 1, table.getn(queue), 1 do
		local u = queue[i]
		
		if distance[u.x][u.y] < distance[lesser.x][lesser.y] then
			lesser.x = u.x
			lesser.y = u.y
			
			queuePos = i
		end
	end
	
	table.remove(queue, queuePos)
	
	return lesser
end

function Graph:getNeighbors(hexPos)
-- retorna uma tabela com as posicoes x e y dos vizinhos
	
	neighbors = {}
	
	-- upper left
	if hexPos.y - 1 >= 1 then
		table.insert(neighbors, Vector:new(hexPos.x, hexPos.y - 1))
	end
	
	-- upper right
	if hexPos.y - 1 >= 1 and hexPos.x + 1 <= self.V.x then
		table.insert(neighbors, Vector:new(hexPos.x + 1, hexPos.y - 1))
	end
	
	-- right
	if hexPos.x + 1 <= self.V.x then
		table.insert(neighbors, Vector:new(hexPos.x + 1, hexPos.y))
	end
	
	-- bottom right
	if hexPos.y + 1 <= self.V.y then
		table.insert(neighbors, Vector:new(hexPos.x, hexPos.y + 1))
	end
	
	-- bottom left
	if hexPos.y + 1 <= self.V.y and hexPos.x - 1 >= 1 then
		table.insert(neighbors, Vector:new(hexPos.x - 1, hexPos.y + 1))
	end
	
	-- left
	if hexPos.x - 1 >= 1 then
		table.insert(neighbors, Vector:new(hexPos.x - 1, hexPos.y))
	end
	
	return neighbors
end

function Graph:getWeight(source, destiny)
-- retorna a distancia (comprimento da aresta) entre source e destiny
	
	-- "value" eh o numero (macro de victoryPath) indicando a qual jogador pertence o hexagono
	local sourceValue = self.vertex[source.y][source.x]
	local destinyValue = self.vertex[destiny.y][destiny.x]

	if sourceValue == 0 then
		-- source livre
		
		if destinyValue == self.pathDirection or destinyValue == self.bothSides then
			-- destino meu ou canto
			
			return 0
		elseif destinyValue ~= 0 then
			-- destino oponente
			
			return self.infinity
		else
			-- destino livre
			
			if self.move and self:checkOpponentMove(source, destiny) then
				-- caso eh uma jogada simulada, checa se o oponente
				-- consegue fechar o caminho na sua proxima jogada
				
				return self.infinity
			elseif self:checkOpponentPathLink(source, destiny) then
				-- checa se eh um hexagono em caminho de ligacao do oponente
				
				return self.infinity
			else
				-- caso ideal
				return 1
			end
		end
	elseif sourceValue ~= self.pathDirection then
		-- source oponente
		
		return self.infinity
	else
		-- source meu
		
		if destinyValue == self.pathDirection or destinyValue == self.bothSides then
			-- destino meu ou canto
			
			return 0
		elseif destinyValue ~= 0 then
			-- destino oponente
			
			return self.infinity
		else
			-- destino livre
			
			if self.move and self:checkOpponentMove(source, destiny) then
				-- caso eh uma jogada simulada, checa se o oponente
				-- consegue fechar o caminho na sua proxima jogada
				
				return self.infinity
			elseif self:checkOwnPathLink(source, destiny) then
				-- checa se eh um hexagono em caminho de ligacao
				
				return 0
			else
				-- caso ideal
				
				return 1
			end
		end
	end
end

function Graph:checkOwnPathLink(source, link)
-- verifica se o hexagono em link eh de ligacao do proprio jogador, valendo peso 0

-- a funcao assume inicialmente que o source eh do jogador e
-- o link existe e nao pertence a ninguem

	if source.y == 1 or source.x == 1 or
		source.y == self.V.y or source.x == self.V.x then
		-- desconsidera se o source eh na borda
		
		return false
	end

	local adjacent = nil
	local farAdjacent = nil
	
	local hexSource = board.hexagon[source.y-1][source.x-1]
	
	if source.y - 1 == link.y and source.x == link.x then
		-- link upper left
		
		adjacent = board:getLeftHexagon(hexSource)
		farAdjacent = board:getFarUpperLeftHexagon(hexSource)
			
		if self:checkOwnLink(adjacent, farAdjacent, victoryPath["horizontal"]) then
			return true
		else		
			adjacent = board:getUpperRightHexagon(hexSource)
			farAdjacent = board:getFarUpperHexagon(hexSource)

			return self:checkOwnLink(adjacent, farAdjacent, victoryPath["vertical"])
		end
	elseif source.y - 1 == link.y and source.x + 1 == link.x then
		-- link upper right
		
		adjacent = board:getUpperLeftHexagon(hexSource)
		farAdjacent = board:getFarUpperHexagon(hexSource)
		
		if self:checkOwnLink(adjacent, farAdjacent, victoryPath["vertical"]) then
			return true
		else
			adjacent = board:getRightHexagon(hexSource)
			farAdjacent = board:getFarUpperRightHexagon(hexSource)
			
			return self:checkOwnLink(adjacent, farAdjacent, victoryPath["horizontal"])
		end
	elseif source.y == link.y and source.x + 1 == link.x then
		-- link right
		
		adjacent = board:getUpperRightHexagon(hexSource)
		farAdjacent = board:getFarUpperRightHexagon(hexSource)
		
		if self:checkOwnLink(adjacent, farAdjacent, victoryPath["horizontal"]) then
			return true
		else		
			adjacent = board:getBottomRightHexagon(hexSource)
			farAdjacent = board:getFarBottomRightHexagon(hexSource)

			return self:checkOwnLink(adjacent, farAdjacent, victoryPath["horizontal"])
		end
	elseif source.y + 1 == link.y and source.x == link.x then
		-- link bottom right
		
		adjacent = board:getRightHexagon(hexSource)
		farAdjacent = board:getFarBottomRightHexagon(hexSource)
		
		if self:checkOwnLink(adjacent, farAdjacent, victoryPath["horizontal"]) then
			return true
		else		
			adjacent = board:getBottomLeftHexagon(hexSource)
			farAdjacent = board:getFarBottomHexagon(hexSource)

			return self:checkOwnLink(adjacent, farAdjacent, victoryPath["vertical"])
		end
	elseif source.y + 1 == link.y and source.x - 1 == link.x then
		-- link bottom left
		
		adjacent = board:getBottomRightHexagon(hexSource)
		farAdjacent = board:getFarBottomHexagon(hexSource)
		
		if self:checkOwnLink(adjacent, farAdjacent, victoryPath["vertical"]) then
			return true
		else		
			adjacent = board:getLeftHexagon(hexSource)
			farAdjacent = board:getFarBottomLeftHexagon(hexSource)

			return self:checkOwnLink(adjacent, farAdjacent, victoryPath["horizontal"])
		end
	elseif source.y == link.y and source.x - 1 == link.x then
		-- link left
		
		adjacent = board:getBottomLeftHexagon(hexSource)
		farAdjacent = board:getFarBottomLeftHexagon(hexSource)
		
		if self:checkOwnLink(adjacent, farAdjacent, victoryPath["horizontal"]) then
			return true
		else		
			adjacent = board:getUpperLeftHexagon(hexSource)
			farAdjacent = board:getFarUpperLeftHexagon(hexSource)

			return self:checkOwnLink(adjacent, farAdjacent, victoryPath["horizontal"])
		end
	end
	
	return false
end

function Graph:checkOwnLink(adjacent, farAdjacent, edge)
-- usado para checar as ligacoes da funcao de cima
-- "adjacent" e "farAdjacent" parametros de entrada sao hexagonos do board
-- "edge" eh a direcao para qual borda ("upper" e "bottom" sao para vertical,
-- "upper left, upper right, bottom left e bottom right" sao para horizontal)

	if adjacent ~= nil and adjacent.hold == 0 then
		if farAdjacent == nil then
			if edge == self.pathDirection then
				return true
			end
		elseif farAdjacent.hold == self.pathDirection then
			return true
		end
	end
	
	return false
end

function Graph:checkOpponentPathLink(source, link)
-- verifica se o hexagono em link eh de ligacao do oponente, valendo peso infinito

-- a funcao assume inicialmente que o source e link esta livre

	if source.y == 1 or source.x == 1 or
		source.y == self.V.y or source.x == self.V.x then
		-- desconsidera se o source eh na borda
		
		return false
	end
	
	-- hexagonos adjacentes em sentido horario na direita
	local leftAdjacent = nil
	local rightAdjacent = nil
	
	local hexSource = board.hexagon[source.y-1][source.x-1]

	if source.y - 1 == link.y and source.x == link.x then
		-- link upper left
		
		leftAdjacent = board:getLeftHexagon(hexSource)
		rightAdjacent = board:getUpperRightHexagon(hexSource)
		
	elseif source.y - 1 == link.y and source.x + 1 == link.x then
		-- link upper right
		
		leftAdjacent = board:getUpperLeftHexagon(hexSource)
		rightAdjacent = board:getRightHexagon(hexSource)

	elseif source.y == link.y and source.x + 1 == link.x then
		-- link right
		
		leftAdjacent = board:getUpperRightHexagon(hexSource)
		rightAdjacent = board:getBottomRightHexagon(hexSource)

	elseif source.y + 1 == link.y and source.x == link.x then
		-- link bottom right
		
		leftAdjacent = board:getRightHexagon(hexSource)
		rightAdjacent = board:getBottomLeftHexagon(hexSource)

	elseif source.y + 1 == link.y and source.x - 1 == link.x then
		-- link bottom left
		
		leftAdjacent = board:getBottomRightHexagon(hexSource)
		rightAdjacent = board:getLeftHexagon(hexSource)

	elseif source.y == link.y and source.x - 1 == link.x then
		-- link left
		
		leftAdjacent = board:getBottomLeftHexagon(hexSource)
		rightAdjacent = board:getUpperLeftHexagon(hexSource)
	end
	
	-- se os dois hexagonos adjacentes for do oponente ou estao na borda
	if ((leftAdjacent == nil) or (leftAdjacent.hold ~= 0 and leftAdjacent ~= self.pathDirection)) and
	   ((rightAdjacent == nil) or (rightAdjacent.hold ~= 0 and rightAdjacent ~= self.pathDirection)) then
	   
	   return true
	else
		return false
	end
end

function Graph:checkOpponentMove(source, destiny)
-- se eh uma jogada simulada sendo avaliada, verifica para
-- para a situacao em que se o opoennte jogar no hexagono 
-- de destino no proximo turno o caminho sera fechado

-- a funcao assume inicialmente que o atributo move eh true
-- e o hexagono em destiny eh livre
	
	if source.y == 1 or source.x == 1 or
		source.y == self.V.y or source.x == self.V.x then
		-- desconsidera se o source eh na borda
		
		return false
	end
	
	local opponentPath = nil
	
	if self.pathDirection == victoryPath["horizontal"] then
		opponentPath = victoryPath["vertical"]
	else
		opponentPath = victoryPath["horizontal"]
	end
	
	local hexDestiny = board.hexagon[destiny.y-1][destiny.x-1]
	
	local adjacentUpperLeft =	board:getUpperLeftHexagon(hexDestiny)
	local adjacentUpperRight =	board:getUpperRightHexagon(hexDestiny)
	local adjacentRight =		board:getRightHexagon(hexDestiny)
	local adjacentBottomRight = board:getBottomRightHexagon(hexDestiny)
	local adjacentBottomLeft =	board:getBottomLeftHexagon(hexDestiny)
	local adjacentLeft =		board:getLeftHexagon(hexDestiny)
	
	if adjacentUpperLeft ~= nil and adjacentUpperLeft.hold == opponentPath then
		if adjacentRight == nil or adjacentRight.hold == opponentPath then
			return true
		elseif adjacentBottomRight == nil or adjacentBottomRight.hold == opponentPath then
			return true
		elseif adjacentBottomLeft == nil or adjacentBottomLeft.hold == opponentPath then
			return true
		end
	end
	
	if adjacentUpperRight ~= nil and adjacentUpperRight.hold == opponentPath then
		if adjacentBottomRight == nil or adjacentBottomRight.hold == opponentPath then
			return true
		elseif adjacentBottomLeft == nil or adjacentBottomLeft.hold == opponentPath then
			return true
		elseif adjacentLeft == nil or adjacentLeft.hold == opponentPath then
			return true
		end
	end
	
	if adjacentRight ~= nil and adjacentRight.hold == opponentPath then
		if adjacentBottomLeft == nil or adjacentBottomLeft.hold == opponentPath then
			return true
		elseif adjacentLeft == nil or adjacentLeft.hold == opponentPath then
			return true
		elseif adjacentUpperLeft == nil or adjacentUpperLeft.hold == opponentPath then
			return true
		end
	end
	
	if adjacentBottomRight ~= nil and adjacentBottomRight.hold == opponentPath then
		if adjacentLeft == nil or adjacentLeft.hold == opponentPath then
			return true
		elseif adjacentUpperLeft == nil or adjacentUpperLeft.hold == opponentPath then
			return true
		elseif adjacentUpperRight == nil or adjacentUpperRight.hold == opponentPath then
			return true
		end
	end
	
	if adjacentBottomLeft ~= nil and adjacentBottomLeft.hold == opponentPath then
		if adjacentUpperLeft == nil or adjacentUpperLeft.hold == opponentPath then
			return true
		elseif adjacentUpperRight == nil or adjacentUpperRight.hold == opponentPath then
			return true
		elseif adjacentRight == nil or adjacentRight.hold == opponentPath then
			return true
		end
	end
	
	if adjacentLeft ~= nil and adjacentLeft.hold == opponentPath then
		if adjacentUpperRight == nil or adjacentUpperRight.hold == opponentPath then
			return true
		elseif adjacentRight == nil or adjacentRight.hold == opponentPath then
			return true
		elseif adjacentBottomRight == nil or adjacentBottomRight.hold == opponentPath then
			return true
		end
	end
	
	return false
end

function Graph:showDistance(dist)
-- funcao para debug
	local font = MOAIFont.new ()
	font:loadFromTTF("font/zekton free.ttf", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!'", 25)
	
	for i = 1, table.getn(self.texts), 1 do
		window.interface.layer:removeProp(self.texts[i])
	end
	
	self.texts = {}
	
	for i = 2, table.getn(dist) - 1, 1 do
		for j = 2, table.getn(dist) - 1, 1 do
			local hex = board.hexagon[i-1][j-1]
		
			if hex ~= nil then
				textbox = MOAITextBox.new ()
				textbox:setRect(-0.5 * window.resolution.x, -0.5 * window.resolution.y, 0.5 * window.resolution.x, 0.5 * window.resolution.y)
				textbox:setLoc(hex.pos.x, hex.pos.y)
				textbox:setFont(font)
				textbox:setYFlip(true)
				window.interface.layer:insertProp(textbox)
				changePriority(textbox, "interface")
				
				if dist[i][j] < self.infinity then
					textbox:setString("" .. dist[i][j])
				else
					textbox:setString("x")
				end
				
				textbox:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
				textbox:setColor(0, 1, 1, 1)
				
				table.insert(self.texts, textbox)
			else
				print("nulo")
			end
		end
	end
end