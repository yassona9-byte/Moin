# ⚽ Moin Soccer 3D (Godot 4.3)

Versión **3D real** del juego: campo, porterías, balón y jugadores en 3D con
**cámara detrás del jugador** y profundidad. Hecho con el motor **Godot 4.3**.

> ⚠️ Es un primer 3D: los jugadores son **cápsulas 3D** con su dorsal (todavía
> no modelos detallados tipo Dream League). Es la base para ir mejorando los
> gráficos. Partido 11 vs 11 con IA, marcador, reloj y controles táctiles.

## Cómo conseguir el APK (compilado en la nube)

1. En GitHub, pestaña **Actions** → workflow **"Build 3D Android (Godot)"**.
2. Abre la última ejecución en verde y descarga el artefacto
   **`moin-soccer-3d-apk`**.
3. Descomprime → instala `moin-soccer-3d.apk` en tu Android (permite
   "fuentes desconocidas").

## Controles

- **Joystick** (mitad izquierda): mover al jugador. La cámara está detrás, así
  que "arriba" = hacia la portería rival.
- **TIRO** (rojo): dispara; mantén para más potencia.
- **PASE** (azul): pasa al mejor compañero; sin balón, presiona hacia la pelota.
- **CORRER** (amarillo): esprint.
- Controlas al jugador de tu equipo más cercano al balón (cambia solo).

## Abrir/editar en tu PC

Instala **Godot 4.3** (gratis, godotengine.org), abre esta carpeta `game3d/`
como proyecto y pulsa Play. Para exportar el APK tú mismo necesitas las
*export templates* de Android y un keystore de depuración.
