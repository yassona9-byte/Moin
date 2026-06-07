-- ⚠️ TEMPORAL — solo para PRUEBAS. Bórralo (o marca su casilla
-- "Disabled" en Properties) antes de lanzar el juego de verdad.
--
-- Lugar: ServerScriptService  |  Tipo: Script
--
-- Para qué sirve: te da mucha Moneda (para probar la tienda y
-- desbloquear zonas sin grindear) y te VACÍA la mochila de Ecos,
-- para que la recolección por zonas funcione mientras pruebas.

local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	-- Esperamos a que el DataManager cree sus contadores.
	local leaderstats = player:WaitForChild("leaderstats")
	local ecos = leaderstats:WaitForChild("Ecos")
	local moneda = leaderstats:WaitForChild("Moneda")

	-- Vaciamos la mochila: así NO estás "lleno" y puedes recoger.
	-- (El DevEcos viejo metía 1000 Ecos y bloqueaba la recogida.)
	ecos.Value = 0

	-- Regalo de Moneda para probar tienda y desbloquear zonas.
	moneda.Value += 100000

	print("🎁 [DEV] Mochila vaciada y +100000 Moneda para " .. player.Name)
end)
