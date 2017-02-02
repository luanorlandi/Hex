Player = {}
Player.__index = Player

function Player:new(name, myPath, myTurn)
	local P = {}
	setmetatable(P, Player)
	
	P.name = name
	
	P.color = nil
	
	if myPath == victoryPath["horizontal"] then
		P.color = Color:new(0, 0, 1)
	else
		P.color = Color:new(1, 0, 0)
	end
	
	P.myPath = myPath
	P.myTurn = myTurn
	
	-- guarda o ultimo hexagono escolhido
	P.lastMove = nil
	P.colorLastMove = Color:new(P.color.red * 0.70,
								P.color.green * 0.70,
								P.color.blue * 0.70)
	
	return P
end

