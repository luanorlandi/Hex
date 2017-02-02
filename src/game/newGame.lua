NewGame = {}
NewGame.__index = NewGame

function NewGame:new()
	local N = {}
	setmetatable(N, NewGame)
	
	-- valores iniciais sao iguais ao da partida atual
	N.boardSize = Vector:new(board.size.x, board.size.y)
	N.player1name = tostring(player1.name)
	N.player2name = tostring(player2.name)
	
	N.mode = turn.mode
	N.myPath = player1.myPath
	N.myTurn = player1.myTurn
	
	if player1.myTurn == playerTurn["first"] then
		N.startingPlayer = player1.myPath
	else
		N.startingPlayer = player2.myPath
	end
	
	return N
end

function NewGame:start()
	board.active = false
	bot.cancelAnalysis = true
	
	coroutine.yield()
	
	if window.camera.zoomStatus == "in" then
		window.camera:swapZoom()
	end

	local gameLoop = GameLoop:new(self.boardSize, self.player1name,
			self.player2name, self.mode, self.myPath, self.myTurn)
	gameLoop:start()
end