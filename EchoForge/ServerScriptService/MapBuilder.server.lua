--[[
============================================================
  ECHO FORGE — MUNDO ABIERTO (TERRENO real)  v4
  Script: MapBuilder
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Esculpe un MUNDO GRANDE con workspace.Terrain (no bloques):
    - Llanura de hierba enorme + colinas suaves.
    - Caminos hacia cada zona.
    - VOLCÁN real: cono de basalto con cráter y lava.
    - CUEVA real: domo de roca hueco por dentro, con túnel.
    - TUNDRA: nieve + lago helado.
    - SKY: meseta clara con nubes y pilares de luz.
    - Anillo de MONTAÑAS con nieve en el horizonte.
    - Iluminación Future con niebla, bloom y rayos de sol.

  El suelo jugable de cada zona está a y≈0, así los demás
  scripts (forja, puertas, Ecos a y=3) funcionan tal cual.

  NOTA: es una v1 generada "a ciegas". Mándame capturas y
  afinamos formas y tamaños. Para vegetación/props finos, lo
  ideal son packs de assets del Creator Store.
============================================================
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Terrain = Workspace.Terrain
local Zonas = require(ReplicatedStorage:WaitForChild("Zonas"))

-- Mundo grande => moverse más rápido se agradece.
StarterPlayer.CharacterWalkSpeed = 34

-- Búsqueda rápida de una zona por id.
local Z = {}
for _, zona in ipairs(Zonas.Lista) do Z[zona.id] = zona end

-- ┌──────────────────────────────────────────────────────┐
-- │ LIMPIEZA                                              │
-- └──────────────────────────────────────────────────────┘
Terrain:Clear()
for _, nombre in ipairs({ "Baseplate", "SpawnLocation" }) do
	local v = Workspace:FindFirstChild(nombre)
	if v then v:Destroy() end
end
local mapa = Workspace:FindFirstChild("Mapa")
if mapa then mapa:Destroy() end
mapa = Instance.new("Folder")
mapa.Name = "Mapa"
mapa.Parent = Workspace

-- ┌──────────────────────────────────────────────────────┐
-- │ AYUDAS                                                │
-- └──────────────────────────────────────────────────────┘
local function parte(tamano, posicion, color, material)
	local p = Instance.new("Part")
	p.Size = tamano
	p.Position = posicion
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.Parent = mapa
	return p
end

local function luz(objeto, color, brillo, alcance)
	local l = Instance.new("PointLight")
	l.Color = color; l.Brightness = brillo; l.Range = alcance
	l.Parent = objeto
end

-- Disco de terreno horizontal (cilindro vertical fino).
local function disco(x, y, z, radio, alto, material)
	Terrain:FillCylinder(CFrame.new(x, y, z), alto, radio, material)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 1. LLANURA BASE (hierba) + COLINAS SUAVES             │
-- └──────────────────────────────────────────────────────┘
-- Gran bloque de hierba: tapa a y=0, grosor 20.
Terrain:FillBlock(CFrame.new(0, -10, 0), Vector3.new(2200, 20, 2200), Enum.Material.Grass)

-- Colinas suaves repartidas (bolas de hierba medio enterradas),
-- evitando el centro del hub y de las zonas.
for i = 1, 40 do
	local a = math.random() * math.pi * 2
	local d = math.random(180, 950)
	local x = math.cos(a) * d
	local z = math.sin(a) * d
	-- no poner colinas encima de una zona o del hub
	local cerca = (math.sqrt(x * x + z * z) < 140)
	for _, zona in ipairs(Zonas.Lista) do
		if (Vector3.new(x, 0, z) - Vector3.new(zona.centro.X, 0, zona.centro.Z)).Magnitude < zona.radio + 60 then
			cerca = true
		end
	end
	if not cerca then
		Terrain:FillBall(Vector3.new(x, math.random(-6, 4), z), math.random(20, 55), Enum.Material.Grass)
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. CAMINOS DE TIERRA HACIA CADA ZONA                  │
-- └──────────────────────────────────────────────────────┘
for _, zona in ipairs(Zonas.Lista) do
	local destino = Vector3.new(zona.centro.X, 0, zona.centro.Z)
	if destino.Magnitude > 1 then
		local dir = destino.Unit
		local inicio = dir * 120
		local fin = destino - dir * (zona.radio - 5)
		local medio = (inicio + fin) / 2
		local largo = (fin - inicio).Magnitude
		local cf = CFrame.lookAt(Vector3.new(medio.X, -3, medio.Z), Vector3.new(fin.X, -3, fin.Z))
		Terrain:FillBlock(cf, Vector3.new(22, 6, largo), Enum.Material.Ground)
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 3. HUB (plaza, spawn, carteles)                       │
-- └──────────────────────────────────────────────────────┘
-- Plaza de piedra (cilindro de terreno) en el centro.
disco(0, 0, 0, 110, 4, Enum.Material.Pavement)

-- Plataforma de mármol decorativa + spawn.
local plaza = parte(Vector3.new(40, 1, 40), Vector3.new(0, 1, 0),
	Color3.fromRGB(225, 225, 235), Enum.Material.Marble)
plaza.Name = "PlazaHub"

local spawn = Instance.new("SpawnLocation")
spawn.Name = "SpawnEchoForge"
spawn.Size = Vector3.new(12, 1, 12)
spawn.Position = Vector3.new(0, 2, 40)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(120, 220, 255)
spawn.Transparency = 0.2
spawn.Parent = mapa

-- Pedestal de la forja (la forja la coloca ForgeManager en 0,3,-20).
parte(Vector3.new(16, 1.5, 16), Vector3.new(0, 1.2, -20),
	Color3.fromRGB(70, 65, 70), Enum.Material.Cobblestone)

-- Monumento central giratorio (gran Eco).
local nucleo = parte(Vector3.new(8, 8, 8), Vector3.new(0, 14, 0),
	Color3.fromRGB(90, 210, 255), Enum.Material.Neon)
nucleo.Shape = Enum.PartType.Ball
luz(nucleo, Color3.fromRGB(90, 210, 255), 2.5, 30)
task.spawn(function()
	while nucleo and nucleo.Parent do
		nucleo.CFrame = nucleo.CFrame * CFrame.Angles(0, math.rad(0.6), 0)
		task.wait()
	end
end)

-- Carteles que apuntan a cada zona.
for _, zona in ipairs(Zonas.Lista) do
	local dir = Vector3.new(zona.centro.X, 0, zona.centro.Z)
	if dir.Magnitude > 1 then
		dir = dir.Unit
		local pos = dir * 95
		local poste = parte(Vector3.new(1, 7, 1), Vector3.new(pos.X, 4.5, pos.Z),
			Color3.fromRGB(90, 70, 45), Enum.Material.WoodPlanks)
		local cartel = Instance.new("BillboardGui")
		cartel.Size = UDim2.new(0, 200, 0, 46)
		cartel.StudsOffset = Vector3.new(0, 4, 0)
		cartel.AlwaysOnTop = true
		cartel.Parent = poste
		local t = Instance.new("TextLabel")
		t.Size = UDim2.new(1, 0, 1, 0)
		t.BackgroundTransparency = 1
		t.Text = "➜ " .. zona.nombre
		t.TextColor3 = zona.color
		t.TextStrokeTransparency = 0.3
		t.TextScaled = true
		t.Font = Enum.Font.FredokaOne
		t.Parent = cartel
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 4. VOLCÁN REAL (cono de basalto + cráter + lava)      │
-- └──────────────────────────────────────────────────────┘
local function construirVolcan(zona)
	local cx, cz = zona.centro.X, zona.centro.Z
	local radioCrater = zona.radio + 8
	local H = 150
	local radioBase = radioCrater + 95
	local pasos = 30

	-- Cono macizo: discos apilados que se estrechan al subir.
	for i = 0, pasos do
		local t = i / pasos
		local y = t * H
		local r = radioBase * (1 - t) + 12
		disco(cx, y, cz, r, 9, Enum.Material.Basalt)
	end

	-- Vaciamos el cráter (columna de aire central).
	Terrain:FillCylinder(CFrame.new(cx, H / 2, cz), H + 30, radioCrater, Enum.Material.Air)
	-- Suelo del cráter (basalto a y=0).
	disco(cx, 0, cz, radioCrater + 4, 8, Enum.Material.Basalt)
	-- Lago de lava en el centro.
	disco(cx, 1.5, cz, radioCrater - 14, 4, Enum.Material.CrackedLava)

	-- Túnel de entrada hacia el hub (lado que mira al centro del mapa).
	local dir = Vector3.new(cx, 0, cz).Unit
	local mouth = Vector3.new(cx, 14, cz) - dir * (radioBase + 10)
	local cf = CFrame.lookAt(mouth, Vector3.new(cx, 14, cz))
	Terrain:FillBlock(cf, Vector3.new(34, 28, radioBase + 60), Enum.Material.Air)

	-- Resplandor de la lava (varias luces).
	for i = 1, 4 do
		local a = (i / 4) * math.pi * 2
		local lp = parte(Vector3.new(1, 1, 1),
			Vector3.new(cx + math.cos(a) * (radioCrater - 20), 4, cz + math.sin(a) * (radioCrater - 20)),
			Color3.fromRGB(255, 120, 40), Enum.Material.Neon)
		lp.Transparency = 1
		luz(lp, Color3.fromRGB(255, 110, 35), 3, 40)
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 5. CUEVA REAL (domo de roca hueco + túnel)            │
-- └──────────────────────────────────────────────────────┘
local function cristal(pos)
	local alto = math.random(6, 16)
	local c = parte(Vector3.new(2.4, alto, 2.4), pos + Vector3.new(0, alto / 2, 0),
		Color3.fromRGB(150, 100, 255), Enum.Material.Neon)
	c.Orientation = Vector3.new(math.random(-15, 15), math.random(0, 360), math.random(-15, 15))
	luz(c, Color3.fromRGB(160, 110, 255), 1.6, 16)
end

local function construirCueva(zona)
	local cx, cz = zona.centro.X, zona.centro.Z
	local radioCamara = zona.radio + 5
	local radioDomo = radioCamara + 75

	-- Domo macizo de roca.
	Terrain:FillBall(Vector3.new(cx, 12, cz), radioDomo, Enum.Material.Rock)
	-- Vaciamos la cámara interior (deja suelo a y≈0).
	Terrain:FillBall(Vector3.new(cx, radioCamara, cz), radioCamara, Enum.Material.Air)
	-- Suelo de roca dentro.
	disco(cx, 0, cz, radioCamara + 6, 8, Enum.Material.Rock)

	-- Túnel de entrada hacia el hub.
	local dir = Vector3.new(cx, 0, cz).Unit
	local mouth = Vector3.new(cx, 14, cz) - dir * (radioDomo + 10)
	local cf = CFrame.lookAt(mouth, Vector3.new(cx, 14, cz))
	Terrain:FillBlock(cf, Vector3.new(30, 26, radioDomo + 40), Enum.Material.Air)

	-- Cristales que iluminan por dentro.
	for i = 1, 22 do
		local a = math.random() * math.pi * 2
		local d = math.random(8, radioCamara - 8)
		cristal(Vector3.new(cx + math.cos(a) * d, 0, cz + math.sin(a) * d))
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 6. TUNDRA (nieve + lago helado)                       │
-- └──────────────────────────────────────────────────────┘
local function construirTundra(zona)
	local cx, cz = zona.centro.X, zona.centro.Z
	-- Manto de nieve (reemplaza la hierba; tapa a y=0).
	Terrain:FillBlock(CFrame.new(cx, -10, cz), Vector3.new(zona.radio * 2.6, 20, zona.radio * 2.6), Enum.Material.Snow)
	-- Colinas de nieve.
	for i = 1, 12 do
		local a = math.random() * math.pi * 2
		local d = math.random(20, zona.radio - 10)
		Terrain:FillBall(Vector3.new(cx + math.cos(a) * d, math.random(-4, 6), cz + math.sin(a) * d),
			math.random(14, 30), Enum.Material.Snow)
	end
	-- Lago helado: hueco + agua + borde de glaciar.
	Terrain:FillCylinder(CFrame.new(cx + 30, -4, cz - 20), 14, 45, Enum.Material.Air)
	Terrain:FillCylinder(CFrame.new(cx + 30, -5, cz - 20), 8, 45, Enum.Material.Water)
	disco(cx + 30, -1, cz - 20, 48, 3, Enum.Material.Glacier)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 7. SKY SANCTUARY (meseta clara + nubes + pilares)     │
-- └──────────────────────────────────────────────────────┘
local function construirCielo(zona)
	local cx, cz = zona.centro.X, zona.centro.Z
	-- Suelo claro (sal = blanquecino).
	Terrain:FillBlock(CFrame.new(cx, -10, cz), Vector3.new(zona.radio * 2.4, 20, zona.radio * 2.4), Enum.Material.Salt)
	-- Pilares de luz.
	for i = 1, 7 do
		local a = (i / 7) * math.pi * 2
		local d = zona.radio * 0.6
		local p = parte(Vector3.new(3, 50, 3),
			Vector3.new(cx + math.cos(a) * d, 25, cz + math.sin(a) * d),
			Color3.fromRGB(255, 240, 170), Enum.Material.Neon)
		p.Transparency = 0.35
		luz(p, Color3.fromRGB(255, 235, 160), 1.4, 18)
	end
	-- Nubes flotantes (bolas blancas semitransparentes).
	for i = 1, 14 do
		local a = math.random() * math.pi * 2
		local d = math.random(10, zona.radio - 6)
		local s = math.random(10, 20)
		local b = parte(Vector3.new(s, s * 0.6, s),
			Vector3.new(cx + math.cos(a) * d, math.random(8, 26), cz + math.sin(a) * d),
			Color3.fromRGB(245, 248, 255), Enum.Material.SmoothPlastic)
		b.Shape = Enum.PartType.Ball
		b.Transparency = 0.15
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 8. PRADERA (charca + ambiente)                        │
-- └──────────────────────────────────────────────────────┘
local function construirPradera(zona)
	local cx, cz = zona.centro.X, zona.centro.Z
	-- Charca de agua.
	Terrain:FillCylinder(CFrame.new(cx - 35, -4, cz + 20), 12, 38, Enum.Material.Air)
	Terrain:FillCylinder(CFrame.new(cx - 35, -5, cz + 20), 7, 38, Enum.Material.Water)
	-- Algunas colinas suaves de hierba.
	for i = 1, 8 do
		local a = math.random() * math.pi * 2
		local d = math.random(20, zona.radio - 15)
		Terrain:FillBall(Vector3.new(cx + math.cos(a) * d, math.random(-4, 5), cz + math.sin(a) * d),
			math.random(14, 28), Enum.Material.Grass)
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 9. MONTAÑAS DEL HORIZONTE                             │
-- └──────────────────────────────────────────────────────┘
local function construirHorizonte()
	for i = 1, 30 do
		local a = (i / 30) * math.pi * 2
		local R = 1250 + math.random(-90, 90)
		local x = math.cos(a) * R
		local z = math.sin(a) * R
		local altura = math.random(140, 280)
		local radio = math.random(130, 220)
		Terrain:FillBall(Vector3.new(x, altura * 0.15, z), radio, Enum.Material.Rock)
		Terrain:FillBall(Vector3.new(x, altura * 0.5, z), radio * 0.62, Enum.Material.Rock)
		Terrain:FillBall(Vector3.new(x, altura * 0.78, z), radio * 0.34, Enum.Material.Snow)
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 10. CONSTRUIR TODO                                    │
-- └──────────────────────────────────────────────────────┘
construirHorizonte()
if Z.Pradera then construirPradera(Z.Pradera) end
if Z.Cuevas then construirCueva(Z.Cuevas) end
if Z.Volcan then construirVolcan(Z.Volcan) end
if Z.Tundra then construirTundra(Z.Tundra) end
if Z.Cielo then construirCielo(Z.Cielo) end

-- ┌──────────────────────────────────────────────────────┐
-- │ 11. ILUMINACIÓN Y EFECTOS                             │
-- └──────────────────────────────────────────────────────┘
local function ponerEfecto(instancia)
	local viejo = Lighting:FindFirstChild(instancia.Name)
	if viejo then viejo:Destroy() end
	instancia.Parent = Lighting
end

Lighting.Technology = Enum.Technology.Future
Lighting.ClockTime = 14.5
Lighting.Brightness = 2.5
Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 140)
Lighting.Ambient = Color3.fromRGB(70, 70, 85)
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1

local atmosfera = Instance.new("Atmosphere")
atmosfera.Name = "AtmosferaEchoForge"
atmosfera.Density = 0.36
atmosfera.Haze = 1.8
atmosfera.Glare = 0.2
atmosfera.Color = Color3.fromRGB(199, 205, 224)
atmosfera.Decay = Color3.fromRGB(106, 112, 125)
ponerEfecto(atmosfera)

local bloom = Instance.new("BloomEffect")
bloom.Name = "BloomEchoForge"
bloom.Intensity = 0.9
bloom.Size = 24
bloom.Threshold = 1.1
ponerEfecto(bloom)

local rayos = Instance.new("SunRaysEffect")
rayos.Name = "RayosEchoForge"
rayos.Intensity = 0.12
rayos.Spread = 0.6
ponerEfecto(rayos)

local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "ColorEchoForge"
cc.Saturation = 0.16
cc.Contrast = 0.06
ponerEfecto(cc)
