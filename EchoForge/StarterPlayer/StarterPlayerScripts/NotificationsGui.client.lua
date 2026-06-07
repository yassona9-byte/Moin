--[[
============================================================
  ECHO FORGE — SISTEMA 7: NOTIFICACIONES (toasts)
  Script: NotificationsGui
  Tipo:   LocalScript
  Lugar:  StarterPlayer > StarterPlayerScripts
============================================================
  Qué hace, en una frase:
  "Escucha el canal 'Notificar' y, cada vez que el servidor
   manda un aviso, muestra un cartelito animado que aparece,
   se queda unos segundos y desaparece solo."
============================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- TweenService = el servicio que hace ANIMACIONES suaves
-- (mover, desvanecer...). Lo usamos para que los toasts no
-- aparezcan de golpe sino con un fundido bonito.
local TweenService = game:GetService("TweenService")

local notificar = ReplicatedStorage:WaitForChild("Notificar")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Lienzo.
local gui = Instance.new("ScreenGui")
gui.Name = "NotificationsGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Contenedor centrado en la parte de arriba (bajo el HUD).
-- Aquí se irán apilando los toasts uno debajo de otro.
local contenedor = Instance.new("Frame")
contenedor.Size = UDim2.new(0, 340, 0, 400)
contenedor.Position = UDim2.new(0.5, 0, 0, 95)
contenedor.AnchorPoint = Vector2.new(0.5, 0)
contenedor.BackgroundTransparency = 1
contenedor.Parent = gui

local layout = Instance.new("UIListLayout")
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Padding = UDim.new(0, 6)
layout.Parent = contenedor

-- Muestra un toast con un mensaje y un color de fondo.
local function mostrar(mensaje, color)
	local toast = Instance.new("TextLabel")
	toast.Size = UDim2.new(1, 0, 0, 46)
	toast.BackgroundColor3 = color or Color3.fromRGB(45, 45, 60)
	toast.TextColor3 = Color3.fromRGB(255, 255, 255)
	toast.TextStrokeTransparency = 0.5
	toast.Font = Enum.Font.FredokaOne
	toast.TextScaled = true
	toast.Text = mensaje
	-- Empezamos invisible para poder animar la entrada.
	toast.BackgroundTransparency = 1
	toast.TextTransparency = 1
	toast.Parent = contenedor

	local esquina = Instance.new("UICorner")
	esquina.CornerRadius = UDim.new(0, 10)
	esquina.Parent = toast

	-- Un poco de margen interior para que el texto respire.
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = toast

	-- Animación de ENTRADA (aparece en 0.2s).
	TweenService:Create(toast, TweenInfo.new(0.2), {
		BackgroundTransparency = 0.1,
		TextTransparency = 0,
	}):Play()

	-- Tras 2.5s, animación de SALIDA y lo destruimos.
	task.delay(2.5, function()
		local salida = TweenService:Create(toast, TweenInfo.new(0.4), {
			BackgroundTransparency = 1,
			TextTransparency = 1,
		})
		salida:Play()
		salida.Completed:Wait()
		toast:Destroy()
	end)
end

-- Cada vez que el servidor "llame" por el canal, mostramos toast.
notificar.OnClientEvent:Connect(function(mensaje, color)
	mostrar(mensaje, color)
end)
