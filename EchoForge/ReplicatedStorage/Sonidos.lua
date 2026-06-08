--[[
============================================================
  ECHO FORGE — CONFIGURACIÓN DE SONIDOS
  Script: Sonidos
  Tipo:   ModuleScript
  Lugar:  ReplicatedStorage
============================================================
  IDs de los sonidos del juego. Dos formatos válidos:
   - "rbxasset://sounds/...."  → sonidos integrados de Roblox
     (siempre funcionan, no hay que tener permisos).
   - "rbxassetid://NUMERO"     → audio del Creator Store que
     hayas conseguido (botón "Get"). Pega aquí su ID.
   - ""  (vacío) → ese sonido no suena.

  Cómo conseguir audio gratis: en Studio, Toolbox → pestaña
  Marketplace → Audio → filtra por gratis → "Get" → copia su
  ID y pégalo aquí como "rbxassetid://NUMERO".
============================================================
]]

local Sonidos = {}

-- De serie usamos un "ping" integrado de Roblox para que YA
-- suene algo. Cámbialos por sonidos del Creator Store cuando
-- quieras (uno suave para recoger, un "clang" para forjar...).
Sonidos.recoger     = "rbxasset://sounds/electronicpingshort.wav"  -- recoger Eco
Sonidos.forjar      = "rbxasset://sounds/electronicpingshort.wav"  -- forjar
Sonidos.comprar     = "rbxasset://sounds/electronicpingshort.wav"  -- comprar
Sonidos.rareza_alta = ""   -- fanfarria para Legendary/Mythic (pon un id)
Sonidos.musica      = ""   -- música de fondo en bucle (pon un id)

Sonidos.volumenMusica = 0.25

return Sonidos
