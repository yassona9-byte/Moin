--[[
============================================================
  ECHO FORGE — DATOS DE ZONAS (mundo abierto grande)
  Script: Zonas
  Tipo:   ModuleScript
  Lugar:  ReplicatedStorage
============================================================
  Zonas repartidas por un mundo GRANDE de terreno. El hub está
  en el centro (0,0,0); cada zona es un BIOMA grande a cientos
  de studs. El MapBuilder esculpe el terreno en cada 'centro'.
  El suelo jugable de cada zona está a y≈0 (los Ecos aparecen
  un poco por encima).
============================================================
]]

local Zonas = {}

Zonas.Lista = {
	{
		id = "Pradera",
		nombre = "Meadow",
		centro = Vector3.new(0, 3, 300),       -- pradera frente al hub
		radio = 130,
		valorEco = 1,
		color = Color3.fromRGB(80, 200, 255),
		precio = 0,
		maxEcos = 40,
	},
	{
		id = "Cuevas",
		nombre = "Crystal Caves",
		centro = Vector3.new(-820, 3, 0),      -- cueva al oeste
		radio = 55,
		valorEco = 5,
		color = Color3.fromRGB(150, 100, 255),
		precio = 5000,
		maxEcos = 35,
	},
	{
		id = "Volcan",
		nombre = "Volcanic Crater",
		centro = Vector3.new(820, 3, 0),       -- volcán al este
		radio = 70,
		valorEco = 25,
		color = Color3.fromRGB(255, 90, 40),
		precio = 50000,
		maxEcos = 35,
	},
	{
		id = "Tundra",
		nombre = "Frozen Tundra",
		centro = Vector3.new(0, 3, -820),      -- nieve al norte
		radio = 130,
		valorEco = 100,
		color = Color3.fromRGB(150, 220, 255),
		precio = 500000,
		maxEcos = 40,
	},
	{
		id = "Cielo",
		nombre = "Sky Sanctuary",
		centro = Vector3.new(640, 3, 640),     -- santuario al noreste
		radio = 120,
		valorEco = 500,
		color = Color3.fromRGB(255, 240, 170),
		precio = 5000000,
		maxEcos = 40,
	},
}

return Zonas
