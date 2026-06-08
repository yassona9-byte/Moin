--[[
============================================================
  ECHO FORGE — SISTEMA 7: HUD + INVENTARIO DE RELIQUIAS
  Script: HudGui
  Tipo:   LocalScript
  Lugar:  StarterPlayer > StarterPlayerScripts
============================================================
  Qué hace, en una frase:
  "Dibuja arriba dos contadores (Echoes con tu capacidad, y
   Coins abreviadas) y un botón 'Relics' que abre un panel
   con cuántas Reliquias tienes de cada rareza, con su color."
============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rarezas = require(ReplicatedStorage:WaitForChild("Rarezas"))
local Mejoras = require(ReplicatedStorage:WaitForChild("Mejoras"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperamos los datos que crea el DataManager.
local leaderstats = player:WaitForChild("leaderstats")
local ecos = leaderstats:WaitForChild("Ecos")
local moneda = leaderstats:WaitForChild("Moneda")
local carpetaMejoras = player:WaitForChild("Mejoras")
local carpetaReliquias = player:WaitForChild("Reliquias")

-- ┌──────────────────────────────────────────────────────┐
-- │ AYUDA: abreviar números grandes (1500 -> "1.5K")      │
-- └──────────────────────────────────────────────────────┘
local function abreviar(n)
	local sufijos = { "", "K", "M", "B", "T" }
	local i = 1
	while n >= 1000 and i < #sufijos do
		n = n / 1000
		i += 1
	end
	if i == 1 then
		return tostring(n)            -- números pequeños, tal cual
	end
	return string.format("%.1f%s", n, sufijos[i])  -- ej. "1.5K"
end

-- ┌──────────────────────────────────────────────────────┐
-- │ LIENZO                                                │
-- └──────────────────────────────────────────────────────┘
local gui = Instance.new("ScreenGui")
gui.Name = "HudGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- ┌──────────────────────────────────────────────────────┐
-- │ HUD SUPERIOR (dos "pastillas": Echoes y Coins)        │
-- └──────────────────────────────────────────────────────┘
-- Un contenedor centrado arriba con layout horizontal.
local hud = Instance.new("Frame")
hud.Size = UDim2.new(0, 320, 0, 50)
hud.Position = UDim2.new(0.5, 0, 0, 12)
hud.AnchorPoint = Vector2.new(0.5, 0)
hud.BackgroundTransparency = 1
hud.Parent = gui

local hudLayout = Instance.new("UIListLayout")
hudLayout.FillDirection = Enum.FillDirection.Horizontal
hudLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hudLayout.VerticalAlignment = Enum.VerticalAlignment.Center
hudLayout.Padding = UDim.new(0, 10)
hudLayout.Parent = hud

-- Función para crear una "pastilla" del HUD y devolver su texto.
local function crearPastilla(colorFondo)
	local pastilla = Instance.new("Frame")
	pastilla.Size = UDim2.new(0, 150, 0, 44)
	pastilla.BackgroundColor3 = colorFondo
	pastilla.Parent = hud
	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(0, 22)
	esquina.Parent = pastilla

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.Text = ""
	label.Parent = pastilla
	return label
end

local labelEcos = crearPastilla(Color3.fromRGB(40, 110, 160))   -- azul
local labelMoneda = crearPastilla(Color3.fromRGB(180, 140, 40)) -- dorado

-- ── Actualizadores ──
local function actualizarEcos()
	-- Capacidad según el nivel de la mejora Mochila.
	local capacidad = Mejoras.capacidadMochila(carpetaMejoras.Mochila.Value)
	labelEcos.Text = "💠 " .. ecos.Value .. " / " .. capacidad
end

local function actualizarMoneda()
	labelMoneda.Text = "🪙 " .. abreviar(moneda.Value)
end

-- .Changed se dispara cuando el valor cambia: así el HUD se
-- actualiza solo, en tiempo real, sin un bucle.
ecos.Changed:Connect(actualizarEcos)
carpetaMejoras.Mochila.Changed:Connect(actualizarEcos)
moneda.Changed:Connect(actualizarMoneda)
actualizarEcos()
actualizarMoneda()

-- ┌──────────────────────────────────────────────────────┐
-- │ PANEL DE RELIQUIAS                                    │
-- └──────────────────────────────────────────────────────┘
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 320, 0, 300)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
panel.Visible = false
panel.Parent = gui
local panelEsquina = Instance.new("UICorner")
panelEsquina.CornerRadius = UDim.new(0, 14)
panelEsquina.Parent = panel

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -50, 0, 40)
titulo.Position = UDim2.new(0, 10, 0, 4)
titulo.BackgroundTransparency = 1
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.Font = Enum.Font.FredokaOne
titulo.TextScaled = true
titulo.Text = "🎒 Relics"
titulo.Parent = panel

local cerrar = Instance.new("TextButton")
cerrar.Size = UDim2.new(0, 34, 0, 34)
cerrar.Position = UDim2.new(1, -40, 0, 6)
cerrar.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
cerrar.TextColor3 = Color3.fromRGB(255, 255, 255)
cerrar.Font = Enum.Font.FredokaOne
cerrar.TextScaled = true
cerrar.Text = "X"
cerrar.Parent = panel
local ceEsquina = Instance.new("UICorner")
ceEsquina.CornerRadius = UDim.new(0, 8)
ceEsquina.Parent = cerrar

local lista = Instance.new("Frame")
lista.Position = UDim2.new(0, 10, 0, 50)
lista.Size = UDim2.new(1, -20, 1, -60)
lista.BackgroundTransparency = 1
lista.Parent = panel
local listaLayout = Instance.new("UIListLayout")
listaLayout.Padding = UDim.new(0, 6)
listaLayout.Parent = lista

-- Creamos una fila por rareza (en orden) y guardamos su label.
local filasReliquias = {}
for orden, nombre in ipairs(Rarezas.Lista) do
	local ficha = Rarezas.Datos[nombre]

	local fila = Instance.new("Frame")
	fila.Size = UDim2.new(1, 0, 0, 42)
	fila.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
	fila.LayoutOrder = orden
	fila.Parent = lista
	local fe = Instance.new("UICorner")
	fe.CornerRadius = UDim.new(0, 8)
	fe.Parent = fila

	-- Cuadradito del color de la rareza, a la izquierda.
	local muestra = Instance.new("Frame")
	muestra.Size = UDim2.new(0, 26, 0, 26)
	muestra.Position = UDim2.new(0, 8, 0.5, 0)
	muestra.AnchorPoint = Vector2.new(0, 0.5)
	muestra.BackgroundColor3 = ficha.color
	muestra.Parent = fila
	local me = Instance.new("UICorner")
	me.CornerRadius = UDim.new(0, 6)
	me.Parent = muestra

	-- Texto "Common ........ x3".
	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.new(1, -50, 1, 0)
	texto.Position = UDim2.new(0, 44, 0, 0)
	texto.BackgroundTransparency = 1
	texto.TextXAlignment = Enum.TextXAlignment.Left
	texto.TextColor3 = ficha.color
	texto.Font = Enum.Font.FredokaOne
	texto.TextScaled = true
	texto.Parent = fila

	filasReliquias[nombre] = texto
end

-- Refresca los textos de cantidades.
local function refrescarReliquias()
	for _, nombre in ipairs(Rarezas.Lista) do
		local ficha = Rarezas.Datos[nombre]
		local cantidad = carpetaReliquias:FindFirstChild(nombre).Value
		filasReliquias[nombre].Text = ficha.nombre .. "   x" .. cantidad
	end
end

-- Canal del menú "a prueba de fallos": si MenuBar no lo creó,
-- lo creamos aquí para no colgarnos ni perder el HUD.
local menuToggle = playerGui:FindFirstChild("MenuToggle")
if not menuToggle then
	menuToggle = Instance.new("BindableEvent")
	menuToggle.Name = "MenuToggle"
	menuToggle.Parent = playerGui
end

-- La barra de menú nos avisa: si es "Relics", alternamos.
menuToggle.Event:Connect(function(nombre)
	if nombre == "Relics" then
		panel.Visible = not panel.Visible
		if panel.Visible then refrescarReliquias() end
	else
		panel.Visible = false
	end
end)
cerrar.Activated:Connect(function()
	panel.Visible = false
end)

-- Si cambia cualquier contador de reliquias, refrescamos (si abierto).
for _, nombre in ipairs(Rarezas.Lista) do
	carpetaReliquias:FindFirstChild(nombre).Changed:Connect(function()
		if panel.Visible then
			refrescarReliquias()
		end
	end)
end
