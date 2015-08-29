--[[
-------------------------------------------------------------------
Esse jogo nao tem fins comerciais e foi desenvolvido por Luan
Gustavo Orlandi em um projeto de Iniciacao Cientifica no
ICMC-USP, com orientacao de Leandro Fiorini Aurichi e apoio do
CNPq.
-------------------------------------------------------------------
versao 1.0
-------------------------------------------------------------------
]]

MOAILogMgr.setLogLevel(MOAILogMgr.LOG_NONE)

require "socket"

require "data/math/vector"
require "data/math/rectangle"
require "data/math/circle"
require "data/math/utils"

require "data/window/window"
require "data/window/deckManager"
require "data/window/camera"

window = Window:new()

require "data/interface/priority"
require "data/loop/thread"
require "data/loop/introLoop"
require "data/loop/gameLoop"

require "data/input/input"

input = Input:new()

--input:keyboardActive()
input:mouseActive()
input:touchActive()

local timeCoroutine = MOAICoroutine.new()
timeCoroutine:run(getTime)

local introCoroutine = MOAICoroutine.new()
introCoroutine:run(introLoop)

--local gameLoop = GameLoop:new(Vector:new(11, 11), "Player 1", "Player 2",
--	gameMode["bot"], victoryPath["horizontal"], playerTurn["first"])
--gameLoop:start()