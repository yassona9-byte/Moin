--[[
============================================================
  ECHO FORGE — SISTEMA 5: TIENDA (lado cliente / la GUI)
  Script: ShopGui
  Tipo:   LocalScript
  Lugar:  StarterPlayer > StarterPlayerScripts
============================================================
  Qué hace, en una frase:
  "Construye en pantalla un botón '🛒 Tienda' y un panel con
   una fila por mejora (nivel, efecto, precio y botón Comprar).
   Al pulsar Comprar, avisa al servidor por el RemoteEvent."

  ¿Por qué un LocalScript y en StarterPlayerScripts?
  La GUI es cosa del CLIENTE (la pantalla de cada jugador).
  Los LocalScripts de StarterPlayerScripts corren en el
  cliente al entrar. El servidor NO dibuja interfaces.
============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- La misma ficha de mejoras que usa el servidor.
local Mejoras = require(ReplicatedStorage:WaitForChild("Mejoras"))
-- El "teléfono" al servidor (lo crea ShopServer).
local remoteComprar = ReplicatedStorage:WaitForChild("ComprarMejora")

-- LocalPlayer = el jugador dueño de esta pantalla (solo existe
-- en el cliente; en el servidor no tendría sentido).
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperamos a que el DataManager cree sus datos.
local leaderstats = player:WaitForChild("leaderstats")
local moneda = leaderstats:WaitForChild("Moneda")
local carpetaMejoras = player:WaitForChild("Mejoras")

-- ┌──────────────────────────────────────────────────────┐
-- │ 1. EL LIENZO (ScreenGui)                              │
-- └──────────────────────────────────────────────────────┘
local gui = Instance.new("ScreenGui")
gui.Name = "TiendaGui"
gui.ResetOnSpawn = false   -- que no se borre al reaparecer el personaje
gui.Parent = playerGui

-- ┌──────────────────────────────────────────────────────┐
-- │ 2. EL PANEL DE LA TIENDA                              │
-- └──────────────────────────────────────────────────────┘
-- (El botón para abrirla ya no vive aquí: lo gestiona la barra
--  de menú de la derecha, MenuBar, a través de "MenuToggle".)
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 340, 0, 320)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)  -- centro de la pantalla
panel.AnchorPoint = Vector2.new(0.5, 0.5)   -- el punto de anclaje es su centro
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
panel.Visible = false   -- empieza oculto
panel.Parent = gui
local panelEsquina = Instance.new("UICorner")
panelEsquina.CornerRadius = UDim.new(0, 14)
panelEsquina.Parent = panel

-- Título del panel.
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -50, 0, 40)
titulo.Position = UDim2.new(0, 10, 0, 4)
titulo.BackgroundTransparency = 1
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.Font = Enum.Font.FredokaOne
titulo.TextScaled = true
titulo.Text = "🛒 Upgrades Shop"
titulo.Parent = panel

-- Botón cerrar (la X).
local cerrar = Instance.new("TextButton")
cerrar.Size = UDim2.new(0, 34, 0, 34)
cerrar.Position = UDim2.new(1, -40, 0, 6)
cerrar.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
cerrar.TextColor3 = Color3.fromRGB(255, 255, 255)
cerrar.Font = Enum.Font.FredokaOne
cerrar.TextScaled = true
cerrar.Text = "X"
cerrar.Parent = panel
local cerrarEsquina = Instance.new("UICorner")
cerrarEsquina.CornerRadius = UDim.new(0, 8)
cerrarEsquina.Parent = cerrar

-- Contenedor donde irán las filas de mejoras.
local lista = Instance.new("Frame")
lista.Name = "Lista"
lista.Position = UDim2.new(0, 10, 0, 50)
lista.Size = UDim2.new(1, -20, 1, -60)
lista.BackgroundTransparency = 1
lista.Parent = panel
-- UIListLayout apila las filas automáticamente, una bajo otra.
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = lista

-- ┌──────────────────────────────────────────────────────┐
-- │ 4. CREAR UNA FILA POR MEJORA                          │
-- └──────────────────────────────────────────────────────┘
-- Guardamos referencias a los textos/botones para actualizarlos.
local filas = {}

local function crearFila(nombre, orden)
	local fila = Instance.new("Frame")
	fila.Size = UDim2.new(1, 0, 0, 72)
	fila.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
	fila.LayoutOrder = orden
	fila.Parent = lista
	local fe = Instance.new("UICorner")
	fe.CornerRadius = UDim.new(0, 10)
	fe.Parent = fila

	-- Texto de info (nombre, nivel, efecto) a la izquierda.
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(0.58, 0, 1, 0)
	info.Position = UDim2.new(0, 10, 0, 0)
	info.BackgroundTransparency = 1
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Center
	info.TextColor3 = Color3.fromRGB(255, 255, 255)
	info.Font = Enum.Font.Gotham
	info.TextSize = 15
	info.TextWrapped = true
	info.Parent = fila

	-- Botón Comprar a la derecha.
	local comprar = Instance.new("TextButton")
	comprar.Size = UDim2.new(0.36, 0, 0.72, 0)
	comprar.Position = UDim2.new(0.62, 0, 0.14, 0)
	comprar.BackgroundColor3 = Color3.fromRGB(60, 170, 90)
	comprar.TextColor3 = Color3.fromRGB(255, 255, 255)
	comprar.Font = Enum.Font.FredokaOne
	comprar.TextScaled = true
	comprar.Parent = fila
	local ce = Instance.new("UICorner")
	ce.CornerRadius = UDim.new(0, 8)
	ce.Parent = comprar

	-- Al pulsar: "llamamos" al servidor diciendo qué queremos.
	-- FireServer envía el mensaje; el servidor decide y aplica.
	comprar.Activated:Connect(function()
		remoteComprar:FireServer(nombre)
	end)

	filas[nombre] = { info = info, comprar = comprar }
end

for orden, nombre in ipairs(Mejoras.Lista) do
	crearFila(nombre, orden)
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 5. REFRESCAR LOS TEXTOS (nivel, efecto, precio)       │
-- └──────────────────────────────────────────────────────┘
local function refrescar()
	for _, nombre in ipairs(Mejoras.Lista) do
		local ficha = Mejoras.Datos[nombre]
		local nivel = carpetaMejoras:FindFirstChild(nombre).Value
		local f = filas[nombre]

		-- Texto del efecto actual según la mejora.
		local efecto = ficha.descripcion
		if nombre == "Mochila" then
			efecto = "Capacity: " .. Mejoras.capacidadMochila(nivel)
		elseif nombre == "Ingreso" then
			efecto = "Multiplier: x" .. string.format("%.1f", Mejoras.multiplicadorIngreso(nivel))
		end
		f.info.Text = ficha.nombre .. "  (Level " .. nivel .. ")\n" .. efecto

		if nivel >= ficha.nivelMax then
			-- Ya está al máximo.
			f.comprar.Text = "MAX"
			f.comprar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		else
			local costo = Mejoras.costo(nombre, nivel)
			f.comprar.Text = "Buy\n" .. costo .. " 🪙"
			-- Verde si puedes pagar, rojizo si no (pista visual).
			if moneda.Value >= costo then
				f.comprar.BackgroundColor3 = Color3.fromRGB(60, 170, 90)
			else
				f.comprar.BackgroundColor3 = Color3.fromRGB(120, 70, 70)
			end
		end
	end
end

-- ┌──────────────────────────────────────────────────────┐
-- │ 6. CONECTAR BOTONES Y ACTUALIZACIONES                 │
-- └──────────────────────────────────────────────────────┘
-- Canal del menú "a prueba de fallos" (obtener o crear).
local menuToggle = playerGui:FindFirstChild("MenuToggle")
if not menuToggle then
	menuToggle = Instance.new("BindableEvent")
	menuToggle.Name = "MenuToggle"
	menuToggle.Parent = playerGui
end

-- La barra de menú nos avisa por "MenuToggle". Si nos toca a
-- nosotros ("Shop"), alternamos; si abren otro panel, cerramos.
menuToggle.Event:Connect(function(nombre)
	if nombre == "Shop" then
		panel.Visible = not panel.Visible
		if panel.Visible then refrescar() end
	else
		panel.Visible = false
	end
end)

cerrar.Activated:Connect(function()
	panel.Visible = false
end)

-- Si cambia la Moneda (sube sola con el idle), refrescamos para
-- que los botones se pongan verdes en cuanto puedas permitírtelo.
moneda.Changed:Connect(function()
	if panel.Visible then
		refrescar()
	end
end)

-- Si cambia el nivel de una mejora (tras comprar), refrescamos.
for _, nombre in ipairs(Mejoras.Lista) do
	carpetaMejoras:FindFirstChild(nombre).Changed:Connect(function()
		if panel.Visible then
			refrescar()
		end
	end)
end
