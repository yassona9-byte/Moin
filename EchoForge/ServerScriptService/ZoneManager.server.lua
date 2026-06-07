--[[
============================================================
  ECHO FORGE — SISTEMA 6: ZONAS (puertas y desbloqueos)
  Script: ZoneManager
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Qué hace, en una frase:
  "Construye una puerta con botón para cada zona de pago y,
   cuando un jugador la activa, le cobra la Moneda y le marca
   esa zona como desbloqueada."
============================================================
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Zonas = require(ReplicatedStorage:WaitForChild("Zonas"))
local notificar = ReplicatedStorage:WaitForChild("Notificar")

-- ┌──────────────────────────────────────────────────────┐
-- │ DESBLOQUEAR UNA ZONA PARA UN JUGADOR                  │
-- └──────────────────────────────────────────────────────┘
local function desbloquear(player, zona)
	local leaderstats = player:FindFirstChild("leaderstats")
	local zonasDesbloqueadas = player:FindFirstChild("ZonasDesbloqueadas")
	if not leaderstats or not zonasDesbloqueadas then
		return
	end

	local marca = zonasDesbloqueadas:FindFirstChild(zona.id)
	if not marca then
		return
	end

	-- ¿Ya la tenía? No hacemos nada (ni cobramos).
	if marca.Value then
		return
	end

	-- ¿Puede pagarla?
	if leaderstats.Moneda.Value < zona.precio then
		notificar:FireClient(player, "Not enough Coins!", Color3.fromRGB(200, 60, 60))
		return
	end

	-- Cobramos y desbloqueamos.
	leaderstats.Moneda.Value -= zona.precio
	marca.Value = true
	notificar:FireClient(player, "Zone unlocked: " .. zona.nombre .. "!", zona.color)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ CONSTRUIR LA PUERTA DE UNA ZONA                       │
-- └──────────────────────────────────────────────────────┘
local function construirPuerta(zona)
	-- La zona inicial (precio 0) no necesita puerta.
	if zona.precio <= 0 then
		return
	end

	-- La puerta es una pared translúcida en la "entrada" de la
	-- zona (el borde más cercano al spawn). No bloquea el paso
	-- (CanCollide = false): es un cartel-barrera. Quien no haya
	-- pagado simplemente no puede recoger los Ecos de dentro.
	local puerta = Instance.new("Part")
	puerta.Name = "Puerta_" .. zona.id
	puerta.Size = Vector3.new(zona.radio * 2, 14, 2)
	puerta.Position = zona.centro + Vector3.new(0, 7, zona.radio)
	puerta.Anchored = true
	puerta.CanCollide = false
	puerta.Material = Enum.Material.ForceField
	puerta.Color = zona.color
	puerta.Parent = Workspace

	-- Cartel flotante con el nombre de la zona.
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.new(0, 260, 0, 60)
	cartel.StudsOffset = Vector3.new(0, 6, 0)
	cartel.AlwaysOnTop = true
	cartel.Parent = puerta

	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.new(1, 0, 1, 0)
	texto.BackgroundTransparency = 1
	texto.Text = "🔒 " .. zona.nombre
	texto.TextColor3 = Color3.fromRGB(255, 255, 255)
	texto.TextStrokeTransparency = 0.4
	texto.TextScaled = true
	texto.Font = Enum.Font.FredokaOne
	texto.Parent = cartel

	-- Botón de desbloqueo.
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Desbloquear (" .. zona.precio .. " 🪙)"
	prompt.ObjectText = zona.nombre
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 16
	prompt.RequiresLineOfSight = false
	prompt.Parent = puerta

	prompt.Triggered:Connect(function(player)
		desbloquear(player, zona)
	end)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ CONSTRUIR TODAS LAS PUERTAS AL ARRANCAR               │
-- └──────────────────────────────────────────────────────┘
for _, zona in ipairs(Zonas.Lista) do
	construirPuerta(zona)
end
