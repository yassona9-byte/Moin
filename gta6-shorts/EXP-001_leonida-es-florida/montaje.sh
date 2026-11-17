#!/usr/bin/env bash
# EXP-001 · montaje final con FFmpeg (1080x1920, 30 fps, H.264)
# Uso: ./montaje.sh [mezcla_final|mezcla_sin_voz] [salida.mp4]
set -euo pipefail
cd "$(dirname "$0")"
AUDIO="build/${1:-mezcla_final}.wav"
OUT="${2:-export/EXP-001_leonida-es-florida.mp4}"
mkdir -p "$(dirname "$OUT")"
S1=$(python3 -c "import json;print(round(json.load(open('build/eventos.json'))['stamps'][0],2))")
S2=$(python3 -c "import json;print(round(json.load(open('build/eventos.json'))['stamps'][1],2))")
POP="if(lt(t\,ST)\,1.7\,if(lt(t-ST\,0.14)\,1.7-5*(t-ST)\,1))"

ffmpeg -y -v error -stats \
  -framerate 30 -i build/frames/f_%04d.png \
  -i "$AUDIO" \
  -loop 1 -framerate 30 -i build/rotulo.png \
  -loop 1 -framerate 30 -i build/intro.png \
  -loop 1 -framerate 30 -i build/sello_confirmado.png \
  -loop 1 -framerate 30 -i build/sello_teoria.png \
  -loop 1 -framerate 30 -i build/aviso.png \
  -filter_complex "
    [0]scale=1080:1920:flags=lanczos,unsharp=5:5:0.7,eq=saturation=1.12:contrast=1.04,
       rgbashift=rh=2:bh=-2,vignette=PI/4.5,noise=alls=7:allf=t+u,format=yuv420p[v0];
    [3]format=rgba,fade=out:st=0.75:d=0.25:alpha=1[intro];
    [4]scale=w='0.8*iw*${POP//ST/$S1}':h=-2:eval=frame[s1];
    [5]scale=w='0.8*iw*${POP//ST/$S2}':h=-2:eval=frame[s2];
    [v0][2]overlay=enable='gte(t,0.9)':shortest=1[v1];
    [v1][intro]overlay=enable='lt(t,1)':shortest=1[v2];
    [v2]ass=build/subs.ass:fontsdir=fonts[v3];
    [v3][s1]overlay=x=(W-w)/2+40:y=740-h/2:enable='gte(t,$S1)':shortest=1[v4];
    [v4][s2]overlay=x=(W-w)/2-30:y=1010-h/2:enable='gte(t,$S2)':shortest=1[v5];
    [v5][6]overlay=enable='gte(t,31.4)':shortest=1[vout];
    [1:a]loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000[aout]" \
  -map "[vout]" -map "[aout]" -shortest \
  -c:v libx264 -preset slow -crf 17 -profile:v high -pix_fmt yuv420p -r 30 \
  -c:a aac -b:a 320k -movflags +faststart "$OUT"
echo "OK -> $OUT"
