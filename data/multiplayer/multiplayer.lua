require "data/multiplayer/socket/client"
require "data/multiplayer/socket/server"

Multiplayer = {}
Multiplayer.__index = Multiplayer

function Multiplayer:new()
	local M = {}
	setmetatable(M, Multiplayer)
	
	M.active = false
	
	M.timeOut = 0.001
	
	-- objeto que pode ser o cliente ou servidor(cliente host), nele ha o socket
	M.client = nil
	
	return M
end

function Multiplayer:startServer()
	-- inicia como host
	self.client = Server:new()
	local open = self.client:open(65739)
	local accepted = self.client:acceptClient()
	
	if accepted then
		multiplayer.active = true
		
		self:readOpponent()
	end
end

function Multiplayer:connectToServer()
	-- inicia como cliente
	self.client = Client:new()
	local connected = self.client:connect("192.168.0.100", 65739)
	
	if connected then
		multiplayer.active = true
		
		self:readOpponent()
	end
end

function Multiplayer:readOpponent()
-- cria uma corotina de ficar escutando o socket do outro jogador
	self.client:setTimeOut(self.timeOut)

	local readSocketCoroutine = MOAICoroutine.new()
	readSocketCoroutine:run(function ()
		repeat
			coroutine.yield()
			
			local data, status = self.client:receiveData()
			
			if data ~= nil then
				local hex = turn:decodeMove(data)
				turn:performTurn(hex)
				
				turn.myTurn = true
			else print("aguardando uma jogada.........") end
		until status == "closed"
	end)
end

function Multiplayer:sendMove(data)
	print("enviando: " .. data)
	self.client:sendData(data)
end