require "multiplayer/socket/client"
require "multiplayer/socket/server"

Multiplayer = {}
Multiplayer.__index = Multiplayer

function Multiplayer:new()
	local M = {}
	setmetatable(M, Multiplayer)
	
	M.active = false
	
	M.timeOut = 0.001
	
	-- can be a clint or server (client host), it has a socket
	M.client = nil
	
	return M
end

function Multiplayer:startServer()
	-- start as host
	self.client = Server:new()
	local open = self.client:open(65739)
	local accepted = self.client:acceptClient()
	
	if accepted then
		multiplayer.active = true
		
		self:readOpponent()
	end
end

function Multiplayer:connectToServer()
	-- start as client
	self.client = Client:new()
	local connected = self.client:connect("192.168.0.100", 65739)
	
	if connected then
		multiplayer.active = true
		
		self:readOpponent()
	end
end

function Multiplayer:readOpponent()
	-- create a coroutine to listen the other player socket
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