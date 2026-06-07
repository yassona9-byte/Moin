--[[
============================================================
  ECHO FORGE — SISTEMA 9: MONETIZACIÓN (lado servidor)
  Script: MonetizationServer
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  - Comprueba qué Game Passes tiene cada jugador y activa sus
    beneficios (mediante "atributos" en el jugador).
  - Procesa la compra de Developer Products (coin packs) de
    forma segura, sin duplicar ni perder compras.
  - Auto-Collector: recoge solo los Ecos cercanos a quien
    tenga ese pase.
============================================================
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")

local Mejoras = require(ReplicatedStorage:WaitForChild("Mejoras"))
local Monetizacion = require(ReplicatedStorage:WaitForChild("Monetizacion"))
local notificar = ReplicatedStorage:WaitForChild("Notificar")

-- Historial de compras (para no dar un producto dos veces).
local historial = DataStoreService:GetDataStore("EchoForge_Compras_v1")

-- Mapas rápidos: idProducto -> Moneda que da.
local monedaPorProducto = {}
for _, p in ipairs(Monetizacion.Productos) do
	if p.id ~= 0 then monedaPorProducto[p.id] = p.moneda end
end
-- idPase -> clave del beneficio.
local clavePorPase = {}
for _, g in ipairs(Monetizacion.GamePasses) do
	if g.id ~= 0 then clavePorPase[g.id] = g.clave end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ GAME PASSES: activar beneficios                       │
-- └──────────────────────────────────────────────────────┘
-- Guardamos el beneficio como un ATRIBUTO en el jugador.
-- Otros scripts (EcoSpawner, IncomeManager) lo leen con
-- player:GetAttribute("BackpackX2"), etc.
local function aplicarPases(player)
	for _, g in ipairs(Monetizacion.GamePasses) do
		local tiene = false
		if g.id ~= 0 then
			-- UserOwnsGamePassAsync habla con Roblox: lo envolvemos
			-- en pcall por si falla la red.
			local ok, res = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, g.id)
			end)
			tiene = ok and res or false
		end
		player:SetAttribute(g.clave, tiene)
	end
end

Players.PlayerAdded:Connect(aplicarPases)

-- Si compra un pase DURANTE la partida, lo activamos al momento.
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, comprado)
	if comprado and clavePorPase[gamePassId] then
		player:SetAttribute(clavePorPase[gamePassId], true)
		notificar:FireClient(player, "Thanks! Perk activated 🎉", Color3.fromRGB(60, 170, 90))
	end
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ DEVELOPER PRODUCTS: coin packs (compra segura)        │
-- └──────────────────────────────────────────────────────┘
local function darMoneda(player, productId)
	local moneda = monedaPorProducto[productId]
	if not moneda then return false end
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end
	leaderstats.Moneda.Value += moneda
	notificar:FireClient(player, "+" .. moneda .. " Coins! 🪙", Color3.fromRGB(180, 140, 40))
	return true
end

-- ProcessReceipt: Roblox la llama por CADA compra de producto.
-- Devolvemos PurchaseGranted solo cuando hemos dado el premio;
-- si algo falla, NotProcessedYet y Roblox reintenta más tarde.
MarketplaceService.ProcessReceipt = function(info)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	if not player then
		-- No está en el server ahora: reintentar cuando vuelva.
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Clave única de ESTA compra (jugador + id de compra).
	local clave = info.PlayerId .. "_" .. info.PurchaseId

	-- ¿Ya la procesamos antes? (evita dar el premio dos veces)
	local yaDado = false
	local okLeer = pcall(function()
		yaDado = historial:GetAsync(clave)
	end)
	if not okLeer then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if yaDado then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- Damos el premio.
	if not darMoneda(player, info.ProductId) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Marcamos la compra como procesada.
	local okGuardar = pcall(function()
		historial:SetAsync(clave, true)
	end)
	if not okGuardar then
		-- Se dio el premio pero no se pudo registrar. Aun así lo
		-- damos por bueno para no cobrar sin entregar.
		warn("Echo Forge: compra " .. clave .. " entregada pero no registrada")
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- ┌──────────────────────────────────────────────────────┐
-- │ AUTO-COLLECTOR (pase): recoge Ecos cercanos solo      │
-- └──────────────────────────────────────────────────────┘
local RADIO_AUTO = 40   -- alcance del imán, en studs

task.spawn(function()
	while true do
		task.wait(0.4)
		local carpetaEcos = Workspace:FindFirstChild("Ecos")
		if not carpetaEcos then continue end

		for _, player in ipairs(Players:GetPlayers()) do
			if player:GetAttribute("AutoCollect") then
				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local leaderstats = player:FindFirstChild("leaderstats")
				local carpetaMejoras = player:FindFirstChild("Mejoras")
				local zonas = player:FindFirstChild("ZonasDesbloqueadas")

				if hrp and leaderstats and carpetaMejoras and zonas then
					-- Capacidad (con Backpack x2 si lo tiene).
					local capacidad = Mejoras.capacidadMochila(carpetaMejoras.Mochila.Value)
					if player:GetAttribute("BackpackX2") then
						capacidad *= 2
					end

					for _, eco in ipairs(carpetaEcos:GetChildren()) do
						if leaderstats.Ecos.Value >= capacidad then break end
						if (eco.Position - hrp.Position).Magnitude <= RADIO_AUTO then
							local idZona = eco:GetAttribute("Zona")
							local desbloqueada = idZona and zonas:FindFirstChild(idZona)
							-- Solo recoge de zonas que tenga desbloqueadas.
							if desbloqueada and desbloqueada.Value then
								leaderstats.Ecos.Value += (eco:GetAttribute("Valor") or 1)
								eco:Destroy()
							end
						end
					end
				end
			end
		end
	end
end)
