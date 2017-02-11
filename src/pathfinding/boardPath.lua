require "pathfinding/graph"

BoardPath = {}
BoardPath.__index = BoardPath

function BoardPath:new(pathDirection, owner)
	local B = {}
	setmetatable(B, BoardPath)
	
	B.pathDirection = pathDirection			-- vertical or horizontal path
	B.owner = owner							-- player path that is evaluating (AI)
	
	-- has the hexagons to form the path
	B.paths = {}
	
	-- has a number to indicate the distance to complete the path
	B.distanceToWin = {}

	-- has the hexagons that finish the path	
	-- only useful if the path is almost complete
	-- to make the AI play in the connections
	B.pathLinks = {}
	
	B.graph = Graph:new(B.pathDirection)
	
	return B
end

function BoardPath:resetSearch()
	-- reset visited hexagons
	for i = 1, board.size.y, 1 do
		for j = 1, board.size.x, 1 do
			board.hexagon[i][j].visited = false
		end
	end
	
	-- clear the previous paths found
	self.paths = {}
	
	-- clear calculated distances
	self.distanceToWin = {}
	
	-- clear the connection hexagons
	self.pathLinks = {}
end

function BoardPath:searchBestPath()
	-- search for all possible paths for the player
	-- return the best path and his distance
	self:resetSearch()
	
	for i = 1, board.size.y, 1 do
		for j = 1, board.size.x, 1 do
			local hex = board.hexagon[i][j]
			
			if not hex.visited and hex.hold == self.pathDirection then
				-- mark the ehxagon as visited
				hex.visited = true
				
				local path = {}
				local pathLink = {}
				
				table.insert(path, hex)
				
				-- start a recursion to search a in this hexagon
				self:getPathFromHexagon(path, pathLink, hex)
				
				-- calculate the distance in hexagon that last to complete the path
				local distance = self:calculateDistancePathComplete(path)
				table.insert(self.distanceToWin, distance)
				
				-- include the new path found and his connection hexagons
				table.insert(self.paths, path)
				table.insert(self.pathLinks, pathLink)
			end
		end
	end
	
	return self:getBestPath()
end

function BoardPath:calculateNewDistance(hexNew, hexSource)
	-- "hexNew" is the hexagon that will be analyzed in a simulated move

	-- this method simulate the move given in the arguments
	-- return the new distance and the amount of hexagons that make connections in the path
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

	-- start a recursion to seach the path in this hexagon
	self:getPathFromHexagon(path, pathLink, hexSource)
	
	hexNew:resetHex()
	
	local distTopLeft = dist[1][1]
	local distBottomRight = dist[self.graph.V.x][self.graph.V.y]
	
	return path, distTopLeft + distBottomRight, pathLink
end

function BoardPath:getPathFromHexagon(path, pathLink, hex)
	-- recursive function that build a path from a hexagon

	-- adjacent hexagon:
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
	
	-- far adjacent hexagons
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
		-- mark that the hexagon was aldeary visited
		adjacentHex.visited = true
		
		table.insert(path, adjacentHex)

		-- continue recursively	the search for the next hexagon
		self:getPathFromHexagon(path, pathLink, adjacentHex)
	end
end

function BoardPath:getFarAdjacencyPath(path, pathLink, farHex, adjacentHex1, adjacentHex2)
	-- check for the far adjacent hexagon, that the path can be
	-- connected in the next turn independently of the oponnent's next move

	if farHex ~= nil and not farHex.visited and farHex.hold == self.pathDirection then
		if adjacentHex1.available and adjacentHex2.available then
			farHex.visited = true
		
			table.insert(path, farHex)
			
			table.insert(pathLink, adjacentHex1)
			table.insert(pathLink, adjacentHex2)
			
			-- continue recursively	the search for the next hexagon
			self:getPathFromHexagon(path, pathLink, farHex)
		end
	else
		-- check if the far adjacent is close to the edge and exist the adjacent
		if farHex == nil and adjacentHex1 ~= nil and adjacentHex2 ~= nil then
		
			-- check if the adjacents are free
			if adjacentHex1.available and adjacentHex2.available then

				-- check if the adjacents are the player edge (horizontal or vertical)
				-- if they are, add it to the connection path
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
	-- search which path has the lesser distance
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