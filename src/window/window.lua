require "interface/interface"

Window = {}
Window.__index = Window

function Window:new()
	local W = {}
	setmetatable(W, Window)
	
	W.ratio = 16 / 9

	-- try to read from a file
	local r = readResolutionFile()
	
	-- if was not possible, try to get from OS
	if r.x == nil or r.x == 0 or r.y == nil or r.y == 0 then
		r.x, r.y = MOAIGfxDevice.getViewSize()
		
		-- if was not possible, create a window with default resolution
		if r.x == nil or r.x == 0 or r.y == nil or r.y == 0 then
			r.x = 1280
			r.y = 720
		end
	end

	if r.x / r.y < W.ratio then
		r.y = r.x / W.ratio
	else
		r.x = r.y * W.ratio
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
	local path = locateSaveLocation()

	-- probably an unexpected host (like html)
	if path == nil then
		return nil
	end

	local file = io.open(path .. "/resolution.lua", "r")
	
	local resolution = Vector:new(0, 0)
	
	if file ~= nil then
		resolution.x = tonumber(file:read())
		resolution.y = tonumber(file:read())
		
		io.close(file)
	end
	
	return resolution
end

function writeResolutionFile(resolution)
	local path = locateSaveLocation()

	-- probably a unexpected host (like html)
	if path == nil then
		return nil
	end

	local file = io.open(path .. "/resolution.lua", "w")
	
	if file ~= nil then
		file:write(resolution.x .. "\n")
		file:write(resolution.y)
		
		io.close(file)
	end
end

function onEventValueChanged(key, value)
	-- callback function, if the window size change, call it
	
	if value > 0 then
		--[[if key == "horizontalResolution" then
			window.resolution.x = value
		elseif key == "verticalResolution" then
			window.resolution.y = value
		end]]
		
		window.resolution.x = MOAIEnvironment.horizontalResolution
		window.resolution.y = MOAIEnvironment.verticalResolution
		
		if window.resolution.x / window.resolution.y < window.ratio then
			window.resolution.y = window.resolution.x / window.ratio
		else
			window.resolution.x = window.resolution.y * window.ratio
		end
		
		window.viewport:setSize(window.resolution.x, window.resolution.y)
		window.viewport:setScale(window.resolution.x, window.resolution.y)
		
		window.scale = window.resolution.x / 1280
		
		window.deckManager:resizeDecks()
		
		window.camera:calculateMinDistanceMove()
	end
end

function showInfo()
	-- show a lot of information about the device
	print("appDisplayName", MOAIEnvironment.appDisplayName)
	print("appVersion", MOAIEnvironment.appVersion)
	print("cacheDirectory", MOAIEnvironment.cacheDirectory)
	print("carrierISOCountryCode", MOAIEnvironment.carrierISOCountryCode)
	print("carrierMobileCountryCode", MOAIEnvironment.carrierMobileCountryCode)
	print("carrierMobileNetworkCode", MOAIEnvironment.carrierMobileNetworkCode)
	print("carrierName", MOAIEnvironment.carrierName)
	print("connectionType", MOAIEnvironment.connectionType)
	print("countryCode", MOAIEnvironment.countryCode)
	print("cpuabi", MOAIEnvironment.cpuabi)
	print("devBrand", MOAIEnvironment.devBrand)
	print("devName", MOAIEnvironment.devName)
	print("devManufacturer", MOAIEnvironment.devManufacturer)
	print("devModel", MOAIEnvironment.devModel)
	print("devPlatform", MOAIEnvironment.devPlatform)
	print("devProduct", MOAIEnvironment.devProduct)
	print("documentDirectory", MOAIEnvironment.documentDirectory)
	print("iosRetinaDisplay", MOAIEnvironment.iosRetinaDisplay)
	print("languageCode", MOAIEnvironment.languageCode)
	print("numProcessors", MOAIEnvironment.numProcessors)
	print("osBrand", MOAIEnvironment.osBrand)
	print("osVersion", MOAIEnvironment.osVersion)
	print("resourceDirectory", MOAIEnvironment.resourceDirectory)
	print("windowDpi", MOAIEnvironment.windowDpi)
	print("verticalResolution", MOAIEnvironment.verticalResolution)
	print("horizontalResolution", MOAIEnvironment.horizontalResolution)
	print("udid", MOAIEnvironment.udid)
	print("openUdid", MOAIEnvironment.openUdid)
end