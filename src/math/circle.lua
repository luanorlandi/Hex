require "math/vector"

Circle = {}
Circle.__index = Circle

function Circle:new(c, r)
	-- cria um circulo com centro na posicao "c", e raio de tamanho "r"
	
	local C = {}
	setmetatable(C, Circle)
	
	C.center = Vector:new(c.x, c.y)
	
	C.radius = r
	
	return C
end

function Circle:equal(b)
	self.center:equal(b.center)
	self.radius = b.radius
end

function Circle:pointInside(p)
	-- verifica se ha o ponto "p" dentro do circulo
	
	-- calcula a distancia do centro ao ponto
	local distanceX = math.abs(self.center.x - p.x)
	local distanceY = math.abs(self.center.y - p.y)
	
	local distance = math.sqrt(distanceX * distanceX + distanceY * distanceY)
	
	return distance < self.radius
end