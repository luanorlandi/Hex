Menu = {}
Menu.__index = Menu

menuType = {
	["newGame"] = 1,
	["welcome"] = 2,
	["gameOver"] = 3,
}

function Menu:new(type)
-- "menuType" is which menu: welcome, newGame
	local M = {}
	setmetatable(M, Menu)
	
	M.type = type
	
	-- desenho da janela de fundo
	M.background = MOAIProp2D.new()
	changePriority(M.background, "interface")
	
	if not (type == menuType["gameOver"]) then
		M.background:setDeck(window.deckManager.menuBackground)
	else
		-- if game over menu, create a smaller window
		M.background:setDeck(window.deckManager.smallMenuBackground)
	end
	
	M.background:setLoc(0, 0)
	window.interface.layer:insertProp(M.background)
	
	-- tables that has all texts and buttons on window
	M.texts = {}
	M.textRect = {}
	M.textSize = {}
	
	M.buttons = {}
	M.buttonDeck = {}
	M.buttonSize = {}
	M.buttonPos = {}
	
	-- buttons highlight
	M.highlights = {}
	M.highlightPos = {}
	M.highlightSize = Vector:new(100, 100)			-- 100 * window.scale
	M.highlightDeck = window.deckManager.buttonHighlight
	M.highlightAlpha = 0.4
	
	M.hexLogoSize = Vector:new(156, 75)

	return M
end

function Menu:clear()
	window.interface.layer:removeProp(self.background)
	
	while table.getn(self.texts) > 0 do
		window.interface.layer:removeProp(self.texts[1])
		table.remove(self.texts, 1)
	end
	
	while table.getn(self.buttons) > 0 do
		self.buttons[1]:clear()
		table.remove(self.buttons, 1)
	end
	
	while table.getn(self.highlights) > 0 do
		window.interface.layer:removeProp(self.highlights[1])
		table.remove(self.highlights, 1)
	end
end

function Menu:reposition()
	for i = 1, table.getn(self.texts) do
		self.texts[i]:setRect(
			(self.textRect[i].center.x - self.textRect[i].size.x) * window.resolution.x,
			(self.textRect[i].center.y - self.textRect[i].size.y) * window.resolution.y,
			(self.textRect[i].center.x + self.textRect[i].size.x) * window.resolution.x,
			(self.textRect[i].center.y + self.textRect[i].size.y) * window.resolution.y)
		
		self.texts[i]:setTextSize(self.textSize[i] * window.scale)
	end
	
	for i = 1, table.getn(self.buttons) do
		local size = Vector:new(self.buttonSize[i].x * window.scale,
								self.buttonSize[i].y * window.scale)
		
		local pos = Vector:new(self.buttonPos[i].x * window.resolution.x/2,
							   self.buttonPos[i].y * window.resolution.y/2)
							   
		local area = Rectangle:new(pos, size)
		
		self.buttons[i]:setPos(pos)
		self.buttons[i]:setArea(area)
	end
	
	for i = 1, table.getn(self.highlights) do
		local pos = self.highlightPos[i]
		self.highlights[i]:setLoc(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2)
	end
end

function Menu:getButton(pos)
	for i = 1, table.getn(self.buttons) do
		if self.buttons[i].available and self.buttons[i]:checkSelect(pos) then
			return self.buttons[i]
		end
	end
end

function Menu:newText(rect, textSize, text)
	-- create a text inside the window
	-- rectBottomLeft is the bottom left corner of the text
	-- rectTopRight is the top right corner of the text
	
	textbox = MOAITextBox.new()

	textbox:setRect(
		(rect.center.x - rect.size.x) * window.resolution.x,
		(rect.center.y - rect.size.y) * window.resolution.y,
		(rect.center.x + rect.size.x) * window.resolution.x,
		(rect.center.y + rect.size.y) * window.resolution.y)

	textbox:setTextSize(textSize * window.scale)
	
	textbox:setFont(window.deckManager.fontZekton)
	textbox:setYFlip(true)
	window.interface.layer:insertProp(textbox)
	changePriority(textbox, "interface")
	
	textbox:setString(text)
	
	textbox:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
	textbox:setColor(0, 0, 0, 1)
	
	table.insert(self.texts, textbox)
	
	table.insert(self.textRect, rect:copy())
	table.insert(self.textSize, textSize)
end

function Menu:newButton(pos, area, type, deck, size, color)
	deck:setRect(-size.x * window.scale, -size.y * window.scale,
				  size.x * window.scale,  size.y * window.scale)

	local button = Button:new(Vector:new(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2),
							  area, type, deck, color)
	
	table.insert(self.buttons, button)
	table.insert(self.buttonDeck, deck)
	table.insert(self.buttonSize, size)
	table.insert(self.buttonPos, pos)
end

function Menu:newHighlight(size)
	self.highlightDeck:setRect(-self.highlightSize.x * window.scale, -self.highlightSize.y * window.scale,
								self.highlightSize.x * window.scale,  self.highlightSize.y * window.scale)
	
	local highlight = MOAIProp2D.new()
	changePriority(highlight, "interface")
	highlight:setDeck(self.highlightDeck)
	
	-- adjust the size
	highlight:setScl(size.x, size.y)
	
	-- put an alpha
	highlight:setColor(1, 1, 1, self.highlightAlpha)
	
	window.interface.layer:insertProp(highlight)
	
	table.insert(self.highlights, highlight)
	table.insert(self.highlightPos, Vector:new(0, 0))
end

function Menu:hightlightChangeOption(highlight, pos)
	-- "highlight" is the index in array self.highlights
	self.highlightPos[highlight] = Vector:new(pos.x, pos.y)

	self.highlights[highlight]:setLoc(pos.x * window.resolution.x/2, pos.y * window.resolution.y/2)
end