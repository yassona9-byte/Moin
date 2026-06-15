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
- **Modo Torneo (Copa Moin):** 4 equipos, semifinal y final con cuadro de
  eliminatorias; las demás eliminatorias se simulan, los empates se deciden por
  penaltis, y si ganas la final te proclamas campeón.
- **Sonidos** generados por código (Web Audio): tiro, pase, robo, poste, gol y
  pitido del árbitro. Se pueden silenciar desde el menú.

## URL pública (GitHub Pages)

El repositorio incluye un workflow (`.github/workflows/pages.yml`) que publica
este juego en GitHub Pages. Para activarlo (una sola vez):

1. En GitHub: **Settings → Pages → Build and deployment → Source: "GitHub Actions"**.
2. Asegúrate de que estos cambios estén en la rama **main** (haz merge de la rama
   de trabajo). El workflow se ejecuta solo en cada push a `main` que toque
   `futbol/`; también puedes lanzarlo a mano desde la pestaña **Actions**.

Cuando termine, la URL será aproximadamente:

```
https://yassona9-byte.github.io/Moin/
```

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
