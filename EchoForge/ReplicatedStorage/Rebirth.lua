--[[
============================================================
  ECHO FORGE — CONFIGURACIÓN DE REBIRTH (prestigio)
  Script: Rebirth
  Tipo:   ModuleScript
  Lugar:  ReplicatedStorage
============================================================
  La "fuente de verdad" del prestigio. La leen el servidor
  (para cobrar y aplicar) y el cliente (para mostrar coste y
  multiplicador). Cambia los números aquí para rebalancear.
============================================================
]]

local Rebirth = {}

Rebirth.costeBase = 100000      -- Moneda para el Rebirth #1
Rebirth.costeFactor = 2.5       -- cada Rebirth cuesta x2.5 más
Rebirth.bonoPorRebirth = 0.5    -- +50% de ingreso por Rebirth

-- Cuánta Moneda cuesta el próximo Rebirth, según cuántos lleves.
function Rebirth.coste(rebirths)
	return math.floor(Rebirth.costeBase * (Rebirth.costeFactor ^ rebirths))
end

-- Multiplicador de ingreso total para ese número de Rebirths.
-- 0 -> x1.0 ; 1 -> x1.5 ; 2 -> x2.0 ...
function Rebirth.multiplicador(rebirths)
	return 1 + Rebirth.bonoPorRebirth * rebirths
end

return Rebirth
