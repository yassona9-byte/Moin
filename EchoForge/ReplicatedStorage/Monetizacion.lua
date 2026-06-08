--[[
============================================================
  ECHO FORGE — CONFIGURACIÓN DE MONETIZACIÓN
  Script: Monetizacion
  Tipo:   ModuleScript
  Lugar:  ReplicatedStorage
============================================================
  Aquí van los IDs de tus Game Passes y Developer Products.
  Mientras un id sea 0, el juego lo IGNORA (no se rompe nada),
  y la tienda mostrará "coming soon". Cuando crees cada pase/
  producto en el panel de creador, pega aquí su ID.

  Te explico en el chat cómo crearlos y de dónde sacar el ID.
============================================================
]]

local Monetizacion = {}

-- ── GAME PASSES (pago único, beneficio permanente) ──
--   id     = el GamePassId (ponlo cuando lo crees; 0 = aún no)
--   clave  = nombre del "atributo" que activa el beneficio
--   nombre / desc = textos para la tienda
Monetizacion.GamePasses = {
	{ id = 1867231097, clave = "BackpackX2",  nombre = "🎒 Backpack x2",   desc = "Double backpack capacity" },
	{ id = 1866935532, clave = "IncomeX2",    nombre = "💰 Income x2",      desc = "Double passive income" },
	{ id = 1868880256, clave = "AutoCollect", nombre = "🧲 Auto-Collector", desc = "Auto-grabs nearby Echoes" },
}

-- ── DEVELOPER PRODUCTS (se compran muchas veces) ──
--   id     = el ProductId (0 = aún no)
--   moneda = cuánta Moneda da
Monetizacion.Productos = {
	{ id = 0, nombre = "🪙 Small Coin Pack",  moneda = 10000 },
	{ id = 0, nombre = "🪙 Medium Coin Pack", moneda = 60000 },
	{ id = 0, nombre = "🪙 Large Coin Pack",  moneda = 200000 },
}

return Monetizacion
