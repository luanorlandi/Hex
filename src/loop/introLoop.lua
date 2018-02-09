require "interface/intro/introInterface"

function introLoop()
    local intro = Intro:new()
    
    window.deckManager.intro = true
    window.deckManager:resizeDecks()
    
    if MOAIEnvironment.osBrand ~= nil then
        while coroutine.status(intro.coroutine) ~= "dead" and not input.pointerReleased do
            coroutine.yield()

            coroutine.resume(intro.coroutine)
        end
    else
        -- probably html host
        while coroutine.status(intro.coroutine) ~= "dead" and not input.pointerPressed do
            coroutine.yield()

            coroutine.resume(intro.coroutine)
        end
    end
    
    input.pointerPressed = false
    
    window.deckManager.intro = false
    
    intro:clear()
    
    local gameLoop = GameLoop:new(Vector:new(11, 11), "Player 1", "Player 2",
        gameMode["bot"], victoryPath["horizontal"], playerTurn["first"])
    gameLoop:start()
end