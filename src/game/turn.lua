Turn = {}
Turn.__index = Turn

function Turn:new(player1, player2, mode)
	local T = {}
	setmetatable(T, Turn)
	
	T.qty = 0
	
	T.currentPlayer = nil
	T.waitingPlayer = nil
	self.myTurn = nil			-- this attribute is only relevant against bot
	
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
	
	T.undoTime = 2.3			-- time available to undo the move
	T.inUndo = false			-- indicate if it's possible to undo the move
	T.inRedo = false			-- indicate if it's possible to redo the move
	T.undoLastMove = nil		-- highlighted hexagon in the last turn
	T.redoMove = nil			-- hexagon that will be the redo move
	
	return T
end

function Turn:makeMove(hex)
	-- try to make a move
	
	-- if the game is not over, allow the move
	if not board.gameOver then
	
		-- for a local game, always make the move
		if self.mode == gameMode["local"] then
			self:performTurn(hex)
		else
			-- human vs AI mode
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
	hex:setHex(self.currentPlayer.colorLastMove, self.currentPlayer.myPath)
	
	-- swap the last hexagon selected
	if self.currentPlayer.lastMove ~= nil then
		self.currentPlayer.lastMove:setHex(self.currentPlayer.color, self.currentPlayer.myPath)
	end
	
	self.undoLastMove = self.currentPlayer.lastMove
	self.currentPlayer.lastMove = hex
	
	-- selected the player's grid
	local grid = board.hexGrid[self.currentPlayer.myPath]
	grid:setElement(hex.row, hex.column)
	
	if not (grid:findPath()) then
		-- swap the lanes indicating the other player's turn
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
		-- only allow undo the move if it's his turn, or local game
		
		-- if the move that was very fast and it's still possible to undo
		-- only reset button time
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
			
			-- if another move is done while it's still possible to undo
			-- reset button time
			if self.resetTimerUndo then
				start = gameTime
				
				self.resetTimerUndo = false
			end
		end
		
		-- if didn't click/tap the button, disable it
		if not (gameTime < start + self.undoTime) or board.gameOver then
			window.interface.gameInterface.undoButton:setAvailable(false)
		end
		
		self.inUndo = false
	end)
end

function Turn:undoRedo()
	if window.interface.gameInterface.currentUndo == "undo" then
	
		-- undo the move and return to previous state
		self.qty = self.qty - 1
		
		local tmp = self.currentPlayer
		self.currentPlayer = self.waitingPlayer
		self.waitingPlayer = tmp
		
		board.lane[self.waitingPlayer.myPath]:blendOut()
		board.lane[self.currentPlayer.myPath]:blendIn()
		
		local grid = self.currentPlayer.myPath
		local lastMove = self.currentPlayer.lastMove
		
		-- undo matrix and grid
		board.hexGrid[grid]:resetElement(lastMove.row, lastMove.column)
		lastMove:resetHex()
		
		if self.undoLastMove ~= nil then
			-- turn the highlighted hexagon of the previous move
			self.undoLastMove:setHex(self.currentPlayer.colorLastMove, self.currentPlayer.myPath)
		end
		
		-- assign the undone move as a possible redo
		self.redoMove = self.currentPlayer.lastMove
		
		-- assign the previous move as the penultimate
		self.currentPlayer.lastMove = self.undoLastMove
		
		self.myTurn = true
		
		-- cancel the move of bot, if any
		if bot ~= nil then
			bot.cancelAnalysis = true
		end
	else
		self.inRedo = true
		
		-- redo the move
		self:makeMove(self.redoMove)
		
		self.inRedo = false
	end
end

function startAIturn()
	bot:startTurn()
end