Camera = {}
Camera.__index = Camera

function Camera:new(layer, scale)
	local C = {}
	setmetatable(C, Camera)
	
	C.camera = MOAICamera2D:new()
	C.layer = layer
	
	layer:setCamera(C.camera)
	
	-- amplia em 2x
	C.zoom = 0.5
	C.zoomDuration = 0.5
	C.zoomAction = nil
	C.zoomStatus = "out"
	
	-- habilidade ou desabilita o movimento da camera
	C.movement = false
	
	-- auxilia para indicar se deve pegar as posicoes do pointerPos
	-- ou realizar o movimento
	C.movePressed = false
	
	-- auxilia indicando a posicao inicial do movimento
	C.moveStartPos = nil
	
	-- posicao inicial do movimenta dentro da camera
	C.moveStartPosCam = nil
	
	C.minDistanceMove = nil
	C:calculateMinDistanceMove(scale)
	
	C.minDistanceAchieved = false
	
	-- define o tipo de suavidez da animacao
	C.actionEaseType = MOAIEaseType.SOFT_SMOOTH
	
	return C
end

function Camera:zoomIn()
	self.zoomAction = self.camera:moveScl(-self.zoom, -self.zoom, self.zoomDuration, self.actionEaseType)
	self.zoomStatus = "in"
end

function Camera:zoomOut()
	self.zoomAction = self.camera:moveScl(self.zoom, self.zoom, self.zoomDuration, self.actionEaseType)
	self.camera:seekLoc(0, 0, self.zoomDuration, self.actionEaseType)
	self.zoomStatus = "out"
end

function Camera:swapZoom()
-- alterna entre zoom in e zoom out
	if self.zoomStatus == "out" then
		self:zoomIn()
		self:enableMovement()
	else
		self:zoomOut()
		self:disableMovement()
	end
end

function Camera:isInZoomAction()
	if self.zoomAction ~= nil then
		return not (self.zoomAction:isDone())
	else
		return false
	end
end

function Camera:move()
	-- realiza o movimento da camera pelo click/tap
	if self.movement and input.pointerPressed then
		if not (self.movePressed) then
			-- posicao inicial da camera
			local start = Vector:new(self.camera:getLoc())
			
			-- posicao inicial do movimento em relacao a camera, com origem no centro
			self.moveStartPosCam = Vector:new(input.pointerPos.x - window.resolution.x/2 + start.x,
											 -input.pointerPos.y + window.resolution.y/2 + start.y)
											 
			-- posicao inicial do movimento, com origem no centro
			self.moveStartPos = Vector:new(input.pointerPos.x - window.resolution.x/2,
										  -input.pointerPos.y + window.resolution.y/2)
										  
			self.movePressed = true
		else
			local circle = Circle:new(self.moveStartPos, self.minDistanceMove)
			
			local newPos = Vector:new(input.pointerPos.x - window.resolution.x/2,
									 -input.pointerPos.y + window.resolution.y/2)
			
			if self.minDistanceAchieved or not (circle:pointInside(newPos)) then
				self.minDistanceAchieved = true
				
				self.camera:setLoc(self:calculateNewPos())
			end
		end
	else
		self.movePressed = false
		self.minDistanceAchieved = false
	end
end

function Camera:calculateNewPos()
	-- posicao atual do pointer pela origem no centro
	local newPos = Vector:new( input.pointerPos.x - window.resolution.x/2,
							  -input.pointerPos.y + window.resolution.y/2)
	
	local newCameraPos = Vector:new(self.zoom * (-newPos.x) + self.moveStartPosCam.x - self.zoom * self.moveStartPos.x,
									self.zoom * (-newPos.y) + self.moveStartPosCam.y - self.zoom * self.moveStartPos.y)
	-- Movimento sem Zoom:   self.camera:setLoc(-newPos.x + self.moveStartPosCam.x, -newPos.y + self.moveStartPosCam.y)
	
	if newCameraPos.x < -window.resolution.x/4 then
		newCameraPos.x = -window.resolution.x/4
		self.movePressed = false
	end
	
	if newCameraPos.x > window.resolution.x/4 then
		newCameraPos.x = window.resolution.x/4
		self.movePressed = false
	end
	
	if newCameraPos.y < -window.resolution.y/4 then
		newCameraPos.y = -window.resolution.y/4
		self.movePressed = false
	end
	
	if newCameraPos.y > window.resolution.y/4 then
		newCameraPos.y = window.resolution.y/4
		self.movePressed = false
	end

	return newCameraPos.x, newCameraPos.y
end

function Camera:enableMovement()
	self.movement = true
end

function Camera:disableMovement()
	self.movement = false
end

function Camera:isInMovement()
	return self.minDistanceAchieved
end

function Camera:calculateMinDistanceMove(scale)
	if window ~= nil then
		self.minDistanceMove = 20 * window.scale
	else
		self.minDistanceMove = 20 * scale
	end
end

function Camera:getPosition()
	local pos = Vector:new(self.camera:getLoc())
	
	return pos
end