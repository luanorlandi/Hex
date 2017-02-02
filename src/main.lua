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

require "math/vector"
require "math/rectangle"
require "math/circle"
require "math/utils"

require "window/window"
require "window/deckManager"
require "window/camera"

window = Window:new()

require "interface/priority"
require "loop/thread"
require "loop/introLoop"
require "loop/gameLoop"

require "input/input"

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