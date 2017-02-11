require "math/vector"
require "input/keyboard"
require "input/mouse"
require "input/touch"

Input = {}
Input.__index = Input

function Input:new()
	I = {}
	setmetatable(I, Input)
	
	I.pointerPos = Vector:new(0, 0)
	I.pointerPressed = false
	
	-- object (button or haxagon) that is currently selected
	I.selection = nil
	
	-- flag that prevent selecting anything in case pressed in a empty space
	I.pointerPressedCancel = false
	
	return I
end

function Input:keyboardActive()
	if MOAIInputMgr.device.keyboard then
		MOAIInputMgr.device.keyboard:setCallback(onKeyboardEvent)
	end
end

function Input:mouseActive()
	if MOAIInputMgr.device.pointer then
		MOAIInputMgr.device.pointer:setCallback(onMouseMoveEvent)
		MOAIInputMgr.device.mouseLeft:setCallback(onMouseLeftEvent)
	end
end

function Input:touchActive()
	if MOAIInputMgr.device.touch then
		MOAIInputMgr.device.touch:setCallback(onTouchEvent)
	end
end

function Input:dealWithPointerPressed()
	if not (window.camera:isInMovement()) then
	
	if self.pointerPressed then
		if not (self.pointerPressedCancel) then
			-- avoid select anything from a click/tap in a empty space
			if self.selection == nil then
				-- if there is nothing selected, search for a press in something valid
				self.selection = window.interface:getButton(input.pointerPos)
				
				if self.selection == nil and
				window.interface.gameInterface.menu == nil and
				board ~= nil and not (window.camera:isInZoomAction()) then
					self.selection = board:getHexagon(input.pointerPos)
				end
				
				if self.selection ~= nil then
					-- if selected something, then show to the player
					self.selection:showSelect()
				else
					-- selected nothing, then cancel possible click/tap selections
					self.pointerPressedCancel = true
				end
			else
				-- if already has something selected, check if kept pressed in it
				local selection
				
				selection = window.interface:getButton(input.pointerPos)
				
				if selection == nil and
				window.interface.gameInterface.menu == nil and
				board ~= nil and not (window.camera:isInZoomAction()) then
					selection = board:getHexagon(input.pointerPos)
				end
				
				if selection ~= self.selection then
					-- unselect the previous, and select the other
					self.selection:showDeselect()
					self.selection = selection
					
					if self.selection ~= nil then
						-- if changed to something else, show it
						self.selection:showSelect()
					end
				end
			end
		end
	else
		-- didn't press it
		if self.selection ~= nil then
			-- check if there is something selected
			if self.selection.name == "hexagon" then
				-- is a hexagon
				if self.selection.available then
					turn:makeMove(self.selection)
				end
			end
			
			if self.selection.name == "button" then
				-- is a button
				self.selection:doAction()
			end
			
			-- clear what was selected
			self.selection:showDeselect()
			self.selection = nil
		end
		
		-- disable the flag
		self.pointerPressedCancel = false
	end
	
	else
		if self.selection ~= nil then
			self.selection:showDeselect()
		end
		
		self.selection = nil
		self.pointerPressedCancel = false
	end
end