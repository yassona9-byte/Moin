--[[
============================================================
  ECHO FORGE — SISTEMA 9: TIENDA PREMIUM (la interfaz)
  Script: StoreGui
  Tipo:   LocalScript
  Lugar:  StarterPlayer > StarterPlayerScripts
============================================================
  Botón "Store" + panel con los Game Passes y los Coin Packs.
  Al pulsar comprar, abre el diálogo de compra de Roblox
  (MarketplaceService). El cobro y la entrega los maneja el
  servidor; aquí solo lanzamos el diálogo.
============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Monetizacion = require(ReplicatedStorage:WaitForChild("Monetizacion"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local menuToggle = playerGui:WaitForChild("MenuToggle")

local gui = Instance.new("ScreenGui")
gui.Name = "StoreGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

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

-- (El botón "Store" lo gestiona ahora la barra de menú derecha.)

-- Panel.
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 340, 0, 360)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
panel.Visible = false
panel.Parent = gui
local pe = Instance.new("UICorner"); pe.CornerRadius = UDim.new(0, 14); pe.Parent = panel

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -50, 0, 36)
titulo.Position = UDim2.new(0, 10, 0, 4)
titulo.BackgroundTransparency = 1
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.Font = Enum.Font.FredokaOne
titulo.TextScaled = true
titulo.Text = "💎 Store"
titulo.Parent = panel

boton("X", UDim2.new(0, 32, 0, 32), UDim2.new(1, -38, 0, 6), Color3.fromRGB(200, 60, 60), panel)
	.Activated:Connect(function() panel.Visible = false end)

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0, 10, 0, 46)
scroll.Size = UDim2.new(1, -20, 1, -56)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = panel
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = scroll

-- Crea una fila de producto: textos + botón a la derecha.
local function crearFila(nombre, desc, ordenar)
	local fila = Instance.new("Frame")
	fila.Size = UDim2.new(1, 0, 0, 64)
	fila.BackgroundColor3 = Color3.fromRGB(42, 42, 60)
	fila.LayoutOrder = ordenar
	fila.Parent = scroll
	local fe = Instance.new("UICorner"); fe.CornerRadius = UDim.new(0, 10); fe.Parent = fila

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(0.6, 0, 1, 0)
	info.Position = UDim2.new(0, 10, 0, 0)
	info.BackgroundTransparency = 1
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Center
	info.TextColor3 = Color3.fromRGB(255, 255, 255)
	info.Font = Enum.Font.Gotham
	info.TextSize = 15
	info.TextWrapped = true
	info.Text = nombre .. "\n" .. desc
	info.Parent = fila

	local b = boton("...", UDim2.new(0.34, 0, 0.7, 0), UDim2.new(0.63, 0, 0.15, 0),
		Color3.fromRGB(60, 170, 90), fila)
	return b
end

local orden = 0

-- ── Game Passes ──
for _, g in ipairs(Monetizacion.GamePasses) do
	orden += 1
	local b = crearFila(g.nombre, g.desc, orden)
	if g.id == 0 then
		b.Text = "Soon"
		b.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	else
		-- Función que pone el botón en "Owned" o "Buy".
		local function refrescar()
			if player:GetAttribute(g.clave) then
				b.Text = "Owned ✅"
				b.BackgroundColor3 = Color3.fromRGB(70, 120, 90)
			else
				b.Text = "Buy"
				b.BackgroundColor3 = Color3.fromRGB(60, 170, 90)
			end
		end
		refrescar()
		player:GetAttributeChangedSignal(g.clave):Connect(refrescar)
		b.Activated:Connect(function()
			if not player:GetAttribute(g.clave) then
				MarketplaceService:PromptGamePassPurchase(player, g.id)
			end
		end)
	end
end

-- ── Coin Packs (Developer Products) ──
for _, p in ipairs(Monetizacion.Productos) do
	orden += 1
	local b = crearFila(p.nombre, "+" .. p.moneda .. " Coins", orden)
	if p.id == 0 then
		b.Text = "Soon"
		b.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	else
		b.Text = "Buy"
		b.BackgroundColor3 = Color3.fromRGB(180, 140, 40)
		b.Activated:Connect(function()
			MarketplaceService:PromptProductPurchase(player, p.id)
		end)
	end
end

menuToggle.Event:Connect(function(nombre)
	if nombre == "Store" then
		panel.Visible = not panel.Visible
	else
		panel.Visible = false
	end
end)
