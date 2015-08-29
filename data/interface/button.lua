Button = {}
Button.__index = Button

function Button:new(pos, area, type, deck, color, text, textSize)
-- "type" corresponde a uma string do que o botao deve fazer
-- se for um texto, "text" contem a string dele

	local B = {}
	setmetatable(B, Button)
	
	B.name = "button"
	B.selected = false
	
	B.type = type
	
	-- indica se eh possivel apertar nesse botao
	B.available = true
	
	-- define a cor do botao
	if color ~= nil then
		B.color = color
	else
		B.color = Color:new(1, 1, 1)
	end
	
	B.prop = nil					-- contem um sprite ou um text
	if text == nil then
		B:createSprite(deck)
	else
		B:createText(deck, text, textSize)	-- deck contem a fonte a ser usada
	end
	changePriority(B.prop, "interface")
	
	-- posicao central e area de hitbox do click/tap
	B.pos = pos
	B.area = area
	
	B.prop:setLoc(pos.x, pos.y)
	B.prop:setBlendMode(MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA)
	window.interface.layer:insertProp(B.prop)
	
	return B
end

function Button:clear()
	window.interface.layer:removeProp(self.prop)
end

function Button:createSprite(deck)
	self.prop = MOAIProp2D.new()
	self.prop:setDeck(deck)
end

function Button:changeDeck(deck)
	self.prop:setDeck(deck)
end

function Button:createText(font, text, size)
	self.prop = MOAITextBox.new()
	self.prop:setFont(font)
	self.prop:setString(text)
	self.prop:setTextSize(size)
	self.prop:setYFlip(true)
	self.prop:setRect(-window.resolution.x/2, -window.resolution.y/2, window.resolution.x/2, window.resolution.y/2)
	self.prop:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
	self.prop:setColor(self.color:getColor())
end

function Button:setPos(pos)
	self.pos = pos
	
	self.prop:setLoc(pos.x, pos.y)
end

function Button:setArea(area)
	self.area = Rectangle:new(area.center, area.size)
end

function Button:setAvailable(available)
	self.available = available
	
	if available then
		self.prop:setColor(self.color:getColor())
	else
		self.prop:setColor(1, 1, 1, 0.4)
	end
end

function Button:showSelect()
	if not (self.select) then
		self.select = true
		
		local r, g, b = self.color:getColor()
		self.prop:seekColor(0.5 * r, 0.5 * g, 0.5 * b, 1, 0)
	end
end

function Button:showDeselect()
	if self.select then
		self.select = false
		
		local r, g, b = self.color:getColor()
		self.prop:seekColor(r, g, b, 1, 0)
	end
end

function Button:checkSelect(pos)
	return self.area:pointInside(pos)
end

function Button:doAction()
	if self.type == "newGameButton" then
	
		window.interface.gameInterface:openNewGameMenu()
		
	elseif self.type == "howToPlay" then
	
		window.interface.gameInterface:openHowToPlayMenu()
		
	elseif self.type == "zoom" then
	
		window.camera:swapZoom()
		window.interface.gameInterface:swapZoomButton()
		
	elseif self.type == "undo" then
	
		turn:undoRedo()
		window.interface.gameInterface:swapUndoButton()
	
	elseif self.type == "close" then
		
		window.interface.gameInterface.menu:clear()
		window.interface.gameInterface.menu = nil
	
	-- acoes do menu de criar um novo jogo:-------------------------------------------
	elseif self.type == "7x7" then
	
		newGame.boardSize = Vector:new(7, 7)
		
		local pos = window.interface.gameInterface.posBoardSize7x7
		window.interface.gameInterface.menu:hightlightChangeOption(1, pos)
	
	elseif self.type == "9x9" then
	
		newGame.boardSize = Vector:new(9, 9)
		
		local pos = window.interface.gameInterface.posBoardSize9x9
		window.interface.gameInterface.menu:hightlightChangeOption(1, pos)
	
	elseif self.type == "11x11" then
	
		newGame.boardSize = Vector:new(11, 11)

		local pos = window.interface.gameInterface.posBoardSize11x11
		window.interface.gameInterface.menu:hightlightChangeOption(1, pos)
	
	elseif self.type == "humanVShuman" then
	
		newGame.mode = gameMode["local"]
		newGame.myPath = victoryPath["horizontal"]
		
		local pos = window.interface.gameInterface.posGameMode1
		window.interface.gameInterface.menu:hightlightChangeOption(2, pos)
	
	elseif self.type == "humanVSai" then
	-- jogador humano eh o azul, horizontal
		newGame.mode = gameMode["bot"]
		newGame.myPath = victoryPath["horizontal"]
		
		if newGame.startingPlayer == newGame.myPath then
			newGame.myTurn = playerTurn["first"]
		else
			newGame.myTurn = playerTurn["second"]
		end
		
		local pos = window.interface.gameInterface.posGameMode2
		window.interface.gameInterface.menu:hightlightChangeOption(2, pos)
	
	elseif self.type == "aiVShuman" then
	-- jogador humano eh o vermelho, vertical
		newGame.mode = gameMode["bot"]
		newGame.myPath = victoryPath["vertical"]
		
		if newGame.startingPlayer == newGame.myPath then
			newGame.myTurn = playerTurn["first"]
		else
			newGame.myTurn = playerTurn["second"]
		end
		
		local pos = window.interface.gameInterface.posGameMode3
		window.interface.gameInterface.menu:hightlightChangeOption(2, pos)
	
	elseif self.type == "horizontal" then
	
		newGame.startingPlayer = victoryPath["horizontal"]
		
		if newGame.startingPlayer == newGame.myPath then
			newGame.myTurn = playerTurn["first"]
		else
			newGame.myTurn = playerTurn["second"]
		end
		
		local pos = window.interface.gameInterface.posStartingPlayer1
		window.interface.gameInterface.menu:hightlightChangeOption(3, pos)
	
	elseif self.type == "vertical" then
	
		newGame.startingPlayer = victoryPath["vertical"]
		
		if newGame.startingPlayer == newGame.myPath then
			newGame.myTurn = playerTurn["first"]
		else
			newGame.myTurn = playerTurn["second"]
		end
		
		local pos = window.interface.gameInterface.posStartingPlayer2
		window.interface.gameInterface.menu:hightlightChangeOption(3, pos)
	
	elseif self.type == "startNewGame" then
	
		newGame:start()
		
	end
end