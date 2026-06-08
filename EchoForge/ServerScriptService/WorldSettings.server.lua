--[[
============================================================
  ECHO FORGE — AJUSTES DEL MUNDO (sin generar nada)
  Script: WorldSettings
  Tipo:   Script (servidor)
  Lugar:  ServerScriptService
============================================================
  Solo ajusta velocidad de movimiento e iluminación bonita.
  NO genera terreno ni borra tu mapa. Úsalo cuando trabajes
  con tu PROPIO mapa importado (y desactiva MapBuilder).

  Si tu pack de mapa ya trae su iluminación y la prefieres,
  borra la sección de iluminación de abajo.
============================================================
]]

local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

-- Velocidad de caminar (mundo grande = un poco más rápido).
StarterPlayer.CharacterWalkSpeed = 28

-- ── Iluminación (opcional; borra si tu mapa ya trae la suya) ──
local function ponerEfecto(instancia)
	local viejo = Lighting:FindFirstChild(instancia.Name)
	if viejo then viejo:Destroy() end
	instancia.Parent = Lighting
end

Lighting.Technology = Enum.Technology.Future
Lighting.Brightness = 2.5
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1

local bloom = Instance.new("BloomEffect")
bloom.Name = "BloomEchoForge"
bloom.Intensity = 0.9
bloom.Size = 24
bloom.Threshold = 1.1
ponerEfecto(bloom)

local atmosfera = Instance.new("Atmosphere")
atmosfera.Name = "AtmosferaEchoForge"
atmosfera.Density = 0.3
atmosfera.Haze = 1.2
ponerEfecto(atmosfera)
