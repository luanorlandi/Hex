--[[
--------------------------------------------------------------------------------
This is a free game developed by Luan Orlandi in project of scientific research
at ICMC-USP, guided by Leandro Fiorini Aurichi and supported by CNPq

For more information, access https://github.com/luanorlandi/Hex
--------------------------------------------------------------------------------
]]

version = "1.1.0"
firstGame = false

MOAILogMgr.setLogLevel(MOAILogMgr.LOG_NONE)

require "math/vector"
require "math/rectangle"
require "math/circle"
require "math/utils"

require "file/saveLocation"
require "file/strings"
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