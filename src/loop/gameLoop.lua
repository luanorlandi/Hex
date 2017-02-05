require "effect/color"
require "game/board"
require "game/turn"
require "game/player"

require "game/ai"

require "game/newGame"

gameMode = {
	["local"] = 1,
	["bot"] = 2,
	["online"] = 3,
}

victoryPath = {
	["horizontal"] = 1,
	["vertical"] = 2,
}

playerTurn = {
	["first"] = 1,
	["second"] = 2,
}

GameLoop = {}
GameLoop.__index = GameLoop

function GameLoop:new(boardSize, player1name, player2name, mode, myPath, myTurn)
-- gerencia as definições da partida
-- "boardSize" tamanho do tabuleiro, padrao 11x11
-- "mode" modo de jogo: local, online ou bot
-- "myPath" fazer caminho na horizontal ou vertical para ganhar
-- "myTurn" joga no primeiro ou no segundo turno

-- "my" eh relacao ao jogador 1, "opponent" em relacao ao 2, podendo este ser um bot

	local G = {}
	setmetatable(G, GameLoop)
	
	G.mode = mode
	
	G.boardSize = boardSize
	
	G.player1name = player1name
	G.player2name = player2name
	
	G.myPath = myPath
	G.myTurn = myTurn
	
	G.opponentPath = nil
	G.opponentTurn = nil
	
	if myPath == victoryPath["horizontal"] then
		G.opponentPath = victoryPath["vertical"]
	else
		G.opponentPath = victoryPath["horizontal"]
	end
	
	if myTurn == playerTurn["first"] then
		G.opponentTurn = playerTurn["second"]
	else
		G.opponentTurn = playerTurn["first"]
	end
	
	return G
end

function GameLoop:start()
	local gameCoroutine = MOAICoroutine.new()
	gameCoroutine:run(function ()
		player1 = Player:new(self.player1name, self.myPath, self.myTurn)
		player2 = Player:new(self.player2name, self.opponentPath, self.opponentTurn)
		
		turn = Turn:new(player1, player2, self.mode)
		
		board = Board:new(self.boardSize)
		
		board.lane[turn.waitingPlayer.myPath]:blendOut()
		
		window.interface:createGameInterface()

		bot = AI:new(player2.myPath, player1.myPath)
		
		newGame = NewGame:new()
		
		window.deckManager.game = true
		window.deckManager:resizeDecks()
		
		while board.active == true do
			coroutine.yield()
			input:dealWithPointerPressed()
			
			window.camera:move()
		end
		
		board:clear()
		window.interface.gameInterface:clear()
		
		window.deckManager.game = false
	end)
end