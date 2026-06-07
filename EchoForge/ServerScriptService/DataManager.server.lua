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

local almacen = DataStoreService:GetDataStore("EchoForge_Datos_v1")

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. CONFIGURACIÓN                                      │
-- └──────────────────────────────────────────────────────┘
local INTERVALO_AUTOGUARDADO = 60  -- segundos

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
		else
			-- Jugador nuevo.
			ecos.Value = DATOS_INICIALES.Ecos
			moneda.Value = DATOS_INICIALES.Moneda
			crearReliquias(player, nil)              -- todas a 0
		end
	else
		-- Falló la carga: no arriesgamos a guardar luego.
		noGuardar[player] = true
		crearReliquias(player, nil)  -- le damos contadores en 0 para que juegue
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

	local datos = {
		Ecos = leaderstats.Ecos.Value,
		Moneda = leaderstats.Moneda.Value,
		Reliquias = reliquias,
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
