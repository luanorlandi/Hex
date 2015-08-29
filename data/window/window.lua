require "data/interface/interface"

local ratio = 16 / 9

Window = {}
Window.__index = Window

function Window:new()
	local W = {}
	setmetatable(W, Window)
	
	local r = Vector:new(0, 0)
	
	r.x = MOAIEnvironment.horizontalResolution
	r.y = MOAIEnvironment.verticalResolution
	
	if r.x == nil or r.x == 0 or r.y == nil or r.y == 0 then
		-- se houver falha ao tentar ler o tamanho da tela, cria uma com tamanho padrao
	
		r = readResolutionFile()
	end
	
	if r.x / r.y < ratio then
		r.y = r.x / ratio
	else
		r.x = r.y * ratio
	end
	
	W.resolution = r
	
	W.scale = W.resolution.x / 1280
	
	MOAISim.openWindow("Hex", W.resolution.x, W.resolution.y)
	
	W.viewport = MOAIViewport.new()
	W.viewport:setSize(W.resolution.x, W.resolution.y)
	W.viewport:setScale(W.resolution.x, W.resolution.y)

	W.layer = MOAILayer2D.new()
	W.layer:setViewport(W.viewport)
	
	W.interface = Interface:new(W.viewport)
	
	W.camera = Camera:new(W.layer, W.scale)
	
	W.deckManager = DeckManager:new()

	MOAIRenderMgr.pushRenderPass(W.layer)
	W.interface:enableRender()
	
	MOAIEnvironment.setListener(MOAIEnvironment.EVENT_VALUE_CHANGED, onEventValueChanged)
	
	return W
end

function readResolutionFile()
	local file = io.open("file/resolutionDefault.lua", "r")
	
	local resolution = Vector:new(0, 0)
	
	if file ~= nil then
		resolution.x = tonumber(file:read())
		resolution.y = tonumber(file:read())
		
		io.close(file)
	end
	
	return resolution
end

function onEventValueChanged(key, value)
-- funcao callback, se o tamanho da janela mudar, ela eh chamada
	
	if value > 0 then
		--[[if key == "horizontalResolution" then
			window.resolution.x = value
		elseif key == "verticalResolution" then
			window.resolution.y = value
		end]]
		
		window.resolution.x = MOAIEnvironment.horizontalResolution
		window.resolution.y = MOAIEnvironment.verticalResolution
		
		if window.resolution.x / window.resolution.y < ratio then
			window.resolution.y = window.resolution.x / ratio
		else
			window.resolution.x = window.resolution.y * ratio
		end
		
		window.viewport:setSize(window.resolution.x, window.resolution.y)
		window.viewport:setScale(window.resolution.x, window.resolution.y)
		
		window.scale = window.resolution.x / 1280
		
		window.deckManager:resizeDecks()
		
		window.camera:calculateMinDistanceMove()
	end
end