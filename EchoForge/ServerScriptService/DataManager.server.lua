--[[
============================================================
  ECHO FORGE — SISTEMA 2: DATOS DEL JUGADOR (DataStore)
  Script: DataManager
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Qué hace, en una frase:
  "Es el ÚNICO dueño de los datos del jugador: los carga de
   la nube cuando entra, los mantiene mientras juega, y los
   guarda cuando se va o se apaga el servidor — con red de
   seguridad para no perder nada."

  Actualizado en el Sistema 3: ahora también crea y guarda
  la lista de Reliquias del jugador (cuántas tiene de cada
  rareza).
============================================================
  ⚠️  El DataStore necesita "Enable Studio Access to API
  Services" activado (Game Settings → Security) y el juego
  publicado. Ya lo tienes hecho.
============================================================
]]

-- ┌──────────────────────────────────────────────────────┐
-- │ 1. SERVICIOS Y CONFIGURACIÓN COMPARTIDA               │
-- └──────────────────────────────────────────────────────┘
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Misma "biblioteca" de rarezas que usa la Forja: así ambos
-- coinciden siempre en los nombres de rareza.
local Rarezas = require(ReplicatedStorage:WaitForChild("Rarezas"))
local Mejoras = require(ReplicatedStorage:WaitForChild("Mejoras"))

local almacen = DataStoreService:GetDataStore("EchoForge_Datos_v1")

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. CONFIGURACIÓN                                      │
-- └──────────────────────────────────────────────────────┘
local INTERVALO_AUTOGUARDADO = 60  -- segundos

-- Tope de ganancias offline: como máximo te pagamos por estas
-- horas, aunque hayas estado fuera mucho más. Evita números locos.
local MAX_HORAS_OFFLINE = 8

local DATOS_INICIALES = {
	Ecos = 0,
	Moneda = 0,
	-- Reliquias se rellena solo a partir de la lista de rarezas.
}

-- ┌──────────────────────────────────────────────────────┐
-- │ 3. ESTADO INTERNO                                     │
-- └──────────────────────────────────────────────────────┘
-- Jugadores cuya CARGA falló: no los guardamos para no
-- machacar sus datos buenos de la nube con valores en 0.
local noGuardar = {}

-- ┌──────────────────────────────────────────────────────┐
-- │ 4. FUNCIONES AUXILIARES                               │
-- └──────────────────────────────────────────────────────┘
local function clavePara(player)
	return "Jugador_" .. player.UserId
end

-- Crea la carpeta "Reliquias" dentro del jugador, con un
-- contador (IntValue) por cada rareza. "guardadas" es la
-- tabla recuperada de la nube (o nil si es jugador nuevo).
local function crearReliquias(player, guardadas)
	guardadas = guardadas or {}
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Reliquias"
	for _, nombre in ipairs(Rarezas.Lista) do
		local contador = Instance.new("IntValue")
		contador.Name = nombre                     -- "Comun", "Rara", ...
		contador.Value = guardadas[nombre] or 0    -- lo guardado, o 0
		contador.Parent = carpeta
	end
	carpeta.Parent = player
end

-- Calcula el ingreso POR SEGUNDO a partir de una tabla de
-- reliquias guardada { Comun=.., Rara=.. }. Lo usamos para las
-- ganancias offline (no podemos leer la carpeta porque el
-- jugador aún se está cargando).
local function ingresoDeTabla(reliquias)
	reliquias = reliquias or {}
	local total = 0
	for _, nombre in ipairs(Rarezas.Lista) do
		local cantidad = reliquias[nombre] or 0
		total += cantidad * Rarezas.Datos[nombre].ingreso
	end
	return total
end

-- Crea la carpeta "Mejoras" dentro del jugador, con un nivel
-- (IntValue) por cada mejora de la tienda.
local function crearMejoras(player, guardadas)
	guardadas = guardadas or {}
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Mejoras"
	for _, nombre in ipairs(Mejoras.Lista) do
		local nivel = Instance.new("IntValue")
		nivel.Name = nombre              -- "Mochila", "Ingreso"
		nivel.Value = guardadas[nombre] or 0
		nivel.Parent = carpeta
	end
	carpeta.Parent = player
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 5. CUANDO UN JUGADOR ENTRA: CARGAR Y MOSTRAR          │
-- └──────────────────────────────────────────────────────┘
local function alEntrar(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local ecos = Instance.new("IntValue")
	ecos.Name = "Ecos"

	local moneda = Instance.new("IntValue")
	moneda.Name = "Moneda"

	-- Leemos de la nube con red de seguridad.
	local exito, datos = pcall(function()
		return almacen:GetAsync(clavePara(player))
	end)

	if exito then
		if datos then
			-- Jugador que vuelve.
			ecos.Value = datos.Ecos or 0
			moneda.Value = datos.Moneda or 0
			crearReliquias(player, datos.Reliquias)  -- sus reliquias guardadas
			crearMejoras(player, datos.Mejoras)      -- sus niveles de mejora

			-- ── GANANCIAS OFFLINE ──
			-- Si guardamos cuándo se fue, calculamos lo que ganó
			-- mientras no estaba y se lo sumamos a la Moneda.
			if datos.UltimaConexion then
				local segundosFuera = os.time() - datos.UltimaConexion

				-- Aplicamos el tope (en segundos).
				local tope = MAX_HORAS_OFFLINE * 3600
				if segundosFuera > tope then
					segundosFuera = tope
				end

				if segundosFuera > 0 then
					local ingresoSeg = ingresoDeTabla(datos.Reliquias)
					local ganancia = ingresoSeg * segundosFuera
					if ganancia > 0 then
						moneda.Value += ganancia
						-- Por ahora avisamos en Output. En el Sistema 7
						-- será un cartel bonito de "¡Bienvenido de nuevo!".
						print("🌙 [OFFLINE] " .. player.Name .. " ganó " .. ganancia ..
							" Moneda tras " .. segundosFuera .. "s desconectado")
					end
				end
			end
		else
			-- Jugador nuevo.
			ecos.Value = DATOS_INICIALES.Ecos
			moneda.Value = DATOS_INICIALES.Moneda
			crearReliquias(player, nil)              -- todas a 0
			crearMejoras(player, nil)                -- niveles a 0
		end
	else
		-- Falló la carga: no arriesgamos a guardar luego.
		noGuardar[player] = true
		crearReliquias(player, nil)  -- le damos contadores en 0 para que juegue
		crearMejoras(player, nil)    -- niveles a 0 para que pueda jugar
		warn("Echo Forge: error al CARGAR datos de " .. player.Name .. " → " .. tostring(datos))
	end

	ecos.Parent = leaderstats
	moneda.Parent = leaderstats
	leaderstats.Parent = player
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 6. GUARDAR LOS DATOS DE UN JUGADOR                    │
-- └──────────────────────────────────────────────────────┘
local function guardarDatos(player)
	if noGuardar[player] then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end

	-- Empaquetamos las reliquias en una tabla { Comun=.., Rara=.. }.
	local reliquias = {}
	local carpetaReliquias = player:FindFirstChild("Reliquias")
	if carpetaReliquias then
		for _, contador in ipairs(carpetaReliquias:GetChildren()) do
			reliquias[contador.Name] = contador.Value
		end
	end

	-- Empaquetamos los niveles de mejora { Mochila=.., Ingreso=.. }.
	local mejoras = {}
	local carpetaMejoras = player:FindFirstChild("Mejoras")
	if carpetaMejoras then
		for _, nivel in ipairs(carpetaMejoras:GetChildren()) do
			mejoras[nivel.Name] = nivel.Value
		end
	end

	local datos = {
		Ecos = leaderstats.Ecos.Value,
		Moneda = leaderstats.Moneda.Value,
		Reliquias = reliquias,
		Mejoras = mejoras,
		-- Guardamos la hora actual: así, al volver, sabremos
		-- cuánto tiempo estuvo fuera para pagarle el offline.
		UltimaConexion = os.time(),
	}

	local exito, err = pcall(function()
		almacen:SetAsync(clavePara(player), datos)
	end)

	if not exito then
		warn("Echo Forge: error al GUARDAR datos de " .. player.Name .. " → " .. tostring(err))
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 7. CONECTAR LOS EVENTOS                               │
-- └──────────────────────────────────────────────────────┘
Players.PlayerAdded:Connect(alEntrar)

Players.PlayerRemoving:Connect(function(player)
	guardarDatos(player)
	noGuardar[player] = nil
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ 8. AUTOGUARDADO PERIÓDICO                             │
-- └──────────────────────────────────────────────────────┘
task.spawn(function()
	while true do
		task.wait(INTERVALO_AUTOGUARDADO)
		for _, player in ipairs(Players:GetPlayers()) do
			guardarDatos(player)
		end
	end
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ 9. GUARDAR AL APAGAR EL SERVIDOR                      │
-- └──────────────────────────────────────────────────────┘
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		guardarDatos(player)
	end
end)
