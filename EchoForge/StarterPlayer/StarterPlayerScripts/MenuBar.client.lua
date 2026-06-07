--[[
============================================================
  ECHO FORGE — MENÚ LATERAL (barra de la derecha)
  Script: MenuBar
  Tipo:   LocalScript
  Lugar:  StarterPlayer > StarterPlayerScripts
============================================================
  Crea una barra vertical de botones-icono en el lado DERECHO
  (lejos del joystick de móvil). Cada botón abre/cierra su
  panel. Para hablar con los otros scripts de GUI usamos un
  "BindableEvent" llamado MenuToggle: este menú lo dispara y
  cada panel (Shop, Relics, Trade, Store) lo escucha.

  ⚠️ Este script debe existir para que los demás funcionen
  (ellos esperan el MenuToggle). No pasa nada por el orden de
  carga: WaitForChild aguanta hasta que se crea.
============================================================
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ┌──────────────────────────────────────────────────────┐
-- │ EL CANAL INTERNO (BindableEvent)                      │
-- └──────────────────────────────────────────────────────┘
-- Un BindableEvent comunica scripts DEL MISMO lado (cliente).
-- Aquí lo creamos; los paneles lo esperan con WaitForChild.
local menuToggle = Instance.new("BindableEvent")
menuToggle.Name = "MenuToggle"
menuToggle.Parent = playerGui

-- ┌──────────────────────────────────────────────────────┐
-- │ LA BARRA                                              │
-- └──────────────────────────────────────────────────────┘
local gui = Instance.new("ScreenGui")
gui.Name = "MenuBarGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Lista de botones del menú. El "nombre" debe coincidir con
-- el que escucha cada panel (Shop / Relics / Trade / Store).
local items = {
	{ nombre = "Shop",   icono = "🛒", color = Color3.fromRGB(60, 120, 200) },
	{ nombre = "Relics", icono = "🎒", color = Color3.fromRGB(120, 80, 190) },
	{ nombre = "Trade",  icono = "🤝", color = Color3.fromRGB(200, 120, 60) },
	{ nombre = "Store",  icono = "💎", color = Color3.fromRGB(90, 200, 150) },
}

local TAM = 58          -- tamaño de cada botón (px)
local SEP = 10          -- separación entre botones

-- Contenedor anclado al borde derecho, centrado en vertical.
local barra = Instance.new("Frame")
barra.Name = "Barra"
barra.AnchorPoint = Vector2.new(1, 0.5)
barra.Position = UDim2.new(1, -12, 0.5, 0)   -- pegada a la derecha
barra.Size = UDim2.new(0, TAM, 0, #items * TAM + (#items - 1) * SEP)
barra.BackgroundTransparency = 1
barra.Parent = gui

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, SEP)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = barra

-- Creamos un botón redondo por cada item.
for orden, item in ipairs(items) do
	local b = Instance.new("TextButton")
	b.Name = item.nombre
	b.Size = UDim2.new(0, TAM, 0, TAM)
	b.LayoutOrder = orden
	b.BackgroundColor3 = item.color
	b.Text = item.icono
	b.TextScaled = true
	b.Font = Enum.Font.FredokaOne
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.AutoButtonColor = true
	b.Parent = barra

	-- Esquinas muy redondeadas (casi circular).
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(0, 14)
	esquina.Parent = b

	-- Un borde sutil para que destaque sobre el mundo.
	local borde = Instance.new("UIStroke")
	borde.Color = Color3.fromRGB(255, 255, 255)
	borde.Thickness = 2
	borde.Transparency = 0.6
	borde.Parent = b

	-- Al pulsar, avisamos a todos los paneles con el nombre.
	-- El panel que coincida se abre/cierra; los demás se cierran.
	b.Activated:Connect(function()
		menuToggle:Fire(item.nombre)
	end)
end
