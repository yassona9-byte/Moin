# EXP-002 · montaje completo: planos -> ritmo de la voz, música/SFX originales, subtítulos, look final
#   python3 montaje.py            -> export/EXP-002_lucia.mp4  (+ export/EXP-002_SIN_VOZ.mp4 con --sin-voz)
import json, os, re, subprocess, sys, wave
import numpy as np
from scipy.signal import butter, sosfilt, fftconvolve
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
B = os.path.join(HERE, "build"); A = os.path.join(HERE, "audio"); EX = os.path.join(HERE, "export")
FONTS = os.path.join(HERE, "..", "kit", "fonts"); os.makedirs(EX, exist_ok=True)
T = json.load(open(os.path.join(B, "timings.json")))
SHOTDUR = json.load(open(os.path.join(B, "duraciones.json")))
FPS = 30; SR = 48000
END = T[-1]["start"] + T[-1]["dur"] + 2.0
slots = []
for i, s in enumerate(T):
    a = 0.0 if i == 0 else T[i]["start"] - 0.12          # el corte llega justo antes de la frase
    b = END if i == len(T) - 1 else T[i + 1]["start"] - 0.12
    slots.append((s["shot"], a, b))

# ---------------------------------------------------------------- 1. vídeo base (planos encajados al ritmo)
parts = []
for shot, a, b in slots:
    d = b - a; sd = SHOTDUR[shot]
    k = d / sd                                            # >1 ralentiza, <1 acelera
    vf = f"setpts={k:.4f}*PTS,fps={FPS},scale=1080:1920:flags=lanczos,trim=duration={d:.3f},setpts=PTS-STARTPTS"
    out = os.path.join(B, f"part_{shot}.mp4")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-framerate", str(FPS), "-i",
                    os.path.join(B, "shots", shot, "f_%04d.png"), "-vf", vf, "-c:v", "libx264", "-crf", "12",
                    "-preset", "fast", "-pix_fmt", "yuv420p", out], check=True)
    parts.append(out); print("plano", shot, f"{d:.2f}s (x{k:.2f})")
lst = os.path.join(B, "parts.txt"); open(lst, "w").write("".join(f"file '{p}'\n" for p in parts))
base = os.path.join(B, "base.mp4")
subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", lst, "-c", "copy", base], check=True)

# ---------------------------------------------------------------- 2. subtítulos (palabra a palabra)
KEY = {"lucía", "1997", "mujeres", "divine", "katie", "mikki", "ulrika", "muñequito", "candy", "gretchen",
       "2013", "protagonista", "nombre", "voz", "historia", "verdad", "ocho", "cuatro", "rockstar", "primera"}
def ts(t): return f"{int(t // 3600)}:{int(t % 3600 // 60):02d}:{t % 60:05.2f}"
lines = []
for s in T:
    ws = s["words"]; groups, cur = [], []
    for w in ws:
        cur.append(w)
        if len(cur) >= 3 or re.search(r"[.,:;?!]$", w[0]) or (len(cur) == 2 and len(cur[0][0] + cur[1][0]) > 13):
            groups.append(cur); cur = []
    if cur: groups.append(cur)
    for gi, g in enumerate(groups):
        t0 = s["start"] + g[0][1]
        t1 = s["start"] + (groups[gi + 1][0][1] if gi + 1 < len(groups) else s["dur"] + 0.15)
        txt = " ".join((r"{\c&H00882EFF&}" + w[0].upper() + r"{\c&H00E6F4FF&}")
                       if re.sub(r"[^\wáéíóúñü]", "", w[0].lower()) in KEY else w[0].upper() for w in g)
        lines.append([t0, t1, txt])
lines[-1][1] = END
anim = r"{\fscx72\fscy72\t(0,90,\fscx106\fscy106)\t(90,150,\fscx100\fscy100)}"
ass = f"""[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Sub,Anton,86,&H00E6F4FF,&H000000FF,&H00120A0B,&H96000000,0,0,0,0,100,100,1,0,1,7,4,2,80,80,600,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
""" + "\n".join(f"Dialogue: 0,{ts(a)},{ts(b)},Sub,,0,0,0,,{anim}{t}" for a, b, t in lines) + "\n"
open(os.path.join(B, "subs.ass"), "w").write(ass)

# rótulo superior + aviso final
im = Image.new("RGBA", (1080, 1920), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
fE = ImageFont.truetype(os.path.join(FONTS, "SpecialElite-Regular.ttf"), 36)
d.rounded_rectangle((60, 150, 410, 206), 8, fill=(11, 10, 18, 160), outline=(255, 46, 136, 255), width=3)
d.text((235, 179), "EXPEDIENTE #002", font=fE, fill=(255, 244, 230, 255), anchor="mm")
im.save(os.path.join(B, "rotulo.png"))
im = Image.new("RGBA", (1080, 1920), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
d.text((540, 1430), "Canal no oficial · Sin relación con Rockstar Games ni Take-Two",
       font=ImageFont.truetype(os.path.join(FONTS, "BebasNeue-Regular.ttf"), 34), fill=(255, 244, 230, 190), anchor="mm")
im.save(os.path.join(B, "aviso.png"))

# ---------------------------------------------------------------- 3. música + SFX originales
N = int((END + 0.1) * SR); rng = np.random.default_rng(2)
def lp(x, f): return sosfilt(butter(2, f, "low", fs=SR, output="sos"), x)
def hp(x, f): return sosfilt(butter(2, f, "high", fs=SR, output="sos"), x)
def saw(f, t): return 2 * ((f * t) % 1) - 1
def sq(f, t, duty=0.5): return np.where((f * t) % 1 < duty, 1.0, -1.0)
def midi(n): return 440 * 2 ** ((n - 69) / 12)
def put(buf, sig, t0, g=1.0):
    i = int(t0 * SR); j = min(len(buf), i + len(sig))
    if 0 <= i < len(buf): buf[i:j] += sig[: j - i] * g
IR = rng.standard_normal(int(2 * SR)) * np.exp(-np.linspace(0, 7, int(2 * SR)))
def verb(x, wet):
    y = fftconvolve(x, IR)[: len(x)]; y /= np.max(np.abs(y)) + 1e-9
    return x * (1 - wet) + y * wet * (np.max(np.abs(x)) + 1e-9)
seg = {s["id"]: s for s in T}
t_8bit0, t_8bit1 = seg["y1997"]["start"] - 0.1, seg["online"]["start"] - 0.1
t_rev = seg["reveal"]["start"]
BPM = 104; beat = 60 / BPM; bar = 4 * beat
CH = [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]
pad = np.zeros(N); bass = np.zeros(N); chip = np.zeros(N); drums = np.zeros(N)
for b in range(int(END / bar) + 1):
    t0 = b * bar; ch = CH[b % 4]; n = int((bar + 0.4) * SR); t = np.arange(n) / SR
    env = np.minimum(1, t / 0.4) * np.minimum(1, (bar + 0.4 - t) / 0.4)
    put(pad, sum(saw(midi(m) * (1 + dt), t) for m in ch for dt in (-0.004, 0.005)) * env, t0, 0.05)
    for k in range(8):
        bt = t0 + k * beat / 2; nn = int(beat / 2 * SR); tt = np.arange(nn) / SR
        put(bass, saw(midi(ch[0] - 24), tt) * np.exp(-tt * 8), bt, 0.3 if bt > 0.3 else 0)
    for k in range(16):  # chiptune solo en la parte "retro"
        at = t0 + k * beat / 4
        if not (t_8bit0 <= at < t_8bit1): continue
        note = ch[[0, 2, 1, 2][k % 4]] + 24; nn = int(beat / 4 * SR); tt = np.arange(nn) / SR
        put(chip, sq(midi(note), tt, 0.25) * np.exp(-tt * 10), at, 0.045)
    for k in range(4):
        kt = t0 + k * beat
        if kt < seg["y1997"]["start"] - 0.1 or (t_rev - 0.1 < kt < t_rev + 2.0): continue
        nn = int(0.3 * SR); tt = np.arange(nn) / SR
        put(drums, np.sin(2 * np.pi * (45 + 100 * np.exp(-tt * 30)) * tt) * np.exp(-tt * 9), kt, 0.5)
        if k % 2: put(drums, hp(rng.standard_normal(nn), 1800) * np.exp(-tt * 20), kt, 0.1)
music = verb(lp(pad, 1500), 0.35) + lp(bass, 380) + lp(chip, 5000) + drums
fo = int(1.3 * SR); music[-fo:] *= np.linspace(1, 0, fo)

sfx = np.zeros(N)
def whoosh(d=0.5):
    n = int(d * SR); tt = np.linspace(0, 1, n); x = rng.standard_normal(n); o = np.zeros(n)
    for i in range(0, n, 1024): o[i:i + 1024] = lp(x[i:i + 1024], 300 + 5000 * np.sin(np.pi * tt[i]) ** 2)
    return o * np.sin(np.pi * tt) ** 2
def boom(d=1.6):
    n = int(d * SR); tt = np.arange(n) / SR
    return np.sin(2 * np.pi * (38 + 60 * np.exp(-tt * 12)) * tt) * np.exp(-tt * 2.6) + lp(rng.standard_normal(n), 800) * np.exp(-tt * 10) * 0.4
def blip(f=880, d=0.09):
    n = int(d * SR); tt = np.arange(n) / SR; return sq(f, tt) * np.exp(-tt * 25)
def buzz(d=0.35):
    n = int(d * SR); tt = np.arange(n) / SR
    return (saw(100, tt) + 0.5 * saw(200, tt)) * (rng.random(n) > 0.3) * np.exp(-tt * 4)
for shot, a, b in slots[1:]: put(sfx, whoosh(), a - 0.25, 0.3)
put(sfx, buzz(0.5), 0.15, 0.12)                                   # neón del título
put(sfx, buzz(0.4), slots[0][2] * 0.8, 0.15)                      # "y no es verdad": el neón falla
put(sfx, blip(220, 0.25) * np.linspace(1, 0.2, int(0.25 * SR)), seg["y1997"]["start"] - 0.1, 0.25)  # encendido CRT
for i in range(4): put(sfx, blip(660 + 110 * i), slots[2][1] + (slots[2][2] - slots[2][1]) * (0.12 + 0.07 * i), 0.18)
put(sfx, boom(), t_rev + 0.05, 0.75)
sfx = verb(sfx, 0.15)

voice = np.zeros(N)
for s in T:
    with wave.open(os.path.join(A, s["id"] + ".wav")) as w:
        sr = w.getframerate(); x = np.frombuffer(w.readframes(w.getnframes()), np.int16).astype(float) / 32768
        if w.getnchannels() == 2: x = x[::2]
    x = np.interp(np.arange(int(len(x) * SR / sr)) * sr / SR, np.arange(len(x)), x)
    put(voice, x, s["start"])
voice = hp(voice, 85)
ev = lp(np.abs(voice), 6); ev /= ev.max() + 1e-9
duck = 1 - 0.62 * np.clip(ev * 4, 0, 1)
for name, sig in (("mezcla_final", music * 0.5 * duck + sfx * 0.6 + voice), ("mezcla_sin_voz", music * 0.5 + sfx * 0.6)):
    sig = sig / (np.max(np.abs(sig)) + 1e-9) * 0.89; st = np.stack([sig, sig], 1)
    with wave.open(os.path.join(B, name + ".wav"), "w") as w:
        w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes((st * 32767).astype(np.int16).tobytes())

# ---------------------------------------------------------------- 4. look final + subtítulos + exportación
def export(audio, out):
    fc = (f"[0]eq=saturation=1.1:contrast=1.04,rgbashift=rh=2:bh=-2,vignette=PI/4.6,noise=alls=6:allf=t+u,"
          f"ass={os.path.join(B, 'subs.ass')}:fontsdir={FONTS}[v1];"
          f"[v1][2]overlay=enable='gte(t,0.4)'[v2];[v2][3]overlay=enable='gte(t,{END - 3.2:.2f})',format=yuv420p[v];"
          f"[1:a]loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000[a]")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", base, "-i", audio,
                    "-loop", "1", "-framerate", "30", "-i", os.path.join(B, "rotulo.png"),
                    "-loop", "1", "-framerate", "30", "-i", os.path.join(B, "aviso.png"),
                    "-filter_complex", fc, "-map", "[v]", "-map", "[a]", "-t", f"{END:.3f}",
                    "-c:v", "libx264", "-preset", "slow", "-crf", "20", "-maxrate", "16M", "-bufsize", "32M",
                    "-pix_fmt", "yuv420p", "-r", "30", "-c:a", "aac", "-b:a", "256k", "-movflags", "+faststart", out], check=True)
    print("OK ->", out)
tag = sys.argv[sys.argv.index("--tag") + 1] if "--tag" in sys.argv else ""
export(os.path.join(B, "mezcla_final.wav"), os.path.join(EX, f"EXP-002_lucia{tag}.mp4"))
if "--sin-voz" in sys.argv:
    export(os.path.join(B, "mezcla_sin_voz.wav"), os.path.join(EX, "EXP-002_SIN_VOZ.mp4"))
