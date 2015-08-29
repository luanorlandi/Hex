function getTime()
	while true do
		gameTime = MOAISim.getElapsedTime()
		coroutine.yield()
	end
end