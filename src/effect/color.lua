Color = {}
Color.__index = Color

function Color:new(red, green, blue, alpha)
	local C = {}
	setmetatable(C, Color)
	
	C.red = red
	C.green = green
	C.blue = blue
	
	if alpha == nil then
		C.alpha = 1
	else
		C.alpha = alpha
	end
	
	return C
end

function Color:getColor()
	return self.red, self.green, self.blue, self.alpha
end