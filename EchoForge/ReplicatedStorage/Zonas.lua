--[[
============================================================
  ECHO FORGE — DATOS DE ZONAS (configuración compartida)
  Script: Zonas
  Tipo:   ModuleScript
  Lugar:  ReplicatedStorage
============================================================
  La "fuente de verdad" de las zonas del mapa. La leen el
  EcoSpawner (para saber dónde y de qué valor aparecen los
  Ecos), el ZoneManager (para construir las puertas) y el
  DataManager (para guardar qué zonas tienes desbloqueadas).

  Para AÑADIR una zona nueva, solo copia un bloque aquí y
  ajústalo. Todo el resto del juego se adapta solo.
============================================================
]]

local Zonas = {}

-- Las zonas van en LÍNEA hacia el fondo (eje Z negativo),
-- separadas para que no se solapen.
--   id       = nombre interno (para guardar datos). SIN espacios.
--   nombre   = texto bonito para la puerta.
--   centro   = punto central de la zona en el mundo 3D.
--   radio    = cómo de grande es (los Ecos aparecen dentro).
--   valorEco = cuántos Ecos te da cada orbe de esta zona.
--   color    = color de los orbes de esta zona.
--   precio   = Moneda para desbloquearla (0 = gratis, inicial).
--   maxEcos  = cuántos orbes puede haber a la vez en la zona.
Zonas.Lista = {
	{
		id = "Pradera",
		nombre = "Pradera",
		centro = Vector3.new(0, 3, 0),
		radio = 40,
		valorEco = 1,
		color = Color3.fromRGB(80, 200, 255),   -- azul
		precio = 0,
		maxEcos = 20,
	},
	{
		id = "Cuevas",
		nombre = "Cuevas de Cristal",
		centro = Vector3.new(0, 3, -130),
		radio = 40,
		valorEco = 5,
		color = Color3.fromRGB(150, 100, 255),   -- morado
		precio = 5000,
		maxEcos = 20,
	},
	{
		id = "Volcan",
		nombre = "Cráter Volcánico",
		centro = Vector3.new(0, 3, -260),
		radio = 40,
		valorEco = 25,
		color = Color3.fromRGB(255, 90, 40),     -- naranja fuego
		precio = 50000,
		maxEcos = 20,
	},
}

return Zonas
