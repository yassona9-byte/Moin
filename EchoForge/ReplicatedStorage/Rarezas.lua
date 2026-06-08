--[[
============================================================
  ECHO FORGE — DATOS DE RAREZAS (configuración compartida)
  Script: Rarezas
  Tipo:   ModuleScript
  Lugar:  ReplicatedStorage
============================================================
  ¿Qué es un ModuleScript?
  Un script que NO hace nada por sí solo: es una "biblioteca"
  que otros scripts piden con require(). Sirve para guardar
  datos o funciones en UN solo sitio y reutilizarlos.

  ¿Por qué en ReplicatedStorage?
  Es la carpeta que VEN tanto el servidor como los jugadores
  (clientes). Así, cuando hagamos la GUI (Sistema 7), la
  pantalla podrá leer los mismos colores y nombres de rareza.

  Esta es la ÚNICA "fuente de verdad" de las rarezas: si un
  día quieres cambiar una probabilidad o un color, lo cambias
  aquí y todo el juego se actualiza solo.
============================================================
]]

local Rarezas = {}  -- la tabla que devolveremos al final

-- ORDEN oficial de las rarezas, de menor a mayor.
-- Lo usamos para recorrerlas siempre en el mismo orden.
Rarezas.Lista = { "Comun", "Rara", "Epica", "Legendaria", "Mitica", "Divina", "Celestial" }

-- Ficha de cada rareza:
--   nombre        = texto bonito para mostrar en pantalla
--   color         = color (lo usaremos en la GUI más adelante)
--   probabilidad  = % de salir al forjar (¡deben sumar 100!)
--   ingreso       = moneda por segundo que dará (Sistema 4)
Rarezas.Datos = {
	Comun = {
		nombre = "Common",
		color = Color3.fromRGB(160, 160, 160),  -- gris
		probabilidad = 60,
		ingreso = 1,
	},
	Rara = {
		nombre = "Rare",
		color = Color3.fromRGB(60, 120, 255),    -- azul
		probabilidad = 25,
		ingreso = 5,
	},
	Epica = {
		nombre = "Epic",
		color = Color3.fromRGB(170, 70, 255),    -- morado
		probabilidad = 10,
		ingreso = 25,
	},
	Legendaria = {
		nombre = "Legendary",
		color = Color3.fromRGB(255, 170, 40),    -- dorado
		probabilidad = 4,
		ingreso = 125,
	},
	Mitica = {
		nombre = "Mythic",
		color = Color3.fromRGB(255, 60, 120),    -- rosa intenso
		probabilidad = 1,
		ingreso = 625,
	},
	-- ── Rarezas SOLO por fusión (probabilidad 0 al forjar) ──
	Divina = {
		nombre = "Divine",
		color = Color3.fromRGB(120, 255, 230),   -- cian brillante
		probabilidad = 0,
		ingreso = 3125,
	},
	Celestial = {
		nombre = "Celestial",
		color = Color3.fromRGB(255, 225, 120),   -- dorado radiante
		probabilidad = 0,
		ingreso = 15625,
	},
}
-- Comprobación: las FORJABLES suman 60+25+10+4+1 = 100 ✓
-- (Divine y Celestial valen 0: no salen al forjar, solo al fusionar)

-- "return" entrega la tabla a quien haga require() de este módulo.
return Rarezas
