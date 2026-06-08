--[[
============================================================
  ECHO FORGE — REBIRTH (lado servidor)
  Script: RebirthServer
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Cuando el jugador pide Rebirth y tiene Moneda suficiente:
  resetea su progreso (Ecos, Moneda, Reliquias, Mejoras),
  mantiene sus zonas, y le sube +1 el contador de Rebirths
  (que da +50% de ingreso permanente). Todo validado aquí.
============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rebirth = require(ReplicatedStorage:WaitForChild("Rebirth"))
local notificar = ReplicatedStorage:WaitForChild("Notificar")

local ROJO = Color3.fromRGB(200, 60, 60)
local DORADO = Color3.fromRGB(255, 215, 0)

-- Canal cliente -> servidor. (Se llama "RebirthEvent" para NO
-- chocar con el ModuleScript "Rebirth".)
local rebirthEvent = Instance.new("RemoteEvent")
rebirthEvent.Name = "RebirthEvent"
rebirthEvent.Parent = ReplicatedStorage

rebirthEvent.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local rebirths = leaderstats:FindFirstChild("Rebirths")
	local moneda = leaderstats:FindFirstChild("Moneda")
	local ecos = leaderstats:FindFirstChild("Ecos")
	if not rebirths or not moneda or not ecos then return end

	-- ¿Puede pagar el Rebirth?
	local coste = Rebirth.coste(rebirths.Value)
	if moneda.Value < coste then
		notificar:FireClient(player, "Need " .. coste .. " Coins to Rebirth", ROJO)
		return
	end

	-- RESET del progreso (las zonas se mantienen).
	moneda.Value = 0
	ecos.Value = 0

	local carpetaReliquias = player:FindFirstChild("Reliquias")
	if carpetaReliquias then
		for _, v in ipairs(carpetaReliquias:GetChildren()) do
			v.Value = 0
		end
	end

	local carpetaMejoras = player:FindFirstChild("Mejoras")
	if carpetaMejoras then
		for _, v in ipairs(carpetaMejoras:GetChildren()) do
			v.Value = 0
		end
	end

	-- Sube el prestigio.
	rebirths.Value += 1

	local mult = Rebirth.multiplicador(rebirths.Value)
	notificar:FireClient(player,
		"⭐ Rebirth " .. rebirths.Value .. "! Income x" .. string.format("%.1f", mult),
		DORADO)
end)
