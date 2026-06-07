--[[
============================================================
  ECHO FORGE — SISTEMA 3: LA FORJA (Ecos → Reliquias)
  Script: ForgeManager
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Qué hace, en una frase:
  "Construye la Forja en el mundo y, cuando el jugador la
   activa, le resta Ecos, tira un dado de rareza y le suma
   una Reliquia de esa rareza."
============================================================
]]

-- ┌──────────────────────────────────────────────────────┐
-- │ 1. SERVICIOS Y CONFIGURACIÓN COMPARTIDA               │
-- └──────────────────────────────────────────────────────┘
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- require(...) trae la "biblioteca" de rarezas que creamos.
-- WaitForChild espera a que exista (por si este script corre
-- antes de que el módulo termine de cargar).
local Rarezas = require(ReplicatedStorage:WaitForChild("Rarezas"))
-- Canal para avisar a la pantalla del jugador (Sistema 7).
local notificar = ReplicatedStorage:WaitForChild("Notificar")

-- Cuántos Ecos cuesta UNA fundición. Tu elección: 10.
local COSTE_FORJA = 10

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. CONSTRUIR LA FORJA EN EL MUNDO                     │
-- └──────────────────────────────────────────────────────┘
-- Creamos la pieza desde el script para que no tengas que
-- colocar nada a mano en el explorador.
local forja = Instance.new("Part")
forja.Name = "Forja"
forja.Size = Vector3.new(6, 6, 6)
forja.Position = Vector3.new(0, 3, -20)   -- cerca del spawn, visible
forja.Anchored = true                     -- fija, no se cae
forja.Material = Enum.Material.Metal
forja.Color = Color3.fromRGB(90, 60, 40)  -- marrón metálico
forja.Parent = Workspace

-- ── Cartel flotante con el nombre (estético, opcional) ──
local cartel = Instance.new("BillboardGui")
cartel.Size = UDim2.new(0, 200, 0, 50)
cartel.StudsOffset = Vector3.new(0, 4, 0)  -- flota encima de la forja
cartel.AlwaysOnTop = true
cartel.Parent = forja

local texto = Instance.new("TextLabel")
texto.Size = UDim2.new(1, 0, 1, 0)
texto.BackgroundTransparency = 1
texto.Text = "🔨 FORJA"
texto.TextColor3 = Color3.fromRGB(255, 220, 150)
texto.TextScaled = true
texto.Font = Enum.Font.FredokaOne
texto.Parent = cartel

-- ┌──────────────────────────────────────────────────────┐
-- │ 3. EL BOTÓN DE INTERACCIÓN (ProximityPrompt)          │
-- └──────────────────────────────────────────────────────┘
-- ProximityPrompt = ese botón flotante "Pulsa E" que aparece
-- al acercarte. En MÓVIL sale solo como botón táctil. Es la
-- forma más cómoda y universal de interactuar con algo.
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Forjar (" .. COSTE_FORJA .. " Ecos)"  -- texto del botón
prompt.ObjectText = "Forja"                -- título encima del botón
prompt.KeyboardKeyCode = Enum.KeyCode.E    -- tecla en PC
prompt.HoldDuration = 0.2                  -- mantener pulsado un pelín
prompt.MaxActivationDistance = 12          -- a qué distancia aparece
prompt.RequiresLineOfSight = false         -- aparece aunque no la "mires"
prompt.Parent = forja

-- ┌──────────────────────────────────────────────────────┐
-- │ 4. ELEGIR LA RAREZA (el "dado")                       │
-- └──────────────────────────────────────────────────────┘
-- Tiramos un número del 1 al 100 y vamos sumando las
-- probabilidades hasta que el dado "cae" dentro de un rango.
-- Ej.: Común 60 → 1-60 ; Rara 25 → 61-85 ; Épica 10 → 86-95 ...
local function elegirRareza()
	local dado = math.random(1, 100)
	local acumulado = 0
	for _, nombre in ipairs(Rarezas.Lista) do
		acumulado += Rarezas.Datos[nombre].probabilidad
		if dado <= acumulado then
			return nombre
		end
	end
	return Rarezas.Lista[1]  -- red de seguridad (no debería llegar aquí)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 5. QUÉ PASA AL ACTIVAR LA FORJA                       │
-- └──────────────────────────────────────────────────────┘
-- Triggered se dispara EN EL SERVIDOR cuando un jugador
-- completa el prompt. "player" es quien lo activó.
prompt.Triggered:Connect(function(player)
	-- Sus contadores los crea el DataManager al entrar.
	local leaderstats = player:FindFirstChild("leaderstats")
	local carpetaReliquias = player:FindFirstChild("Reliquias")
	if not leaderstats or not carpetaReliquias then
		return  -- aún no están listos sus datos
	end

	local ecos = leaderstats.Ecos

	-- ¿Tiene suficientes Ecos?
	if ecos.Value < COSTE_FORJA then
		-- Notificación roja en la pantalla del jugador.
		notificar:FireClient(player, "Not enough Echoes!", Color3.fromRGB(200, 60, 60))
		return
	end

	-- 1) Cobramos el coste.
	ecos.Value -= COSTE_FORJA

	-- 2) Tiramos el dado de rareza.
	local rareza = elegirRareza()

	-- 3) Sumamos +1 a la Reliquia de esa rareza.
	local contador = carpetaReliquias:FindFirstChild(rareza)
	if contador then
		contador.Value += 1
	end

	-- 4) ¡Notificación juicy! Cartel del color de la rareza.
	local ficha = Rarezas.Datos[rareza]
	notificar:FireClient(player, "You forged a " .. ficha.nombre .. "!", ficha.color)
end)
