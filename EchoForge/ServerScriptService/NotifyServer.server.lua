--[[
============================================================
  ECHO FORGE — SISTEMA 7: CANAL DE NOTIFICACIONES
  Script: NotifyServer
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Qué hace, en una frase:
  "Crea el RemoteEvent 'Notificar', el canal por el que el
   servidor manda avisos a la pantalla del jugador (forjas,
   compras, zonas...). Otros scripts del servidor lo usan."
============================================================
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent que va del SERVIDOR al CLIENTE (al revés que el
-- de la tienda). El servidor llama :FireClient(jugador, ...) y
-- la GUI del jugador lo recibe con .OnClientEvent.
local notificar = Instance.new("RemoteEvent")
notificar.Name = "Notificar"
notificar.Parent = ReplicatedStorage
