Turn = {}
Turn.__index = Turn

function Turn:new(player1, player2, mode)
	local T = {}
	setmetatable(T, Turn)
	
	T.qty = 0
	
	T.currentPlayer = nil
	T.waitingPlayer = nil
	self.myTurn = nil			-- esse atributo so eh relevante contra bot
	
	if player1.myTurn == playerTurn["first"] then
		self.myTurn = true
		
		T.currentPlayer = player1
		T.waitingPlayer = player2
	else
		self.myTurn = false
		
		T.currentPlayer = player2
		T.waitingPlayer = player1
	end
	
	T.mode = mode
	
	T.undoTime = 2.3			-- tempo disponivel para desfazer a jogada
	T.inUndo = false			-- indica se eh possivel desfazer a jogada
	T.inRedo = false			-- indica se eh possivel refazer a jogada
	T.undoLastMove = nil		-- hexagono que era de destaque no ultimo movimento
	T.redoMove = nil			-- hexagono que sera a jogada de refazer
	
	return T
end

function Turn:makeMove(hex)
-- tenta realizar uma jogada
	
	-- se o jogo ainda nao acabou permite a jogada
	if not board.gameOver then
	
		-- para o jogo local, sempre ira fazer a jogada
		if self.mode == gameMode["local"] then
			self:performTurn(hex)
		else
		-- modo contra bot
			if self.myTurn then
				self:performTurn(hex)
				
				self.myTurn = false
				
				if not (board.gameOver) then
					local botTurnCoroutine = MOAICoroutine.new()
					botTurnCoroutine:run(startAIturn)
				end
			end
		end
	end
end

function Turn:performTurn(hex)
-- realiza o turno
	hex:setHex(self.currentPlayer.colorLastMove, self.currentPlayer.myPath)
	
	-- troca o ultimo hexagono selecionado
	if self.currentPlayer.lastMove ~= nil then
		self.currentPlayer.lastMove:setHex(self.currentPlayer.color, self.currentPlayer.myPath)
	end
	
	self.undoLastMove = self.currentPlayer.lastMove
	self.currentPlayer.lastMove = hex
	
	-- seleciona a grade do jogador
	local grid = board.hexGrid[self.currentPlayer.myPath]
	grid:setElement(hex.row, hex.column)
	
	if not (grid:findPath()) then
		-- troca as faixas indicando a vez do outro jogador
		board.lane[self.currentPlayer.myPath]:blendOut()
		board.lane[self.waitingPlayer.myPath]:blendIn()
		
		self:change()
	else
		board.gameOver = true
		
		window.interface.gameInterface:openGameOverMenu(self.currentPlayer)
	end
end

function Turn:change()
	self.qty = self.qty + 1
	
	local tmp = self.currentPlayer
	self.currentPlayer = self.waitingPlayer
	self.waitingPlayer = tmp
	
	if self.mode == gameMode["local"] or self.myTurn then
	-- so deixa desfazer a jogada caso seja seu turno, ou um jogo local
	
		-- caso a jogada foi muito rapida e ainda eh possivel desfazer
		-- somente reseta o tempo do botao
		if self.inUndo then
			self.resetTimerUndo = true
		else
			self:allowUndo()
		end
	end
	
	if window.interface.gameInterface.currentUndo == "redo" and not (self.inRedo) then
		window.interface.gameInterface:swapUndoButton()
	end
end

function Turn:allowUndo()
	self.inUndo = true
	
	local turnUndoCoroutine = MOAICoroutine.new()
	turnUndoCoroutine:run(function ()
		window.interface.gameInterface.undoButton:setAvailable(true)
	
		local start = gameTime
		
		while gameTime < start + self.undoTime and (not board.gameOver) and
			window.interface.gameInterface.currentUndo == "undo" do
			
			coroutine.yield()
			
			-- se outra jogada for feita enquanto eh possivel desfazer
			-- eh resetado o tempo do botao
			if self.resetTimerUndo then
				start = gameTime
				
				self.resetTimerUndo = false
			end
		end
		
		-- se nao clickou no botao, desativa ele
		if not (gameTime < start + self.undoTime) or board.gameOver then
			window.interface.gameInterface.undoButton:setAvailable(false)
		end
		
		self.inUndo = false
	end)
end

function Turn:undoRedo()
	if window.interface.gameInterface.currentUndo == "undo" then
	
		-- desfaz a jogada e volta ao estado anterior
		self.qty = self.qty - 1
		
		local tmp = self.currentPlayer
		self.currentPlayer = self.waitingPlayer
		self.waitingPlayer = tmp
		
		board.lane[self.waitingPlayer.myPath]:blendOut()
		board.lane[self.currentPlayer.myPath]:blendIn()
		
		local grid = self.currentPlayer.myPath
		local lastMove = self.currentPlayer.lastMove
		
		-- desfaz na matriz e no grid
		board.hexGrid[grid]:resetElement(lastMove.row, lastMove.column)
		lastMove:resetHex()
		
		if self.undoLastMove ~= nil then
			-- volta o hexagono de destaque da jogada anterior
			self.undoLastMove:setHex(self.currentPlayer.colorLastMove, self.currentPlayer.myPath)
		end
		
		-- atribui a jogada desfeita como a possivel jogada para refazer
		self.redoMove = self.currentPlayer.lastMove
		
		-- atribui de jogada anterior como sendo a penultima
		self.currentPlayer.lastMove = self.undoLastMove
		
		self.myTurn = true
		
		-- cancela a jogada do bot, se houver
		if bot ~= nil then
			bot.cancelAnalysis = true
		end
	else
		self.inRedo = true
		
		-- refaz a jogada
		self:makeMove(self.redoMove)
		
		self.inRedo = false
	end
end

function startAIturn()
	bot:startTurn()
end