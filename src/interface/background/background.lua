Background = {}
Background.__index = Background

function Background:new(deck)
	local B = {}
	setmetatable(B, Background)
	
	B.sprite = MOAIProp2D.new()
	changePriority(B.sprite, "background")
	B.sprite:setDeck(deck)
	
	B.sprite:setLoc(0, 0)
	window.layer:insertProp(B.sprite)
	
	return B
end

function Background:clear()
	window.layer:removeProp(self.sprite)
end