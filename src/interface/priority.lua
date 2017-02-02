local listPriority = {
	["background"] = 1,
	["hexagon"] = 2,
	["effect"] = 3,
	["interface"] = 4
}

function changePriority(sprite, priority)
	sprite:setPriority(listPriority[priority])
end