--[[
============================================================
  ECHO FORGE — MAPA v3: HUB + ZONAS REALES (mundo grande)
  Script: MapBuilder
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Construye un MUNDO con:
    - HUB central (plaza de mármol, monumento giratorio,
      farolas, pedestal de la forja y spawn).
    - 3 caminos que salen del hub hacia las zonas.
    - PRADERA: campo verde con colinas, árboles, flores, charca.
    - CUEVAS: una CUEVA real (domo de roca, entrada, cristales
      que iluminan, estalactitas/estalagmitas).
    - VOLCÁN: un CONO real con cráter, lava cayendo por dentro
      y brasas/humo.
    - Anillo de MONTAÑAS en el horizonte que enmarca todo.
    - Iluminación Future con niebla, bloom y rayos de sol.

  La forja (ForgeManager) y las puertas (ZoneManager) las
  ponen sus scripts; este construye TODO el escenario.
  Lee las posiciones de las zonas desde el módulo Zonas.
============================================================
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Zonas = require(ReplicatedStorage:WaitForChild("Zonas"))

local SUELO = 0.1               -- altura de la superficie pisable
local HUB_RADIO = 55            -- radio de la plaza central
local MAX_LUCES = 26            -- tope de luces dinámicas (rendimiento)
local lucesUsadas = 0

-- Mundo más grande => caminar un poco más rápido se agradece.
StarterPlayer.CharacterWalkSpeed = 22

-- ┌──────────────────────────────────────────────────────┐
-- │ 0. LIMPIEZA + CARPETA                                 │
-- └──────────────────────────────────────────────────────┘
for _, nombre in ipairs({ "Baseplate", "SpawnLocation" }) do
	local viejo = Workspace:FindFirstChild(nombre)
	if viejo then viejo:Destroy() end
end
local mapa = Workspace:FindFirstChild("Mapa")
if mapa then mapa:Destroy() end
mapa = Instance.new("Folder")
mapa.Name = "Mapa"
mapa.Parent = Workspace

-- ┌──────────────────────────────────────────────────────┐
-- │ AYUDAS GENERALES                                      │
-- └──────────────────────────────────────────────────────┘
-- Crea un Part anclado y lo mete en el mapa. Devuelve la parte.
local function parte(tamano, posicion, color, material)
	local p = Instance.new("Part")
	p.Size = tamano
	p.Position = posicion
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = mapa
	return p
end

-- Igual pero colocando por CFrame (para cosas giradas: caminos,
-- paredes inclinadas...).
local function parteCF(tamano, cframe, color, material)
	local p = Instance.new("Part")
	p.Size = tamano
	p.CFrame = cframe
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.Parent = mapa
	return p
end

-- Añade una luz puntual (respeta el tope para no matar el FPS).
local function luz(objeto, color, brillo, alcance)
	if lucesUsadas >= MAX_LUCES then return end
	lucesUsadas += 1
	local l = Instance.new("PointLight")
	l.Color = color
	l.Brightness = brillo
	l.Range = alcance
	l.Parent = objeto
end

-- Recorre una circunferencia llamando fn(pos, angulo, i).
local function anillo(centroX, centroZ, radio, y, cantidad, fn)
	for i = 1, cantidad do
		local a = (i / cantidad) * math.pi * 2
		local pos = Vector3.new(centroX + math.cos(a) * radio, y, centroZ + math.sin(a) * radio)
		fn(pos, a, i)
	end
end

-- Punto al azar dentro del disco de una zona.
local function puntoEnZona(zona, margen)
	margen = margen or 6
	local a = math.random() * math.pi * 2
	local d = math.random(margen, zona.radio - 4)
	return Vector3.new(zona.centro.X + math.cos(a) * d, SUELO, zona.centro.Z + math.sin(a) * d)
end

-- Dirección (unitaria) del hub hacia una zona, en el plano.
local function dirHubAZona(zona)
	local v = Vector3.new(zona.centro.X, 0, zona.centro.Z)
	return (v.Magnitude > 0) and v.Unit or Vector3.new(0, 0, 1)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 1. SUELO GIGANTE (base del mundo, sin caídas)         │
-- └──────────────────────────────────────────────────────┘
parte(Vector3.new(1000, 8, 1000), Vector3.new(0, -4, 0),
	Color3.fromRGB(58, 70, 48), Enum.Material.LeafyGrass)

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. CAMINOS DEL HUB A CADA ZONA                        │
-- └──────────────────────────────────────────────────────┘
local function construirCamino(zona)
	local dir = dirHubAZona(zona)
	local inicio = dir * HUB_RADIO                          -- borde del hub
	local entrada = zona.centro - dir * zona.radio          -- borde de la zona
	inicio = Vector3.new(inicio.X, SUELO, inicio.Z)
	entrada = Vector3.new(entrada.X, SUELO, entrada.Z)

	local medio = (inicio + entrada) / 2
	local largo = (entrada - inicio).Magnitude
	-- Camino: losa larga orientada del hub a la zona.
	parteCF(Vector3.new(16, 1, largo),
		CFrame.lookAt(medio, entrada) * CFrame.new(0, -0.5, 0),
		Color3.fromRGB(120, 110, 95), Enum.Material.Sandstone)

	-- Farolas a lo largo del camino.
	local pasos = math.floor(largo / 28)
	for n = 1, pasos do
		local t = n / (pasos + 1)
		local p = inicio:Lerp(entrada, t)
		local perp = Vector3.new(-dir.Z, 0, dir.X) * 10  -- a un lado
		local base = p + perp
		parte(Vector3.new(0.8, 7, 0.8), base + Vector3.new(0, 3.5, 0),
			Color3.fromRGB(40, 40, 45), Enum.Material.Metal)
		local globo = parte(Vector3.new(1.8, 1.8, 1.8), base + Vector3.new(0, 7.2, 0),
			Color3.fromRGB(255, 240, 200), Enum.Material.Neon)
		globo.Shape = Enum.PartType.Ball
		luz(globo, Color3.fromRGB(255, 235, 195), 1.5, 16)
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 3. EL HUB                                             │
-- └──────────────────────────────────────────────────────┘
local function construirHub()
	-- Plaza redonda de mármol (cilindro tumbado).
	local plaza = parteCF(Vector3.new(2, HUB_RADIO * 2, HUB_RADIO * 2),
		CFrame.new(0, SUELO, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(225, 225, 235), Enum.Material.Marble)
	plaza.Shape = Enum.PartType.Cylinder
	plaza.Name = "PlazaHub"

	-- Anillo de pilares con globos de luz alrededor de la plaza.
	anillo(0, 0, HUB_RADIO - 3, SUELO, 12, function(pos)
		parte(Vector3.new(2, 10, 2), pos + Vector3.new(0, 5, 0),
			Color3.fromRGB(210, 210, 220), Enum.Material.Marble)
		local globo = parte(Vector3.new(2.4, 2.4, 2.4), pos + Vector3.new(0, 10.5, 0),
			Color3.fromRGB(150, 220, 255), Enum.Material.Neon)
		globo.Shape = Enum.PartType.Ball
		luz(globo, Color3.fromRGB(150, 220, 255), 1.2, 16)
	end)

	-- Monumento central: pedestal + gran Eco flotante que GIRA.
	parte(Vector3.new(10, 4, 10), Vector3.new(0, SUELO + 2, 0),
		Color3.fromRGB(120, 120, 135), Enum.Material.Marble)
	local nucleo = parte(Vector3.new(7, 7, 7), Vector3.new(0, SUELO + 12, 0),
		Color3.fromRGB(90, 210, 255), Enum.Material.Neon)
	nucleo.Shape = Enum.PartType.Ball
	luz(nucleo, Color3.fromRGB(90, 210, 255), 2.5, 28)
	-- Giro lento del núcleo (bucle ligero, una sola parte).
	task.spawn(function()
		while nucleo and nucleo.Parent do
			nucleo.CFrame = nucleo.CFrame * CFrame.Angles(0, math.rad(0.6), 0)
			task.wait()
		end
	end)

	-- Pedestal de la forja (la forja la pone ForgeManager en 0,3,-20).
	parte(Vector3.new(16, 1.5, 16), Vector3.new(0, SUELO + 0.5, -20),
		Color3.fromRGB(70, 65, 70), Enum.Material.Cobblestone)

	-- Spawn (al borde del hub, mirando al monumento).
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnEchoForge"
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, SUELO + 1, HUB_RADIO - 12)
	spawn.Orientation = Vector3.new(0, 180, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(120, 220, 255)
	spawn.Transparency = 0.2
	spawn.Parent = mapa

	-- Carteles indicadores hacia cada zona.
	for _, zona in ipairs(Zonas.Lista) do
		local dir = dirHubAZona(zona)
		local pos = dir * (HUB_RADIO - 8)
		local poste = parte(Vector3.new(1, 6, 1),
			Vector3.new(pos.X, SUELO + 3, pos.Z), Color3.fromRGB(90, 70, 45), Enum.Material.Wood)
		local cartel = Instance.new("BillboardGui")
		cartel.Size = UDim2.new(0, 170, 0, 44)
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
-- │ 4. DECORACIONES DE PRADERA                            │
-- └──────────────────────────────────────────────────────┘
local function arbol(pos)
	local altura = math.random(6, 11)
	parte(Vector3.new(1.8, altura, 1.8), pos + Vector3.new(0, altura / 2, 0),
		Color3.fromRGB(95, 62, 35), Enum.Material.Wood)
	local copa1 = parte(Vector3.new(9, 9, 9), pos + Vector3.new(0, altura + 1, 0),
		Color3.fromRGB(70, 155, 60), Enum.Material.Grass)
	copa1.Shape = Enum.PartType.Ball
	local copa2 = parte(Vector3.new(6, 6, 6),
		pos + Vector3.new(math.random(-2, 2), altura + 4, math.random(-2, 2)),
		Color3.fromRGB(85, 175, 70), Enum.Material.Grass)
	copa2.Shape = Enum.PartType.Ball
end

local function arbusto(pos)
	local b = parte(Vector3.new(4, 3, 4), pos + Vector3.new(0, 1.4, 0),
		Color3.fromRGB(75, 150, 65), Enum.Material.Grass)
	b.Shape = Enum.PartType.Ball
end

local function flor(pos)
	parte(Vector3.new(0.3, 1.4, 0.3), pos + Vector3.new(0, 0.7, 0),
		Color3.fromRGB(60, 130, 55), Enum.Material.Grass)
	local colores = { Color3.fromRGB(255, 120, 180), Color3.fromRGB(255, 220, 80), Color3.fromRGB(180, 130, 255) }
	local cabeza = parte(Vector3.new(1, 1, 1), pos + Vector3.new(0, 1.6, 0),
		colores[math.random(#colores)], Enum.Material.Neon)
	cabeza.Shape = Enum.PartType.Ball
end

local function colina(pos)
	-- Bola grande medio enterrada = colina suave.
	local s = math.random(20, 36)
	local h = parte(Vector3.new(s, s, s), pos + Vector3.new(0, -s * 0.35, 0),
		Color3.fromRGB(80, 150, 68), Enum.Material.Grass)
	h.Shape = Enum.PartType.Ball
end

local function construirPradera(zona)
	-- Suelo de césped.
	local piso = parteCF(Vector3.new(2, zona.radio * 2 + 16, zona.radio * 2 + 16),
		CFrame.new(zona.centro.X, SUELO - 1, zona.centro.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(92, 162, 78), Enum.Material.Grass)
	piso.Shape = Enum.PartType.Cylinder

	for i = 1, 6 do colina(puntoEnZona(zona, 14)) end
	for i = 1, 14 do arbol(puntoEnZona(zona)) end
	for i = 1, 12 do arbusto(puntoEnZona(zona)) end
	for i = 1, 26 do flor(puntoEnZona(zona)) end

	-- Charca azul translúcida.
	local charca = parteCF(Vector3.new(2, 26, 26),
		CFrame.new(zona.centro.X + 22, SUELO, zona.centro.Z - 18) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(80, 160, 220), Enum.Material.Glass)
	charca.Shape = Enum.PartType.Cylinder
	charca.Transparency = 0.35

	-- Luciérnagas.
	local p = Instance.new("Part")
	p.Size = Vector3.new(zona.radio * 1.7, 12, zona.radio * 1.7)
	p.Position = zona.centro + Vector3.new(0, 7, 0)
	p.Transparency = 1; p.CanCollide = false; p.Anchored = true; p.Parent = mapa
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(Color3.fromRGB(255, 245, 150))
	e.Lifetime = NumberRange.new(2, 4)
	e.Rate = 22
	e.Speed = NumberRange.new(0.4, 1.2)
	e.Size = NumberSequence.new(0.5)
	e.Transparency = NumberSequence.new(0.2)
	e.LightEmission = 1
	e.Parent = p
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 5. LA CUEVA REAL                                      │
-- └──────────────────────────────────────────────────────┘
local function cristal(pos, haciaAbajo)
	local alto = math.random(5, 14)
	local offset = haciaAbajo and -alto / 2 or alto / 2
	local c = parte(Vector3.new(2.2, alto, 2.2), pos + Vector3.new(0, offset, 0),
		Color3.fromRGB(150, 100, 255), Enum.Material.Neon)
	c.Orientation = Vector3.new(math.random(-15, 15), math.random(0, 360), math.random(-15, 15))
	luz(c, Color3.fromRGB(160, 110, 255), 1.6, 13)
end

local function construirCuevas(zona)
	-- Suelo de piedra oscura.
	local piso = parteCF(Vector3.new(2, zona.radio * 2 + 10, zona.radio * 2 + 10),
		CFrame.new(zona.centro.X, SUELO - 1, zona.centro.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(40, 35, 52), Enum.Material.Slate)
	piso.Shape = Enum.PartType.Cylinder

	-- Domo de roca: anillos que suben y se cierran (cúpula).
	-- Dejamos un HUECO en la parte baja que mira al hub = entrada.
	local dir = dirHubAZona(zona)
	local angEntrada = math.atan2(-dir.Z, -dir.X)  -- ángulo hacia el hub
	local niveles = 6
	local altoDomo = 78
	for n = 0, niveles do
		local t = n / niveles
		local rr = (zona.radio + 12) * math.cos(t * (math.pi / 2))
		local yy = altoDomo * math.sin(t * (math.pi / 2))
		local cuantos = math.max(6, math.floor(rr / 4))
		anillo(zona.centro.X, zona.centro.Z, rr, SUELO + yy, cuantos, function(pos, a)
			-- En los 2 anillos más bajos, saltamos el hueco de entrada.
			if n <= 1 then
				local dif = math.abs((a - angEntrada + math.pi) % (math.pi * 2) - math.pi)
				if dif < 0.5 then return end  -- deja la entrada abierta
			end
			local roca = parte(Vector3.new(10, 12, 10), pos,
				Color3.fromRGB(46, 40, 55), Enum.Material.Rock)
			roca.Orientation = Vector3.new(math.random(-10, 10), math.random(0, 360), math.random(-10, 10))
		end)
	end
	-- Tapa superior para cerrar el agujero del centro del domo.
	parte(Vector3.new(40, 8, 40), zona.centro + Vector3.new(0, altoDomo - 2, 0),
		Color3.fromRGB(44, 38, 52), Enum.Material.Rock)

	-- Cristales en el suelo (estalagmitas) y colgando (estalactitas).
	for i = 1, 18 do cristal(puntoEnZona(zona), false) end
	for i = 1, 10 do
		local p = puntoEnZona(zona, 10)
		cristal(Vector3.new(p.X, SUELO + altoDomo * 0.55, p.Z), true)
	end

	-- Destellos morados.
	local pe = Instance.new("Part")
	pe.Size = Vector3.new(zona.radio * 1.5, 30, zona.radio * 1.5)
	pe.Position = zona.centro + Vector3.new(0, 16, 0)
	pe.Transparency = 1; pe.CanCollide = false; pe.Anchored = true; pe.Parent = mapa
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(Color3.fromRGB(180, 130, 255))
	e.Lifetime = NumberRange.new(2, 4)
	e.Rate = 24
	e.Speed = NumberRange.new(0.2, 0.8)
	e.Size = NumberSequence.new(0.45)
	e.Transparency = NumberSequence.new(0.1)
	e.LightEmission = 1
	e.Parent = pe
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 6. EL VOLCÁN REAL                                     │
-- └──────────────────────────────────────────────────────┘
local function construirVolcan(zona)
	-- Suelo del cráter (basalto).
	local piso = parteCF(Vector3.new(2, zona.radio * 2 + 6, zona.radio * 2 + 6),
		CFrame.new(zona.centro.X, SUELO - 1, zona.centro.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(46, 32, 30), Enum.Material.Basalt)
	piso.Shape = Enum.PartType.Cylinder

	-- Pared del cono: anillos que suben e inclinan hacia dentro.
	-- Dejamos un hueco de entrada mirando al hub.
	local dir = dirHubAZona(zona)
	local angEntrada = math.atan2(-dir.Z, -dir.X)
	local niveles = 7
	for n = 0, niveles do
		local rr = zona.radio + 14 - n * 1.6   -- se cierra al subir
		local yy = n * 8
		local cuantos = math.max(10, math.floor(rr / 3.5))
		anillo(zona.centro.X, zona.centro.Z, rr, SUELO + yy, cuantos, function(pos, a)
			if n <= 1 then
				local dif = math.abs((a - angEntrada + math.pi) % (math.pi * 2) - math.pi)
				if dif < 0.45 then return end  -- entrada
			end
			local color = (n >= niveles - 1) and Color3.fromRGB(70, 40, 35) or Color3.fromRGB(55, 38, 35)
			local roca = parte(Vector3.new(11, 12, 11), pos, color, Enum.Material.Basalt)
			roca.Orientation = Vector3.new(math.random(-8, 8), math.random(0, 360), math.random(-8, 8))
		end)
	end

	-- Lava: moat en el borde + charcos + caídas por la pared.
	anillo(zona.centro.X, zona.centro.Z, zona.radio - 4, SUELO + 0.4, 18, function(pos)
		local l = parte(Vector3.new(8, 0.5, 8), pos, Color3.fromRGB(255, 110, 30), Enum.Material.Neon)
		luz(l, Color3.fromRGB(255, 120, 40), 2, 16)
	end)
	for i = 1, 6 do
		local p = puntoEnZona(zona, 8)
		parte(Vector3.new(math.random(7, 12), 0.5, math.random(7, 12)),
			p + Vector3.new(0, 0.35, 0), Color3.fromRGB(255, 120, 35), Enum.Material.Neon)
	end
	-- Cascadas de lava por la pared interior.
	anillo(zona.centro.X, zona.centro.Z, zona.radio - 2, SUELO + 18, 5, function(pos)
		parte(Vector3.new(3, 36, 1.5), pos + Vector3.new(0, 0, 0),
			Color3.fromRGB(255, 100, 25), Enum.Material.Neon)
	end)

	-- Brasas que suben + humo.
	local pe = Instance.new("Part")
	pe.Size = Vector3.new(zona.radio * 1.4, 4, zona.radio * 1.4)
	pe.Position = zona.centro + Vector3.new(0, 2, 0)
	pe.Transparency = 1; pe.CanCollide = false; pe.Anchored = true; pe.Parent = mapa
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(Color3.fromRGB(255, 130, 40))
	e.Lifetime = NumberRange.new(2, 3.5)
	e.Rate = 34
	e.Speed = NumberRange.new(3, 6)
	e.Acceleration = Vector3.new(0, 7, 0)
	e.Size = NumberSequence.new(0.4)
	e.Transparency = NumberSequence.new(0.2)
	e.LightEmission = 1
	e.Parent = pe
	local h = Instance.new("ParticleEmitter")
	h.Color = ColorSequence.new(Color3.fromRGB(70, 60, 60))
	h.Lifetime = NumberRange.new(3, 5)
	h.Rate = 7
	h.Speed = NumberRange.new(2, 4)
	h.Acceleration = Vector3.new(0, 5, 0)
	h.Size = NumberSequence.new(8)
	h.Transparency = NumberSequence.new(0.7)
	h.Parent = pe
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 7. MONTAÑAS DEL HORIZONTE (enmarcan el mundo)         │
-- └──────────────────────────────────────────────────────┘
local function construirHorizonte()
	anillo(0, 0, 430, 0, 30, function(pos)
		local altura = math.random(60, 120)
		local ancho = math.random(70, 120)
		local m = parte(Vector3.new(ancho, altura, ancho), pos + Vector3.new(0, altura / 2 - 10, 0),
			Color3.fromRGB(60, 62, 72), Enum.Material.Rock)
		m.Orientation = Vector3.new(0, math.random(0, 360), 0)
	end)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 8. CONSTRUIR TODO                                     │
-- └──────────────────────────────────────────────────────┘
construirHorizonte()
construirHub()

for _, zona in ipairs(Zonas.Lista) do
	construirCamino(zona)
	if zona.id == "Pradera" then
		construirPradera(zona)
	elseif zona.id == "Cuevas" then
		construirCuevas(zona)
	elseif zona.id == "Volcan" then
		construirVolcan(zona)
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 9. ILUMINACIÓN Y EFECTOS                              │
-- └──────────────────────────────────────────────────────┘
local function ponerEfecto(instancia)
	local viejo = Lighting:FindFirstChild(instancia.Name)
	if viejo then viejo:Destroy() end
	instancia.Parent = Lighting
end

Lighting.Technology = Enum.Technology.Future
Lighting.ClockTime = 14.5
Lighting.Brightness = 2.5
Lighting.OutdoorAmbient = Color3.fromRGB(110, 110, 130)
Lighting.Ambient = Color3.fromRGB(70, 70, 85)
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1

local atmosfera = Instance.new("Atmosphere")
atmosfera.Name = "AtmosferaEchoForge"
atmosfera.Density = 0.34
atmosfera.Offset = 0.2
atmosfera.Haze = 1.6
atmosfera.Glare = 0.2
atmosfera.Color = Color3.fromRGB(199, 205, 224)
atmosfera.Decay = Color3.fromRGB(106, 112, 125)
ponerEfecto(atmosfera)

local bloom = Instance.new("BloomEffect")
bloom.Name = "BloomEchoForge"
bloom.Intensity = 0.95
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
cc.Saturation = 0.18
cc.Contrast = 0.06
cc.Brightness = 0.02
ponerEfecto(cc)
