--[[
============================================================
  ECHO FORGE — DATOS DE MEJORAS (configuración compartida)
  Script: Mejoras
  Tipo:   ModuleScript
  Lugar:  ReplicatedStorage
============================================================
  La "fuente de verdad" de las mejoras de la tienda. La leen
  tanto el servidor (para validar compras y aplicar efectos)
  como el cliente (para dibujar la tienda). Si quieres
  rebalancear precios o efectos, cámbialo SOLO aquí.
============================================================
]]

local Mejoras = {}

-- Orden en que se muestran en la tienda.
Mejoras.Lista = { "Mochila", "Ingreso" }

-- Ficha de cada mejora:
--   nombre, descripcion = textos para la GUI
--   nivelMax            = hasta qué nivel se puede subir
--   costeBase           = precio del nivel 0 → 1
--   costeFactor         = cuánto se encarece cada nivel (x1.5 = +50%)
Mejoras.Datos = {
	Mochila = {
		nombre = "🎒 Backpack",
		descripcion = "Carry more Echoes",
		nivelMax = 25,
		costeBase = 100,
		costeFactor = 1.5,
		-- propios de la mochila:
		base = 50,        -- capacidad en nivel 0
		incremento = 40,  -- +40 de capacidad por nivel
	},
	Ingreso = {
		nombre = "💰 Income",
		descripcion = "+10% Coins/sec",
		nivelMax = 50,
		costeBase = 200,
		costeFactor = 1.5,
	},
}

-- ── FUNCIONES DE CÁLCULO ──
-- Un ModuleScript puede contener funciones, no solo datos.
-- Estas las usarán el servidor y el cliente para no repetir
-- las mismas cuentas en dos sitios (y que nunca difieran).

-- Cuánto cuesta subir del nivel actual al siguiente.
function Mejoras.costo(nombre, nivel)
	local d = Mejoras.Datos[nombre]
	-- math.floor redondea hacia abajo (precios enteros).
	return math.floor(d.costeBase * (d.costeFactor ^ nivel))
end

-- Capacidad de mochila para un nivel dado.
function Mejoras.capacidadMochila(nivel)
	local d = Mejoras.Datos.Mochila
	return d.base + nivel * d.incremento
end

-- Multiplicador de ingreso para un nivel dado (1.0, 1.1, 1.2...).
function Mejoras.multiplicadorIngreso(nivel)
	return 1 + nivel * 0.10
end

return Mejoras
