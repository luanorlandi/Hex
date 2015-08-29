-- esta funcao indica a posicao do cursor
function onMouseMoveEvent(x, y)
	input.pointerPos.x = x
	input.pointerPos.y = y
end

function onMouseLeftEvent(down)
	input.pointerPressed = down
end

function onMouseMiddleEvent(down)

end

function onMouseRightEvent(down)

end