require "data/interface/background/background"
require "data/interface/game/gameInterface"
require "data/interface/button"

Interface = {}
Interface.__index = Interface

function Interface:new(viewport)
	local I = {}
	setmetatable(I, Interface)

	I.layer = MOAILayer2D.new()
	I.layer:setViewport(viewport)
	
	I.gameInterface = nil
	
	return I
end

function Interface:clear()
	if self.gameInterface ~= nil then
		self.gameInterface:clear()
	end
end

function Interface:enableRender()
	MOAIRenderMgr.pushRenderPass(self.layer)
end

function Interface:createGameInterface()
	self.gameInterface = GameInterface:new()
end

function Interface:reposition()
	if self.gameInterface ~= nil then
		self.gameInterface:reposition()
	end
end

function Interface:getButton(pos)
-- procura se ha um botao na interface na posicao "pos"
-- retorna ele ou nil caso nao encontrar
	local newPos = Vector:new(pos.x, -pos.y)
	local windowCorner = Vector:new(-window.resolution.x/2, window.resolution.y/2)		-- canto superior esquerdo
	
	newPos:sum(windowCorner)
	
	if self.gameInterface ~= nil then
		return self.gameInterface:getButton(newPos)
	end
end