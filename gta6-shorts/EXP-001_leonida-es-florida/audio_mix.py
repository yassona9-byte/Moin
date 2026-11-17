# EXP-001 · música original + SFX + mezcla con ducking (todo sintetizado aquí, sin samples de terceros)
import json, os, wave
import numpy as np
from scipy.signal import butter, sosfilt, fftconvolve

HERE = os.path.dirname(os.path.abspath(__file__))
B = os.path.join(HERE, "build"); A = os.path.join(HERE, "audio")
SR = 48000
T = {s["id"]: s for s in json.load(open(os.path.join(B, "timings.json")))}
DUR = 1025 / 30 + 0.05
N = int(DUR * SR)
rng = np.random.default_rng(7)
t_all = np.arange(N) / SR

def lp(x, fc, order=2): return sosfilt(butter(order, fc, "low", fs=SR, output="sos"), x)
def hp(x, fc, order=2): return sosfilt(butter(order, fc, "high", fs=SR, output="sos"), x)
def bp(x, lo, hi): return sosfilt(butter(2, [lo, hi], "band", fs=SR, output="sos"), x)
def saw(f, t): return 2 * ((f * t) % 1) - 1
def midi(n): return 440 * 2 ** ((n - 69) / 12)
def put(buf, sig, t0, gain=1.0):
    i = int(t0 * SR); j = min(N, i + len(sig))
    if i < N and j > i: buf[i:j] += sig[: j - i] * gain
def env_adsr(n, a, d, s, r):
    e = np.ones(n) * s; ia, idd, ir = int(a * SR), int(d * SR), int(r * SR)
    e[:ia] = np.linspace(0, 1, ia); e[ia:ia + idd] = np.linspace(1, s, idd)[: max(0, min(idd, n - ia))]
    if ir: e[-ir:] *= np.linspace(1, 0, ir)
    return e

reverb_ir = rng.standard_normal(int(2.2 * SR)) * np.exp(-np.linspace(0, 7, int(2.2 * SR)))
def verb(x, wet=0.25):
    y = fftconvolve(x, reverb_ir)[: len(x)]; y /= (np.max(np.abs(y)) + 1e-9)
    return x * (1 - wet) + y * wet * np.max(np.abs(x))

# ------------------------------------------------------------------ música
BPM = 100; beat = 60 / BPM; bar = 4 * beat
CH = [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]   # Am F C G
ctx0 = T["ctx"]["start"]; rv = T["reveal"]["start"]; boom_t = rv + 1.62
pad = np.zeros(N); bass = np.zeros(N); arp = np.zeros(N); drums = np.zeros(N)
nb = int(DUR / bar) + 1
for b in range(nb):
    t0 = b * bar; chord = CH[b % 4]; n = int(bar * SR) + int(0.4 * SR); t = np.arange(n) / SR
    sig = sum(saw(midi(m) * (1 + d), t) for m in chord for d in (-0.004, 0, 0.005))
    put(pad, sig * env_adsr(n, 0.5, 0.3, 0.8, 0.5), t0, 0.06)
    for k in range(8):  # bajo en corcheas
        bt = t0 + k * beat / 2
        if bt < ctx0 - 0.05: continue
        nn = int(beat / 2 * SR); tt = np.arange(nn) / SR
        s = saw(midi(chord[0] - 24), tt) * np.exp(-tt * 9)
        put(bass, s, bt, 0.35)
    for k in range(16):  # arpegio en semicorcheas
        at = t0 + k * beat / 4
        if at < ctx0 + 0.3: continue
        note = chord[[0, 1, 2, 1][k % 4]] + 12 + (12 if k % 8 >= 4 else 0)
        nn = int(beat / 4 * SR); tt = np.arange(nn) / SR
        s = np.sign(np.sin(2 * np.pi * midi(note) * tt)) * np.exp(-tt * 14)
        put(arp, s, at, 0.05)
    for k in range(4):  # bombo + caja
        kt = t0 + k * beat
        if kt < ctx0 - 0.05 or (rv - 0.1 < kt < boom_t): continue
        nn = int(0.35 * SR); tt = np.arange(nn) / SR
        kick = np.sin(2 * np.pi * (45 + 110 * np.exp(-tt * 30)) * tt) * np.exp(-tt * 9)
        put(drums, kick, kt, 0.55)
        if k % 2 == 1:
            sn = hp(rng.standard_normal(nn), 1500) * np.exp(-tt * 18)
            put(drums, sn, kt, 0.12)
pad = lp(pad, 1400); bass = lp(bass, 380); arp = lp(arp, 2600)
music = verb(pad, 0.35) + bass + verb(arp, 0.3) + drums
# silencio de tensión antes de LEONIDA
gate = np.ones(N); i0, i1 = int((rv + 0.9) * SR), int(boom_t * SR)
gate[i0:i1] = np.linspace(1, 0.25, i1 - i0); music *= gate
# fade final
fo = int(1.2 * SR); music[-fo:] *= np.linspace(1, 0, fo)

# ------------------------------------------------------------------ SFX
sfx = np.zeros(N)
def whoosh(d=0.55):
    n = int(d * SR); tt = np.linspace(0, 1, n)
    x = rng.standard_normal(n); out = np.zeros(n); blk = 1024
    for i in range(0, n, blk):
        fc = 300 + 5000 * np.sin(np.pi * tt[i]) ** 2
        out[i:i + blk] = lp(x[i:i + blk], fc)[: len(out[i:i + blk])]
    return out * np.sin(np.pi * tt) ** 2
def boom(d=1.8):
    n = int(d * SR); tt = np.arange(n) / SR
    return (np.sin(2 * np.pi * (38 + 60 * np.exp(-tt * 12)) * tt) * np.exp(-tt * 2.5)
            + lp(rng.standard_normal(n), 900) * np.exp(-tt * 10) * 0.5)
def thud():
    n = int(0.5 * SR); tt = np.arange(n) / SR
    return (np.sin(2 * np.pi * (70 + 80 * np.exp(-tt * 40)) * tt) * np.exp(-tt * 14)
            + bp(rng.standard_normal(n), 800, 4000) * np.exp(-tt * 45) * 0.7)
def riser(d):
    n = int(d * SR); tt = np.arange(n) / SR; p = tt / d
    f = 200 * (1 + 6 * p ** 2)
    tone = np.sin(2 * np.pi * np.cumsum(f) / SR) * 0.3
    return (hp(rng.standard_normal(n), 2000) * 0.5 + tone) * p ** 2

put(sfx, thud(), 0.05, 0.9)                                  # sello EXP #001
put(sfx, whoosh(0.9), T["ctx"]["start"] + 0.35, 0.35)        # grúa a panorámica
for k in range(6): put(sfx, thud() * 0.5, ctx0 + 3.4 + k * 4 / 30, 0.25)  # pilares
for rid in ("vice", "keys", "grass", "ambro", "kalaga", "port"):
    put(sfx, whoosh(), T[rid]["start"] - 0.2, 0.32)
put(sfx, whoosh(0.9), rv - 0.1, 0.35)
put(sfx, riser(1.5), boom_t - 1.5, 0.35)
put(sfx, boom(), boom_t, 0.9)
STAMPS = [rv + 2.35, rv + 3.05]
for st in STAMPS: put(sfx, thud(), st, 0.85)
sfx = verb(sfx, 0.18)

# ------------------------------------------------------------------ voz
voice = np.zeros(N)
for sid, s in T.items():
    w = wave.open(os.path.join(A, f"{sid}.wav")); sr = w.getframerate()
    x = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(np.float64) / 32768; w.close()
    x = np.interp(np.arange(int(len(x) * SR / sr)) / SR * sr, np.arange(len(x)), x)
    put(voice, x, s["start"], 1.0)
voice = hp(voice, 85)
voice = voice + 0.12 * verb(voice, 1.0)  # un poco de sala

# ducking: la música baja cuando hay voz
envv = np.abs(voice); envv = lp(envv, 6, 1); envv /= envv.max()
duck = 1 - 0.6 * np.clip(envv * 4, 0, 1)
mix_nv = music * 0.55 * duck + sfx * 0.6
mix = mix_nv + voice * 0.9
for name, sig in (("mezcla_final", mix), ("mezcla_sin_voz", mix_nv), ("musica", music * 0.55), ("sfx", sfx * 0.6)):
    sig = sig / (np.max(np.abs(sig)) + 1e-9) * 0.89
    st = np.stack([sig, sig], 1)
    with wave.open(os.path.join(B, f"{name}.wav"), "w") as w:
        w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((st * 32767).astype(np.int16).tobytes())
json.dump({"stamps": STAMPS, "boom": boom_t}, open(os.path.join(B, "eventos.json"), "w"))
print("ok", DUR)
