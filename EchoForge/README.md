# Echo Forge — Guía de scripts

Simulador de recolección y forja para Roblox (Luau).

La estructura de carpetas de este repo **imita el explorador de Roblox Studio**.
Cada subcarpeta = un contenedor de Studio donde debes pegar el script.

| Carpeta del repo        | Contenedor en Studio   | Para qué sirve                          |
|-------------------------|------------------------|-----------------------------------------|
| `ServerScriptService/`  | ServerScriptService    | Lógica del servidor (invisible, segura) |
| `StarterPlayer/`        | StarterPlayer          | Scripts/GUI que se copian a cada jugador|
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
- [ ] 4. Generación pasiva de moneda (idle)
- [ ] 5. Tienda de mejoras (GUI)
- [ ] 6. Desbloqueo de zonas
- [ ] 7. Interfaz (GUI)
- [ ] 8. Capa social
- [ ] 9. Monetización
