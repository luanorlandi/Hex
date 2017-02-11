require "socket"

Server = {}
Server.__index = Server

function Server:new()
	local S = {}
	setmetatable(S, Server)
	
	S.port = nil
	
	S.socket = nil
	
	-- a client that will connect
	S.clientSocket = nil
	S.clientName = nil
	
	return S
end

function Server:open(port)
	print("abrindo servidor...")
	
	local errorMsg
	self.socket, errorMsg = socket.bind("*", port)
	
	if self.socket ~= nil then
		self.port = port
		print("servidor aberto na porta:", self.port)
		
		return true
	else
		print("falha ao abrir o servidor: " .. errorMsg)
		
		font = MOAIFont.new ()
		font:loadFromTTF("font/zekton free.ttf", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!'", 30)
		
		textbox = MOAITextBox.new ()
		textbox:setRect(-0.5 * window.resolution.x, -0.5 * window.resolution.y, 0.5 * window.resolution.x, 0.5 * window.resolution.y)
		textbox:setFont(font)
		textbox:setYFlip(true)
		window.interface.layer:insertProp(textbox)
		
		textbox:setString ("falha ao abrir o servidor: " .. errorMsg)
		textbox:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
		textbox:setColor(0, 1, 0, 1)
		
		return false
	end
end

function Server:setTimeOut(number)
	self.clientSocket:settimeout(number)
end

function Server:acceptClient()
	if self.socket ~= nil then
		print("aguardando um cliente...")
		self.clientSocket = self.socket:accept()
		local aa, bb
		self.clientName = self.clientSocket:getpeername()
		print("cliente conectado:", self.clientName)
		
		return true
	else
		print("servidor nao foi aberto ainda!")
		
		return false
	end
end

function Server:sendData(data)
	-- send "data" in socket
	if self.clientSocket ~= nil then
		self.clientSocket:send(data)
		print("dados enviados: ", data)
	else
		print("nao ha cliente conectado!")
	end
end

function Server:receiveData()
	-- return "data" from client

	if self.clientSocket ~= nil then
		print("aguardando dados...")
		return self.clientSocket:receive()
	else
		print("servidor nao aceitou um cliente ainda!")
		return nil
	end
end