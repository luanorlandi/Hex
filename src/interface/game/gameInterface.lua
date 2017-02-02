require "interface/game/menu"

GameInterface = {}
GameInterface.__index = GameInterface

function GameInterface:new()
	local G = {}
	setmetatable(G, GameInterface)

	G.buttonSize = nil
	G.gapSize = nil
	G:calculateButtonsSize()
	
	G.textColor = Color:new(0.4, 0.4, 0.4)
	
	local pos, area = G:buttonPos(1)
	G.newGameButton = Button:new(pos, area, "newGameButton", window.deckManager.newGameButton)
	
	pos, area = G:buttonPos(2)
	G.howToPlay = Button:new(pos, area, "howToPlay", window.deckManager.howToPlay)
	
	pos, area = G:buttonPos(3)
	G.zoomButton = Button:new(pos, area, "zoom", window.deckManager.zoomIn)
	G.currentZoom = "in"					-- guarda qual eh a o botao atual do zoom
	
	pos, area = G:buttonPos(4)
	G.undoButton = Button:new(pos, area, "undo", window.deckManager.undo)
	G.undoButton:setAvailable(false)
	G.currentUndo = "undo"					-- guarda qual eh a o botao atual de undo ou redo
	
	-- janela de menu, se for nil indica que nao ha nenhuma aberta
	G.menu = nil
	
	-- posicoes dos botao de escolha de um novo jogo
	-- valores em relacao ao tamanho da janela,
	-- sendo 1 em x e y o canto de cima direito e 0 em e y o centro
	
	G.posBoardSize7x7 = Vector:new(-0.60, 0.40)
	G.posBoardSize9x9 = Vector:new(-0.15, 0.40)
	G.posBoardSize11x11 = Vector:new(0.30, 0.40)
	
	G.posGameMode1 = Vector:new(-0.60, -0.07)
	G.posGameMode2 = Vector:new(-0.15, -0.07)
	G.posGameMode3 = Vector:new(0.30, -0.07)
	
	G.posStartingPlayer1 = Vector:new(-0.60, -0.55)
	G.posStartingPlayer2 = Vector:new(-0.15, -0.55)
	
	G:calculateButtonsPos()
	
	return G
end

function GameInterface:clear()
	self.newGameButton:clear()
	self.howToPlay:clear()
	self.zoomButton:clear()
	self.undoButton:clear()
	
	if self.menu ~= nil then
		self.menu:clear()
	end
end

function GameInterface:calculateButtonsSize()
	self.buttonSize = Vector:new(30 * window.scale, 30 * window.scale)
	self.gapSize = 14 * window.scale
end

function GameInterface:buttonPos(n)
	-- determina a posicao e area do botao de acordo com o new
	-- quanto maior for, mais longe esta
	
	local pos = Vector:new(window.resolution.x/2 - self.gapSize - self.buttonSize.x,
						   window.resolution.y/2 - n * self.gapSize - (2 * n - 1) * self.buttonSize.y)
	local area = Rectangle:new(pos, self.buttonSize)
	
	return pos, area
end

function GameInterface:calculateButtonsPos()
	local pos, area = self:buttonPos(1)
	self.newGameButton:setPos(pos)
	self.newGameButton:setArea(area)
	
	pos, area = self:buttonPos(2)
	self.howToPlay:setPos(pos)
	self.howToPlay:setArea(area)
	
	pos, area = self:buttonPos(3)
	self.zoomButton:setPos(pos)
	self.zoomButton:setArea(area)
	
	pos, area = self:buttonPos(4)
	self.undoButton:setPos(pos)
	self.undoButton:setArea(area)
end

function GameInterface:reposition()
	self:calculateButtonsSize()
	self:calculateButtonsPos()
	
	if self.menu ~= nil then
		self.menu:reposition()
	end
end

function GameInterface:getButton(pos)
	if self.newGameButton.available and self.newGameButton:checkSelect(pos) then
		return self.newGameButton
		
	elseif self.howToPlay.available and self.howToPlay:checkSelect(pos) then
		return self.howToPlay
	
	elseif self.zoomButton.available and self.zoomButton:checkSelect(pos) then
		return self.zoomButton
	
	elseif self.undoButton.available and self.undoButton:checkSelect(pos) then
		return self.undoButton
		
	elseif self.menu ~= nil then
	-- caso tenha um menu, procura em cada um dos botoes do menu
		return self.menu:getButton(pos)
	end
end

function GameInterface:swapZoomButton()
-- troca o deck do zoomIn com zoomOut
	if self.currentZoom == "in" then
		self.zoomButton:changeDeck(window.deckManager.zoomOut)
		self.currentZoom = "out"
	else
		self.zoomButton:changeDeck(window.deckManager.zoomIn)
		self.currentZoom = "in"
	end
end

function GameInterface:swapUndoButton()
-- troca o deck do undo com redo
	if self.currentUndo == "undo" then
		self.undoButton:changeDeck(window.deckManager.redo)
		self.currentUndo = "redo"
	else
		self.undoButton:changeDeck(window.deckManager.undo)
		self.currentUndo = "undo"
	end
end

function GameInterface:openHowToPlayMenu()
	if self.menu ~= nil then
		if self.menu.type == menuType["howToPlay"] then
			-- se essa janela ja estava aberta, fecha ela apenas
			self.menu:clear()
			self.menu = nil
			
			return
		else
			self.menu:clear()
		end
	end
	
	-- janela do menu
	self.menu = Menu:new(menuType["howToPlay"])
	
	-- icone de fechar a janela
	local pos = Vector:new(0.78, 0.74)			-- proporcao em relacao a janela
	local size = Vector:new(25, 25)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "close", window.deckManager.close, size)
	
	-- texto de como jogar
	local rectBottomLeft = Vector:new(-0.39, -0.38)
	local rectTopRight = Vector:new(0.39, 0.38)
	pos = Vector:new(0, 0)
	size = window.deckManager.mediumFont
	
	local file = io.open("file/comoJogar.txt", "r")
	local text = file:read("*a")
	io.close(file)
	
	self.menu:newText(rectBottomLeft, rectTopRight, pos, size, text)
end

function GameInterface:openNewGameMenu()
	if self.menu ~= nil then
		if self.menu.type == menuType["newGame"] then
			-- se essa janela ja estava aberta, fecha ela apenas
			self.menu:clear()
			self.menu = nil
			
			return
		else
			self.menu:clear()
		end
	end
	
	self.menu = Menu:new(menuType["newGame"])
	
	-- icone de fechar a janela
	local pos = Vector:new(0.78, 0.74)			-- proporcao em relacao a janela
	local size = Vector:new(25, 25)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "close", window.deckManager.close, size)
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- texto de escolher as opcoes
	local rectBottomLeft = Vector:new(-0.39, -0.38)
	local rectTopRight = Vector:new(0.39, 0.38)
	pos = Vector:new(0, 0)
	size = window.deckManager.mediumFont
	
	local file = io.open("file/menuNovoJogo.txt", "r")
	local text = file:read("*a")
	io.close(file)
	
	self.menu:newText(rectBottomLeft, rectTopRight, pos, size, text)
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- quadrados de destaque para a opcao selecionada
	self.menu:newHighlight(Vector:new(1.0, 0.85))
	self.menu:newHighlight(Vector:new(1.0, 0.45))
	self.menu:newHighlight(Vector:new(1.1, 0.75))
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- texto de iniciar novo jogo
	local rectBottomLeft = Vector:new(-0.39, -0.38)
	local rectTopRight = Vector:new(0.39, 0.38)
	pos = Vector:new(0, 0)
	size = window.deckManager.mediumFont
	
	local file = io.open("file/iniciarNovoJogo.txt", "r")
	local text = file:read("*a")
	io.close(file)
	
	self.menu:newText(rectBottomLeft, rectTopRight, pos, size, text)
	self.menu.texts[table.getn(self.menu.texts)]:setAlignment(MOAITextBox.RIGHT_JUSTIFY, MOAITextBox.RIGHT_JUSTIFY)
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- icone do tabuleiro 7x7
	pos = self.posBoardSize7x7			-- proporcao em relacao a janela
	size = Vector:new(85, 85)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "7x7", window.deckManager.boardSize7, size)
	
	if newGame.boardSize.x == 7 then
		self.menu:hightlightChangeOption(1, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- icone do tabuleiro 9x9
	pos = self.posBoardSize9x9			-- proporcao em relacao a janela
	size = Vector:new(85, 85)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "9x9", window.deckManager.boardSize9, size)
	
	if newGame.boardSize.x == 9 then
		self.menu:hightlightChangeOption(1, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- icone do tabuleiro 11x11
	pos = self.posBoardSize11x11			-- proporcao em relacao a janela
	size = Vector:new(85, 85)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "11x11", window.deckManager.boardSize11, size)
	
	if newGame.boardSize.x == 11 then
		self.menu:hightlightChangeOption(1, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- icone de pessoa x pessoa
	pos = self.posGameMode1			-- proporcao em relacao a janela
	size = Vector:new(90, 45)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "humanVShuman", window.deckManager.humanVShuman, size)
	
	if newGame.mode == gameMode["local"] then
		self.menu:hightlightChangeOption(2, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- icone de pessoa x ia
	pos = self.posGameMode2			-- proporcao em relacao a janela
	size = Vector:new(90, 45)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "humanVSai", window.deckManager.humanVSai, size)
	
	if newGame.mode == gameMode["bot"] and newGame.myPath == victoryPath["horizontal"] then
		self.menu:hightlightChangeOption(2, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- icone de ai x pessoa
	pos = self.posGameMode3			-- proporcao em relacao a janela
	size = Vector:new(90, 45)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "aiVShuman", window.deckManager.aiVShuman, size)
	
	if newGame.mode == gameMode["bot"] and newGame.myPath == victoryPath["vertical"] then
		self.menu:hightlightChangeOption(2, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- icone de jogador na horizontal comeca no primeiro turno
	pos = self.posStartingPlayer1			-- proporcao em relacao a janela
	size = Vector:new(100, 100)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "horizontal", window.deckManager.horizontal, size)
	
	if newGame.startingPlayer == victoryPath["horizontal"] then
		self.menu:hightlightChangeOption(3, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- icone de jogador na vertical comeca no primeiro turno
	pos = self.posStartingPlayer2			-- proporcao em relacao a janela
	size = Vector:new(100, 100)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "vertical", window.deckManager.vertical, size)
	
	if newGame.startingPlayer == victoryPath["vertical"] then
		self.menu:hightlightChangeOption(3, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- icone de iniciar um novo jogo
	local pos = Vector:new(0.63, -0.5)			-- proporcao em relacao a janela
	local size = Vector:new(45, 45)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "startNewGame", window.deckManager.startNewGame, size)
end

function GameInterface:openGameOverMenu(winner)
-- "winner" jogador que venceu a partida

	if self.menu ~= nil then
		self.menu:clear()
		self.menu = nil
	end
	
	self.menu = Menu:new(menuType["gameOver"])
	
	-- icone de fechar a janela
	local pos = Vector:new(0.30, 0.26)			-- proporcao em relacao a janela
	local size = Vector:new(25, 25)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "close", window.deckManager.close, size)
	
	-- texto de como jogar
	local rectBottomLeft = Vector:new(-0.16, -0.12)
	local rectTopRight = Vector:new(0.16, 0.12)
	pos = Vector:new(0, 0)
	size = window.deckManager.bigFont
	
	local file = io.open("file/gameOver.txt", "r")
	local text = file:read("*l")
	
	if winner.myPath == victoryPath["vertical"] then
		-- se foi o vermelho/vertical que venceu, le a proxima linha
		
		text = file:read("*l")
	end
	
	io.close(file)
	
	self.menu:newText(rectBottomLeft, rectTopRight, pos, size, text)
	self.menu.texts[table.getn(self.menu.texts)]:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
end