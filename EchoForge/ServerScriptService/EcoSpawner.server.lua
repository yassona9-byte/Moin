--[[
============================================================
  ECHO FORGE — SISTEMA 1 + 6: RECOLECCIÓN POR ZONAS
  Script: EcoSpawner
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Qué hace, en una frase:
  "Hace aparecer Ecos en cada zona del mapa (con su color y
   valor). Al tocarlos, si tienes esa zona desbloqueada y te
   cabe en la mochila, suma su valor a tus Ecos."
============================================================
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Fichas compartidas: capacidad de mochila y definición de zonas.
local Mejoras = require(ReplicatedStorage:WaitForChild("Mejoras"))
local Zonas = require(ReplicatedStorage:WaitForChild("Zonas"))

-- ┌──────────────────────────────────────────────────────┐
-- │ CONFIGURACIÓN                                         │
-- └──────────────────────────────────────────────────────┘
local INTERVALO_SPAWN = 1   -- cada cuánto intentamos crear orbes
local ALTURA_SPAWN = 3      -- altura sobre el suelo

-- Carpeta para mantener todos los Ecos ordenados.
local carpetaEcos = Instance.new("Folder")
carpetaEcos.Name = "Ecos"
carpetaEcos.Parent = Workspace

-- ┌──────────────────────────────────────────────────────┐
-- │ CONTAR ECOS DE UNA ZONA                               │
-- └──────────────────────────────────────────────────────┘
-- Para no pasarnos del máximo por zona, contamos los que ya
-- existen leyendo su atributo "Zona".
local function contarEcosZona(idZona)
	local total = 0
	for _, eco in ipairs(carpetaEcos:GetChildren()) do
		if eco:GetAttribute("Zona") == idZona then
			total += 1
		end
	end
	return total
end

-- ┌──────────────────────────────────────────────────────┐
-- │ CREAR UN ECO EN UNA ZONA                              │
-- └──────────────────────────────────────────────────────┘
local function crearEcoEnZona(zona)
	if contarEcosZona(zona.id) >= zona.maxEcos then
		return
	end

	local eco = Instance.new("Part")
	eco.Name = "Eco"
	eco.Shape = Enum.PartType.Ball
	eco.Size = Vector3.new(2, 2, 2)
	eco.Material = Enum.Material.Neon
	eco.Color = zona.color        -- cada zona, su color
	eco.Anchored = true
	eco.CanCollide = false

	-- Posición aleatoria DENTRO del círculo de la zona.
	-- Usamos un ángulo al azar y una distancia al azar desde
	-- el centro (trigonometría básica: coseno/seno).
	local angulo = math.random() * 2 * math.pi
	local distancia = math.random(0, zona.radio)
	local x = zona.centro.X + math.cos(angulo) * distancia
	local z = zona.centro.Z + math.sin(angulo) * distancia
	eco.Position = Vector3.new(x, ALTURA_SPAWN, z)

	-- Le "pegamos" su info con atributos.
	eco:SetAttribute("Zona", zona.id)
	eco:SetAttribute("Valor", zona.valorEco)

	eco.Parent = carpetaEcos

	-- ── Recogida ──
	local recogido = false
	eco.Touched:Connect(function(hit)
		if recogido then return end

		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end

		local leaderstats = player:FindFirstChild("leaderstats")
		local carpetaMejoras = player:FindFirstChild("Mejoras")
		local zonasDesbloqueadas = player:FindFirstChild("ZonasDesbloqueadas")
		if not leaderstats or not carpetaMejoras or not zonasDesbloqueadas then
			return
		end

		-- ¿Tiene esta zona desbloqueada? Si no, NO recoge (el
		-- orbe se queda como "cebo" hasta que pague la puerta).
		local desbloqueada = zonasDesbloqueadas:FindFirstChild(zona.id)
		if not desbloqueada or not desbloqueada.Value then
			return
		end

		-- ¿Le cabe en la mochila?
		local capacidad = Mejoras.capacidadMochila(carpetaMejoras.Mochila.Value)
		if leaderstats.Ecos.Value < capacidad then
			recogido = true
			leaderstats.Ecos.Value += zona.valorEco   -- suma el valor de la zona
			eco:Destroy()
		end
	end)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ BUCLE DE SPAWN (recorre todas las zonas)              │
-- └──────────────────────────────────────────────────────┘
while true do
	task.wait(INTERVALO_SPAWN)
	for _, zona in ipairs(Zonas.Lista) do
		crearEcoEnZona(zona)
	end
end
