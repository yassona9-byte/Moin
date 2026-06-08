# Echo Forge — Guía de scripts

Simulador de recolección y forja para Roblox (Luau).

La estructura de carpetas de este repo **imita el explorador de Roblox Studio**.
Cada subcarpeta = un contenedor de Studio donde debes pegar el script.

| Carpeta del repo        | Contenedor en Studio   | Para qué sirve                          |
|-------------------------|------------------------|-----------------------------------------|
| `ServerScriptService/`  | ServerScriptService    | Lógica del servidor (invisible, segura) |
| `StarterPlayer/StarterPlayerScripts/` | StarterPlayer > StarterPlayerScripts | LocalScripts del cliente (GUI, input) |
| `ReplicatedStorage/`    | ReplicatedStorage      | Cosas compartidas servidor↔cliente      |

> Convención de nombres de archivo:
> - `.server.lua` = es un **Script** (corre en el servidor)
> - `.client.lua` = es un **LocalScript** (corre en el jugador)
> - `.lua` = un **ModuleScript** (código reutilizable)
>
> En Studio el tipo lo eliges tú al crear el objeto; el sufijo solo
> te recuerda cuál usar.

---

## Sistemas (orden de construcción)

- [x] **1. Recolección de Ecos** — `ServerScriptService/EcoSpawner.server.lua`
- [x] **2. Inventario y datos (DataStore)** — `ServerScriptService/DataManager.server.lua`
- [x] **3. Sistema de Forja** — `ServerScriptService/ForgeManager.server.lua` + `ReplicatedStorage/Rarezas.lua`
- [x] **4. Generación pasiva de moneda (idle)** — `ServerScriptService/IncomeManager.server.lua` (+ ganancias offline en DataManager)
- [x] **5. Tienda de mejoras (GUI)** — `ReplicatedStorage/Mejoras.lua` + `ServerScriptService/ShopServer.server.lua` + `StarterPlayer/StarterPlayerScripts/ShopGui.client.lua`
- [x] **6. Desbloqueo de zonas** — `ReplicatedStorage/Zonas.lua` + `ServerScriptService/ZoneManager.server.lua` (EcoSpawner ahora es por zonas)
- [x] **7. Interfaz (GUI)** — `ServerScriptService/NotifyServer.server.lua` + `StarterPlayer/StarterPlayerScripts/HudGui.client.lua` + `NotificationsGui.client.lua` (textos en inglés)
- [x] **8. Capa social** — Trading de Reliquias: `ServerScriptService/TradeServer.server.lua` + `StarterPlayer/StarterPlayerScripts/TradeGui.client.lua`
- [x] **9. Monetización** — `ReplicatedStorage/Monetizacion.lua` + `ServerScriptService/MonetizationServer.server.lua` + `StarterPlayer/StarterPlayerScripts/StoreGui.client.lua`
- [x] **Localización** — todo el texto visible en inglés (base); traducción automática se activa en el panel de Localization
- [x] **Juice** — sonidos + celebraciones: `ReplicatedStorage/Sonidos.lua` + `StarterPlayer/StarterPlayerScripts/JuiceManager.client.lua`
- [x] **Fusión de Reliquias** — `ServerScriptService/FusionServer.server.lua` (botones en el panel Relics de HudGui)
- [x] **Rebirth / Prestigio** — `ReplicatedStorage/Rebirth.lua` + `ServerScriptService/RebirthServer.server.lua` + `StarterPlayer/StarterPlayerScripts/RebirthGui.client.lua`
- [x] **Mapa visual** (temático por zona) — `ServerScriptService/MapBuilder.server.lua`
