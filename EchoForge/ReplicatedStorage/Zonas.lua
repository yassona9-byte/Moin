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

-- ┌──────────────────────────────────────────────────────┐
-- │ RESOLVER POSICIÓN POR MARCADOR (mapa a medida)        │
-- └──────────────────────────────────────────────────────┘
-- Devuelve el CENTRO y el RADIO reales de una zona.
-- Si colocas en Workspace un Part llamado "Zona_<id>" (p.ej.
-- "Zona_Volcan"), o dentro de una carpeta "ZoneMarkers", el
-- juego usa SU posición (centro) y SU tamaño (radio). Así
-- puedes usar CUALQUIER mapa: solo arrastras los marcadores
-- a cada bioma. Si no hay marcador, usa los valores de arriba.
function Zonas.posicion(zona)
	local marcador = workspace:FindFirstChild("Zona_" .. zona.id)
	if not marcador then
		local carpeta = workspace:FindFirstChild("ZoneMarkers")
		if carpeta then
			marcador = carpeta:FindFirstChild("Zona_" .. zona.id)
		end
	end
	if marcador and marcador:IsA("BasePart") then
		local radio = math.max(marcador.Size.X, marcador.Size.Z) / 2
		return marcador.Position, radio
	end
	return zona.centro, zona.radio
end

return Zonas
