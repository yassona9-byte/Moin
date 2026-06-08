--[[
============================================================
  ECHO FORGE — JUICE (sonidos + celebraciones)
  Script: JuiceManager
  Tipo:   LocalScript
  Lugar:  StarterPlayer > StarterPlayerScripts
============================================================
  Da "vida" al juego SIN tocar los demás scripts: se entera
  de lo que pasa mirando cómo cambian tus datos.
   - Suben tus Ecos     -> sonido de recoger.
   - Baja tu Moneda     -> sonido de compra.
   - Sube una Reliquia  -> sonido de forja; y si es Legendary
                           o Mythic, celebración a pantalla.
   - Música de fondo en bucle (si pones un id en Sonidos).
============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Rarezas = require(ReplicatedStorage:WaitForChild("Rarezas"))
local Sonidos = require(ReplicatedStorage:WaitForChild("Sonidos"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local leaderstats = player:WaitForChild("leaderstats")
local ecos = leaderstats:WaitForChild("Ecos")
local moneda = leaderstats:WaitForChild("Moneda")
local carpetaReliquias = player:WaitForChild("Reliquias")

-- ┌──────────────────────────────────────────────────────┐
-- │ REPRODUCIR UN SONIDO                                   │
-- └──────────────────────────────────────────────────────┘
-- Crea un Sound temporal, lo reproduce y lo borra solo.
-- "velocidad" cambia el tono (para variar el sonido de recoger).
local function reproducir(id, volumen, velocidad)
	if not id or id == "" then return end
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = volumen or 0.5
	s.PlaybackSpeed = velocidad or 1
	s.Parent = SoundService
	s:Play()
	Debris:AddItem(s, 6)   -- se autodestruye a los 6s
end

-- Música de fondo (si hay id).
if Sonidos.musica and Sonidos.musica ~= "" then
	local m = Instance.new("Sound")
	m.SoundId = Sonidos.musica
	m.Looped = true
	m.Volume = Sonidos.volumenMusica or 0.25
	m.Parent = SoundService
	m:Play()
end

-- ┌──────────────────────────────────────────────────────┐
-- │ GUI DE CELEBRACIÓN (flash + texto gigante)            │
-- └──────────────────────────────────────────────────────┘
local gui = Instance.new("ScreenGui")
gui.Name = "JuiceGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Flash de color a pantalla completa (no bloquea clics).
local flash = Instance.new("Frame")
flash.Size = UDim2.new(1, 0, 1, 0)
flash.BackgroundColor3 = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.Active = false
flash.ZIndex = 50
flash.Parent = gui

-- Texto gigante centrado (ej. "MYTHIC!").
local granTexto = Instance.new("TextLabel")
granTexto.AnchorPoint = Vector2.new(0.5, 0.5)
granTexto.Position = UDim2.new(0.5, 0, 0.35, 0)
granTexto.Size = UDim2.new(0.85, 0, 0, 110)
granTexto.BackgroundTransparency = 1
granTexto.Font = Enum.Font.FredokaOne
granTexto.TextScaled = true
granTexto.TextStrokeTransparency = 0.3
granTexto.TextTransparency = 1
granTexto.Text = ""
granTexto.ZIndex = 51
granTexto.Parent = gui

local function celebrar(nombre, color)
	-- Flash de color que se desvanece.
	flash.BackgroundColor3 = color
	flash.BackgroundTransparency = 0.45
	TweenService:Create(flash, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()

	-- Texto que "salta" (efecto Back) y luego se desvanece.
	granTexto.Text = string.upper(nombre) .. "!"
	granTexto.TextColor3 = color
	granTexto.TextTransparency = 0
	granTexto.Size = UDim2.new(0.4, 0, 0, 60)
	TweenService:Create(granTexto,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = UDim2.new(0.9, 0, 0, 120) }):Play()
	task.delay(0.9, function()
		TweenService:Create(granTexto, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
	end)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ RECOGER ECOS -> sonido (suave, con tono variado)      │
-- └──────────────────────────────────────────────────────┘
local ultimoRecoger = 0
local ecosPrev = ecos.Value
ecos.Changed:Connect(function(nuevo)
	if nuevo > ecosPrev then
		-- Limitamos a ~12 por segundo para no saturar.
		local ahora = os.clock()
		if ahora - ultimoRecoger > 0.08 then
			ultimoRecoger = ahora
			reproducir(Sonidos.recoger, 0.3, 0.95 + math.random() * 0.2)
		end
	end
	ecosPrev = nuevo
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ GASTAR MONEDA -> sonido de compra                     │
-- └──────────────────────────────────────────────────────┘
local monedaPrev = moneda.Value
moneda.Changed:Connect(function(nuevo)
	if nuevo < monedaPrev then          -- bajó = compraste algo
		reproducir(Sonidos.comprar, 0.5)
	end
	monedaPrev = nuevo
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ FORJAR RELIQUIA -> sonido (+ celebración si es buena) │
-- └──────────────────────────────────────────────────────┘
for _, nombre in ipairs(Rarezas.Lista) do
	local contador = carpetaReliquias:WaitForChild(nombre)
	local prev = contador.Value
	contador.Changed:Connect(function(nuevo)
		if nuevo > prev then
			reproducir(Sonidos.forjar, 0.5)
			-- Las rarezas top merecen fiesta.
			if nombre == "Legendaria" or nombre == "Mitica" then
				local ficha = Rarezas.Datos[nombre]
				celebrar(ficha.nombre, ficha.color)
				reproducir(Sonidos.rareza_alta, 0.7)
			end
		end
		prev = nuevo
	end)
end
