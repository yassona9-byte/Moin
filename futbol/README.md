# ⚽ Moin Soccer — fútbol arcade para móvil

Juego de fútbol estilo *Dream League Soccer*, hecho en **HTML5 + Canvas**, sin
dependencias. Funciona en cualquier navegador de móvil y se puede **instalar
como app** en la pantalla de inicio (PWA).

## Cómo jugar

- **Joystick** (mitad izquierda de la pantalla): mover al jugador.
- **TIRO** (rojo): dispara. Mantén pulsado para cargar más potencia; la dirección
  es la del joystick (o hacia la portería si no mueves).
- **PASE** (azul): pasa al mejor compañero. Sin balón, presiona hacia la pelota.
- **CORRER** (amarillo): esprint.
- Controlas automáticamente al jugador de tu equipo más cercano al balón.

En PC: **WASD/flechas** mover, **Espacio** tirar, **X** pasar, **Shift** correr.

## Características

- Partidos 5 vs 5 (4 de campo + portero) con IA de compañeros y rivales.
- Portero que ataja y despeja.
- Marcador, reloj de partido, dos mitades con descanso.
- Elección de color de equipo y rival, dificultad y duración.
- Celebración de gol, pantalla de resultado y revancha.
- Cámara que sigue el balón, campo vertical optimizado para móvil.

## Cómo ejecutarlo

Necesita servirse por HTTP (por el Service Worker / PWA). En local:

```bash
cd futbol
python3 -m http.server 8000
# abre http://localhost:8000 en el móvil (misma red) o en el navegador
```

Para "instalarlo" en el móvil: ábrelo en Chrome/Safari y usa
**"Añadir a pantalla de inicio"**.

> Subir la carpeta `futbol/` a cualquier hosting estático (GitHub Pages, Netlify,
> etc.) y abrir la URL en el móvil también funciona.
