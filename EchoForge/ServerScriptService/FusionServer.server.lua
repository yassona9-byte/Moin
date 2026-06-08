--[[
============================================================
  ECHO FORGE — FUSIÓN DE RELIQUIAS (lado servidor)
  Script: FusionServer
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Combina N Reliquias de una rareza en 1 de la rareza
  superior. El cliente solo PIDE fusionar una rareza; el
  servidor comprueba que tengas suficientes y hace el cambio.
============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarezas = require(ReplicatedStorage:WaitForChild("Rarezas"))
local notificar = ReplicatedStorage:WaitForChild("Notificar")

local ROJO = Color3.fromRGB(200, 60, 60)

-- Cuántas Reliquias hacen falta para fusionar 1 de la siguiente.
local FUSION_RATIO = 5

-- Canal cliente -> servidor.
local fusionar = Instance.new("RemoteEvent")
fusionar.Name = "Fusionar"
fusionar.Parent = ReplicatedStorage

-- Mapa "rareza -> rareza siguiente" según el orden de la lista.
local siguiente = {}
for i = 1, #Rarezas.Lista - 1 do
	siguiente[Rarezas.Lista[i]] = Rarezas.Lista[i + 1]
end

fusionar.OnServerEvent:Connect(function(player, rareza)
	-- ¿Rareza válida?
	if type(rareza) ~= "string" or not Rarezas.Datos[rareza] then
		return
	end

	-- ¿Tiene siguiente? (la Mythic no se puede fusionar)
	local sig = siguiente[rareza]
	if not sig then
		notificar:FireClient(player, "Can't fuse the top rarity!", ROJO)
		return
	end

	local carpeta = player:FindFirstChild("Reliquias")
	if not carpeta then return end
	local actual = carpeta:FindFirstChild(rareza)
	local destino = carpeta:FindFirstChild(sig)
	if not actual or not destino then return end

	-- ¿Tiene suficientes?
	if actual.Value < FUSION_RATIO then
		notificar:FireClient(player,
			"Need " .. FUSION_RATIO .. " " .. Rarezas.Datos[rareza].nombre .. " to fuse", ROJO)
		return
	end

	-- Hacemos la fusión.
	actual.Value -= FUSION_RATIO
	destino.Value += 1

	notificar:FireClient(player,
		"Fused into a " .. Rarezas.Datos[sig].nombre .. "!", Rarezas.Datos[sig].color)
end)
