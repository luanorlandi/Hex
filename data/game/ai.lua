require "data/pathfinding/boardPath"
require "data/sort/quickSort"

AI = {}
AI.__index = AI

function AI:new(myPath, opponentPath)
-- cria uma inteligencia articial
-- "myPath" horizontal ou vertical
	local A = {}
	setmetatable(A, AI)
	
	-- se o jogador desfazer a jogada eh ativado
	--  a flag, cancelando a analise do bot
	A.cancelAnalysis = false
	
	A.myPath = myPath
	
	-- auxiliares de analise, "hex" contem os hexagonos disponiveis analisados
	-- "hexPoints" contem a pontuacao atribuida para o hexagono
	A.hex = {}
	A.hexPoints = {}
	
	-- atributo que ajuda a calcular os pontos em proximidade do centro
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
	
	-- essa quantia limita o numero de dijkstra
	-- executa esse numero maximo de hexagonos que serao analisados usando dijkstra por turno
	A.qtyAnalysisBoardPath = 30				-- esse numero aumenta conforme o decorrer dos turnos
	
	-- valores iniciais para ajustar a prioridade de cada analise
	A.scoreMultiplierCenter = math.ceil((board.size.x + board.size.y) / 2)
	A.scoreMultiplierAdjacency = 0.2
	A.scoreMultiplierMyBoardPath = 0.4
	A.scoreMultiplierOpponentBoardPath = 0.5
	A.scoreMultiplierFavorablePath = 3
	
	A.scoreMultiplierAdvantage = 2				-- quem estiver ganhando recebe aumento de valor na analise
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
	
	-- se eh o bot quem inicia o primeiro turno, ativa o turno do bot
	if turn.mode == gameMode["bot"] and player2.myTurn == playerTurn["first"] then
		local botTurnCoroutine = MOAICoroutine.new()
		botTurnCoroutine:run(startAIturn)
	end
	
	return A
end

function AI:getBoardCenter()
-- retorna uma matriz dos hexagonos com valores mais altos perto do centro
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
-- analise a situacao no tabuleiro, atribuindo valores em hexPoints
-- valores altos indicam que o respectivo hexagono eh uma boa jogada pela analise

	--local start = os.clock()		-- inica contagem do tempo
	
	-- reseta os valores
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
	
	-- analise que valoriza as jogadas que reduzem
	-- o seu caminho minimo e aumenta o do oponente
	if not (self.cancelAnalysis) then
		self:analyzeBoardPath()
	end
	
	-- se a analise foi rapida e o jogador ainda pode desfazer a jogada
	-- ocorre o loop abaixo esperando que a jogada nao possa mais ser desfeita
	while turn.inUndo and not (self.cancelAnalysis) do
		coroutine.yield()
	end
	
	--local ending = os.clock()					-- finaliza contagem
	--self:showAnalysisDuration(ending - start)	-- mostra duracao a analise
	
	-- atualiza valorizacao em cada tipo de analise
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
	-- hexagonos adjacentes:
	local upperLeft =		board:getUpperLeftHexagon(hex)
	local upperRight =		board:getUpperRightHexagon(hex)
	local right =			board:getRightHexagon(hex)
	local bottomRight =		board:getBottomRightHexagon(hex)
	local bottomLeft =		board:getBottomLeftHexagon(hex)
	local left =			board:getLeftHexagon(hex)
	
	-- hexagonos adjacentes longes:
	local farUpperLeft =	board:getFarUpperLeftHexagon(hex)
	local farUpper =		board:getFarUpperHexagon(hex)
	local farUpperRight =	board:getFarUpperRightHexagon(hex)
	local farBottomRight =	board:getFarBottomRightHexagon(hex)
	local farBottom =		board:getFarBottomHexagon(hex)
	local farBottomLeft =	board:getFarBottomLeftHexagon(hex)
	
	local score = 0
	
	-- analisa cada adjacencia para o hexagono
	local tmpPoints = 0
	
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farUpperLeft, left, upperLeft)
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farUpperRight, upperRight, right)
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farBottomRight, right, bottomRight)
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farBottomLeft, bottomLeft, left)
	
	-- caso seja uma adjacencia mais favoravel a sua direcao horizontal, aumenta os pontos
	if self.myPath == victoryPath["horizontal"] then
		tmpPoints = self.scoreMultiplierFavorablePath * tmpPoints
	end
	
	score = score + tmpPoints
	
	tmpPoints = 0
	
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farUpper, upperLeft, upperRight)
	tmpPoints = tmpPoints + self:analyzeFarAdjacency(farBottom, bottomRight, bottomLeft)
	
	-- caso seja uma adjacencia mais favoravel a sua direcao vertical, aumenta os pontos
	if self.myPath == victoryPath["vertical"] then
		tmpPoints = self.scoreMultiplierFavorablePath * tmpPoints
	end
	
	score = score + tmpPoints
	
	return score
end

function AI:analyzeFarAdjacency(farHex, adjacentHex1, adjacentHex2)
	local score = 0
	
	if adjacentHex1 ~= nil then
	-- adjacente nao esta numa borda
		if adjacentHex1.hold ~= 0 then
		-- adjacente nao esta livre
			score = score + self.scoreAdderHexAdjacentNotFree
		end
	end
	
	if adjacentHex2 ~= nil then
	-- adjacente nao esta numa borda
		if adjacentHex2.hold ~= 0 then
		-- adjacente nao esta livre
			score = score + self.scoreAdderHexAdjacentNotFree
		end
	end
	
	if farHex == nil then
	-- adjacente distante esta numa borda
		score = score + self.scoreAdderFarAdjacentOnEdge
	else
	-- adjacente distante nao esta numa borda
		if farHex.hold ~= 0 then
		-- adjacente distante nao esta livre
			score = score + self.scoreAdderFarAdjacentNotFree
		end
	end
	
	return score
end

function AI:analyzeBoardPath()
	local qtyHexAnalyzing = table.getn(self.hex)
	
	if qtyHexAnalyzing > self.qtyAnalysisBoardPath then
		-- limita a analise executar somente em hexagonos que ja possuem os valores mais altos 
		
		quickSortTwoArrays(self.hexPoints, self.hex, 1, qtyHexAnalyzing)
		qtyHexAnalyzing = self.qtyAnalysisBoardPath
	end
	
	-- busca pelo seu melhor caminho atual
	local path, distance, pathLink = self.myBoardPath:searchBestPath()
	
	-- busca pelo melhor caminho atual do oponente
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
-- analisa o quanto melhora o caminho se o hexagono for selecionado
-- "hex" hexagono sendo avaliado
-- "path" caminho atual
-- "distance" distancia atual para completar o caminho
-- "pathLink" hexagonos que completam o caminho
	
	local score = 0
	
	if distance ~= nil then
	-- caso haja ao menos um hexagono do jogador ja colocado no tabuleiro, havera uma distancia
		if distance > 0 then
		-- o caminho nao esta completo, verifica o quanto diminui a distancia jogando na posicao de "hex"
			local newPath, newDistance, newPathLink = self.myBoardPath:calculateNewDistance(hex, path[1])
			
			if newDistance < self.myBoardPath.graph.infinity then
				if distance < self.myBoardPath.graph.infinity then
					-- se as duas distancias serem validas, calcula a pontuacao
					score = score + self.scoreMultiplierDistance * (self.myBoardSize - newDistance)
					score = score + self.scoreMultiplierDifferenceDistances * (distance - newDistance)
				else
					-- se a distancia inicial era infinita, e apos a jogada nao eh mais
					-- entao calcula de forma diferente a pontuacao
					score = score + self.scoreMultiplierDistance
				end
				
				local pathLinkDifference = table.getn(pathLink) - table.getn(newPathLink)
				score = score + self.scoreMultiplierLinkAmount * pathLinkDifference
			else
				-- senao desconsidera essa analise
				return 0
			end
			
			if distance > self.myBoardSize then
			-- caso a distance seja maior do que o proprio tabuleiro
			-- desvaloriza a analise, deixando a analise do outro jogador mais importante
			
				if distance - self.myBoardSize > 2 then
					score = math.floor(score / (distance - self.myBoardSize))
				end
			end
		else
		-- distance = 0, situacao em que o caminho esta quase completo
		-- valoriza os hexagonos que completam o caminho
		
			for i = 1, table.getn(pathLink), 1 do
				local hexLink = pathLink[i]
				
				if hex.row == hexLink.row and hex.column == hexLink.column then
					score = score + self.scoreAdderPathCompleteLink
				end
			end
		end
		
		if distance <= 1 then
		-- verifica se para o hexagono "hex" eh o unico que
		-- falta para completar o caminho totalmente
		-- evitando jogadas que prolongue a partida
			
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
-- analisa o quanto melhora o caminho do oponente se o hexagono fosse selecionado pelo oponente
-- "hex" hexagono sendo avaliado
-- "path" caminho atual
-- "distance" distancia atual para completar o caminho
-- "pathLink" hexagonos que completam o caminho
	
	local score = 0
	
	if distance ~= nil then
	-- caso haja ao menos um hexagono do jogador ja colocado no tabuleiro, havera uma distancia
		if distance > 0 then
		-- o caminho nao esta completo, verifica o quanto diminui a distancia jogando na posicao de "hex"
			local newPath, newDistance, newPathLink = self.opponentBoardPath:calculateNewDistance(hex, path[1])

			if newDistance < self.opponentBoardPath.graph.infinity then
				if distance < self.opponentBoardPath.graph.infinity then
					-- se as duas distancias serem validas, calcula a pontuacao
					score = score + self.scoreMultiplierDistance * (self.myBoardSize - newDistance)
					score = score + self.scoreMultiplierDifferenceDistances * (distance - newDistance)
				else
					-- se a distancia inicial era infinita, e apos a jogada nao eh mais
					-- entao calcula de forma diferente a pontuacao
					score = score + self.scoreMultiplierDistance
				end
				
				local pathLinkDifference = table.getn(pathLink) - table.getn(newPathLink)
				score = score + self.scoreMultiplierLinkAmount * pathLinkDifference
			
			else
				-- senao desconsidera essa analise
				return 0
			end
			
			if distance > self.myBoardSize then
			-- caso a distance seja maior do que o proprio tabuleiro
			-- desvaloriza a analise, deixando a analise do outro jogador mais importante
			
				if distance - self.myBoardSize > 2 then
					score = math.floor(score / (distance - self.myBoardSize))
				end
			end
		end
		-- caso a distancia ja ser 0, entao nao ha como impedir o oponente de completar o caminho
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
-- retorna um hexagono de melhor jogada analisada
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
	-- se nao foi desfeita a jogada do jogador, o bot faz sua jogada
		local hex = self:selectMove()
		
		turn:performTurn(hex)
	else
		self.cancelAnalysis = false
	end
	
	turn.myTurn = true
end

function AI:showPoints()
-- funcao para debug
	local font = MOAIFont.new ()
	font:loadFromTTF("font/zekton free.ttf", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!'", 25)
	
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
-- funcao para debug
	local font = MOAIFont.new ()
	font:loadFromTTF("font/zekton free.ttf", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!'.", 25)
	
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