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
	
	-- objeto (botao ou hexagono) que esta selecionado no momento
	I.selection = nil
	
	-- flag que impede selecionar algo caso tenha pressionado num lugar vazio
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
	-- pressionado
		if not (self.pointerPressedCancel) then
		-- evita que selecione algo apartir no click/tap em uma posicao vazia
			if self.selection == nil then
			-- se nao houver nada selecionado, procura se pressionou em algo valido
				self.selection = window.interface:getButton(input.pointerPos)
				
				if self.selection == nil and
				window.interface.gameInterface.menu == nil and
				board ~= nil and not (window.camera:isInZoomAction()) then
					self.selection = board:getHexagon(input.pointerPos)
				end
				
				if self.selection ~= nil then
				-- se selecionou algo, entao mostra para o jogador
					self.selection:showSelect()
				else
				-- nao selecionou nada, entao cancela outras selecoes possiveis neste click/tap
					self.pointerPressedCancel = true
				end
			else
			-- se ja tem algo selecionado, verifica se manteve pressionado nele
				local selection
				
				selection = window.interface:getButton(input.pointerPos)
				
				if selection == nil and
				window.interface.gameInterface.menu == nil and
				board ~= nil and not (window.camera:isInZoomAction()) then
					selection = board:getHexagon(input.pointerPos)
				end
				
				if selection ~= self.selection then
				-- deseleciona o anterior, e seleciona o outro
					self.selection:showDeselect()
					self.selection = selection
					
					if self.selection ~= nil then
					-- se trocou por outra coisa, mostra ela selecionada
						self.selection:showSelect()
					end
				end
			end
		end
	else
	-- nao pressionado
		if self.selection ~= nil then
		-- se houver algo selecionado
			if self.selection.name == "hexagon" then
			-- eh um hexagono
				if self.selection.available then
					turn:makeMove(self.selection)
				end
			end
			
			if self.selection.name == "button" then
			-- eh um botao
				self.selection:doAction()
			end
			
			-- limpa o que foi selecionado
			self.selection:showDeselect()
			self.selection = nil
		end
		
		-- desativa a flag
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