--[[
============================================================
  ECHO FORGE — SISTEMA 5: TIENDA (lado servidor)
  Script: ShopServer
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Qué hace, en una frase:
  "Crea el RemoteEvent de compra y, cuando el cliente pide
   comprar una mejora, comprueba que pueda pagarla y, si sí,
   le cobra y le sube el nivel. Toda la decisión vive aquí,
   en el servidor, para que nadie haga trampa."
============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mejoras = require(ReplicatedStorage:WaitForChild("Mejoras"))

-- ┌──────────────────────────────────────────────────────┐
-- │ 1. CREAR EL "TELÉFONO" CLIENTE ↔ SERVIDOR             │
-- └──────────────────────────────────────────────────────┘
-- RemoteEvent = canal de comunicación. Lo creamos en
-- ReplicatedStorage (carpeta que ven los dos lados) para que
-- la GUI del cliente pueda encontrarlo y "llamarnos".
local remoteComprar = Instance.new("RemoteEvent")
remoteComprar.Name = "ComprarMejora"
remoteComprar.Parent = ReplicatedStorage

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. ATENDER LAS COMPRAS                                │
-- └──────────────────────────────────────────────────────┘
-- OnServerEvent se dispara cuando un cliente "llama" por el
-- RemoteEvent. Roblox SIEMPRE nos pasa primero quién llamó
-- (player); lo demás (nombreMejora) lo manda el cliente.
--
-- ⚠️ REGLA DE ORO: NUNCA confíes en lo que manda el cliente.
-- Por eso aquí revalidamos TODO (que la mejora exista, que no
-- esté al máximo, que tenga dinero). El cliente solo dice
-- "quiero comprar esto"; el servidor decide de verdad.
remoteComprar.OnServerEvent:Connect(function(player, nombreMejora)
	-- ¿Es una mejora que existe de verdad? (el cliente podría
	-- mandar basura para intentar romper algo).
	if type(nombreMejora) ~= "string" or not Mejoras.Datos[nombreMejora] then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local carpetaMejoras = player:FindFirstChild("Mejoras")
	if not leaderstats or not carpetaMejoras then
		return
	end

	local nivelValue = carpetaMejoras:FindFirstChild(nombreMejora)
	if not nivelValue then
		return
	end

	local ficha = Mejoras.Datos[nombreMejora]

	-- ¿Ya está al nivel máximo?
	if nivelValue.Value >= ficha.nivelMax then
		return
	end

	-- El precio lo calcula el SERVIDOR (nunca el cliente).
	local costo = Mejoras.costo(nombreMejora, nivelValue.Value)

	-- ¿Tiene suficiente Moneda?
	if leaderstats.Moneda.Value < costo then
		return
	end

	-- Todo correcto: cobramos y subimos el nivel.
	leaderstats.Moneda.Value -= costo
	nivelValue.Value += 1

	print(player.Name .. " mejoró " .. nombreMejora .. " a nivel " .. nivelValue.Value)
end)
