--[[
============================================================
  ECHO FORGE — SISTEMA 8: TRADING (lado servidor)
  Script: TradeServer
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  El cerebro del intercambio: gestiona solicitudes, sesiones
  de trade, ofertas de cada lado, confirmaciones y el swap
  final. TODO se valida aquí; el cliente solo pide cosas.
============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarezas = require(ReplicatedStorage:WaitForChild("Rarezas"))
local notificar = ReplicatedStorage:WaitForChild("Notificar")

local ROJO = Color3.fromRGB(200, 60, 60)
local VERDE = Color3.fromRGB(60, 170, 90)

-- ┌──────────────────────────────────────────────────────┐
-- │ CANALES (RemoteEvents)                                │
-- └──────────────────────────────────────────────────────┘
local remotes = Instance.new("Folder")
remotes.Name = "TradeRemotes"
remotes.Parent = ReplicatedStorage

local function nuevoRemote(nombre)
	local r = Instance.new("RemoteEvent")
	r.Name = nombre
	r.Parent = remotes
	return r
end

-- Cliente -> Servidor
local rRequest = nuevoRemote("Request")   -- pedir trade a un userId
local rRespond = nuevoRemote("Respond")   -- aceptar/rechazar
local rUpdate  = nuevoRemote("Update")    -- poner/quitar 1 de una rareza
local rConfirm = nuevoRemote("Confirm")   -- confirmar/desconfirmar
local rCancel  = nuevoRemote("Cancel")    -- cancelar el trade
-- Servidor -> Cliente (un solo canal con "tipo" + datos)
local rEvent   = nuevoRemote("Event")

-- ┌──────────────────────────────────────────────────────┐
-- │ ESTADO                                                │
-- └──────────────────────────────────────────────────────┘
local sesiones = {}    -- id -> sesion
local sesionDe = {}    -- player -> id
local pendiente = {}   -- objetivo(player) -> solicitante(player)
local idCount = 0

-- ┌──────────────────────────────────────────────────────┐
-- │ AYUDAS                                                │
-- └──────────────────────────────────────────────────────┘
-- Cuántas Reliquias de esa rareza tiene el jugador AHORA.
local function tiene(player, rareza)
	local rel = player:FindFirstChild("Reliquias")
	local v = rel and rel:FindFirstChild(rareza)
	return v and v.Value or 0
end

-- ¿Es el jugador el lado A o el B de la sesión?
local function ladoDe(sesion, player)
	return (sesion.a == player) and "A" or "B"
end

-- Envía a cada jugador SU oferta como "mia" y la del otro como "otro".
local function enviarEstado(sesion)
	if sesion.a and sesion.a.Parent then
		rEvent:FireClient(sesion.a, "state", {
			mia = sesion.ofertaA, otro = sesion.ofertaB,
			confMio = sesion.confA, confOtro = sesion.confB,
		})
	end
	if sesion.b and sesion.b.Parent then
		rEvent:FireClient(sesion.b, "state", {
			mia = sesion.ofertaB, otro = sesion.ofertaA,
			confMio = sesion.confB, confOtro = sesion.confA,
		})
	end
end

-- Cierra una sesión y avisa a ambos.
local function cerrar(sesion, razon)
	sesionDe[sesion.a] = nil
	sesionDe[sesion.b] = nil
	sesiones[sesion.id] = nil
	if sesion.a and sesion.a.Parent then rEvent:FireClient(sesion.a, "closed", razon) end
	if sesion.b and sesion.b.Parent then rEvent:FireClient(sesion.b, "closed", razon) end
end

-- Ejecuta el intercambio (revalida y mueve las Reliquias).
local function ejecutar(sesion)
	local A, B = sesion.a, sesion.b
	if not (A and A.Parent and B and B.Parent) then
		cerrar(sesion, "cancelled")
		return
	end

	-- Revalidación final: ambos deben TENER lo que ofrecen.
	for rareza, n in pairs(sesion.ofertaA) do
		if tiene(A, rareza) < n then cerrar(sesion, "cancelled"); return end
	end
	for rareza, n in pairs(sesion.ofertaB) do
		if tiene(B, rareza) < n then cerrar(sesion, "cancelled"); return end
	end

	local relA = A:FindFirstChild("Reliquias")
	local relB = B:FindFirstChild("Reliquias")

	-- A entrega su oferta a B.
	for rareza, n in pairs(sesion.ofertaA) do
		relA[rareza].Value -= n
		relB[rareza].Value += n
	end
	-- B entrega su oferta a A.
	for rareza, n in pairs(sesion.ofertaB) do
		relB[rareza].Value -= n
		relA[rareza].Value += n
	end

	cerrar(sesion, "completed")
	notificar:FireClient(A, "Trade completed!", VERDE)
	notificar:FireClient(B, "Trade completed!", VERDE)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ PEDIR TRADE                                           │
-- └──────────────────────────────────────────────────────┘
rRequest.OnServerEvent:Connect(function(player, targetUserId)
	if typeof(targetUserId) ~= "number" then return end
	local target = Players:GetPlayerByUserId(targetUserId)
	if not target or target == player then return end

	-- ¿Alguno está ya ocupado en otro trade?
	if sesionDe[player] or sesionDe[target] then
		notificar:FireClient(player, "That player is busy", ROJO)
		return
	end

	pendiente[target] = player
	rEvent:FireClient(target, "incoming", {
		fromName = player.DisplayName,
		fromUserId = player.UserId,
	})
	notificar:FireClient(player, "Trade request sent", VERDE)
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ RESPONDER (aceptar / rechazar)                        │
-- └──────────────────────────────────────────────────────┘
rRespond.OnServerEvent:Connect(function(player, aceptar)
	local solicitante = pendiente[player]
	pendiente[player] = nil
	if not solicitante or not solicitante.Parent then return end

	if not aceptar then
		notificar:FireClient(solicitante, player.DisplayName .. " declined", ROJO)
		return
	end

	-- Por si entre medias alguno empezó otro trade.
	if sesionDe[player] or sesionDe[solicitante] then return end

	idCount += 1
	local sesion = {
		id = idCount,
		a = solicitante, b = player,
		ofertaA = {}, ofertaB = {},
		confA = false, confB = false,
	}
	sesiones[idCount] = sesion
	sesionDe[solicitante] = idCount
	sesionDe[player] = idCount

	rEvent:FireClient(solicitante, "started", { otro = player.DisplayName })
	rEvent:FireClient(player, "started", { otro = solicitante.DisplayName })
	enviarEstado(sesion)
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ PONER / QUITAR UNA RELIQUIA DE LA OFERTA              │
-- └──────────────────────────────────────────────────────┘
rUpdate.OnServerEvent:Connect(function(player, rareza, delta)
	local id = sesionDe[player]
	local sesion = id and sesiones[id]
	if not sesion then return end
	if not Rarezas.Datos[rareza] then return end       -- rareza falsa
	if typeof(delta) ~= "number" then return end
	delta = (delta > 0) and 1 or -1                     -- solo de 1 en 1

	local oferta = (ladoDe(sesion, player) == "A") and sesion.ofertaA or sesion.ofertaB
	local nuevo = (oferta[rareza] or 0) + delta
	if nuevo < 0 then nuevo = 0 end
	local tope = tiene(player, rareza)                  -- no más de lo que tienes
	if nuevo > tope then nuevo = tope end
	oferta[rareza] = (nuevo > 0) and nuevo or nil

	-- Cualquier cambio en la oferta resetea las confirmaciones.
	sesion.confA = false
	sesion.confB = false
	enviarEstado(sesion)
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ CONFIRMAR                                             │
-- └──────────────────────────────────────────────────────┘
rConfirm.OnServerEvent:Connect(function(player, confirmado)
	local id = sesionDe[player]
	local sesion = id and sesiones[id]
	if not sesion then return end

	confirmado = confirmado and true or false
	if ladoDe(sesion, player) == "A" then
		sesion.confA = confirmado
	else
		sesion.confB = confirmado
	end

	if sesion.confA and sesion.confB then
		ejecutar(sesion)        -- ¡los dos! intercambiamos
	else
		enviarEstado(sesion)
	end
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ CANCELAR / SALIR                                      │
-- └──────────────────────────────────────────────────────┘
rCancel.OnServerEvent:Connect(function(player)
	local id = sesionDe[player]
	local sesion = id and sesiones[id]
	if sesion then cerrar(sesion, "cancelled") end
end)

Players.PlayerRemoving:Connect(function(player)
	pendiente[player] = nil
	-- limpiar solicitudes donde este jugador era el solicitante
	for objetivo, solicitante in pairs(pendiente) do
		if solicitante == player then pendiente[objetivo] = nil end
	end
	local id = sesionDe[player]
	local sesion = id and sesiones[id]
	if sesion then cerrar(sesion, "cancelled") end
end)
