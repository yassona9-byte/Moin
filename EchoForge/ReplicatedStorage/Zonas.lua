--[[
============================================================
  ECHO FORGE — DATOS DE ZONAS (configuración compartida)
  Script: Zonas
  Tipo:   ModuleScript
  Lugar:  ReplicatedStorage
============================================================
  Distribución HUB + ZONAS: el hub está en el centro (0,0,0)
  y las zonas se reparten ALREDEDOR (no en línea), cada una
  en una dirección distinta. El MapBuilder construye cada
  bioma en su 'centro' y el ZoneManager pone la puerta en el
  borde que mira al hub.

  Para AÑADIR una zona: copia un bloque y dale un 'centro'
  en otra dirección. Todo lo demás se adapta solo.
============================================================
]]

local Zonas = {}

Zonas.Lista = {
	{
		id = "Pradera",
		nombre = "Meadow",
		centro = Vector3.new(0, 3, 200),       -- al norte del hub
		radio = 60,
		valorEco = 1,
		color = Color3.fromRGB(80, 200, 255),
		precio = 0,
		maxEcos = 30,
	},
	{
		id = "Cuevas",
		nombre = "Crystal Caves",
		centro = Vector3.new(-173, 3, -100),   -- suroeste
		radio = 60,
		valorEco = 5,
		color = Color3.fromRGB(150, 100, 255),
		precio = 5000,
		maxEcos = 30,
	},
	{
		id = "Volcan",
		nombre = "Volcanic Crater",
		centro = Vector3.new(173, 3, -100),    -- sureste
		radio = 60,
		valorEco = 25,
		color = Color3.fromRGB(255, 90, 40),
		precio = 50000,
		maxEcos = 30,
	},
	{
		id = "Tundra",
		nombre = "Frozen Tundra",
		centro = Vector3.new(-173, 3, 100),    -- noroeste
		radio = 60,
		valorEco = 100,
		color = Color3.fromRGB(150, 220, 255),  -- azul hielo
		precio = 500000,
		maxEcos = 30,
	},
	{
		id = "Cielo",
		nombre = "Sky Sanctuary",
		centro = Vector3.new(173, 3, 100),     -- noreste
		radio = 60,
		valorEco = 500,
		color = Color3.fromRGB(255, 240, 170),  -- dorado celestial
		precio = 5000000,
		maxEcos = 30,
	},
}

return Zonas
