--[[
============================================================
  ECHO FORGE — SISTEMA 2: DATOS DEL JUGADOR (DataStore)
  Script: DataManager
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Qué hace, en una frase:
  "Es el ÚNICO dueño de los datos del jugador: los carga de
   la nube cuando entra, los mantiene en su leaderstats
   mientras juega, y los guarda cuando se va o se apaga el
   servidor — todo con red de seguridad para no perder nada."
============================================================
  ⚠️  IMPORTANTE ANTES DE PROBAR:
  El DataStore NO funciona en Studio hasta que actives:
  Game Settings (Configuración del juego) → Security →
  "Enable Studio Access to API Services" (activado).
  Te explico el paso a paso en el chat.
============================================================
]]

-- ┌──────────────────────────────────────────────────────┐
-- │ 1. SERVICIOS                                          │
-- └──────────────────────────────────────────────────────┘
local Players = game:GetService("Players")
-- DataStoreService = la puerta a la "caja fuerte" en la nube.
local DataStoreService = game:GetService("DataStoreService")

-- GetDataStore nos da UNA caja fuerte concreta, por nombre.
-- El "_v1" al final es un truco: si algún día cambiamos la
-- forma de los datos y queremos empezar limpio, usamos "_v2"
-- y no chocamos con los datos viejos.
local almacen = DataStoreService:GetDataStore("EchoForge_Datos_v1")

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. CONFIGURACIÓN                                      │
-- └──────────────────────────────────────────────────────┘
-- Cada cuánto guardamos automáticamente (por si el juego
-- se cierra de golpe y no da tiempo a guardar al salir).
local INTERVALO_AUTOGUARDADO = 60  -- segundos

-- Con qué valores empieza un jugador totalmente nuevo.
-- Cuando añadamos más cosas (capacidad, velocidad...), las
-- pondremos aquí y se aplicarán solas a los jugadores nuevos.
local DATOS_INICIALES = {
	Ecos = 0,
	Moneda = 0,
}

-- ┌──────────────────────────────────────────────────────┐
-- │ 3. ESTADO INTERNO                                     │
-- └──────────────────────────────────────────────────────┘
-- Si al ENTRAR un jugador falla la carga (problema de red),
-- lo apuntamos aquí para NO guardar luego sobre sus datos
-- buenos en la nube (si guardáramos 0 Ecos, ¡le borraríamos
-- el progreso!). Mejor no tocar nada y que reintente al volver.
local noGuardar = {}

-- ┌──────────────────────────────────────────────────────┐
-- │ 4. FUNCIONES AUXILIARES                               │
-- └──────────────────────────────────────────────────────┘
-- La "clave" única de cada jugador en la caja fuerte.
-- UserId es un número que Roblox da a cada cuenta y nunca
-- cambia (el nombre de usuario sí puede cambiar; el ID no).
local function clavePara(player)
	return "Jugador_" .. player.UserId
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 5. CUANDO UN JUGADOR ENTRA: CARGAR Y MOSTRAR          │
-- └──────────────────────────────────────────────────────┘
local function alEntrar(player)
	-- Creamos el leaderstats (el contador visible en pantalla).
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local ecos = Instance.new("IntValue")
	ecos.Name = "Ecos"

	local moneda = Instance.new("IntValue")
	moneda.Name = "Moneda"

	-- Intentamos LEER de la nube, con red de seguridad (pcall).
	-- exito = ¿salió bien la llamada? / datos = lo que devolvió.
	local exito, datos = pcall(function()
		return almacen:GetAsync(clavePara(player))
	end)

	if exito then
		-- La llamada funcionó. Ahora, ¿había datos guardados?
		if datos then
			-- Jugador que vuelve: usamos sus valores guardados.
			-- "datos.Ecos or 0" = si por algo no existe, usa 0.
			ecos.Value = datos.Ecos or 0
			moneda.Value = datos.Moneda or 0
		else
			-- datos es nil => jugador NUEVO: valores iniciales.
			ecos.Value = DATOS_INICIALES.Ecos
			moneda.Value = DATOS_INICIALES.Moneda
		end
	else
		-- La llamada FALLÓ (red, etc.). No arriesgamos: marcamos
		-- a este jugador para no guardar y avisamos en Output.
		noGuardar[player] = true
		warn("Echo Forge: error al CARGAR datos de " .. player.Name .. " → " .. tostring(datos))
	end

	-- Colocamos todo en su sitio (esto hace que aparezca en pantalla).
	ecos.Parent = leaderstats
	moneda.Parent = leaderstats
	leaderstats.Parent = player
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 6. GUARDAR LOS DATOS DE UN JUGADOR                    │
-- └──────────────────────────────────────────────────────┘
local function guardarDatos(player)
	-- Si su carga falló, NO guardamos (evitamos borrar progreso).
	if noGuardar[player] then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return  -- aún no tiene stats (entró hace un instante)
	end

	-- Empaquetamos los valores actuales en una tabla.
	local datos = {
		Ecos = leaderstats.Ecos.Value,
		Moneda = leaderstats.Moneda.Value,
	}

	-- Escribimos en la nube, otra vez con red de seguridad.
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
-- Cuando alguien entra -> cargar.
Players.PlayerAdded:Connect(alEntrar)

-- Cuando alguien se va -> guardar y olvidar su marca interna.
Players.PlayerRemoving:Connect(function(player)
	guardarDatos(player)
	noGuardar[player] = nil  -- limpiamos para no acumular memoria
end)

-- ┌──────────────────────────────────────────────────────┐
-- │ 8. AUTOGUARDADO PERIÓDICO                             │
-- └──────────────────────────────────────────────────────┘
-- task.spawn lanza este bucle "en paralelo", sin frenar el
-- resto del script. Cada minuto guarda a todos los presentes.
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
-- BindToClose corre justo antes de que el servidor (o tu
-- sesión de Studio) se cierre. Guardamos a todos para no
-- perder los últimos segundos de juego.
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		guardarDatos(player)
	end
end)
