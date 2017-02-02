deckLane = MOAIGfxQuad2D.new()

Lane = {}
Lane.__index = Lane

function Lane:new(path)
	-- "path" direcao da faixa
	
	local L = {}
	setmetatable(L, Lane)
	
	L.sprite = MOAIProp2D.new()
	changePriority(L.sprite, "background")
	L.sprite:setDeck(window.deckManager.lane)
	
	if path == victoryPath["vertical"] then
		L.sprite:setRot(123.7)
	end
	
	if path == player1.myPath then
		L.color = Color:new(player1.color:getColor())
	else
		L.color = Color:new(player2.color:getColor())
	end
	
	L.sprite:setColor(L.color:getColor())
	L.blendDuration = 0.5
	L.action = nil
	
	L.sprite:setLoc(0, 0)
	window.layer:insertProp(L.sprite)
	
	return L
end

function Lane:clear()
	window.layer:removeProp(self.sprite)
end

function Lane:blendIn()
	if self.action then
		self.action:stop()
	end
	
	self.action = self.sprite:seekColor(self.color.red,
										self.color.green,
										self.color.blue,
										self.color.alpha,
										self.blendDuration)
end

function Lane:blendOut()
	if self.action then
		self.action:stop()
	end
	
	self.action = self.sprite:seekColor(self.color.red,
										self.color.green,
										self.color.blue,
										0.5 * self.color.alpha,
										self.blendDuration)
end