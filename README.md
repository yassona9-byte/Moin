# Moin — Mod de Minecraft (NeoForge 1.21.1)

Mod **ficticio** de Minecraft con temática de sustancias. Todo el contenido es
inventado y solo tiene efecto **dentro del juego** (efectos de poción, cultivos,
crafteos). No representa ni explica nada real.

- **Minecraft:** 1.21.1
- **Loader:** NeoForge (21.1.x)
- **Java:** 21

## Contenido

### Plantas cultivables
- **Semilla de Hierba** → se planta en tierra de cultivo y crece en 8 fases (como el trigo).
- Al cosecharla suelta **Cogollos** (y más semillas).

### Items consumibles (efectos de poción ficticios)
| Item | Efectos al consumir |
|------|---------------------|
| **Porro** | Colocón + Náusea + Lentitud + Hambre |
| **Polvo Blanco** | Subidón + Velocidad + Prisa, y luego **Resaca** |
| **Hongo Alucinante** | Viaje + Náusea + Brillo + Salto |
| **Pastilla** | Euforia + Regeneración + Absorción + Velocidad, y luego **Resaca** |

### Efectos personalizados
`Colocón`, `Subidón`, `Viaje`, `Resaca`, `Euforia` — cada uno con su comportamiento
(curar, dañar o alimentar poco a poco) y color propio.

### Mesa de Procesado
Bloque con interfaz propia que transforma ingredientes con el tiempo:
- Cogollo → Porro
- Polvo Bruto → Polvo Blanco
- Polvo Blanco → Pastilla

### Crafteos
- **Semilla de Hierba** = Semillas de trigo + Tinte verde
- **Polvo Bruto** (x2) = Azúcar + Pólvora
- **Hongo Alucinante** = Seta roja + Polvo de piedra luminosa
- **Mesa de Procesado** = 8 lingotes de hierro alrededor de una mesa de crafteo

## Cómo compilar

Necesitas internet (para descargar NeoForge y Minecraft) y Java 21.

```bash
# Compilar
./gradlew build
# El .jar queda en build/libs/

# Probar en el cliente de Minecraft
./gradlew runClient
```

> En el editor en la nube no se pudo compilar porque el repositorio de NeoForge
> está bloqueado por la política de red. Compílalo en tu máquina con internet.

## Notas

- **Texturas:** los items reutilizan texturas de Minecraft (azúcar, pólvora, etc.)
  para verse bien sin archivos extra. Puedes reemplazarlas creando tus propios PNG
  en `src/main/resources/assets/moin/textures/`.
- **Sonidos:** los eventos `toke`, `esnifar` y `viaje` están registrados pero los
  `.ogg` no se incluyen. Si quieres sonido, coloca tus archivos en
  `src/main/resources/assets/moin/sounds/` (`toke.ogg`, `esnifar.ogg`, `viaje.ogg`).
  Sin ellos el mod funciona igual, solo que esos sonidos no suenan.
