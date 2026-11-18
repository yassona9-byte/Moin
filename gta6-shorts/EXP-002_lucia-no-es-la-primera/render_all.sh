#!/usr/bin/env bash
# Renderiza todos los planos de Blender de EXP-002 (en el servidor sin GPU: ~3 h; con RTX 3060: ~15 min a --scale 100)
cd "$(dirname "$0")"
SCALE=${SCALE:-60}; SAMPLES=${SAMPLES:-14}
for s in s1_titulo s2_crt s4_portatil s5_creador s6_lucia s7_linea; do
  echo "== $s $(date +%T)"
  xvfb-run -a -s "-screen 0 1280x1024x24" blender -b -P shots.py -a -- --shot $s --scale $SCALE --samples $SAMPLES > build/render_$s.log 2>&1
  echo "   $(ls build/shots/$s | wc -l) frames"
done
echo FIN
