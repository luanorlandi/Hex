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
	G.about = Button:new(pos, area, "about", window.deckManager.about)
	
	pos, area = G:buttonPos(2)
	G.newGameButton = Button:new(pos, area, "newGameButton", window.deckManager.newGameButton)
	
	pos, area = G:buttonPos(3)
	G.zoomButton = Button:new(pos, area, "zoom", window.deckManager.zoomIn)
	G.currentZoom = "in"					-- save which zoom button currently is
	
	pos, area = G:buttonPos(4)
	G.undoButton = Button:new(pos, area, "undo", window.deckManager.undo)
	G.undoButton:setAvailable(false)
	G.currentUndo = "undo"					-- save which undo/redo button currently is
	
	-- menu window, if it's nil, there is none open
	G.menu = nil
	
	-- positions of buttons in new game
	-- values related to screen size,
	-- (1, 1) is the top right corner, (0, 0) the center

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
	self.about:clear()
	self.zoomButton:clear()
	self.undoButton:clear()
	
	if self.menu ~= nil then
		self.menu:clear()
	end
end

function GameInterface:calculateButtonsSize()
	local unit = window.scale

	if unit > 1 then
		unit = 1
	end

	self.buttonSize = Vector:new(30 * unit, 30 * unit)
	self.gapSize = 15 * unit
end

function GameInterface:buttonPos(n)
	-- determinate the position and button area for "n" value
	
	local pos = Vector:new(window.resolution.x/2 - self.gapSize - self.buttonSize.x,
						   window.resolution.y/2 - n * self.gapSize - (2 * n - 1) * self.buttonSize.y)
	local area = Rectangle:new(pos, self.buttonSize)
	
	return pos, area
end

function GameInterface:calculateButtonsPos()
	pos, area = self:buttonPos(1)
	self.about:setPos(pos)
	self.about:setArea(area)

	local pos, area = self:buttonPos(2)
	self.newGameButton:setPos(pos)
	self.newGameButton:setArea(area)
	
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
		
	elseif self.about.available and self.about:checkSelect(pos) then
		return self.about
	
	elseif self.zoomButton.available and self.zoomButton:checkSelect(pos) then
		return self.zoomButton
	
	elseif self.undoButton.available and self.undoButton:checkSelect(pos) then
		return self.undoButton
		
	elseif self.menu ~= nil then
		-- if there is a menu, search for each of the buttons
		return self.menu:getButton(pos)
	end
end

function GameInterface:swapZoomButton()
	-- swap the deck of zoomIn to zoomOut
	if self.currentZoom == "in" then
		self.zoomButton:changeDeck(window.deckManager.zoomOut)
		self.currentZoom = "out"
	else
		self.zoomButton:changeDeck(window.deckManager.zoomIn)
		self.currentZoom = "in"
	end
end

function GameInterface:swapUndoButton()
	-- swap the deck of zoomOut to zoomIn
	if self.currentUndo == "undo" then
		self.undoButton:changeDeck(window.deckManager.redo)
		self.currentUndo = "redo"
	else
		self.undoButton:changeDeck(window.deckManager.undo)
		self.currentUndo = "undo"
	end
end

function GameInterface:openWelcome()
	if self.menu ~= nil then
		if self.menu.type == menuType["welcome"] then
			-- if the window was already open, close it
			self.menu:clear()
			self.menu = nil
			
			return
		else
			self.menu:clear()
		end
	end
	
	-- menu window
	self.menu = Menu:new(menuType["welcome"])
	
	-- button to close the window
	local pos = Vector:new(0.78, 0.74)			-- proporcao em relacao a janela
	local size = Vector:new(self.buttonSize.x, self.buttonSize.y)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "close", window.deckManager.close, size)
	
	-- text
	local rectBottomLeft = Vector:new(-0.39, -0.38)
	local rectTopRight = Vector:new(0.39, 0.38)
	pos = Vector:new(0, 0)
	size = window.deckManager.mediumFont
	
	self.menu:newText(rectBottomLeft, rectTopRight, pos, size, strings.welcome)
end

function GameInterface:openAbout()
	if(MOAIEnvironment.osBrand == "Windows") then

		os.execute("start " .. strings.url)

	elseif(MOAIEnvironment.osBrand == "Android") then

		if(MOAIBrowserAndroid.canOpenURL(strings.url)) then
			MOAIBrowserAndroid.openURL(strings.url)
		end

	end
end

function GameInterface:openNewGameMenu()
	if self.menu ~= nil then
		if self.menu.type == menuType["newGame"] then
			-- if the window was already open, close it
			self.menu:clear()
			self.menu = nil
			
			return
		else
			self.menu:clear()
		end
	end
	
	self.menu = Menu:new(menuType["newGame"])
	
	-- button to close the window
	local pos = Vector:new(0.78, 0.74)			-- related to window size
	local size = Vector:new(self.buttonSize.x, self.buttonSize.y)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "close", window.deckManager.close, size)
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- text describing the options
	local rectBottomLeft = Vector:new(-0.39, -0.38)
	local rectTopRight = Vector:new(0.39, 0.38)
	pos = Vector:new(0, 0)
	size = window.deckManager.mediumFont
	
	self.menu:newText(rectBottomLeft, rectTopRight, pos, size, strings.menu)
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- highlight square of the selected option
	self.menu:newHighlight(Vector:new(1.0, 0.85))
	self.menu:newHighlight(Vector:new(1.0, 0.45))
	self.menu:newHighlight(Vector:new(1.1, 0.75))
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- text to start new game
	local rectBottomLeft = Vector:new(-0.39, -0.38)
	local rectTopRight = Vector:new(0.39, 0.38)
	pos = Vector:new(0, 0)
	size = window.deckManager.mediumFont
	
	self.menu:newText(rectBottomLeft, rectTopRight, pos, size, strings.startGame)
	self.menu.texts[table.getn(self.menu.texts)]:setAlignment(MOAITextBox.RIGHT_JUSTIFY, MOAITextBox.RIGHT_JUSTIFY)
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- button of 7x7 board
	pos = self.posBoardSize7x7			-- related to window size
	size = Vector:new(85, 85)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "7x7", window.deckManager.boardSize7, size)
	
	if newGame.boardSize.x == 7 then
		self.menu:hightlightChangeOption(1, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- button of 9x9 board
	pos = self.posBoardSize9x9			-- related to window size
	size = Vector:new(85, 85)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "9x9", window.deckManager.boardSize9, size)
	
	if newGame.boardSize.x == 9 then
		self.menu:hightlightChangeOption(1, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- button of 11x11 board
	pos = self.posBoardSize11x11			-- related to window size
	size = Vector:new(85, 85)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "11x11", window.deckManager.boardSize11, size)
	
	if newGame.boardSize.x == 11 then
		self.menu:hightlightChangeOption(1, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- button human x human
	pos = self.posGameMode1			-- related to window size
	size = Vector:new(90, 45)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "humanVShuman", window.deckManager.humanVShuman, size)
	
	if newGame.mode == gameMode["local"] then
		self.menu:hightlightChangeOption(2, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- button human x ai
	pos = self.posGameMode2			-- related to window size
	size = Vector:new(90, 45)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "humanVSai", window.deckManager.humanVSai, size)
	
	if newGame.mode == gameMode["bot"] and newGame.myPath == victoryPath["horizontal"] then
		self.menu:hightlightChangeOption(2, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- button ai x human
	pos = self.posGameMode3			-- related to window size
	size = Vector:new(90, 45)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "aiVShuman", window.deckManager.aiVShuman, size)
	
	if newGame.mode == gameMode["bot"] and newGame.myPath == victoryPath["vertical"] then
		self.menu:hightlightChangeOption(2, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- button horizontal starting player
	pos = self.posStartingPlayer1			-- related to window size
	size = Vector:new(100, 100)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "horizontal", window.deckManager.horizontal, size)
	
	if newGame.startingPlayer == victoryPath["horizontal"] then
		self.menu:hightlightChangeOption(3, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- button vertical starting player
	pos = self.posStartingPlayer2			-- related to window size
	size = Vector:new(100, 100)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "vertical", window.deckManager.vertical, size)
	
	if newGame.startingPlayer == victoryPath["vertical"] then
		self.menu:hightlightChangeOption(3, pos)
	end
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- button start new game
	local pos = Vector:new(0.63, -0.5)			-- related to window size
	local size = Vector:new(50, 50)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "startNewGame", window.deckManager.startNewGame, size)
end

function GameInterface:openGameOverMenu(winner)
	-- "winner" player that won the match
	if self.menu ~= nil then
		self.menu:clear()
		self.menu = nil
	end
	
	self.menu = Menu:new(menuType["gameOver"])
	
	-- button close window
	local pos = Vector:new(0.30, 0.26)			-- related to window size
	local size = Vector:new(25, 25)
	local area = Rectangle:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							   Vector:new(size.x * window.scale, size.y * window.scale))
	
	self.menu:newButton(pos, area, "close", window.deckManager.close, size)
	
	-- text
	local rectBottomLeft = Vector:new(-0.16, -0.12)
	local rectTopRight = Vector:new(0.16, 0.12)
	pos = Vector:new(0, 0)
	size = window.deckManager.bigFont

	local text = strings.blueWins
	
	if winner.myPath == victoryPath["vertical"] then
		text = strings.redWins
	end

	self.menu:newText(rectBottomLeft, rectTopRight, pos, size, text)
	self.menu.texts[table.getn(self.menu.texts)]:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
end