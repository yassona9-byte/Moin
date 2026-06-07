--[[
============================================================
  ECHO FORGE — SISTEMA 4: GENERACIÓN PASIVA (IDLE)
  Script: IncomeManager
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Qué hace, en una frase:
  "Cada segundo, mira las Reliquias de cada jugador y le
   suma Moneda según cuánto rentan — el dinero sube solo."
============================================================
]]

-- ┌──────────────────────────────────────────────────────┐
-- │ 1. SERVICIOS Y CONFIGURACIÓN                          │
-- └──────────────────────────────────────────────────────┘
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Misma "biblioteca" de rarezas: de ahí leemos cuánto renta
-- cada rareza (el campo "ingreso" de cada una).
local Rarezas = require(ReplicatedStorage:WaitForChild("Rarezas"))
-- Sistema 5: para aplicar el multiplicador de la mejora "Ingreso".
local Mejoras = require(ReplicatedStorage:WaitForChild("Mejoras"))

-- Cada cuántos segundos pagamos. 1 = el dinero sube cada segundo.
local INTERVALO = 1

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. CALCULAR EL INGRESO DE UN JUGADOR                  │
-- └──────────────────────────────────────────────────────┘
-- Suma: (nº de cada rareza) × (lo que renta esa rareza).
local function calcularIngreso(player)
	local carpetaReliquias = player:FindFirstChild("Reliquias")
	if not carpetaReliquias then
		return 0  -- aún no tiene sus datos cargados
	end

	local total = 0
	-- Recorremos las rarezas en orden (Comun, Rara, ...).
	for _, nombre in ipairs(Rarezas.Lista) do
		local contador = carpetaReliquias:FindFirstChild(nombre)
		if contador then
			-- cuántas tiene  ×  cuánto renta cada una
			total += contador.Value * Rarezas.Datos[nombre].ingreso
		end
	end
	return total
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 3. EL BUCLE IDLE (el "latido" económico)              │
-- └──────────────────────────────────────────────────────┘
-- while true do ... end = repite para siempre.
-- task.wait(INTERVALO) pausa 1 segundo sin congelar el juego.
while true do
	task.wait(INTERVALO)

	-- Recorremos a TODOS los jugadores conectados.
	for _, player in ipairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		local carpetaMejoras = player:FindFirstChild("Mejoras")
		if leaderstats and carpetaMejoras then
			local ingreso = calcularIngreso(player)

			-- Sistema 5: aplicamos el multiplicador de la mejora "Ingreso".
			local nivelIngreso = carpetaMejoras.Ingreso.Value
			local multiplicador = Mejoras.multiplicadorIngreso(nivelIngreso)
			ingreso = math.floor(ingreso * multiplicador)

			if ingreso > 0 then
				-- ¡Le pagamos! Su Moneda sube sola.
				leaderstats.Moneda.Value += ingreso
			end
		end
	end
end
