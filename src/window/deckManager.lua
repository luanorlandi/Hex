DeckManager = {}
DeckManager.__index = DeckManager

-- manage the deck size and fonts
-- related to the window size

function DeckManager:new()
	local D = {}
	setmetatable(D, DeckManager)
	
	-- indicate which decks must be resized
	D.intro = false
	D.game = false
	
	-- intro decks
	D.deckLua = MOAIGfxQuad2D.new()
	D.deckLua:setTexture("texture/logo/lua.png")
	
	D.deckMOAI = MOAIGfxQuad2D.new()
	D.deckMOAI:setTexture("texture/logo/moai.png")
	
	D.whiteScreen = MOAIGfxQuad2D.new()
	D.whiteScreen:setTexture("texture/effect/whitescreen.png")
	
	-- background art, hexagons and lane
	D.boardBackground = MOAIGfxQuad2D.new()
	D.boardBackground:setTexture("texture/background/gameBackground.png")
	
	D.hexagon = MOAIGfxQuad2D.new()
	D.hexagon:setTexture("texture/board/hexagon.png")
	
	D.lane = MOAIGfxQuad2D.new()
	D.lane:setTexture("texture/board/lane.png")
	
	D.menuBackground = MOAIGfxQuad2D.new()
	D.menuBackground:setTexture("texture/background/window.png")
	
	D.smallMenuBackground = MOAIGfxQuad2D.new()
	D.smallMenuBackground:setTexture("texture/background/smallWindow.png")
	
	D.buttonHighlight = MOAIGfxQuad2D.new()
	D.buttonHighlight:setTexture("texture/effect/buttonHighlight.png")
	
	-- buttons
	D.newGameButton = MOAIGfxQuad2D.new()
	D.newGameButton:setTexture("texture/interface/options.png")
	
	D.about = MOAIGfxQuad2D.new()
	D.about:setTexture("texture/interface/about.png")
	
	D.zoomIn = MOAIGfxQuad2D.new()
	D.zoomIn:setTexture("texture/interface/zoomIn.png")
	
	D.zoomOut = MOAIGfxQuad2D.new()
	D.zoomOut:setTexture("texture/interface/zoomOut.png")
	
	D.undo = MOAIGfxQuad2D.new()
	D.undo:setTexture("texture/interface/undo.png")
	
	D.redo = MOAIGfxQuad2D.new()
	D.redo:setTexture("texture/interface/redo.png")
	
	D.close = MOAIGfxQuad2D.new()
	D.close:setTexture("texture/interface/close.png")
	
	D.boardSize7 = MOAIGfxQuad2D.new()
	D.boardSize7:setTexture("texture/interface/7x7.png")
	
	D.boardSize9 = MOAIGfxQuad2D.new()
	D.boardSize9:setTexture("texture/interface/9x9.png")
	
	D.boardSize11 = MOAIGfxQuad2D.new()
	D.boardSize11:setTexture("texture/interface/11x11.png")
	
	D.humanVShuman = MOAIGfxQuad2D.new()
	D.humanVShuman:setTexture("texture/interface/human vs human.png")
	
	D.humanVSai = MOAIGfxQuad2D.new()
	D.humanVSai:setTexture("texture/interface/human vs AI.png")
	
	D.aiVShuman = MOAIGfxQuad2D.new()
	D.aiVShuman:setTexture("texture/interface/AI vs human.png")
	
	D.horizontal = MOAIGfxQuad2D.new()
	D.horizontal:setTexture("texture/interface/horizontal.png")
	
	D.vertical = MOAIGfxQuad2D.new()
	D.vertical:setTexture("texture/interface/vertical.png")
	
	D.startNewGame = MOAIGfxQuad2D.new()
	D.startNewGame:setTexture("texture/interface/startNewGame.png")
	
	-- fonts size
	D.smallFont = 20
	D.mediumFont = 28
	D.bigFont = 40
	
	--[[15 * window.scale
	20 * window.scale
	25 * window.scale]]
	
	-- fonts
	D.fontArial = MOAIFont.new ()
	D.fontArial:loadFromTTF("font/arial.ttf", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-ãõç", D.smallFont)
	
	D.fontZekton = MOAIFont.new()
	D.fontZekton:loadFromTTF("font/zekton free.ttf", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-ãõç", D.smallFont)
	
	return D
end

function DeckManager:resizeDecks()
	-- when the window size is altered, update deck sizes

	window.interface:reposition()
	
	if self.intro then
		self:resizeIntroDecks()
	end
	
	if self.game then
		self:resizeGameDecks()
	end
end

function DeckManager:resizeIntroDecks()
	self.deckLua:setRect(-window.scale * 200, -window.scale * 200,
						  window.scale * 200, window.scale * 200)
	
	self.deckMOAI:setRect(-window.scale * 250, -window.scale * 250,
						   window.scale * 250, window.scale * 250)
	
	self.whiteScreen:setRect(-window.resolution.x/2, -window.resolution.y/2,
							  window.resolution.x/2,  window.resolution.y/2)
end

function DeckManager:resizeGameDecks()
	-- board background
	self.boardBackground:setRect(-window.resolution.x/2, -window.resolution.y/2,
								  window.resolution.x/2,  window.resolution.y/2)
	
	-- board hexagons
	if board ~= nil then
		board:moveHexagons()
		self.hexagon:setRect(-board.hexagonSize.x/2, -board.hexagonSize.y/2,
							  board.hexagonSize.x/2,  board.hexagonSize.y/2)
	
	-- player lanes
	self.lane:setRect(-2 * window.resolution.x,-((board.size.y - 1) * 1.5) * (1 / 4 * board.hexagonSize.y),
					   2 * window.resolution.x, ((board.size.y - 1) * 1.5) * (1 / 4 * board.hexagonSize.y))
	end
	
	-- window menu
	self.menuBackground:setRect(-window.resolution.x/2, -window.resolution.y/2,
								  window.resolution.x/2,  window.resolution.y/2)
								  
	self.smallMenuBackground:setRect(-window.resolution.x/2, -window.resolution.y/2,
								  window.resolution.x/2,  window.resolution.y/2)
	
	-- game buttons
	if window.interface.gameInterface ~= nil then
		self.about:setRect(-window.interface.gameInterface.buttonSize.x, -window.interface.gameInterface.buttonSize.y,
							 window.interface.gameInterface.buttonSize.x,  window.interface.gameInterface.buttonSize.y)

		self.newGameButton:setRect(-window.interface.gameInterface.buttonSize.x, -window.interface.gameInterface.buttonSize.y,
							 window.interface.gameInterface.buttonSize.x,  window.interface.gameInterface.buttonSize.y)
			
		self.zoomIn:setRect(-window.interface.gameInterface.buttonSize.x, -window.interface.gameInterface.buttonSize.y,
							 window.interface.gameInterface.buttonSize.x,  window.interface.gameInterface.buttonSize.y)
							 
		self.zoomOut:setRect(-window.interface.gameInterface.buttonSize.x, -window.interface.gameInterface.buttonSize.y,
							 window.interface.gameInterface.buttonSize.x,  window.interface.gameInterface.buttonSize.y)
		
		self.undo:setRect(-window.interface.gameInterface.buttonSize.x, -window.interface.gameInterface.buttonSize.y,
						   window.interface.gameInterface.buttonSize.x,  window.interface.gameInterface.buttonSize.y)
		
		self.redo:setRect(-window.interface.gameInterface.buttonSize.x, -window.interface.gameInterface.buttonSize.y,
						   window.interface.gameInterface.buttonSize.x,  window.interface.gameInterface.buttonSize.y)
		
		-- menu buttons
		if window.interface.gameInterface.menu ~= nil then
			for i = 1, table.getn(window.interface.gameInterface.menu.buttons) do
				local size = window.interface.gameInterface.menu.buttonSize[i]
				local deck = window.interface.gameInterface.menu.buttonDeck[i]
				
				deck:setRect(-size.x * window.scale, -size.y * window.scale,
							  size.x * window.scale,  size.y * window.scale)
			end
			
			self.buttonHighlight:setRect(-window.interface.gameInterface.menu.highlightSize * window.scale,
										-window.interface.gameInterface.menu.highlightSize * window.scale,
										window.interface.gameInterface.menu.highlightSize * window.scale,
										window.interface.gameInterface.menu.highlightSize * window.scale)
		end
	end
end
