require "socket"

Client = {}
Client.__index = Client

function Client:new()
	local C = {}
	setmetatable(C, Client)
	
	C.socket = nil
	
	C.adress = nil
	C.port = nil
	
	return C
end

function Client:connect(adress, port)
	-- try to make a connection, return true for success
	if self.socket == nil then
		print("tentando conectar...")
		self.socket, errorMsg = socket.connect(adress, port)
		
		if self.socket ~= nil then
			print("cliente conectado!")
			self.port = port
			self.adress = adress
			
			return true
		else
			print("falha na conexao!")
			
			font = MOAIFont.new ()
			font:loadFromTTF("font/zekton free.ttf", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!'", 30)
			
			textbox = MOAITextBox.new ()
			textbox:setRect(-0.5 * window.resolution.x, -0.5 * window.resolution.y, 0.5 * window.resolution.x, 0.5 * window.resolution.y)
			textbox:setFont(font)
			textbox:setYFlip(true)
			window.interface.layer:insertProp(textbox)
			
			textbox:setString ("falha ao conectar: " .. errorMsg)
			textbox:setAlignment(MOAITextBox.RIGHT_JUSTIFY, MOAITextBox.RIGHT_JUSTIFY)
			textbox:setColor(0, 1, 0, 1)
			
			return false
		end
	else
		print("cliente ja esta conectado!")
		
		return true
	end
end

function Client:setTimeOut(number)
	self.socket:settimeout(number)
end

function Client:sendData(data)
	-- send "data" in socket
	if self.socket ~= nil then
		self.socket:send(data)
		print("dados enviados: ", data)
	else
		print("cliente nao esta conectado!")
	end
end

function Client:receiveData()
	-- return "data" from server

	if self.socket ~= nil then
		print("aguardando dados...")
		return self.socket:receive()
	else
		print("cliente nao esta conectado!")
		return nil
	end
end