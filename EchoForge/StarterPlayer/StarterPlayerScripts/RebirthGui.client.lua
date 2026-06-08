--[[
============================================================
  ECHO FORGE — REBIRTH (la interfaz)
  Script: RebirthGui
  Tipo:   LocalScript
  Lugar:  StarterPlayer > StarterPlayerScripts
============================================================
  Panel que muestra tus Rebirths, tu multiplicador actual, el
  coste del próximo y un botón para hacer Rebirth. Se abre con
  el icono 🔄 de la barra de menú.
============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rebirth = require(ReplicatedStorage:WaitForChild("Rebirth"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local leaderstats = player:WaitForChild("leaderstats")
local moneda = leaderstats:WaitForChild("Moneda")
local rebirths = leaderstats:WaitForChild("Rebirths")

local gui = Instance.new("ScreenGui")
gui.Name = "RebirthGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- ┌──────────────────────────────────────────────────────┐
-- │ PANEL                                                 │
-- └──────────────────────────────────────────────────────┘
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 320, 0, 280)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
panel.Visible = false
panel.Parent = gui
local pe = Instance.new("UICorner"); pe.CornerRadius = UDim.new(0, 14); pe.Parent = panel

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -50, 0, 40)
titulo.Position = UDim2.new(0, 12, 0, 6)
titulo.BackgroundTransparency = 1
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.TextColor3 = Color3.fromRGB(255, 215, 0)
titulo.Font = Enum.Font.FredokaOne
titulo.TextScaled = true
titulo.Text = "🔄 Rebirth"
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
local ce = Instance.new("UICorner"); ce.CornerRadius = UDim.new(0, 8); ce.Parent = cerrar

-- Texto informativo (rebirths actuales, multiplicador, beneficio).
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -24, 0, 150)
info.Position = UDim2.new(0, 12, 0, 50)
info.BackgroundTransparency = 1
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.TextColor3 = Color3.fromRGB(235, 235, 245)
info.Font = Enum.Font.Gotham
info.TextSize = 17
info.TextWrapped = true
info.Text = ""
info.Parent = panel

-- Botón de Rebirth.
local botonRebirth = Instance.new("TextButton")
botonRebirth.Size = UDim2.new(1, -24, 0, 50)
botonRebirth.Position = UDim2.new(0, 12, 1, -62)
botonRebirth.BackgroundColor3 = Color3.fromRGB(180, 140, 40)
botonRebirth.TextColor3 = Color3.fromRGB(255, 255, 255)
botonRebirth.Font = Enum.Font.FredokaOne
botonRebirth.TextScaled = true
botonRebirth.Text = "Rebirth"
botonRebirth.Parent = panel
local be = Instance.new("UICorner"); be.CornerRadius = UDim.new(0, 10); be.Parent = botonRebirth

-- ┌──────────────────────────────────────────────────────┐
-- │ REFRESCAR TEXTOS                                      │
-- └──────────────────────────────────────────────────────┘
local function refrescar()
	local r = rebirths.Value
	local multAhora = Rebirth.multiplicador(r)
	local multSig = Rebirth.multiplicador(r + 1)
	local coste = Rebirth.coste(r)

	info.Text = "Rebirths: " .. r
		.. "\nCurrent income bonus: x" .. string.format("%.1f", multAhora)
		.. "\n\nNext Rebirth → x" .. string.format("%.1f", multSig)
		.. "\nCost: " .. coste .. " 🪙"
		.. "\n\n⚠️ Resets Echoes, Coins, Relics and\nUpgrades. Zones are kept."

	if moneda.Value >= coste then
		botonRebirth.Text = "Rebirth! (x" .. string.format("%.1f", multSig) .. ")"
		botonRebirth.BackgroundColor3 = Color3.fromRGB(180, 140, 40)
	else
		botonRebirth.Text = "Need " .. coste .. " 🪙"
		botonRebirth.BackgroundColor3 = Color3.fromRGB(110, 90, 60)
	end
end

botonRebirth.Activated:Connect(function()
	-- FindFirstChild (no WaitForChild) para no colgar nunca el cliente.
	local remote = ReplicatedStorage:FindFirstChild("RebirthEvent")
	if remote then remote:FireServer() end
end)

cerrar.Activated:Connect(function()
	panel.Visible = false
end)

-- Refrescar en vivo si cambian Moneda o Rebirths con el panel abierto.
moneda.Changed:Connect(function() if panel.Visible then refrescar() end end)
rebirths.Changed:Connect(function() if panel.Visible then refrescar() end end)

-- ┌──────────────────────────────────────────────────────┐
-- │ ABRIR DESDE EL MENÚ                                   │
-- └──────────────────────────────────────────────────────┘
local menuToggle = playerGui:FindFirstChild("MenuToggle")
if not menuToggle then
	menuToggle = Instance.new("BindableEvent")
	menuToggle.Name = "MenuToggle"
	menuToggle.Parent = playerGui
end

menuToggle.Event:Connect(function(nombre)
	if nombre == "Rebirth" then
		panel.Visible = not panel.Visible
		if panel.Visible then refrescar() end
	else
		panel.Visible = false
	end
end)
