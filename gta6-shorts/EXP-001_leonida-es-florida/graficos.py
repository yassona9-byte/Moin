# EXP-001 · subtítulos .ass + gráficos (sellos, rótulos) en PNG transparente
import json, os, re, math, random
from PIL import Image, ImageDraw, ImageFont, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
B = os.path.join(HERE, "build"); F = os.path.join(HERE, "fonts")
segs = json.load(open(os.path.join(B, "timings.json")))
W, H = 1080, 1920

# ---------------------------------------------------------------- subtítulos
def ts(t):
    h = int(t // 3600); m = int(t % 3600 // 60); s = t % 60
    return f"{h}:{m:02d}:{s:05.2f}"

def chunks(text):
    words = text.split(); out, cur = [], []
    for w in words:
        cur.append(w)
        if len(cur) >= 3 or re.search(r"[.,:;?!…]$", w) or (len(cur) == 2 and len(" ".join(cur)) > 14):
            out.append(cur); cur = []
    if cur: out.append(cur)
    return out

PINK, AMBER, CREAM = "&H00882EFF&", "&H0047B5FF&", "&H00E6F4FF&"
lines = []
for s in segs:
    cs = chunks(s["sub"]); total = sum(len(" ".join(c)) + 4 for c in cs)
    t = s["start"]
    for c in cs:
        d = s["dur"] * (len(" ".join(c)) + 4) / total
        txt = []
        for w in c:
            core = re.sub(r"[^\wÁÉÍÓÚÑÜ]", "", w)
            if len(core) > 1 and core.isupper() and core not in ("GTA",):
                txt.append(r"{\c" + PINK + "}" + w + r"{\c" + CREAM + "}")
            else:
                txt.append(w)
        body = " ".join(txt)
        anim = r"{\fscx70\fscy70\t(0,90,\fscx108\fscy108)\t(90,160,\fscx100\fscy100)}"
        lines.append(f"Dialogue: 0,{ts(t)},{ts(t + d)},Sub,,0,0,0,,{anim}{body}")
        t += d

# la pregunta final se queda en pantalla hasta el final
_l = lines[-1].split(",", 3); _l[2] = ts(1025 / 30); lines[-1] = ",".join(_l)

ass = f"""[Script Info]
ScriptType: v4.00+
PlayResX: {W}
PlayResY: {H}
WrapStyle: 0
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Sub,Anton,92,{CREAM},&H000000FF,&H00120A0B,&H96000000,0,0,0,0,100,100,1,0,1,7,4,2,90,90,560,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
""" + "\n".join(lines) + "\n"
open(os.path.join(B, "subs.ass"), "w").write(ass)

# ---------------------------------------------------------------- gráficos
def font(name, size): return ImageFont.truetype(os.path.join(F, name), size)
random.seed(3)

def grunge(img, amount=0.22):
    px = img.load(); w, h = img.size
    for _ in range(int(w * h * amount / 18)):
        x, y = random.randrange(w), random.randrange(h)
        r = random.choice((1, 1, 2, 3))
        for dx in range(-r, r + 1):
            for dy in range(-r, r + 1):
                if 0 <= x + dx < w and 0 <= y + dy < h:
                    p = px[x + dx, y + dy]; px[x + dx, y + dy] = (p[0], p[1], p[2], int(p[3] * 0.15))
    return img

def stamp(top, big, color, path, angle):
    w, h = 760, 300
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.rounded_rectangle((8, 8, w - 8, h - 8), 22, outline=color, width=12)
    d.rounded_rectangle((30, 30, w - 30, h - 30), 14, outline=color, width=4)
    f1 = font("SpecialElite-Regular.ttf", 46); f2 = font("Anton-Regular.ttf", 128)
    d.text((w / 2, 80), top, font=f1, fill=color, anchor="mm")
    d.text((w / 2, 185), big, font=f2, fill=color, anchor="mm")
    im = grunge(im)
    glow = im.filter(ImageFilter.GaussianBlur(14))
    out = Image.new("RGBA", (w + 120, h + 220), (0, 0, 0, 0))
    out.alpha_composite(glow, (60, 110)); out.alpha_composite(glow, (60, 110)); out.alpha_composite(im, (60, 110))
    out = out.rotate(angle, resample=Image.BICUBIC, expand=True)
    out.save(path)

stamp("LAS 6 REGIONES", "CONFIRMADO", (61, 255, 176, 255), os.path.join(B, "sello_confirmado.png"), 7)
stamp("LAS EQUIVALENCIAS", "TEORÍA", (255, 181, 71, 255), os.path.join(B, "sello_teoria.png"), -6)

# rótulo fijo superior
im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
fE = font("SpecialElite-Regular.ttf", 38); fB = font("BebasNeue-Regular.ttf", 34)
d.rounded_rectangle((60, 150, 420, 210), 8, fill=(11, 10, 18, 170), outline=(255, 46, 136, 255), width=3)
d.text((240, 181), "EXPEDIENTE #001", font=fE, fill=(255, 244, 230, 255), anchor="mm")
d.text((W - 60, 181), "MAPA ILUSTRATIVO · UBICACIONES APROX.", font=fB, fill=(255, 244, 230, 200), anchor="rm")
im.save(os.path.join(B, "rotulo.png"))

# sello de entrada (EXP. #001 grande, 0-0.9 s)
im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
s = Image.new("RGBA", (700, 260), (0, 0, 0, 0)); ds = ImageDraw.Draw(s)
ds.rounded_rectangle((6, 6, 694, 254), 18, outline=(255, 46, 136, 255), width=10)
ds.text((350, 70), "EXPEDIENTE", font=font("SpecialElite-Regular.ttf", 52), fill=(255, 46, 136, 255), anchor="mm")
ds.text((350, 170), "#001", font=font("Anton-Regular.ttf", 120), fill=(255, 244, 230, 255), anchor="mm")
s = grunge(s, 0.15).rotate(-5, resample=Image.BICUBIC, expand=True)
im.alpha_composite(s.filter(ImageFilter.GaussianBlur(10)), ((W - s.width) // 2, 420))
im.alpha_composite(s, ((W - s.width) // 2, 420))
im.save(os.path.join(B, "intro.png"))

# aviso legal final
im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
d.text((W / 2, 1460), "Canal no oficial · Sin relación con Rockstar Games ni Take-Two",
       font=font("BebasNeue-Regular.ttf", 34), fill=(255, 244, 230, 190), anchor="mm")
im.save(os.path.join(B, "aviso.png"))
print("ok", len(lines), "líneas de subtítulos")
