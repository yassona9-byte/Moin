--[[
============================================================
  ECHO FORGE — CONSTRUCCIÓN DEL MAPA v2 (con "ganas")
  Script: MapBuilder
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Genera un mundo en CORREDOR que cruza 3 biomas temáticos:
    Pradera (verde, árboles, luciérnagas)
    Cuevas  (oscuras, cristales morados que brillan)
    Volcán  (basalto, lava que ilumina, brasas)
  Más: acantilados que enmarcan, spawn decorado, e
  iluminación con bloom, neblina y rayos de sol.

  La forja (ForgeManager) y las puertas (ZoneManager) las
  crean sus scripts; este pone TODO el escenario.
============================================================
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Zonas = require(ReplicatedStorage:WaitForChild("Zonas"))

local SUELO = 0.1   -- altura de la superficie pisable

-- ┌──────────────────────────────────────────────────────┐
-- │ 0. LIMPIEZA Y CARPETA                                 │
-- └──────────────────────────────────────────────────────┘
for _, nombre in ipairs({ "Baseplate", "SpawnLocation" }) do
	local viejo = Workspace:FindFirstChild(nombre)
	if viejo then viejo:Destroy() end
end

local carpetaMapa = Workspace:FindFirstChild("Mapa")
if carpetaMapa then carpetaMapa:Destroy() end   -- por si re-ejecutamos
carpetaMapa = Instance.new("Folder")
carpetaMapa.Name = "Mapa"
carpetaMapa.Parent = Workspace

-- ┌──────────────────────────────────────────────────────┐
-- │ AYUDAS                                                │
-- └──────────────────────────────────────────────────────┘
-- Crear una parte anclada. Devuelve la parte para retocarla.
local function parte(tamano, posicion, color, material)
	local p = Instance.new("Part")
	p.Size = tamano
	p.Position = posicion
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.Parent = carpetaMapa
	return p
end

-- Añadir una luz puntual a una parte (para cristales/lava).
local function luz(objeto, color, brillo, alcance)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Brightness = brillo
	l.Range = alcance
	l.Parent = objeto
end

-- Un punto al azar dentro de una zona (sobre el suelo).
local function puntoEnZona(zona, margen)
	margen = margen or 6
	local angulo = math.random() * 2 * math.pi
	local distancia = math.random(margen, zona.radio - 3)
	return Vector3.new(
		zona.centro.X + math.cos(angulo) * distancia,
		SUELO,
		zona.centro.Z + math.sin(angulo) * distancia
	)
end

-- Crear un emisor de partículas en un área (parte invisible).
local function emisor(pos, tamano)
	local p = Instance.new("Part")
	p.Size = tamano
	p.Position = pos
	p.Transparency = 1
	p.CanCollide = false
	p.Anchored = true
	p.Parent = carpetaMapa
	local e = Instance.new("ParticleEmitter")
	e.Parent = p
	return e
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 1. SUELO DE SEGURIDAD + ACANTILADOS QUE ENMARCAN      │
-- └──────────────────────────────────────────────────────┘
-- Suelo grande bajo todo (para no caer al vacío).
parte(Vector3.new(180, 6, 470), Vector3.new(0, -3, -120),
	Color3.fromRGB(30, 30, 40), Enum.Material.Rock)

-- Dos acantilados largos a los lados (paredes de roca) que
-- convierten el mundo en un "camino" entre biomas y evitan
-- caerse por los lados.
for _, ladoX in ipairs({ -56, 56 }) do
	parte(Vector3.new(10, 34, 470), Vector3.new(ladoX, 14, -120),
		Color3.fromRGB(45, 42, 50), Enum.Material.Rock)
	-- Rocas irregulares encima del acantilado, para que no sea
	-- una pared plana y aburrida.
	for i = 1, 22 do
		local s = math.random(6, 12)
		local r = parte(Vector3.new(s, s, s),
			Vector3.new(ladoX + math.random(-3, 3), 30 + math.random(-2, 4), -310 + (i * 28)),
			Color3.fromRGB(50, 47, 55), Enum.Material.Rock)
		r.Orientation = Vector3.new(math.random(0, 50), math.random(0, 360), math.random(0, 50))
	end
end

-- Pared del fondo (tras el Volcán) para cerrar el mundo.
parte(Vector3.new(122, 40, 10), Vector3.new(0, 17, -312),
	Color3.fromRGB(45, 42, 50), Enum.Material.Rock)

-- ┌──────────────────────────────────────────────────────┐
-- │ DECORACIONES TEMÁTICAS                                │
-- └──────────────────────────────────────────────────────┘
-- Árbol con tamaño variable (Pradera).
local function arbol(pos)
	local altura = math.random(5, 9)
	parte(Vector3.new(1.6, altura, 1.6), pos + Vector3.new(0, altura / 2, 0),
		Color3.fromRGB(95, 62, 35), Enum.Material.Wood)
	-- 2 copas para dar volumen.
	local copa1 = parte(Vector3.new(8, 8, 8), pos + Vector3.new(0, altura + 1, 0),
		Color3.fromRGB(70, 155, 60), Enum.Material.Grass)
	copa1.Shape = Enum.PartType.Ball
	local copa2 = parte(Vector3.new(5, 5, 5), pos + Vector3.new(math.random(-2, 2), altura + 4, math.random(-2, 2)),
		Color3.fromRGB(85, 170, 70), Enum.Material.Grass)
	copa2.Shape = Enum.PartType.Ball
end

-- Arbusto (Pradera).
local function arbusto(pos)
	local b = parte(Vector3.new(4, 3, 4), pos + Vector3.new(0, 1.5, 0),
		Color3.fromRGB(75, 150, 65), Enum.Material.Grass)
	b.Shape = Enum.PartType.Ball
end

-- Flor: tallo + cabeza de color neón (Pradera).
local function flor(pos)
	parte(Vector3.new(0.3, 1.4, 0.3), pos + Vector3.new(0, 0.7, 0),
		Color3.fromRGB(60, 130, 55), Enum.Material.Grass)
	local colores = { Color3.fromRGB(255, 120, 180), Color3.fromRGB(255, 220, 80), Color3.fromRGB(180, 130, 255) }
	local cabeza = parte(Vector3.new(1, 1, 1), pos + Vector3.new(0, 1.6, 0),
		colores[math.random(#colores)], Enum.Material.Neon)
	cabeza.Shape = Enum.PartType.Ball
end

-- Cristal brillante con luz (Cuevas).
local function cristal(pos)
	local alto = math.random(6, 16)
	local c = parte(Vector3.new(2.2, alto, 2.2), pos + Vector3.new(0, alto / 2, 0),
		Color3.fromRGB(150, 100, 255), Enum.Material.Neon)
	c.Orientation = Vector3.new(math.random(-18, 18), math.random(0, 360), math.random(-18, 18))
	luz(c, Color3.fromRGB(150, 100, 255), 2, 14)
	-- Un par de cristales pequeños alrededor (racimo).
	for i = 1, math.random(1, 3) do
		local a2 = math.random(2, 5)
		local mini = parte(Vector3.new(1, a2, 1),
			pos + Vector3.new(math.random(-3, 3), a2 / 2, math.random(-3, 3)),
			Color3.fromRGB(170, 120, 255), Enum.Material.Neon)
		mini.Orientation = Vector3.new(math.random(-25, 25), math.random(0, 360), math.random(-25, 25))
	end
end

-- Charco de lava que ilumina (Volcán).
local function lava(pos)
	local r = math.random(7, 13)
	local l = parte(Vector3.new(r, 0.5, r), pos + Vector3.new(0, 0.35, 0),
		Color3.fromRGB(255, 110, 30), Enum.Material.Neon)
	luz(l, Color3.fromRGB(255, 120, 40), 3, 20)
end

-- Roca (Cuevas y Volcán).
local function roca(pos)
	local s = math.random(3, 7)
	local r = parte(Vector3.new(s, s, s), pos + Vector3.new(0, s / 2, 0),
		Color3.fromRGB(58, 52, 55), Enum.Material.Rock)
	r.Orientation = Vector3.new(math.random(0, 45), math.random(0, 360), math.random(0, 45))
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. SUELO TEMÁTICO + DECORACIÓN + AMBIENTE POR ZONA    │
-- └──────────────────────────────────────────────────────┘
local SUELO_COLOR = {
	Pradera = Color3.fromRGB(90, 160, 75),
	Cuevas  = Color3.fromRGB(42, 36, 58),
	Volcan  = Color3.fromRGB(48, 32, 30),
}
local SUELO_MAT = {
	Pradera = Enum.Material.Grass,
	Cuevas  = Enum.Material.Slate,
	Volcan  = Enum.Material.Basalt,
}

for _, zona in ipairs(Zonas.Lista) do
	-- Losa de suelo del bioma (cuadrada, cubre la zona).
	local pad = parte(
		Vector3.new(zona.radio * 2 + 12, 1.2, zona.radio * 2 + 12),
		Vector3.new(zona.centro.X, SUELO - 0.6, zona.centro.Z),
		SUELO_COLOR[zona.id] or Color3.fromRGB(120, 120, 120),
		SUELO_MAT[zona.id] or Enum.Material.SmoothPlastic
	)
	pad.Name = "Suelo_" .. zona.id

	-- Decoración densa y variada según el bioma.
	if zona.id == "Pradera" then
		for i = 1, 10 do arbol(puntoEnZona(zona)) end
		for i = 1, 8 do arbusto(puntoEnZona(zona)) end
		for i = 1, 18 do flor(puntoEnZona(zona)) end
		-- Luciérnagas (partículas amarillas flotando).
		local e = emisor(zona.centro + Vector3.new(0, 6, 0),
			Vector3.new(zona.radio * 1.6, 10, zona.radio * 1.6))
		e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		e.Color = ColorSequence.new(Color3.fromRGB(255, 245, 150))
		e.Lifetime = NumberRange.new(2, 4)
		e.Rate = 18
		e.Speed = NumberRange.new(0.4, 1.2)
		e.Size = NumberSequence.new(0.5)
		e.Transparency = NumberSequence.new(0.2)
		e.LightEmission = 1
		e.Rotation = NumberRange.new(0, 360)

	elseif zona.id == "Cuevas" then
		for i = 1, 16 do cristal(puntoEnZona(zona)) end
		for i = 1, 8 do roca(puntoEnZona(zona)) end
		-- Destellos morados.
		local e = emisor(zona.centro + Vector3.new(0, 7, 0),
			Vector3.new(zona.radio * 1.6, 14, zona.radio * 1.6))
		e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		e.Color = ColorSequence.new(Color3.fromRGB(180, 130, 255))
		e.Lifetime = NumberRange.new(2, 4)
		e.Rate = 22
		e.Speed = NumberRange.new(0.2, 0.8)
		e.Size = NumberSequence.new(0.45)
		e.Transparency = NumberSequence.new(0.1)
		e.LightEmission = 1

	elseif zona.id == "Volcan" then
		for i = 1, 9 do lava(puntoEnZona(zona)) end
		for i = 1, 12 do roca(puntoEnZona(zona)) end
		-- Brasas que suben.
		local e = emisor(zona.centro + Vector3.new(0, 2, 0),
			Vector3.new(zona.radio * 1.6, 4, zona.radio * 1.6))
		e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		e.Color = ColorSequence.new(Color3.fromRGB(255, 130, 40))
		e.Lifetime = NumberRange.new(2, 3.5)
		e.Rate = 30
		e.Speed = NumberRange.new(3, 6)
		e.Acceleration = Vector3.new(0, 6, 0)     -- suben
		e.Size = NumberSequence.new(0.4)
		e.Transparency = NumberSequence.new(0.2)
		e.LightEmission = 1
		-- Humo gris tenue.
		local h = emisor(zona.centro + Vector3.new(0, 3, 0),
			Vector3.new(zona.radio * 1.4, 4, zona.radio * 1.4))
		h.Color = ColorSequence.new(Color3.fromRGB(70, 60, 60))
		h.Lifetime = NumberRange.new(3, 5)
		h.Rate = 6
		h.Speed = NumberRange.new(2, 4)
		h.Acceleration = Vector3.new(0, 4, 0)
		h.Size = NumberSequence.new(6)
		h.Transparency = NumberSequence.new(0.7)
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 3. PEDESTAL DE LA FORJA (en la Pradera)               │
-- └──────────────────────────────────────────────────────┘
-- La forja la coloca ForgeManager en (0, 3, -20). Le ponemos
-- un pedestal de piedra debajo para que destaque.
local dais = parte(Vector3.new(16, 1.5, 16), Vector3.new(0, SUELO + 0.5, -20),
	Color3.fromRGB(70, 65, 70), Enum.Material.Cobblestone)
dais.Name = "PedestalForja"

-- ┌──────────────────────────────────────────────────────┐
-- │ 4. SPAWN DECORADO                                     │
-- └──────────────────────────────────────────────────────┘
-- Plataforma redonda decorativa bajo el spawn.
local plataforma = parte(Vector3.new(20, 1, 20), Vector3.new(0, SUELO + 0.2, 28),
	Color3.fromRGB(220, 220, 230), Enum.Material.Marble)
plataforma.Name = "PlataformaSpawn"

local spawn = Instance.new("SpawnLocation")
spawn.Name = "SpawnEchoForge"
spawn.Size = Vector3.new(12, 1, 12)
spawn.Position = Vector3.new(0, SUELO + 1, 28)
spawn.Orientation = Vector3.new(0, 180, 0)   -- mira hacia las zonas
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(120, 220, 255)
spawn.Transparency = 0.2
spawn.Parent = carpetaMapa

-- Dos farolas a los lados del spawn (poste + globo de luz).
for _, lado in ipairs({ -10, 10 }) do
	parte(Vector3.new(0.8, 8, 0.8), Vector3.new(lado, SUELO + 4, 28),
		Color3.fromRGB(40, 40, 45), Enum.Material.Metal)
	local globo = parte(Vector3.new(2, 2, 2), Vector3.new(lado, SUELO + 8, 28),
		Color3.fromRGB(255, 245, 200), Enum.Material.Neon)
	globo.Shape = Enum.PartType.Ball
	luz(globo, Color3.fromRGB(255, 240, 200), 2, 18)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 5. ILUMINACIÓN Y EFECTOS (lo que da el "look")        │
-- └──────────────────────────────────────────────────────┘
-- Reemplaza un efecto en Lighting (evita duplicados).
local function ponerEfecto(instancia)
	local viejo = Lighting:FindFirstChild(instancia.Name)
	if viejo then viejo:Destroy() end
	instancia.Parent = Lighting
end

-- Tecnología Future: hace que el neón "brille" y las luces
-- (cristales, lava, farolas) iluminen de verdad.
Lighting.Technology = Enum.Technology.Future
Lighting.ClockTime = 14.5
Lighting.Brightness = 2.5
Lighting.OutdoorAmbient = Color3.fromRGB(110, 110, 130)
Lighting.Ambient = Color3.fromRGB(70, 70, 85)
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1

-- Neblina con profundidad.
local atmosfera = Instance.new("Atmosphere")
atmosfera.Name = "AtmosferaEchoForge"
atmosfera.Density = 0.32
atmosfera.Offset = 0.2
atmosfera.Haze = 1.4
atmosfera.Glare = 0.2
atmosfera.Color = Color3.fromRGB(199, 205, 224)
atmosfera.Decay = Color3.fromRGB(106, 112, 125)
ponerEfecto(atmosfera)

-- Bloom: el "resplandor" de las cosas brillantes.
local bloom = Instance.new("BloomEffect")
bloom.Name = "BloomEchoForge"
bloom.Intensity = 0.9
bloom.Size = 24
bloom.Threshold = 1.1
ponerEfecto(bloom)

-- Rayos de sol.
local rayos = Instance.new("SunRaysEffect")
rayos.Name = "RayosEchoForge"
rayos.Intensity = 0.12
rayos.Spread = 0.6
ponerEfecto(rayos)

-- Corrección de color: un pelín más de saturación y contraste.
local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "ColorEchoForge"
cc.Saturation = 0.18
cc.Contrast = 0.06
cc.Brightness = 0.02
ponerEfecto(cc)
