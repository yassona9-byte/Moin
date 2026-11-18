# EXP-002 · S3: plano cenital pixel art (2D, sin Blender) -> build/shots/s3_cenital/f_XXXX.png
import json, os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
TEX = os.path.join(HERE, "build", "tex"); OUT = os.path.join(HERE, "build", "shots", "s3_cenital")
os.makedirs(OUT, exist_ok=True)
PIX = os.path.join(HERE, "..", "kit", "fonts", "PressStart2P-Regular.ttf")
DUR = json.load(open(os.path.join(HERE, "build", "duraciones.json")))["s3_cenital"]
N = int(round(DUR * 30)); S = 4; VW, VH = 270, 480
city = Image.open(os.path.join(TEX, "ciudad.png")).convert("RGB")
spr = [Image.open(os.path.join(TEX, f"sprite_{i}.png")) for i in range(2)]
f_big = ImageFont.truetype(PIX, 40); f_mid = ImageFont.truetype(PIX, 30)
PINK, CREAM, CYAN, AMBER = (255, 46, 136), (255, 244, 230), (46, 200, 255), (255, 181, 71)
NAMES = ["DIVINE", "KATIE", "MIKKI", "ULRIKA"]

# capa de scanlines
scan = Image.new("RGBA", (VW * S, VH * S), (0, 0, 0, 0)); ds = ImageDraw.Draw(scan)
for y in range(0, VH * S, S): ds.line((0, y, VW * S, y), fill=(0, 0, 0, 70))

def label(d, xy, txt, font, col, box=True):
    x, y = xy; w = d.textlength(txt, font=font); h = font.size
    if box: d.rectangle((x - w / 2 - 14, y - h / 2 - 12, x + w / 2 + 14, y + h / 2 + 12), fill=(11, 10, 18, 220), outline=col, width=4)
    d.text((x, y), txt, font=font, fill=col, anchor="mm")

for f in range(N):
    t = f / (N - 1)
    sx, sy = 191 - 4, int(820 - 430 * t)                       # el muñequito sube por la calle
    cy = min(max(sy - VH * 0.55, 0), city.height - VH); cx = 191 - VW // 2
    view = city.crop((cx, int(cy), cx + VW, int(cy) + VH)).copy()
    view.paste(spr[(f // 5) % 2], (sx - cx, int(sy - cy)), spr[(f // 5) % 2])
    big = view.resize((VW * S, VH * S), Image.NEAREST).convert("RGBA")
    big.alpha_composite(scan)
    d = ImageDraw.Draw(big)
    px, py = (sx - cx + 4) * S, (sy - cy + 4) * S             # centro del sprite en pantalla
    # 1) los 4 nombres apuntan al MISMO muñequito
    for i, n in enumerate(NAMES):
        ti = 0.12 + i * 0.07
        if t >= ti:
            lx = 270 if i % 2 == 0 else VW * S - 270; ly = py - 380 + (i // 2) * 150
            d.line((lx, ly + 30, px, py), fill=PINK + (255,), width=5)
            label(d, (lx, ly), n, f_mid, PINK)
    d.rectangle((px - 26, py - 26, px + 26, py + 26), outline=CREAM + (255,), width=5)
    if t >= 0.45: label(d, (VW * S / 2, 330), "= MISMO SPRITE", f_big, CREAM)
    # 2) sin voz, sin historia
    if t >= 0.66: label(d, (VW * S / 2, 450), "SIN VOZ", f_big, CYAN)
    if t >= 0.78: label(d, (VW * S / 2, 570), "SIN HISTORIA", f_big, AMBER)
    big.convert("RGB").save(os.path.join(OUT, f"f_{f + 1:04d}.png"))
print("ok", N)
