function onTouchEvent(event, idx, x, y, tapCount)
	if event == MOAITouchSensor.TOUCH_MOVE then
		input.pointerPos.x = x
		input.pointerPos.y = y
	end
	
	if event == MOAITouchSensor.TOUCH_DOWN then
		input.pointerPressed = true
		input.pointerPos.x = x
		input.pointerPos.y = y
	end
	
	if event == MOAITouchSensor.TOUCH_UP or
	   event == MOAITouchSensor.TOUCH_CANCEL then
	   
		input.pointerPressed = false
		input.pointerPos.x = x
		input.pointerPos.y = y
	end
end