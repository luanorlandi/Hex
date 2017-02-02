require "effect/blend"

Intro = {}
Intro.__index = Intro

function Intro:new()
	local I = {}
	setmetatable(I, Intro)
	
	-- fundo branco
	I.background = Background:new(window.deckManager.whiteScreen)
	
	I.logos = {}
	
	-- logo da linguagem lua
	local lua = MOAIProp2D.new()
	changePriority(lua, "interface")
	lua:setDeck(window.deckManager.deckLua)
	
	lua:setBlendMode(MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA)
	lua:setColor(1, 1, 1, 0)
	window.layer:insertProp(lua)
	
	table.insert(I.logos, lua)
	
	-- logo da engine MOAI
	local moai = MOAIProp2D.new()
	changePriority(moai, "interface")
	moai:setDeck(window.deckManager.deckMOAI)
	
	moai:setBlendMode(MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA)
	moai:setColor(1, 1, 1, 0)
	window.layer:insertProp(moai)
	
	table.insert(I.logos, moai)
	
	I.start = 0.8				-- tempo para comecar
	I.fadeDuration = 0.8	-- tempo de duracao para o efeito de transparencia
	I.logoDuration = 1.2	-- tempo que o logo fica na tela
	I.waitDuration = 0.2	-- tempo entre os logos
	
	I.coroutine = coroutine.create(function()
		I:loop()
	end)
	
	coroutine.resume(I.coroutine)
	
	return I
end

function Intro:loop()
	-- espera para iniciar a intro ---------------------
	local waitingStart = gameTime
	while gameTime - waitingStart < self.start do
		coroutine.yield()
	end
		
	for i = 1, table.getn(self.logos), 1 do
		coroutine.yield()
		-- logo aparecendo ---------------------------------
		local blendThread = coroutine.create(function()
			blend(self.logos[i], self.fadeDuration)
		end)
		coroutine.resume(blendThread)
		
		while coroutine.status(blendThread) ~= "dead" do
			coroutine.yield()
			coroutine.resume(blendThread)
		end
		
		-- deixa o logo por um tempo -----------------------
		waitingStart = gameTime
		while gameTime - waitingStart < self.logoDuration do
			coroutine.yield()
		end
		
		-- logo desaparecendo ------------------------------
		local blendThread = coroutine.create(function()
			blendOut(self.logos[i], self.fadeDuration)
		end)
		coroutine.resume(blendThread)
		
		while coroutine.status(blendThread) ~= "dead" do
			coroutine.yield()
			coroutine.resume(blendThread)
		end
		
		-- espera para o proximo logo ----------------------
		local waitingStart = gameTime
		while gameTime - waitingStart < self.waitDuration do
			coroutine.yield()
		end
	end
end

function Intro:clear()
	self.background:clear()
	
	local logos = table.getn(self.logos)
	
	for i = 1, logos, 1 do
		window.layer:removeProp(self.logos[1])
		table.remove(self.logos, 1)
	end
end