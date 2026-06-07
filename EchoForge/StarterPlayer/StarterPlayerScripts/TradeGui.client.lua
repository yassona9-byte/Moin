--[[
============================================================
  ECHO FORGE — SISTEMA 8: TRADING (la interfaz)
  Script: TradeGui
  Tipo:   LocalScript
  Lugar:  StarterPlayer > StarterPlayerScripts
============================================================
  Dibuja: el botón "Trade", la lista de jugadores para pedir
  trade, el aviso de solicitud entrante (Accept/Decline) y la
  ventana de intercambio con las dos ofertas y los botones.
  Solo PIDE cosas al servidor; el servidor decide todo.
============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rarezas = require(ReplicatedStorage:WaitForChild("Rarezas"))
local remotes = ReplicatedStorage:WaitForChild("TradeRemotes")
local rRequest = remotes:WaitForChild("Request")
local rRespond = remotes:WaitForChild("Respond")
local rUpdate  = remotes:WaitForChild("Update")
local rConfirm = remotes:WaitForChild("Confirm")
local rCancel  = remotes:WaitForChild("Cancel")
local rEvent   = remotes:WaitForChild("Event")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local menuToggle = playerGui:WaitForChild("MenuToggle")
local carpetaReliquias = player:WaitForChild("Reliquias")

-- Guardamos el último estado para los botones de confirmar.
local confirmadoMio = false

local gui = Instance.new("ScreenGui")
gui.Name = "TradeGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Pequeña ayuda para crear botones con esquinas redondeadas.
local function boton(texto, tamano, posicion, color, padre)
	local b = Instance.new("TextButton")
	b.Size = tamano
	b.Position = posicion
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.FredokaOne
	b.TextScaled = true
	b.Text = texto
	b.Parent = padre
	local e = Instance.new("UICorner")
	e.CornerRadius = UDim.new(0, 8)
	e.Parent = b
	return b
end

-- (El botón "Trade" lo gestiona ahora la barra de menú de la
--  derecha, vía "MenuToggle".)

-- ┌──────────────────────────────────────────────────────┐
-- │ PANEL: LISTA DE JUGADORES                             │
-- └──────────────────────────────────────────────────────┘
local listaPanel = Instance.new("Frame")
listaPanel.Size = UDim2.new(0, 280, 0, 280)
listaPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
listaPanel.AnchorPoint = Vector2.new(0.5, 0.5)
listaPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
listaPanel.Visible = false
listaPanel.Parent = gui
local lpEsq = Instance.new("UICorner"); lpEsq.CornerRadius = UDim.new(0, 12); lpEsq.Parent = listaPanel

local lpTitulo = Instance.new("TextLabel")
lpTitulo.Size = UDim2.new(1, -50, 0, 36)
lpTitulo.Position = UDim2.new(0, 10, 0, 4)
lpTitulo.BackgroundTransparency = 1
lpTitulo.TextXAlignment = Enum.TextXAlignment.Left
lpTitulo.TextColor3 = Color3.fromRGB(255, 255, 255)
lpTitulo.Font = Enum.Font.FredokaOne
lpTitulo.TextScaled = true
lpTitulo.Text = "Trade with..."
lpTitulo.Parent = listaPanel

boton("X", UDim2.new(0, 32, 0, 32), UDim2.new(1, -38, 0, 6), Color3.fromRGB(200, 60, 60), listaPanel)
	.Activated:Connect(function() listaPanel.Visible = false end)

local lpScroll = Instance.new("ScrollingFrame")
lpScroll.Position = UDim2.new(0, 10, 0, 44)
lpScroll.Size = UDim2.new(1, -20, 1, -54)
lpScroll.BackgroundTransparency = 1
lpScroll.BorderSizePixel = 0
lpScroll.ScrollBarThickness = 5
lpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
lpScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
lpScroll.Parent = listaPanel
local lpLayout = Instance.new("UIListLayout")
lpLayout.Padding = UDim.new(0, 6)
lpLayout.Parent = lpScroll

local function rellenarLista()
	for _, hijo in ipairs(lpScroll:GetChildren()) do
		if hijo:IsA("TextButton") then hijo:Destroy() end
	end
	for _, otro in ipairs(Players:GetPlayers()) do
		if otro ~= player then
			local b = boton(otro.DisplayName, UDim2.new(1, 0, 0, 40), UDim2.new(), Color3.fromRGB(60, 120, 200), lpScroll)
			b.Activated:Connect(function()
				rRequest:FireServer(otro.UserId)
				listaPanel.Visible = false
			end)
		end
	end
end

menuToggle.Event:Connect(function(nombre)
	if nombre == "Trade" then
		rellenarLista()
		listaPanel.Visible = not listaPanel.Visible
	else
		listaPanel.Visible = false
	end
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ AVISO DE SOLICITUD ENTRANTE                           │
-- └──────────────────────────────────────────────────────┘
local incoming = Instance.new("Frame")
incoming.Size = UDim2.new(0, 300, 0, 90)
incoming.Position = UDim2.new(0.5, 0, 0, 120)
incoming.AnchorPoint = Vector2.new(0.5, 0)
incoming.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
incoming.Visible = false
incoming.Parent = gui
local inEsq = Instance.new("UICorner"); inEsq.CornerRadius = UDim.new(0, 10); inEsq.Parent = incoming

local inTexto = Instance.new("TextLabel")
inTexto.Size = UDim2.new(1, -10, 0, 40)
inTexto.Position = UDim2.new(0, 5, 0, 4)
inTexto.BackgroundTransparency = 1
inTexto.TextColor3 = Color3.fromRGB(255, 255, 255)
inTexto.Font = Enum.Font.FredokaOne
inTexto.TextScaled = true
inTexto.Text = ""
inTexto.Parent = incoming

boton("Accept", UDim2.new(0.45, 0, 0, 34), UDim2.new(0.03, 0, 1, -40), Color3.fromRGB(60, 170, 90), incoming)
	.Activated:Connect(function()
		incoming.Visible = false
		rRespond:FireServer(true)
	end)
boton("Decline", UDim2.new(0.45, 0, 0, 34), UDim2.new(0.52, 0, 1, -40), Color3.fromRGB(200, 60, 60), incoming)
	.Activated:Connect(function()
		incoming.Visible = false
		rRespond:FireServer(false)
	end)

-- ┌──────────────────────────────────────────────────────┐
-- │ VENTANA DE TRADE                                      │
-- └──────────────────────────────────────────────────────┘
local trade = Instance.new("Frame")
trade.Size = UDim2.new(0, 380, 0, 380)
trade.Position = UDim2.new(0.5, 0, 0.5, 0)
trade.AnchorPoint = Vector2.new(0.5, 0.5)
trade.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
trade.Visible = false
trade.Parent = gui
local trEsq = Instance.new("UICorner"); trEsq.CornerRadius = UDim.new(0, 14); trEsq.Parent = trade

local trTitulo = Instance.new("TextLabel")
trTitulo.Size = UDim2.new(1, -20, 0, 34)
trTitulo.Position = UDim2.new(0, 10, 0, 6)
trTitulo.BackgroundTransparency = 1
trTitulo.TextColor3 = Color3.fromRGB(255, 255, 255)
trTitulo.Font = Enum.Font.FredokaOne
trTitulo.TextScaled = true
trTitulo.Text = "Trade"
trTitulo.Parent = trade

-- Cabeceras de columnas.
local cabecera = Instance.new("TextLabel")
cabecera.Size = UDim2.new(1, -20, 0, 20)
cabecera.Position = UDim2.new(0, 10, 0, 42)
cabecera.BackgroundTransparency = 1
cabecera.TextColor3 = Color3.fromRGB(180, 180, 200)
cabecera.Font = Enum.Font.Gotham
cabecera.TextSize = 14
cabecera.Text = "Rarity            You            Them"
cabecera.Parent = trade

-- Contenedor de filas (una por rareza).
local filasCont = Instance.new("Frame")
filasCont.Position = UDim2.new(0, 10, 0, 66)
filasCont.Size = UDim2.new(1, -20, 0, 240)
filasCont.BackgroundTransparency = 1
filasCont.Parent = trade
local filasLayout = Instance.new("UIListLayout")
filasLayout.Padding = UDim.new(0, 4)
filasLayout.Parent = filasCont

local filas = {}
for orden, nombre in ipairs(Rarezas.Lista) do
	local ficha = Rarezas.Datos[nombre]
	local fila = Instance.new("Frame")
	fila.Size = UDim2.new(1, 0, 0, 42)
	fila.BackgroundColor3 = Color3.fromRGB(42, 42, 60)
	fila.LayoutOrder = orden
	fila.Parent = filasCont
	local fe = Instance.new("UICorner"); fe.CornerRadius = UDim.new(0, 6); fe.Parent = fila

	-- Nombre de la rareza (con su color).
	local etq = Instance.new("TextLabel")
	etq.Size = UDim2.new(0, 110, 1, 0)
	etq.Position = UDim2.new(0, 8, 0, 0)
	etq.BackgroundTransparency = 1
	etq.TextXAlignment = Enum.TextXAlignment.Left
	etq.TextColor3 = ficha.color
	etq.Font = Enum.Font.FredokaOne
	etq.TextScaled = true
	etq.Text = ficha.nombre
	etq.Parent = fila

	-- Botón menos, cantidad mía, botón más.
	local menos = boton("-", UDim2.new(0, 26, 0, 26), UDim2.new(0, 120, 0.5, -13), Color3.fromRGB(120, 70, 70), fila)
	local miN = Instance.new("TextLabel")
	miN.Size = UDim2.new(0, 30, 1, 0)
	miN.Position = UDim2.new(0, 148, 0, 0)
	miN.BackgroundTransparency = 1
	miN.TextColor3 = Color3.fromRGB(255, 255, 255)
	miN.Font = Enum.Font.FredokaOne
	miN.TextScaled = true
	miN.Text = "0"
	miN.Parent = fila
	local mas = boton("+", UDim2.new(0, 26, 0, 26), UDim2.new(0, 180, 0.5, -13), Color3.fromRGB(70, 140, 80), fila)

	-- Cantidad del otro.
	local otroN = Instance.new("TextLabel")
	otroN.Size = UDim2.new(0, 60, 1, 0)
	otroN.Position = UDim2.new(1, -66, 0, 0)
	otroN.BackgroundTransparency = 1
	otroN.TextColor3 = Color3.fromRGB(220, 220, 230)
	otroN.Font = Enum.Font.FredokaOne
	otroN.TextScaled = true
	otroN.Text = "0"
	otroN.Parent = fila

	menos.Activated:Connect(function() rUpdate:FireServer(nombre, -1) end)
	mas.Activated:Connect(function() rUpdate:FireServer(nombre, 1) end)

	filas[nombre] = { miN = miN, otroN = otroN }
end

-- Estado de confirmaciones.
local estados = Instance.new("TextLabel")
estados.Size = UDim2.new(1, -20, 0, 22)
estados.Position = UDim2.new(0, 10, 1, -68)
estados.BackgroundTransparency = 1
estados.TextColor3 = Color3.fromRGB(230, 230, 240)
estados.Font = Enum.Font.Gotham
estados.TextSize = 15
estados.Text = "You: …   Them: …"
estados.Parent = trade

local botonConfirm = boton("Confirm", UDim2.new(0.45, 0, 0, 36), UDim2.new(0.03, 0, 1, -42), Color3.fromRGB(60, 170, 90), trade)
local botonCancel = boton("Cancel", UDim2.new(0.45, 0, 0, 36), UDim2.new(0.52, 0, 1, -42), Color3.fromRGB(200, 60, 60), trade)

botonConfirm.Activated:Connect(function()
	-- Alternamos: si no estaba confirmado, confirmamos; y viceversa.
	rConfirm:FireServer(not confirmadoMio)
end)
botonCancel.Activated:Connect(function()
	rCancel:FireServer()
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ RECIBIR EVENTOS DEL SERVIDOR                          │
-- └──────────────────────────────────────────────────────┘
rEvent.OnClientEvent:Connect(function(tipo, datos)
	if tipo == "incoming" then
		inTexto.Text = datos.fromName .. " wants to trade!"
		incoming.Visible = true

	elseif tipo == "started" then
		trTitulo.Text = "Trade with " .. datos.otro
		confirmadoMio = false
		trade.Visible = true
		listaPanel.Visible = false

	elseif tipo == "state" then
		confirmadoMio = datos.confMio
		for _, nombre in ipairs(Rarezas.Lista) do
			local f = filas[nombre]
			f.miN.Text = tostring((datos.mia and datos.mia[nombre]) or 0)
			f.otroN.Text = tostring((datos.otro and datos.otro[nombre]) or 0)
		end
		local tu = datos.confMio and "✅" or "…"
		local el = datos.confOtro and "✅" or "…"
		estados.Text = "You: " .. tu .. "   Them: " .. el
		-- El botón cambia según tu confirmación.
		if datos.confMio then
			botonConfirm.Text = "Confirmed ✅"
			botonConfirm.BackgroundColor3 = Color3.fromRGB(40, 120, 65)
		else
			botonConfirm.Text = "Confirm"
			botonConfirm.BackgroundColor3 = Color3.fromRGB(60, 170, 90)
		end

	elseif tipo == "closed" then
		trade.Visible = false
		confirmadoMio = false
	end
end)
