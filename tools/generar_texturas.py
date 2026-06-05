#!/usr/bin/env python3
"""Genera todas las texturas PNG del mod Moin (pixel art 16x16)."""
import os
from PIL import Image

BASE = "src/main/resources/assets/moin/textures"
os.makedirs(f"{BASE}/item", exist_ok=True)
os.makedirs(f"{BASE}/block", exist_ok=True)
os.makedirs(f"{BASE}/mob_effect", exist_ok=True)

T = (0, 0, 0, 0)  # transparente


def img(w=16, h=16):
    return Image.new("RGBA", (w, h), T)


def px(im, x, y, c):
    if 0 <= x < im.width and 0 <= y < im.height:
        if len(c) == 3:
            c = (c[0], c[1], c[2], 255)
        im.putpixel((x, y), c)


def rect(im, x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            px(im, x, y, c)


def save(im, path):
    im.save(path)


def outline(im, c=(20, 20, 25, 255)):
    """Anade un borde oscuro alrededor de los pixeles opacos."""
    base = im.copy()
    for y in range(im.height):
        for x in range(im.width):
            if base.getpixel((x, y))[3] == 0:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < im.width and 0 <= ny < im.height and base.getpixel((nx, ny))[3] > 0:
                        px(im, x, y, c)
                        break


# ---------------- ITEMS ----------------

def t_cogollo():
    im = img()
    g1 = (40, 110, 45); g2 = (60, 150, 60); g3 = (90, 190, 90)
    blobs = [(7, 3), (5, 5), (9, 5), (4, 7), (7, 6), (10, 7), (6, 9),
             (9, 9), (5, 11), (8, 11), (11, 10), (7, 12)]
    for (x, y) in blobs:
        rect(im, x, y, x + 2, y + 2, g1)
    for (x, y) in blobs:
        px(im, x + 1, y + 1, g2)
        px(im, x + 1, y, g3)
    # tallo
    rect(im, 7, 12, 8, 14, (110, 80, 40))
    # pelos naranjas
    for (x, y) in [(6, 5), (10, 6), (8, 9), (5, 8)]:
        px(im, x, y, (210, 140, 60))
    outline(im, (25, 60, 25, 255))
    return im


def t_hoja_coca():
    im = img()
    g1 = (35, 120, 50); g2 = (70, 170, 75)
    pts = [(8, 2), (7, 3), (8, 3), (9, 3), (6, 4), (7, 4), (8, 4), (9, 4), (10, 4),
           (5, 6), (6, 6), (7, 6), (8, 6), (9, 6), (10, 6), (11, 6),
           (5, 8), (6, 8), (7, 8), (8, 8), (9, 8), (10, 8), (11, 8),
           (6, 10), (7, 10), (8, 10), (9, 10), (10, 10),
           (7, 12), (8, 12), (9, 12), (8, 13)]
    for (x, y) in pts:
        px(im, x, y, g1)
    # nervio central
    for y in range(2, 14):
        px(im, 8, y, (20, 80, 35))
    for (x, y) in pts:
        if (x + y) % 2 == 0:
            px(im, x, y, g2)
    outline(im, (20, 70, 30, 255))
    return im


def t_semillas(color, dark):
    im = img()
    seeds = [(4, 6), (7, 4), (10, 6), (5, 9), (8, 9), (11, 9), (6, 12), (9, 12)]
    for (x, y) in seeds:
        rect(im, x, y, x + 1, y + 2, color)
        px(im, x, y, dark)
    outline(im)
    return im


def t_porro():
    im = img()
    # cuerpo blanco diagonal
    for i in range(11):
        x = 3 + i; y = 12 - i
        px(im, x, y, (235, 235, 225))
        px(im, x, y - 1, (215, 215, 205))
    # boquilla marron
    px(im, 3, 12, (170, 120, 70)); px(im, 4, 11, (170, 120, 70))
    px(im, 3, 11, (150, 100, 55))
    # punta encendida
    px(im, 13, 2, (255, 120, 30)); px(im, 14, 1, (255, 80, 20))
    px(im, 12, 3, (255, 180, 60))
    # humo
    px(im, 14, 0, (200, 200, 200, 160)); px(im, 15, 1, (180, 180, 180, 120))
    outline(im)
    return im


def t_polvo(c1, c2, baggie=False):
    im = img()
    if baggie:
        rect(im, 3, 2, 12, 13, (210, 225, 235, 90))  # bolsita
        rect(im, 5, 1, 10, 2, (180, 195, 205, 160))
    # monton
    rect(im, 4, 9, 11, 12, c1)
    rect(im, 5, 7, 10, 9, c1)
    rect(im, 6, 6, 9, 7, c1)
    for (x, y) in [(6, 8), (8, 7), (9, 9), (5, 10), (10, 11), (7, 11)]:
        px(im, x, y, c2)
    outline(im)
    return im


def t_cristal():
    im = img()
    c1 = (90, 160, 220); c2 = (150, 210, 250); c3 = (60, 110, 180)
    shards = [(7, 2, 8, 8), (4, 6, 5, 12), (10, 7, 11, 13), (8, 9, 9, 13)]
    for (x0, y0, x1, y1) in shards:
        rect(im, x0, y0, x1, y1, c1)
        px(im, x0, y0, c2)
        px(im, x1, y1, c3)
    for (x, y) in [(7, 4), (4, 8), (10, 9)]:
        px(im, x, y, (235, 250, 255))
    outline(im, (30, 60, 110, 255))
    return im


def t_hongo():
    im = img()
    # sombrero rojo/morado
    cap = (170, 50, 120)
    rect(im, 4, 3, 11, 6, cap)
    rect(im, 5, 2, 10, 3, cap)
    rect(im, 3, 6, 12, 7, cap)
    # puntos
    for (x, y) in [(5, 4), (8, 3), (10, 5), (6, 6), (9, 6)]:
        px(im, x, y, (240, 220, 240))
    # tallo
    rect(im, 7, 7, 9, 13, (225, 215, 200))
    rect(im, 7, 13, 9, 13, (200, 190, 175))
    outline(im)
    return im


def t_tripi():
    im = img()
    rect(im, 3, 3, 12, 12, (245, 240, 230))  # papel
    # cuadricula
    for i in range(3, 13, 3):
        for y in range(3, 13):
            px(im, i, y, (210, 205, 195))
        for x in range(3, 13):
            px(im, x, i, (210, 205, 195))
    # dibujito de colores
    px(im, 5, 5, (230, 60, 60)); px(im, 6, 5, (240, 180, 40))
    px(im, 5, 6, (60, 160, 230)); px(im, 6, 6, (80, 200, 90))
    px(im, 9, 9, (200, 70, 200)); px(im, 10, 9, (240, 160, 40))
    px(im, 9, 10, (60, 200, 200)); px(im, 10, 10, (230, 70, 120))
    outline(im)
    return im


def t_pastilla():
    im = img()
    # capsula en diagonal, dos colores
    a = (220, 60, 60); b = (240, 240, 240)
    for i in range(8):
        x = 4 + i; y = 11 - i
        col = a if i < 4 else b
        px(im, x, y, col); px(im, x + 1, y, col)
        px(im, x, y + 1, col); px(im, x + 1, y + 1, col)
    px(im, 5, 10, (255, 150, 150)); px(im, 9, 6, (255, 255, 255))
    outline(im)
    return im


def t_cerveza():
    im = img()
    # jarra
    rect(im, 4, 4, 10, 13, (240, 200, 70))   # cerveza
    rect(im, 4, 2, 10, 4, (250, 250, 245))   # espuma
    px(im, 5, 1, (255, 255, 255)); px(im, 8, 1, (255, 255, 255))
    # vaso lados
    rect(im, 3, 3, 3, 13, (200, 225, 235, 150))
    rect(im, 11, 3, 11, 13, (200, 225, 235, 150))
    # asa
    rect(im, 12, 5, 13, 5, (200, 225, 235))
    rect(im, 13, 5, 13, 9, (200, 225, 235))
    rect(im, 12, 9, 13, 9, (200, 225, 235))
    # burbujas
    for (x, y) in [(6, 7), (8, 9), (7, 11)]:
        px(im, x, y, (255, 235, 150))
    outline(im)
    return im


def t_pipa():
    im = img()
    # cazoleta
    rect(im, 3, 7, 6, 11, (115, 74, 42))
    rect(im, 3, 6, 6, 7, (95, 58, 32))
    px(im, 4, 7, (40, 30, 20)); px(im, 5, 7, (40, 30, 20))
    # boquilla diagonal hacia abajo-derecha
    for i in range(8):
        x = 6 + i; y = 10 + i // 2
        px(im, x, y, (125, 82, 47)); px(im, x, y + 1, (100, 65, 38))
    px(im, 13, 13, (60, 40, 25)); px(im, 14, 14, (60, 40, 25))
    # humo
    px(im, 4, 5, (200, 200, 200, 150)); px(im, 3, 4, (180, 180, 180, 110))
    px(im, 5, 3, (170, 170, 170, 90))
    outline(im)
    return im


# ---------------- BLOQUE: mesa de procesado ----------------

def t_mesa_top():
    im = img()
    rect(im, 0, 0, 15, 15, (95, 70, 50))       # madera
    rect(im, 1, 1, 14, 14, (110, 82, 58))
    # superficie metalica con mortero
    rect(im, 4, 4, 11, 11, (70, 72, 78))
    rect(im, 6, 6, 9, 9, (45, 47, 52))         # cuenco
    px(im, 7, 7, (150, 150, 160)); px(im, 8, 8, (120, 120, 130))
    # vetas
    for x in range(1, 15, 4):
        for y in range(1, 15):
            px(im, x, y, (90, 66, 46))
    return im


def t_mesa_front():
    im = img()
    rect(im, 0, 0, 15, 15, (90, 66, 46))
    rect(im, 1, 1, 14, 14, (105, 78, 54))
    # panel central oscuro
    rect(im, 3, 4, 12, 12, (60, 55, 50))
    # tubos de ensayo de colores
    rect(im, 5, 6, 6, 11, (200, 220, 230, 220)); rect(im, 5, 9, 6, 11, (80, 200, 90))
    rect(im, 9, 6, 10, 11, (200, 220, 230, 220)); rect(im, 9, 8, 10, 11, (220, 80, 80))
    px(im, 5, 5, (230, 240, 245)); px(im, 9, 5, (230, 240, 245))
    # patas
    rect(im, 1, 13, 2, 15, (70, 50, 35)); rect(im, 13, 13, 14, 15, (70, 50, 35))
    return im


def t_mesa_side():
    im = img()
    rect(im, 0, 0, 15, 15, (88, 64, 44))
    rect(im, 1, 1, 14, 14, (102, 76, 52))
    rect(im, 3, 5, 12, 11, (66, 60, 54))
    for y in range(2, 14, 3):
        for x in range(1, 15):
            px(im, x, y, (84, 60, 42))
    rect(im, 1, 13, 2, 15, (70, 50, 35)); rect(im, 13, 13, 14, 15, (70, 50, 35))
    return im


# ---------------- CULTIVOS (sprites tipo cruz) ----------------

def crop_sprite(stage, max_stage, bud_color, leaf=(60, 150, 60)):
    """Planta que crece de abajo hacia arriba segun la fase."""
    im = img()
    frac = (stage + 1) / (max_stage + 1)
    height = int(3 + frac * 11)
    top = 15 - height
    stem = (70, 130, 55)
    # tallo central
    for y in range(15, top, -1):
        px(im, 7, y, stem); px(im, 8, y, stem)
    # hojas a los lados segun altura
    for y in range(15, top, -2):
        if y < 14:
            px(im, 6, y, leaf); px(im, 5, y, leaf)
            px(im, 9, y, leaf); px(im, 10, y, leaf)
    # cogollos/frutos en la parte alta cuando ya esta crecida
    if frac > 0.55:
        for (x, y) in [(7, top + 1), (8, top), (6, top + 2), (9, top + 2)]:
            px(im, x, y, bud_color)
            px(im, x, y + 1, tuple(int(c * 0.8) for c in bud_color[:3]))
    if frac >= 1.0:
        for (x, y) in [(7, top - 1), (8, top - 1), (10, top + 1), (5, top + 1)]:
            px(im, x, y, bud_color)
    outline(im, (25, 60, 25, 255))
    return im


# ---------------- ICONOS DE EFECTOS (18x18) ----------------

def effect_icon(color, symbol=None):
    im = img(18, 18)
    # circulo relleno
    cx, cy, r = 9, 9, 7
    for y in range(18):
        for x in range(18):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                px(im, x, y, color)
            elif (x - cx) ** 2 + (y - cy) ** 2 <= (r + 1) ** 2:
                px(im, x, y, (20, 20, 25, 255))
    # brillo
    px(im, 6, 6, (255, 255, 255, 200)); px(im, 7, 6, (255, 255, 255, 140))
    return im


def main():
    # items
    save(t_cogollo(), f"{BASE}/item/cogollo.png")
    save(t_hoja_coca(), f"{BASE}/item/hoja_coca.png")
    save(t_semillas((90, 170, 80), (50, 110, 50)), f"{BASE}/item/semilla_hierba.png")
    save(t_semillas((150, 110, 70), (100, 70, 45)), f"{BASE}/item/semilla_coca.png")
    save(t_porro(), f"{BASE}/item/porro.png")
    save(t_polvo((130, 130, 135), (90, 90, 95)), f"{BASE}/item/polvo_bruto.png")
    save(t_polvo((245, 245, 248), (210, 210, 215), baggie=True), f"{BASE}/item/polvo_blanco.png")
    save(t_cristal(), f"{BASE}/item/cristal.png")
    save(t_hongo(), f"{BASE}/item/hongo_alucinante.png")
    save(t_tripi(), f"{BASE}/item/tripi.png")
    save(t_pastilla(), f"{BASE}/item/pastilla.png")
    save(t_cerveza(), f"{BASE}/item/cerveza.png")
    save(t_pipa(), f"{BASE}/item/pipa.png")

    # bloque
    save(t_mesa_top(), f"{BASE}/block/mesa_top.png")
    save(t_mesa_front(), f"{BASE}/block/mesa_front.png")
    save(t_mesa_side(), f"{BASE}/block/mesa_side.png")

    # cultivos
    for s in range(8):
        save(crop_sprite(s, 7, (90, 190, 90)), f"{BASE}/block/cogollo_stage{s}.png")
    for s in range(4):
        save(crop_sprite(s, 3, (200, 90, 90), leaf=(70, 160, 70)), f"{BASE}/block/coca_stage{s}.png")

    # iconos de efectos
    save(effect_icon((106, 168, 79)), f"{BASE}/mob_effect/colocon.png")
    save(effect_icon((255, 217, 102)), f"{BASE}/mob_effect/subidon.png")
    save(effect_icon((194, 123, 160)), f"{BASE}/mob_effect/viaje.png")
    save(effect_icon((127, 96, 0)), f"{BASE}/mob_effect/resaca.png")
    save(effect_icon((255, 102, 204)), f"{BASE}/mob_effect/euforia.png")
    save(effect_icon((230, 184, 0)), f"{BASE}/mob_effect/borrachera.png")
    save(effect_icon((61, 61, 61)), f"{BASE}/mob_effect/mono.png")

    print("Texturas generadas en", BASE)


if __name__ == "__main__":
    main()
