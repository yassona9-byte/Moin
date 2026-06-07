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
Rarezas.Lista = { "Comun", "Rara", "Epica", "Legendaria", "Mitica" }

-- Ficha de cada rareza:
--   nombre        = texto bonito para mostrar en pantalla
--   color         = color (lo usaremos en la GUI más adelante)
--   probabilidad  = % de salir al forjar (¡deben sumar 100!)
--   ingreso       = moneda por segundo que dará (Sistema 4)
Rarezas.Datos = {
	Comun = {
		nombre = "Común",
		color = Color3.fromRGB(160, 160, 160),  -- gris
		probabilidad = 60,
		ingreso = 1,
	},
	Rara = {
		nombre = "Rara",
		color = Color3.fromRGB(60, 120, 255),    -- azul
		probabilidad = 25,
		ingreso = 4,
	},
	Epica = {
		nombre = "Épica",
		color = Color3.fromRGB(170, 70, 255),    -- morado
		probabilidad = 10,
		ingreso = 15,
	},
	Legendaria = {
		nombre = "Legendaria",
		color = Color3.fromRGB(255, 170, 40),    -- dorado
		probabilidad = 4,
		ingreso = 60,
	},
	Mitica = {
		nombre = "Mítica",
		color = Color3.fromRGB(255, 60, 120),    -- rosa intenso
		probabilidad = 1,
		ingreso = 250,
	},
}
-- Comprobación mental: 60 + 25 + 10 + 4 + 1 = 100 ✓

-- "return" entrega la tabla a quien haga require() de este módulo.
return Rarezas
