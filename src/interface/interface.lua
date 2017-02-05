require "interface/background/background"
require "interface/game/gameInterface"
require "interface/button"

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

	if (not firstGame) and self:welcomeDisplay() then
		firstGame = true
		self.gameInterface:openWelcome()
	end
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

function Interface:welcomeDisplay()
	-- return true or false if should display the welcome window

	local path = locateSaveLocation()

	-- probably a unexpected host (like html)
	if path == nil then
		return true
	end

	local file = io.open(path .. "/welcome.lua", "r")
	local v = nil

	if file ~= nil then
		v = file:read()
		io.close(file)
	end

	if v == nil or v ~= version then
		-- overwrite game version
		file = io.open(path .. "/welcome.lua", "w")
		file:write(version)
		io.close(file)

		return true
	end

	return false
end