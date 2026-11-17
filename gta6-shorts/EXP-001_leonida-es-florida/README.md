# EXP-001 · "Leonida es Florida"

Short de ~34 s, 1080x1920, 30 fps. Todo el material es original o de dominio público.

| Archivo | Qué hace |
|---|---|
| `guion.json` | Guion: texto para la voz (`tts`) y para los subtítulos (`sub`) |
| `escena_mapa.py` | Escena Blender: mapa neón de Florida/Leonida, pilares, rótulos y cámara sincronizada con la voz |
| `audio_mix.py` | Música synthwave y SFX sintetizados + mezcla con ducking |
| `graficos.py` | Subtítulos `.ass` animados, sellos CONFIRMADO/TEORÍA, rótulos |
| `montaje.sh` | Montaje final con FFmpeg (grano, viñeta, aberración, subtítulos, sellos, -14 LUFS) |
| `publicacion.md` | Título, descripción, hashtags y comentario fijado |

## Rehacer el vídeo
```bash
# 1. voz (Piper, gratis y local) -> build/timings.json   (ver historial de la sesión)
# 2. render (EEVEE). Con la RTX 3060 usa --scale 100 --samples 32
blender -b -P escena_mapa.py -a -- --out build/frames/f_ --scale 100 --samples 32
# 3. audio, gráficos y montaje
python3 audio_mix.py && python3 graficos.py && ./montaje.sh
```

## Cambiar la voz por la tuya
Graba cada frase de `guion.json` como `audio/<id>.wav` (mismos nombres), vuelve a calcular los tiempos y repite los pasos 2-3.
`./montaje.sh mezcla_sin_voz` genera la versión sin voz para montar tu locución en DaVinci Resolve.
