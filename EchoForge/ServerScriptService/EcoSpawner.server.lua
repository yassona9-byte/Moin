--[[
============================================================
  ECHO FORGE — SISTEMA 1: RECOLECCIÓN DE ECOS
  Script: EcoSpawner
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Qué hace este script, en una frase:
  "Hace aparecer orbes de energía (Ecos) por el mapa cada
   pocos segundos, y cuando el jugador camina sobre uno,
   lo suma a su contador de Ecos."
============================================================
]]

-- ┌──────────────────────────────────────────────────────┐
-- │ 1. SERVICIOS                                          │
-- └──────────────────────────────────────────────────────┘
-- Un "servicio" es una caja de herramientas que Roblox ya
-- nos da hecha. game:GetService(...) nos da acceso a ella.
-- Players  = información de todos los jugadores conectados.
-- Workspace = el mundo 3D que el jugador ve y toca.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. CONFIGURACIÓN (tus "perillas" para tunear el juego)│
-- └──────────────────────────────────────────────────────┘
-- Cambiar estos números cambia cómo se siente el juego.
-- No necesitas tocar nada más para ajustar el ritmo.
local INTERVALO_SPAWN = 2     -- segundos entre cada Eco nuevo
local MAX_ECOS        = 25    -- cuántos Ecos puede haber a la vez
local AREA            = 100   -- radio del cuadrado donde aparecen (en "studs")
local ALTURA_SPAWN    = 3     -- altura sobre el suelo (para que floten un poco)

-- ┌──────────────────────────────────────────────────────┐
-- │ 3. CARPETA PARA ORDENAR LOS ECOS                      │
-- └──────────────────────────────────────────────────────┘
-- Instance.new("Folder") crea una carpeta vacía.
-- La metemos en Workspace para no llenar el mundo de orbes
-- sueltos: todos vivirán dentro de Workspace > Ecos.
local carpetaEcos = Instance.new("Folder")
carpetaEcos.Name = "Ecos"          -- así la verás en el explorador
carpetaEcos.Parent = Workspace     -- "Parent" = dónde vive el objeto

-- ┌──────────────────────────────────────────────────────┐
-- │ 4. EL INVENTARIO VISIBLE (leaderstats)                │
-- └──────────────────────────────────────────────────────┘
-- "leaderstats" es una carpeta MÁGICA: si la llamas así y la
-- metes dentro de un jugador, Roblox muestra automáticamente
-- sus valores en la esquina superior derecha de la pantalla.
-- Es la forma más rápida de tener un contador en pantalla.
--
-- Esto es una FUNCIÓN: un bloque de código con nombre que
-- guardamos para usarlo después. Aún no se ejecuta aquí;
-- solo lo definimos.
local function alEntrarJugador(player)
	-- Creamos la carpeta leaderstats DENTRO del jugador.
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"   -- el nombre DEBE ser exactamente este
	leaderstats.Parent = player

	-- IntValue = una caja que guarda un número entero.
	-- Aquí guardaremos cuántos Ecos lleva el jugador.
	local ecos = Instance.new("IntValue")
	ecos.Name = "Ecos"     -- el texto que se verá en pantalla
	ecos.Value = 0         -- empieza en 0
	ecos.Parent = leaderstats
end

-- PlayerAdded es un EVENTO: una señal que Roblox dispara
-- cada vez que alguien entra al juego. :Connect(...) significa
-- "cuando eso pase, ejecuta esta función".
Players.PlayerAdded:Connect(alEntrarJugador)

-- ┌──────────────────────────────────────────────────────┐
-- │ 5. CREAR UN ECO                                       │
-- └──────────────────────────────────────────────────────┘
local function crearEco()
	-- #carpetaEcos:GetChildren() cuenta cuántos Ecos hay ahora.
	-- Si ya llegamos al máximo, no creamos más (rendimiento).
	if #carpetaEcos:GetChildren() >= MAX_ECOS then
		return  -- "return" sale de la función sin hacer nada más
	end

	-- Part = un objeto físico 3D. Será nuestro orbe.
	local eco = Instance.new("Part")
	eco.Name = "Eco"
	eco.Shape = Enum.PartType.Ball               -- forma de bola
	eco.Size = Vector3.new(2, 2, 2)              -- ancho, alto, largo
	eco.Material = Enum.Material.Neon            -- material que "brilla"
	eco.Color = Color3.fromRGB(80, 200, 255)     -- azul energía (R, G, B)
	eco.Anchored = true                          -- no cae con la gravedad
	eco.CanCollide = false                       -- el jugador lo atraviesa
	                                             -- (así no tropieza con él)

	-- math.random(min, max) da un número al azar entre min y max.
	-- Lo usamos para colocar el Eco en un punto aleatorio del área.
	local x = math.random(-AREA, AREA)
	local z = math.random(-AREA, AREA)
	eco.Position = Vector3.new(x, ALTURA_SPAWN, z)
	eco.Parent = carpetaEcos                     -- lo metemos en su carpeta

	-- ── Detección de recogida ──
	-- "recogido" evita que un mismo Eco se cuente dos veces si
	-- el jugador lo toca con varias partes del cuerpo a la vez.
	local recogido = false

	-- Touched es un evento que se dispara cuando ALGO toca el Eco.
	-- "hit" es la parte que lo tocó (un pie, una mano, etc.).
	eco.Touched:Connect(function(hit)
		if recogido then return end          -- ya se recogió, ignoramos

		-- hit.Parent es el modelo dueño de esa parte.
		-- Si ese modelo es el personaje de un jugador,
		-- GetPlayerFromCharacter nos devuelve a ese jugador.
		local player = Players:GetPlayerFromCharacter(hit.Parent)

		if player then                       -- ¿fue un jugador de verdad?
			recogido = true
			local ecos = player.leaderstats.Ecos
			ecos.Value = ecos.Value + 1      -- ¡sumamos 1 Eco!
			eco:Destroy()                    -- el orbe desaparece
		end
	end)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 6. BUCLE DE SPAWN (el "latido" del sistema)           │
-- └──────────────────────────────────────────────────────┘
-- "while true do ... end" = repite para siempre.
-- task.wait(n) pausa el bucle n segundos sin congelar el juego.
-- Así, cada INTERVALO_SPAWN segundos, intentamos crear un Eco.
while true do
	task.wait(INTERVALO_SPAWN)
	crearEco()
end
