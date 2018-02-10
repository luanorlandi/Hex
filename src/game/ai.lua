require "pathfinding/boardPath"
require "sort/quickSort"

AI = {}
AI.__index = AI

function AI:new(myPath, opponentPath)
	-- create an artificial intelligence
	-- "myPath" is horizontal or vertical
	local A = {}
	setmetatable(A, AI)
	
	-- if the player undo his move, this is will be set true
	A.cancelAnalysis = false
	
	A.myPath = myPath
	
	-- aid the analysis, "hex" has the hexagons available to be analyzed
	-- "hexPoints" has the assigned score for the hexagon
	A.hex = {}
	A.hexPoints = {}
	
	-- aid to calculate score in center proximity
	A.boardCenter = A:getBoardCenter()
	
	if myPath == victoryPath["horizontal"] then
		A.myBoardSize = board.size.x
		A.opponentBoardSize = board.size.y
	else
		A.myBoardSize = board.size.y
		A.opponentBoardSize = board.size.x
	end
	
	A.myBoardPath = BoardPath:new(myPath, myPath)
	A.opponentBoardPath = BoardPath:new(opponentPath, myPath)
	
	-- limit dijkstra amount
	-- execute this maximum number of hexagons to be analyzed using dijkstra per turn
	A.qtyAnalysisBoardPath = 30				-- this is increased per turn
	
	-- starting values to adjust priority of each analyse
	A.scoreMultiplierCenter = math.ceil((board.size.x + board.size.y) / 2)
	A.scoreMultiplierAdjacency = 0.2
	A.scoreMultiplierMyBoardPath = 0.4
	A.scoreMultiplierOpponentBoardPath = 0.5
	A.scoreMultiplierFavorablePath = 3
	
	A.scoreMultiplierAdvantage = 2				-- who is winning receives increased analyse value
	A.scoreMultiplierDistance = 80
	A.scoreMultiplierDifferenceDistances = 5
	A.scoreAdderPathCompleteLink = 500
	A.scoreAdderPathComplete = 1000
	
	A.scoreMultiplierLinkAmount = 10
	
	A.scoreAdderOpponentPathLink = -100
	
	A.scoreAdderHexAdjacentNotFree = 1
	A.scoreAdderFarAdjacentNotFree = 3
	A.scoreAdderFarAdjacentOnEdge = 2
	
	-- debug
	A.texts = {}
	A.duration = nil
	
	-- if the bot play the first turn, enable bot turn
	if turn.mode == gameMode["bot"] and player2.myTurn == playerTurn["first"] then
		local botTurnCoroutine = MOAICoroutine.new()
		botTurnCoroutine:run(startAIturn)
	end
	
	return A
end

function AI:getBoardCenter()
	-- return a matrix of hexagons with higher values close to center
	local row = 0
	local column = 0
	
	local result = 0
	
	local center = Vector:new(math.ceil(board.size.x / 2), math.ceil(board.size.y / 2))
	local boardCenter = {}
	
	for i = 1, board.size.y, 1 do
		boardCenter[i] = {}
		
		for j = 1, board.size.x, 1 do
			local hex = board.hexagon[i][j]
		
			if hex.column <= center.x then
				column = hex.column
			else
				column = 2 * center.x - hex.column
			end
			
			if hex.row <= center.y then
				row = hex.row
			else
				row = 2 * center.y - hex.row
			end
			
			result = column + row
			
			if (hex.column >= center.x and hex.row <= center.y)
				or (hex.column <= center.x and hex.row >= center.y) then
				
				result = result + getMin(math.abs(hex.column - center.x), math.abs(hex.row - center.y))
			end
			
			boardCenter[i][j] = result
		end
	end
	
	return boardCenter
end

function AI:analyzeBoard()
	-- analyse board situation, giving values in hexPoints
	-- high values indicates that the hexagon is a good move by the analyse

	--local start = os.clock()		-- start counting time
	
	-- reset values
	self.hex = {}
	self.hexPoints = {}
	
	local i = 1
	
	while i <= board.size.y and not (self.cancelAnalysis) do
		local j = 1
		
		while j <= board.size.x and not (self.cancelAnalysis) do
			coroutine.yield()
		
			local hex = board.hexagon[i][j]
			
			local score = 0
			
			if hex.available then
				score = score + self.scoreMultiplierCenter * self:analyzeCenter(hex)
				
				score = score + self.scoreMultiplierAdjacency * self:analyzeAdjacency(hex)
				
				score = math.floor(score)
				
				table.insert(self.hex, hex)
				table.insert(self.hexPoints, score)
			end
			
			j = j + 1
		end
		
		i = i + 1
	end
	
	-- debug
	--if not (self.cancelAnalysis) then self:showPoints() end
	
	-- analyse to value moves that reduces my minimum path
	-- and increase the opponent's' path
	if not (self.cancelAnalysis) then
		self:analyzeBoardPath()
	end
	
	-- if the analyse was fast and the player can still undo his move
	-- make a loop to wait undo limit time
	while turn.inUndo and not (self.cancelAnalysis) do
		coroutine.yield()
	end
	
	--local ending = os.clock()					-- end counting time
	--self:showAnalysisDuration(ending - start)	-- show analyse duration
	
	-- update evaluation in each analyse type
	if not (self.cancelAnalysis) then
		self:updateMultipliers()
	end
	
	-- debug
	--if not (self.cancelAnalysis) then self:showPoints() end
end

function AI:analyzeCenter(hex)
	local score = 0
	
	score = score + self.boardCenter[hex.column][hex.row]
	
	return score
end

function AI:analyzeAdjacency(hex)
	-- adjacent hexagons:
	local upperLeft =		board:getUpperLeftHexagon(hex)
	local upperRight =		board:getUpperRightHexagon(hex)
	local right =			board:getRightHexagon(hex)
	local bottomRight =		board:getBottomRightHexagon(hex)
	local bottomLeft =		board:getBottomLeftHexagon(hex)
	local left =			board:getLeftHexagon(hex)
	
	-- far adjacent hexagons:
	local farUpperLeft =	board:getFarUpperLeftHexagon(hex)
	local farUpper =		board:getFarUpperHexagon(hex)
	local farUpperRight =	board:getFarUpperRightHexagon(hex)
	local farBottomRight =	board:getFarBottomRightHexagon(hex)
	local farBottom =		board:getFarBottomHexagon(hex)
	local farBottomLeft =	board:getFarBottomLeftHexagon(hex)
	
	local score = 0
	
	-- analyse each adjacency for the hexagon
	local tmpPoints = 0
	
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farUpperLeft, left, upperLeft)
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farUpperRight, upperRight, right)
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farBottomRight, right, bottomRight)
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farBottomLeft, bottomLeft, left)
	
	-- if is a favorable adjacency to my horizontal path, increase score
	if self.myPath == victoryPath["horizontal"] then
		tmpPoints = self.scoreMultiplierFavorablePath * tmpPoints
	end
	
	score = score + tmpPoints
	
	tmpPoints = 0
	
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farUpper, upperLeft, upperRight)
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farBottom, bottomRight, bottomLeft)
	
	-- if is a favorable adjacency to my vertical path, increase score
	if self.myPath == victoryPath["vertical"] then
		tmpPoints = self.scoreMultiplierFavorablePath * tmpPoints
	end
	
	score = score + tmpPoints
	
	return score
end

function AI:analyzeFarAdjacency(farHex, adjacentHex1, adjacentHex2)
	local score = 0
	
	if adjacentHex1 ~= nil then
		-- adjacent it is not in a edge
		if adjacentHex1.hold ~= 0 then
			-- adjacent is not free
			score = score + self.scoreAdderHexAdjacentNotFree
		end
	end
	
	if adjacentHex2 ~= nil then
		-- adjacent it is not in a edge
		if adjacentHex2.hold ~= 0 then
			-- adjacent is not free
			score = score + self.scoreAdderHexAdjacentNotFree
		end
	end
	
	if farHex == nil then
		-- far adjacent is in the edge
		score = score + self.scoreAdderFarAdjacentOnEdge
	else
		-- far adjacent is not in the edge
		if farHex.hold ~= 0 then
			-- far adjacent is not free
			score = score + self.scoreAdderFarAdjacentNotFree
		end
	end
	
	return score
end

function AI:analyzeBoardPath()
	local qtyHexAnalyzing = table.getn(self.hex)
	
	if qtyHexAnalyzing > self.qtyAnalysisBoardPath then
		-- limit analyse to execute only in hexagons which has high scores
		
		quickSortTwoArrays(self.hexPoints, self.hex, 1, qtyHexAnalyzing)
		qtyHexAnalyzing = self.qtyAnalysisBoardPath
	end
	
	-- search for my best current path
	local path, distance, pathLink = self.myBoardPath:searchBestPath()
	
	-- search for opponent's best current path
	local opponentPath, opponentDistance, opponentPathLink = self.opponentBoardPath:searchBestPath()
	
	local advantage = 1
	local opponentAdvantage = 1
	if distance ~= nil and opponentDistance ~= nil and distance > opponentDistance then
		advantage = self.scoreMultiplierAdvantage
	else
		opponentAdvantage = self.scoreMultiplierAdvantage
	end
	
	local i = 1
	
	while i <= qtyHexAnalyzing and not (self.cancelAnalysis) do
		coroutine.yield()
		
		local hex = self.hex[i]
		
		self.hexPoints[i] = advantage * (self.hexPoints[i] + self.scoreMultiplierMyBoardPath * self:analyzeMyBoardPath(hex, path, distance, pathLink))
		
		self.hexPoints[i] = opponentAdvantage * (self.hexPoints[i] + self.scoreMultiplierOpponentBoardPath *
			self:analyzeOpponentBoardPath(hex, opponentPath, opponentDistance, opponentPathLink))
		
		self.hexPoints[i] = math.floor(self.hexPoints[i])
		
		i = i + 1
	end
end

function AI:analyzeMyBoardPath(hex, path, distance, pathLink)
	-- analyse how much improve the path if the hexagon is selected
	-- "hex" hexagon being evaluated
	-- "path" current path
	-- "distance" current distance to complete the path
	-- "pathLink" hexagons that completes the path
	
	local score = 0
	
	if distance ~= nil then
		-- if there is at least one hexagon of the player in the board, it will have a distance
		if distance > 0 then
		-- the path is not compelted, check how much decrease the distance playing in position "hex"
			local newPath, newDistance, newPathLink = self.myBoardPath:calculateNewDistance(hex, path[1])
			
			if newDistance < self.myBoardPath.graph.infinity then
				if distance < self.myBoardPath.graph.infinity then
					-- if both distance is valid, calculate the score
					score = score + self.scoreMultiplierDistance * (self.myBoardSize - newDistance)
					score = score + self.scoreMultiplierDifferenceDistances * (distance - newDistance)
				else
					-- if the starting distance was infinite, and after the move it's not anymore
					-- then calculate the score in a different
					score = score + self.scoreMultiplierDistance
				end
				
				local pathLinkDifference = table.getn(pathLink) - table.getn(newPathLink)
				score = score + self.scoreMultiplierLinkAmount * pathLinkDifference
			else
				-- else discard this analyse
				return 0
			end
			
			if distance > self.myBoardSize then
				-- if the distance in higher than the board size
				-- devalue the analyse, making the opponent's analyse more important

				if distance - self.myBoardSize > 2 then
					score = math.floor(score / (distance - self.myBoardSize))
				end
			end
		else
			-- distance = 0, situation that the path is almost complete
			-- evaluate the hexagons that completes the path
		
			for i = 1, table.getn(pathLink), 1 do
				local hexLink = pathLink[i]
				
				if hex.row == hexLink.row and hex.column == hexLink.column then
					score = score + self.scoreAdderPathCompleteLink
				end
			end
		end
		
		if distance <= 1 then
			-- check if the hexagon "hex" it is the last
			-- one to complete the path totally, avoiding
			-- plays that extend the match
			
			board.hexGrid[self.myPath]:setElement(hex.row, hex.column)
			
			if board.hexGrid[self.myPath]:findPath() then
				score = score + self.scoreAdderPathComplete
			end
			
			board.hexGrid[self.myPath]:resetElement(hex.row, hex.column)
		end
	end
	
	return score
end

function AI:analyzeOpponentBoardPath(hex, path, distance, pathLink)
	-- analyse how much improve the opponent's path if the hexagon is selected by the opponent
	-- "hex" hexagon being evaluated
	-- "path" current path
	-- "distance" current distance to complete the path
	-- "pathLink" hexagons that completes the path
	
	local score = 0
	
	if distance ~= nil then
		-- if there is at least one hexagon of the player in the board, it will have a distance
		if distance > 0 then
			-- the path is not compelted, check how much decrease the distance playing in position "hex"
			local newPath, newDistance, newPathLink = self.opponentBoardPath:calculateNewDistance(hex, path[1])

			if newDistance < self.opponentBoardPath.graph.infinity then
				if distance < self.opponentBoardPath.graph.infinity then
					-- if both distance is valid, calculate the score
					score = score + self.scoreMultiplierDistance * (self.myBoardSize - newDistance)
					score = score + self.scoreMultiplierDifferenceDistances * (distance - newDistance)
				else
					-- if the starting distance was infinite, and after the move it's not anymore
					-- then calculate the score in a different
					score = score + self.scoreMultiplierDistance
				end
				
				local pathLinkDifference = table.getn(pathLink) - table.getn(newPathLink)
				score = score + self.scoreMultiplierLinkAmount * pathLinkDifference
			
			else
				-- else discard this analyse
				return 0
			end
			
			if distance > self.myBoardSize then
				-- if the distance in higher than the board size
				-- devalue the analyse, making the opponent's analyse more important
			
				if distance - self.myBoardSize > 2 then
					score = math.floor(score / (distance - self.myBoardSize))
				end
			end
		end

		-- if the distance is already 0
		-- there is no way to prevent the opponent from completing the path
	end
	
	return score
end

function AI:updateMultipliers()
	if self.qtyAnalysisBoardPath < board.size.x * board.size.x then
		self.qtyAnalysisBoardPath = self.qtyAnalysisBoardPath + 4
	end

	if self.scoreMultiplierCenter > 1 then
		self.scoreMultiplierCenter = self.scoreMultiplierCenter - 1
	end
	
	if self.scoreMultiplierAdjacency < 2 then
		self.scoreMultiplierAdjacency = self.scoreMultiplierAdjacency + 0.2
	end
	
	if self.scoreMultiplierMyBoardPath < 2 then
		self.scoreMultiplierMyBoardPath = self.scoreMultiplierMyBoardPath + 0.2
	end
	
	if self.scoreMultiplierOpponentBoardPath < 3 then
		self.scoreMultiplierOpponentBoardPath = self.scoreMultiplierOpponentBoardPath + 0.2
	end
	
	if self.scoreMultiplierDistance < 50 then
		self.scoreMultiplierDistance = self.scoreMultiplierDistance + 5
	end
	
	if self.scoreMultiplierDifferenceDistances > 30 then
		self.scoreMultiplierDifferenceDistances = self.scoreMultiplierDifferenceDistances - 5
	end
	
	if self.scoreMultiplierLinkAmount < 30 then
		self.scoreMultiplierLinkAmount = self.scoreMultiplierLinkAmount + 1
	end
end

function AI:selectMove()
	-- return the best hexagon found by the analyse
	local hightest = 0
	local hex = self.hex[1]
	
	for i = 1, table.getn(self.hexPoints), 1 do
		if hightest < self.hexPoints[i] then
			hightest = self.hexPoints[i]
			
			hex = self.hex[i]
		end
	end
	
	return hex
end

function AI:startTurn()
	self:analyzeBoard()
	
	if not (self.cancelAnalysis) then
		-- if the move was not undone, the bot make his move
		local hex = self:selectMove()
		
		turn:performTurn(hex)
	else
		self.cancelAnalysis = false
	end
	
	turn.myTurn = true
end

function AI:showPoints()
	-- debug function
	local font = MOAIFont.new ()
	font:loadFromTTF("font/NotoSans-Regular.ttf", 25)
	
	for i = 1, table.getn(self.texts), 1 do
		window.interface.layer:removeProp(self.texts[i])
	end
	
	self.texts = {}
	
	for i = 1, table.getn(self.hex), 1 do
		local hex = self.hex[i]
	
		textbox = MOAITextBox.new ()
		textbox:setRect(-0.5 * window.resolution.x, -0.5 * window.resolution.y, 0.5 * window.resolution.x, 0.5 * window.resolution.y)
		textbox:setLoc(hex.pos.x, hex.pos.y)
		textbox:setFont(font)
		textbox:setYFlip(true)
		window.interface.layer:insertProp(textbox)
		changePriority(textbox, "interface")

		textbox:setString("" .. self.hexPoints[i])
		textbox:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
		textbox:setColor(0, 1, 0, 1)
		
		table.insert(self.texts, textbox)
	end
end

function AI:showAnalysisDuration(duration)
	-- debug function
	local font = MOAIFont.new ()
	font:loadFromTTF("font/NotoSans-Regular.ttf", 25)
	
	if self.duration ~= nil then
		window.interface.layer:removeProp(self.duration)
	end
	
	self.duration = {}
	
	textbox = MOAITextBox.new ()
	textbox:setRect(-0.5 * window.resolution.x, -0.5 * window.resolution.y, 0.5 * window.resolution.x, 0.5 * window.resolution.y)
	textbox:setLoc(0, 0)
	textbox:setFont(font)
	textbox:setYFlip(true)
	window.interface.layer:insertProp(textbox)
	changePriority(textbox, "interface")
	
	textbox:setString(string.format("duration: %.2f\n", duration))
	
	textbox:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.RIGHT_JUSTIFY)
	textbox:setColor(1, 0, 1, 1)
	
	self.duration = textbox
end