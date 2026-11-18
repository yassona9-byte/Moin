# EXP-002 · texturas pixel art ORIGINALES (no reproducen los retratos ni gráficos reales de GTA)
import os, random
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "build", "tex"); os.makedirs(OUT, exist_ok=True)
FONTS = os.path.join(HERE, "..", "kit", "fonts")
random.seed(1997)

SKIN = [(236, 188, 150), (198, 140, 100), (141, 92, 62), (96, 62, 42)]
HAIR = [(30, 22, 18), (120, 70, 30), (220, 190, 110), (170, 40, 40), (60, 40, 30)]
SHIRT = [(40, 90, 200), (200, 60, 60), (60, 160, 90), (180, 140, 40), (130, 60, 170), (220, 220, 220)]

def face(female, seed):
    """Retrato genérico de 16x16 px."""
    r = random.Random(seed); im = Image.new("RGB", (16, 16), (24, 20, 40)); d = ImageDraw.Draw(im)
    sk, hr, sh = r.choice(SKIN), r.choice(HAIR), r.choice(SHIRT)
    d.rectangle((3, 12, 12, 15), fill=sh)                     # hombros
    d.rectangle((7, 10, 8, 12), fill=sk)                      # cuello
    d.rectangle((5, 3, 10, 10), fill=sk)                      # cara
    d.rectangle((4, 1, 11, 3), fill=hr)                       # pelo arriba
    if female:
        d.rectangle((3, 2, 4, 11), fill=hr); d.rectangle((11, 2, 12, 11), fill=hr)
        d.point((7, 9), fill=(190, 50, 80)); d.point((8, 9), fill=(190, 50, 80))
    else:
        if r.random() < 0.5: d.rectangle((5, 9, 10, 10), fill=hr)   # barba
        d.point((7, 9), fill=(120, 60, 50)); d.point((8, 9), fill=(120, 60, 50))
    d.point((6, 6), fill=(10, 10, 10)); d.point((9, 6), fill=(10, 10, 10))
    return im

PIX = os.path.join(FONTS, "PressStart2P-Regular.ttf")
def big_text(im, xy, txt, size, color, anchor="mm"):
    d = ImageDraw.Draw(im); f = ImageFont.truetype(PIX, size)
    d.text(xy, txt, font=f, fill=color, anchor=anchor)

# ------------------------------------------------ pantalla de selección (1997)
MEN = ["BUBBA", "KIVLOV", "TRAVIS", "TROY"]; WOMEN = ["DIVINE", "KATIE", "MIKKI", "ULRIKA"]
ORDER = [("BUBBA", 0), ("DIVINE", 1), ("KIVLOV", 0), ("KATIE", 1), ("TRAVIS", 0), ("MIKKI", 1), ("TROY", 0), ("ULRIKA", 1)]
def select_screen(highlight):
    W, H = 160, 120
    im = Image.new("RGB", (W, H), (12, 10, 26)); d = ImageDraw.Draw(im); LBL = []
    for i, (name, fem) in enumerate(ORDER):
        cx = 12 + (i % 4) * 36; cy = 22 + (i // 4) * 46
        on = highlight and fem; dim = highlight and not fem
        col = (255, 46, 136) if on else ((70, 70, 90) if dim else (200, 200, 220))
        d.rectangle((cx - 2, cy - 2, cx + 33, cy + 33), outline=col)
        fc = face(fem, i * 7 + 3).resize((32, 32), Image.NEAREST)
        if dim: fc = Image.blend(fc, Image.new("RGB", fc.size, (12, 10, 26)), 0.65)
        im.paste(fc, (cx, cy))
        LBL.append(((cx + 16) * 8, (cy + 39) * 8, name, col))
    im = im.resize((W * 8, H * 8), Image.NEAREST)
    big_text(im, (W * 4, 64), "ELIGE TU PERSONAJE", 46, (255, 220, 120))
    for x, y, n, c in LBL: big_text(im, (x, y), n, 30, c)
    big_text(im, (W * 4, H * 8 - 40), "PC · 1997", 30, (120, 200, 255))
    return im
select_screen(False).save(os.path.join(OUT, "select_a.png"))
select_screen(True).save(os.path.join(OUT, "select_b.png"))

# ------------------------------------------------ ciudad cenital (para el plano 2D)
CW, CH = 360, 900
city = Image.new("RGB", (CW, CH), (58, 58, 64)); d = ImageDraw.Draw(city)
ROAD = 22; BLOCK = 68
for by in range(0, CH, BLOCK + ROAD):
    for bx in range(0, CW, BLOCK + ROAD):
        x0, y0 = bx + ROAD, by + ROAD
        roof = random.choice([(150, 70, 60), (90, 90, 110), (170, 150, 110), (70, 110, 80), (120, 60, 120)])
        d.rectangle((x0, y0, x0 + BLOCK, y0 + BLOCK), fill=roof)
        for _ in range(3):
            rx, ry = x0 + random.randint(4, BLOCK - 16), y0 + random.randint(4, BLOCK - 16)
            d.rectangle((rx, ry, rx + random.randint(6, 12), ry + random.randint(6, 12)),
                        fill=tuple(max(0, c - 30) for c in roof))
        d.rectangle((x0 - 3, y0 - 3, x0 + BLOCK + 3, y0 + BLOCK + 3), outline=(150, 150, 150))
for y in range(0, CH, BLOCK + ROAD):
    for x in range(0, CW, 8): d.line((x, y + ROAD // 2, x + 3, y + ROAD // 2), fill=(220, 200, 80))
for x in range(0, CW, BLOCK + ROAD):
    for y in range(0, CH, 8): d.line((x + ROAD // 2, y, x + ROAD // 2, y + 3), fill=(220, 200, 80))
for _ in range(14):  # coches
    if random.random() < 0.5:
        y = random.randrange(0, CH, BLOCK + ROAD) + 4; x = random.randint(0, CW - 14)
        d.rectangle((x, y, x + 13, y + 7), fill=random.choice(SHIRT))
    else:
        x = random.randrange(0, CW, BLOCK + ROAD) + 4; y = random.randint(0, CH - 14)
        d.rectangle((x, y, x + 7, y + 13), fill=random.choice(SHIRT))
city.save(os.path.join(OUT, "ciudad.png"))

def sprite(frame):
    """Muñequito cenital de 8x8 px (genérico), 2 fotogramas de andar."""
    im = Image.new("RGBA", (8, 8), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.rectangle((2, 2, 5, 5), fill=(255, 46, 136))           # cuerpo
    d.rectangle((3, 0, 4, 1), fill=(40, 25, 20))              # cabeza (pelo)
    if frame % 2: d.point((1, 3), fill=(236, 188, 150)); d.point((6, 4), fill=(236, 188, 150))
    else: d.point((1, 4), fill=(236, 188, 150)); d.point((6, 3), fill=(236, 188, 150))
    d.point((3, 6 + frame % 2), fill=(20, 20, 30)); d.point((4, 7 - frame % 2), fill=(20, 20, 30))
    return im
for i in range(2): sprite(i).save(os.path.join(OUT, f"sprite_{i}.png"))

# ------------------------------------------------ pantalla de consola portátil
def handheld(highlight):
    W, H = 160, 144
    pal = [(15, 56, 15), (48, 98, 48), (139, 172, 15), (155, 188, 15)]
    im = Image.new("RGB", (W, H), pal[3]); d = ImageDraw.Draw(im)
    LBL = []
    names = [("CANDY", 1), ("GRETCHEN", 1), ("?", 0), ("?", 0), ("?", 0), ("?", 0)]
    for i, (n, fem) in enumerate(names):
        cx = 14 + (i % 3) * 46; cy = 28 + (i // 3) * 54
        on = highlight and fem
        d.rectangle((cx - 2, cy - 2, cx + 33, cy + 33), outline=pal[0] if on else pal[1], width=2 if on else 1)
        fc = face(fem, 100 + i).convert("L").resize((32, 32), Image.NEAREST)
        q = fc.point(lambda v: 0 if v < 50 else (1 if v < 110 else (2 if v < 170 else 3)))
        fcrgb = Image.new("RGB", (32, 32)); fcrgb.putdata([pal[v] for v in list(q.tobytes())])
        im.paste(fcrgb, (cx, cy))
        LBL.append(((cx + 16) * 6, (cy + 41) * 6, n, pal[0] if on else pal[1]))
    im = im.resize((W * 6, H * 6), Image.NEAREST)
    big_text(im, (W * 3, 60), "ELIGE PERSONAJE", 34, pal[0])
    for x, y, n, c in LBL: big_text(im, (x, y), n, 24, c)
    return im
handheld(False).save(os.path.join(OUT, "gb_a.png")); handheld(True).save(os.path.join(OUT, "gb_b.png"))

# ------------------------------------------------ paneles del creador (2013)
def panel(title, rows):
    W, H = 600, 360
    im = Image.new("RGBA", (W, H), (10, 30, 60, 200)); d = ImageDraw.Draw(im)
    d.rectangle((0, 0, W - 1, H - 1), outline=(46, 200, 255, 255), width=4)
    fT = ImageFont.truetype(os.path.join(FONTS, "Anton-Regular.ttf"), 54)
    fR = ImageFont.truetype(os.path.join(FONTS, "BebasNeue-Regular.ttf"), 44)
    d.text((24, 14), title, font=fT, fill=(255, 244, 230, 255))
    for i, (lab, v) in enumerate(rows):
        y = 110 + i * 78
        d.text((24, y), lab, font=fR, fill=(200, 230, 255, 255))
        d.rectangle((220, y + 18, 570, y + 30), fill=(40, 70, 110, 255))
        d.rectangle((220, y + 18, 220 + int(350 * v), y + 30), fill=(255, 46, 136, 255))
        d.ellipse((220 + int(350 * v) - 14, y + 10, 220 + int(350 * v) + 14, y + 38), fill=(255, 244, 230, 255))
    return im
panel("APARIENCIA", [("CARA", .62), ("PELO", .35), ("ROPA", .8)]).save(os.path.join(OUT, "panel_a.png"))
panel("PERSONAJE", [("SEXO: MUJER", 1.0), ("EDAD", .3), ("ESTILO", .55)]).save(os.path.join(OUT, "panel_b.png"))
print("ok")
