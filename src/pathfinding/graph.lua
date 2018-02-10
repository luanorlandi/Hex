require "sort/heap"

Graph = {}
Graph.__index = Graph

function Graph:new(pathDirection)
	-- create a graph of board
	local G = {}
	setmetatable(G, Graph)
	
	G.V = Vector:new(board.size.y + 2, board.size.x + 2)			-- vertex amount
	-- sum 2 to include edges
	
	G.pathDirection = pathDirection -- vertical or horizontal
	G.bothSides = 3					-- macro to indicate that the hexagon is owned bt both path players
	G.infinity = 9999				-- macro to indicate that the distance is infinite
	
	G.move = false
	
	-- create the graph vertices
	-- and aid to indicate visited vertices
	G.vertex = {}
	for i = 1, G.V.y, 1 do
		G.vertex[i] = {}
	end
	
	G:update()
	
	-- debug
	G.texts = {}
	
	return G
end

function Graph:getValueFromBoard(y, x)
	-- corner, owned by both players
	if (y == 1 and x == 1) or
	   (y == 1 and x == self.V.x) or
	   (y == self.V.y and x == 1) or
	   (y == self.V.y and x == self.V.x) then
		
		return self.bothSides
	end
	
	-- top and bottom edge
	if y == 1 or y == self.V.y then
		return victoryPath["vertical"]
	end
	
	-- left and right edge
	if x == 1 or x == self.V.x then
		return victoryPath["horizontal"]
	end
	
	return board.hexagon[y-1][x-1].hold
end

function Graph:update()
	-- update the values of who own the hexagon
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
	
	local distance = {}			-- source distance
	local previous = {}			-- previous hexagon

	local queue = Heap:new()	-- priority queue (min heap)
	local visited = {}			-- aid to indicate if a vertex was already evaluated
	local inQueue = {}			-- aid to indicate if a vertex is already in the queue
	
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
	--return a table with the positions x and y of neighbors
	
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
	-- return the distance (edge length) beetwen source and destiny
	
	-- "value" is the number (macro of victoryPath) indicate to which player owns the hexagon
	local sourceValue = self.vertex[source.y][source.x]
	local destinyValue = self.vertex[destiny.y][destiny.x]

	if sourceValue == 0 then
		-- source free
		
		if destinyValue == self.pathDirection or destinyValue == self.bothSides then
			-- my destiny or corner
			
			return 0
		elseif destinyValue ~= 0 then
			-- opponent's destiny
			
			return self.infinity
		else
			-- destiny free
			
			if self.move and self:checkOpponentMove(source, destiny) then
				-- in case is a simulated move, check if the opponent
				-- can complete his path in his next move
				
				return self.infinity
			elseif self:checkOpponentPathLink(source, destiny) then
				-- check if it's a hexagon in a opponent's path connection
				
				return self.infinity
			else
				-- ideal case
				return 1
			end
		end
	elseif sourceValue ~= self.pathDirection then
		-- opponent's source
		
		return self.infinity
	else
		-- my source
		
		if destinyValue == self.pathDirection or destinyValue == self.bothSides then
			-- my destiny or corner
			
			return 0
		elseif destinyValue ~= 0 then
			-- opponent's destiny
			
			return self.infinity
		else
			-- destiny free
			
			if self.move and self:checkOpponentMove(source, destiny) then
				-- in case is a simulated move, check if the opponent
				-- can complete his path in his next move
				
				return self.infinity
			elseif self:checkOwnPathLink(source, destiny) then
				-- checa se eh um hexagono em caminho de ligacao
				-- check if it's a hexagon in path connection
				
				return 0
			else
				-- ideal case
				return 1
			end
		end
	end
end

function Graph:checkOwnPathLink(source, link)
	-- check if the hexagon in link is of connection from the player, giving 0 weight

	-- the function assume initially that the source is from the player,
	-- the link exists and not owned

	if source.y == 1 or source.x == 1 or
		source.y == self.V.y or source.x == self.V.x then
		-- discard if the source is in the edge
		
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
	-- used to check the connections from the method above
	-- "adjacent" and "farAdjacent" arguments are hexagons of the board
	-- "edge" is a direction to which edge("upper" and "bottom" are vertical,
	-- "upper left", "upper right", "bottom left" and "bottom right" are horizontal)

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
	-- check if the hexagon in link is the opponent connection, giving infinite weight

	-- the method assume initially that the source and link are free

	if source.y == 1 or source.x == 1 or
		source.y == self.V.y or source.x == self.V.x then
		-- discard if the source is in the edge
		
		return false
	end
	
	-- adjacent hexagons in clockwise on right
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
	
	-- if both adjacent hexagons are owned by the opponent or are in the edge
	if ((leftAdjacent == nil) or (leftAdjacent.hold ~= 0 and leftAdjacent ~= self.pathDirection)) and
	   ((rightAdjacent == nil) or (rightAdjacent.hold ~= 0 and rightAdjacent ~= self.pathDirection)) then
	   
	   return true
	else
		return false
	end
end

function Graph:checkOpponentMove(source, destiny)
	-- if it's a simulated move being evaluated, check for
	-- a situation which if the opponent plays in the destiny
	-- hexagon in the next turn, the path will be completed

	-- the method assume initially that the attribute move is true
	-- and the ehxagon in destiny is free

	if source.y == 1 or source.x == 1 or
		source.y == self.V.y or source.x == self.V.x then
		-- discard if the source is in the edge
		
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
	-- debug
	local font = MOAIFont.new ()
	font:loadFromTTF("font/NotoSans-Regular.ttf", 25)
	
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