--[[
============================================================
  ECHO FORGE — CONSTRUCCIÓN DEL MAPA (por código)
  Script: MapBuilder
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Qué hace, en una frase:
  "Genera el escenario completo al arrancar: un suelo grande
   de seguridad, un suelo temático por cada zona, decoración
   (árboles, cristales, lava), el punto de aparición y un
   ambiente de iluminación agradable."

  La forja (ForgeManager) y las puertas (ZoneManager) se
  construyen en sus propios scripts; este solo pone el mundo.
============================================================
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Leemos las zonas para colocar cada suelo en su sitio.
local Zonas = require(ReplicatedStorage:WaitForChild("Zonas"))

-- Altura de la "superficie" del mundo. Casi todo se apoya aquí.
local SUELO = 0.1

-- ┌──────────────────────────────────────────────────────┐
-- │ 0. LIMPIAR EL MAPA POR DEFECTO                        │
-- └──────────────────────────────────────────────────────┘
-- Borramos el Baseplate y el SpawnLocation de la plantilla
-- para construir lo nuestro sin que se solapen.
for _, nombre in ipairs({ "Baseplate", "SpawnLocation" }) do
	local viejo = Workspace:FindFirstChild(nombre)
	if viejo then
		viejo:Destroy()
	end
end

-- Carpeta para mantener todo el mapa ordenado.
local carpetaMapa = Instance.new("Folder")
carpetaMapa.Name = "Mapa"
carpetaMapa.Parent = Workspace

-- ┌──────────────────────────────────────────────────────┐
-- │ AYUDA: crear una parte rápida                         │
-- └──────────────────────────────────────────────────────┘
-- Una función que crea un Part anclado y lo mete en el mapa.
-- Así no repetimos 8 líneas por cada objeto.
local function crearParte(tamano, posicion, color, material)
	local p = Instance.new("Part")
	p.Size = tamano
	p.Position = posicion
	p.Color = color
	p.Material = material
	p.Anchored = true        -- no se cae con la gravedad
	p.Parent = carpetaMapa
	return p
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 1. SUELO GRANDE DE SEGURIDAD (para no caer al vacío)  │
-- └──────────────────────────────────────────────────────┘
-- Cubre TODA la zona jugable. Va por debajo de los suelos
-- temáticos; su función es que nadie se caiga por un hueco.
crearParte(
	Vector3.new(170, 4, 460),                 -- ancho, alto, largo
	Vector3.new(0, -2, -120),                 -- centrado, su tapa queda en y=0
	Color3.fromRGB(35, 35, 45),               -- gris oscuro neutro
	Enum.Material.Slate
)

-- ┌──────────────────────────────────────────────────────┐
-- │ AYUDA: un punto al azar dentro de una zona            │
-- └──────────────────────────────────────────────────────┘
local function puntoEnZona(zona)
	local angulo = math.random() * 2 * math.pi
	local distancia = math.random(8, zona.radio - 3)
	return Vector3.new(
		zona.centro.X + math.cos(angulo) * distancia,
		SUELO,
		zona.centro.Z + math.sin(angulo) * distancia
	)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ DECORACIONES TEMÁTICAS                                │
-- └──────────────────────────────────────────────────────┘
-- Un árbol: tronco + copa esférica (para la Pradera).
local function arbol(pos)
	crearParte(Vector3.new(1.5, 6, 1.5), pos + Vector3.new(0, 3, 0),
		Color3.fromRGB(90, 60, 35), Enum.Material.Wood)
	local copa = crearParte(Vector3.new(7, 7, 7), pos + Vector3.new(0, 7.5, 0),
		Color3.fromRGB(70, 155, 60), Enum.Material.Grass)
	copa.Shape = Enum.PartType.Ball
end

-- Un cristal: prisma alto, inclinado y brillante (para las Cuevas).
local function cristal(pos)
	local alto = math.random(6, 13)
	local c = crearParte(Vector3.new(2, alto, 2), pos + Vector3.new(0, alto / 2, 0),
		Color3.fromRGB(150, 100, 255), Enum.Material.Neon)
	-- Lo inclinamos un poco al azar para que parezca natural.
	c.Orientation = Vector3.new(math.random(-15, 15), math.random(0, 360), math.random(-15, 15))
end

-- Un charco de lava: plano y brillante naranja (para el Volcán).
local function lava(pos)
	local r = math.random(6, 12)
	crearParte(Vector3.new(r, 0.4, r), pos + Vector3.new(0, 0.3, 0),
		Color3.fromRGB(255, 110, 30), Enum.Material.Neon)
end

-- Una roca: bloque gris inclinado (Cuevas y Volcán).
local function roca(pos)
	local s = math.random(3, 6)
	local r = crearParte(Vector3.new(s, s, s), pos + Vector3.new(0, s / 2, 0),
		Color3.fromRGB(60, 55, 58), Enum.Material.Slate)
	r.Orientation = Vector3.new(math.random(0, 40), math.random(0, 360), math.random(0, 40))
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. UN SUELO TEMÁTICO + DECORACIÓN POR CADA ZONA       │
-- └──────────────────────────────────────────────────────┘
-- Colores de suelo por zona (más apagados que los Ecos).
local SUELO_COLOR = {
	Pradera = Color3.fromRGB(85, 150, 70),   -- hierba
	Cuevas  = Color3.fromRGB(45, 40, 60),    -- piedra oscura morada
	Volcan  = Color3.fromRGB(48, 32, 30),    -- basalto
}

for _, zona in ipairs(Zonas.Lista) do
	-- Suelo de la zona: una losa cuadrada del color del tema.
	-- Su tapa queda justo en y = SUELO (un pelín sobre el suelo
	-- de seguridad, para que no parpadeen al solaparse).
	local pad = crearParte(
		Vector3.new(zona.radio * 2, 1, zona.radio * 2),
		Vector3.new(zona.centro.X, SUELO - 0.5, zona.centro.Z),
		SUELO_COLOR[zona.id] or Color3.fromRGB(120, 120, 120),
		Enum.Material.SmoothPlastic
	)
	pad.Name = "Suelo_" .. zona.id

	-- Decoración propia de cada zona (10 objetos repartidos).
	for i = 1, 10 do
		local p = puntoEnZona(zona)
		if zona.id == "Pradera" then
			arbol(p)
		elseif zona.id == "Cuevas" then
			-- mezcla de cristales y alguna roca
			if math.random() < 0.7 then cristal(p) else roca(p) end
		elseif zona.id == "Volcan" then
			if math.random() < 0.6 then lava(p) else roca(p) end
		end
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 3. PUNTO DE APARICIÓN (en la Pradera, mirando al mapa)│
-- └──────────────────────────────────────────────────────┘
local spawn = Instance.new("SpawnLocation")
spawn.Name = "SpawnEchoForge"
spawn.Size = Vector3.new(10, 1, 10)
spawn.Position = Vector3.new(0, SUELO + 0.5, 28)   -- frente de la Pradera
spawn.Orientation = Vector3.new(0, 180, 0)         -- mira hacia las zonas (-Z)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0                                  -- sin escudo al aparecer
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(255, 255, 255)
spawn.Parent = carpetaMapa

-- ┌──────────────────────────────────────────────────────┐
-- │ 4. AMBIENTE (iluminación)                             │
-- └──────────────────────────────────────────────────────┘
-- Un pequeño retoque para que el mundo se vea más vivo.
Lighting.ClockTime = 14          -- media tarde
Lighting.Brightness = 2
Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 140)
