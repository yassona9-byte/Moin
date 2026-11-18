# EXP-002 · locución por frases + tiempos por palabra -> audio/<id>.wav y build/timings.json
#   python3 voz.py piper                       (borrador gratis, local)
#   python3 voz.py elevenlabs --list           (lista tus voces de ElevenLabs)
#   python3 voz.py elevenlabs --voice <ID>     (versión final)
# La clave de ElevenLabs NO va aquí: la añade el proxy del entorno a las peticiones a api.elevenlabs.io.
import base64, json, os, subprocess, sys, urllib.request, wave

HERE = os.path.dirname(os.path.abspath(__file__))
A = os.path.join(HERE, "audio"); B = os.path.join(HERE, "build"); os.makedirs(A, exist_ok=True)
G = json.load(open(os.path.join(HERE, "guion.json")))
engine = sys.argv[1] if len(sys.argv) > 1 else "piper"
def opt(n, d=None): return sys.argv[sys.argv.index(n) + 1] if n in sys.argv else d
GAP = {"hook": 0.35, "y1997": 0.25, "sprite": 0.2, "gbc": 0.2, "online": 0.3, "reveal": 0.35}

def wav_dur(p):
    with wave.open(p) as w: return w.getnframes() / w.getframerate()

def est_words(text, dur):
    """Tiempos de palabra aproximados (por nº de letras) cuando el motor no los da."""
    ws = text.split(); tot = sum(len(w) + 2 for w in ws); t = 0; out = []
    for w in ws:
        d = dur * (len(w) + 2) / tot; out.append([w, round(t, 3), round(t + d, 3)]); t += d
    return out

def el_request(path, payload=None):
    req = urllib.request.Request("https://api.elevenlabs.io" + path,
                                 data=json.dumps(payload).encode() if payload else None,
                                 headers={"xi-api-key": "proxy-injects-real-key", "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=120) as r: return json.loads(r.read())

if engine == "elevenlabs" and "--list" in sys.argv:
    for v in el_request("/v1/voices")["voices"]:
        print(v["voice_id"], "|", v["name"], "|", v.get("labels", {}))
    sys.exit()

t = 0.3; out = []
for s in G:
    wavp = os.path.join(A, s["id"] + ".wav")
    if engine == "piper":
        M = "/tmp/claude-0/voices/voice-es-carlfm-x-low/es-carlfm-x-low.onnx"
        txt = s["text"].replace("GTA", "ge te a").replace("Grand Theft Auto", "Grand Theft Auto")
        subprocess.run(["python3", "-m", "piper", "-m", M, "--length-scale", "0.9", "-f", wavp],
                       input=txt.encode(), check=True, capture_output=True)
        d = wav_dur(wavp); words = est_words(s["text"], d)
    else:
        vid = opt("--voice") or sys.exit("falta --voice <ID>")
        res = el_request(f"/v1/text-to-speech/{vid}/with-timestamps?output_format=mp3_44100_128", {
            "text": s["text"], "model_id": opt("--model", "eleven_multilingual_v2"),
            "language_code": "es",
            "voice_settings": {"stability": 0.4, "similarity_boost": 0.8, "style": 0.35, "use_speaker_boost": True}})
        mp3 = wavp.replace(".wav", ".mp3"); open(mp3, "wb").write(base64.b64decode(res["audio_base64"]))
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", mp3, "-ar", "48000", "-ac", "1", wavp], check=True)
        d = wav_dur(wavp)
        al = res["alignment"]; chars, st, en = al["characters"], al["character_start_times_seconds"], al["character_end_times_seconds"]
        words, cur, c0 = [], "", None
        for ch, a, b in zip(chars, st, en):
            if ch.isspace():
                if cur: words.append([cur, round(c0, 3), round(pb, 3)]); cur = ""
            else:
                if not cur: c0 = a
                cur += ch; pb = b
        if cur: words.append([cur, round(c0, 3), round(pb, 3)])
    out.append({**s, "start": round(t, 3), "dur": round(d, 3), "words": words})
    t += d + GAP.get(s["id"], 0.2)
json.dump(out, open(os.path.join(B, "timings.json"), "w"), indent=1, ensure_ascii=False)
for o in out: print(f'{o["id"]:8s} {o["start"]:6.2f}s  {o["dur"]:5.2f}s')
print("total", round(t + 2.0, 2), "s")
