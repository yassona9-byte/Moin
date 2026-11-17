# EXP-001 · "Leonida es Florida" · escena Blender (4.0+)
# Uso:  blender -b -P escena_mapa.py -- [--frames A B] [--out ruta] [--scale 100] [--save]
import bpy, json, math, os, sys
from mathutils import Vector

HERE = os.path.dirname(os.path.abspath(__file__))
B = os.path.join(HERE, "build")
FONTS = os.path.join(HERE, "fonts")
FPS = 30

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
def arg(name, n=1, default=None):
    if name in argv:
        i = argv.index(name)
        return argv[i + 1:i + 1 + n] if n > 1 else argv[i + 1]
    return default

T = {s["id"]: s for s in json.load(open(os.path.join(B, "timings.json")))}
def fr(sec): return int(round(sec * FPS))
END = fr(T["cierre"]["start"] + T["cierre"]["dur"] + 2.2)

# ---------------------------------------------------------------- reset
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
sc.render.fps = FPS
sc.frame_start, sc.frame_end = 1, END

def hexcol(h, a=1.0):
    h = h.lstrip("#"); c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(((x / 12.92) if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4) for x in c) + (a,)

PINK, CYAN, ORANGE, PURPLE, AMBER, CREAM = (hexcol(x) for x in
    ("#FF2E88", "#2EC8FF", "#FF7A2F", "#3B1E6E", "#FFB547", "#FFF4E6"))

def emission_mat(name, col, strength):
    m = bpy.data.materials.new(name); m.use_nodes = True
    nt = m.node_tree; nt.nodes.clear()
    o = nt.nodes.new("ShaderNodeOutputMaterial"); e = nt.nodes.new("ShaderNodeEmission")
    e.inputs["Color"].default_value = col; e.inputs["Strength"].default_value = strength
    nt.links.new(e.outputs[0], o.inputs[0]); return m

# ---------------------------------------------------------------- Florida
LON0, LAT0, S = -83.5, 27.5, 2.0
KX = math.cos(math.radians(LAT0))
def proj(lon, lat): return ((lon - LON0) * KX * S, (lat - LAT0) * S)

geo = json.load(open(os.path.join(B, "florida.json")))
rings = []
for poly in geo["coordinates"]:
    ring = poly[0]
    xs = [p[0] for p in ring]; ys = [p[1] for p in ring]
    if max(max(xs) - min(xs), max(ys) - min(ys)) < 0.03: continue
    step = max(1, len(ring) // 400)
    pts = ring[::step]
    if len(pts) >= 4: rings.append([proj(*p) for p in pts])

def make_curve(name, dims, closed=True):
    cu = bpy.data.curves.new(name, "CURVE"); cu.dimensions = dims
    for r in rings:
        sp = cu.splines.new("POLY"); sp.points.add(len(r) - 1)
        for i, (x, y) in enumerate(r): sp.points[i].co = (x, y, 0, 1)
        sp.use_cyclic_u = closed
    ob = bpy.data.objects.new(name, cu); sc.collection.objects.link(ob); return ob

# losa del mapa
land = make_curve("Land", "2D"); land.data.fill_mode = "BOTH"; land.data.extrude = 0.12
m = bpy.data.materials.new("LandMat"); m.use_nodes = True; nt = m.node_tree
bsdf = nt.nodes["Principled BSDF"]
bsdf.inputs["Base Color"].default_value = hexcol("#120E2A")
bsdf.inputs["Roughness"].default_value = 0.35
tc = nt.nodes.new("ShaderNodeTexCoord")
sep = nt.nodes.new("ShaderNodeSeparateXYZ"); nt.links.new(tc.outputs["Object"], sep.inputs[0])
def gridline(axis):
    mul = nt.nodes.new("ShaderNodeMath"); mul.operation = "MULTIPLY"; mul.inputs[1].default_value = 2.0
    nt.links.new(sep.outputs[axis], mul.inputs[0])
    fr_ = nt.nodes.new("ShaderNodeMath"); fr_.operation = "PINGPONG"; fr_.inputs[1].default_value = 0.5
    nt.links.new(mul.outputs[0], fr_.inputs[0])
    lt = nt.nodes.new("ShaderNodeMath"); lt.operation = "LESS_THAN"; lt.inputs[1].default_value = 0.025
    nt.links.new(fr_.outputs[0], lt.inputs[0]); return lt
gx, gy = gridline("X"), gridline("Y")
mx = nt.nodes.new("ShaderNodeMath"); mx.operation = "MAXIMUM"
nt.links.new(gx.outputs[0], mx.inputs[0]); nt.links.new(gy.outputs[0], mx.inputs[1])
mulc = nt.nodes.new("ShaderNodeMath"); mulc.operation = "MULTIPLY"; mulc.inputs[1].default_value = 1.6
nt.links.new(mx.outputs[0], mulc.inputs[0])
bsdf.inputs["Emission Color"].default_value = CYAN
nt.links.new(mulc.outputs[0], bsdf.inputs["Emission Strength"])
land.data.materials.append(m)

# borde neón que "se dibuja"
rim = make_curve("Rim", "3D"); rim.location.z = 0.125
rim.data.bevel_depth = 0.03; rim.data.bevel_resolution = 2
rim.data.materials.append(emission_mat("RimMat", PINK, 14))
rim.data.bevel_factor_mapping_end = "SPLINE"
rim.data.bevel_factor_end = 0.0; rim.data.keyframe_insert("bevel_factor_end", frame=4)
rim.data.bevel_factor_end = 1.0; rim.data.keyframe_insert("bevel_factor_end", frame=fr(2.6))

# agua
bpy.ops.mesh.primitive_plane_add(size=400, location=(0, 0, -0.06))
water = bpy.context.object
wm = bpy.data.materials.new("Water"); wm.use_nodes = True; wn = wm.node_tree
wb = wn.nodes["Principled BSDF"]
wb.inputs["Base Color"].default_value = hexcol("#06050F")
wb.inputs["Roughness"].default_value = 0.06
noise = wn.nodes.new("ShaderNodeTexNoise"); noise.inputs["Scale"].default_value = 6
bump = wn.nodes.new("ShaderNodeBump"); bump.inputs["Strength"].default_value = 0.08
wn.links.new(noise.outputs[0], bump.inputs["Height"]); wn.links.new(bump.outputs[0], wb.inputs["Normal"])
water.data.materials.append(wm)

# cielo de atardecer (cilindro de fondo)
bpy.ops.mesh.primitive_cylinder_add(radius=90, depth=80, location=(0, 0, 30), vertices=96)
sky = bpy.context.object
for p in sky.data.polygons: p.flip()
sm = bpy.data.materials.new("Sky"); sm.use_nodes = True; sn = sm.node_tree; sn.nodes.clear()
so = sn.nodes.new("ShaderNodeOutputMaterial"); se = sn.nodes.new("ShaderNodeEmission")
stc = sn.nodes.new("ShaderNodeTexCoord"); ssep = sn.nodes.new("ShaderNodeSeparateXYZ")
ramp = sn.nodes.new("ShaderNodeValToRGB")
sn.links.new(stc.outputs["Generated"], ssep.inputs[0]); sn.links.new(ssep.outputs["Z"], ramp.inputs[0])
cr = ramp.color_ramp
cr.elements[0].position = 0.125; cr.elements[0].color = hexcol("#FF7A2F")
cr.elements[1].position = 0.45; cr.elements[1].color = hexcol("#07060E")
e = cr.elements.new(0.17); e.color = hexcol("#FF2E88")
e = cr.elements.new(0.26); e.color = hexcol("#3B1E6E")
sn.links.new(ramp.outputs[0], se.inputs["Color"]); se.inputs["Strength"].default_value = 1.4
sn.links.new(se.outputs[0], so.inputs[0]); sky.data.materials.append(sm)

# sol poniente
bpy.ops.mesh.primitive_circle_add(vertices=96, radius=9, fill_type="NGON", location=(-24, 75, 5.0),
                                  rotation=(math.radians(90), 0, math.radians(-17)))
sun = bpy.context.object
um = bpy.data.materials.new("SunM"); um.use_nodes = True; un = um.node_tree; un.nodes.clear()
uo = un.nodes.new("ShaderNodeOutputMaterial"); ue = un.nodes.new("ShaderNodeEmission")
utc = un.nodes.new("ShaderNodeTexCoord"); usep = un.nodes.new("ShaderNodeSeparateXYZ")
ur = un.nodes.new("ShaderNodeValToRGB")
un.links.new(utc.outputs["Generated"], usep.inputs[0]); un.links.new(usep.outputs["Y"], ur.inputs[0])
ur.color_ramp.elements[0].color = hexcol("#FF2E88"); ur.color_ramp.elements[1].color = hexcol("#FFD27A")
# franjas "synthwave" en la mitad inferior del sol
wv = un.nodes.new("ShaderNodeTexWave"); wv.wave_type = "BANDS"; wv.bands_direction = "Y"
wv.inputs["Scale"].default_value = 6
un.links.new(utc.outputs["Generated"], wv.inputs["Vector"])
gt = un.nodes.new("ShaderNodeMath"); gt.operation = "GREATER_THAN"; gt.inputs[1].default_value = 0.42
un.links.new(usep.outputs["Y"], gt.inputs[0])
lt2 = un.nodes.new("ShaderNodeMath"); lt2.operation = "GREATER_THAN"; lt2.inputs[1].default_value = 0.55
un.links.new(wv.outputs["Fac"], lt2.inputs[0])
mx2 = un.nodes.new("ShaderNodeMath"); mx2.operation = "MAXIMUM"
un.links.new(gt.outputs[0], mx2.inputs[0]); un.links.new(lt2.outputs[0], mx2.inputs[1])
st = un.nodes.new("ShaderNodeMath"); st.operation = "MULTIPLY"; st.inputs[1].default_value = 4.0
un.links.new(mx2.outputs[0], st.inputs[0])
un.links.new(ur.outputs[0], ue.inputs["Color"]); un.links.new(st.outputs[0], ue.inputs["Strength"])
un.links.new(ue.outputs[0], uo.inputs[0]); sun.data.materials.append(um)

sun_track_pending = sun

# mundo + niebla
w = bpy.data.worlds.new("W"); sc.world = w; w.use_nodes = True
w.node_tree.nodes["Background"].inputs["Color"].default_value = hexcol("#140A26")
w.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.4
vol = w.node_tree.nodes.new("ShaderNodeVolumePrincipled")
vol.inputs["Density"].default_value = 0.012; vol.inputs["Color"].default_value = hexcol("#B58CFF")
w.node_tree.links.new(vol.outputs[0], w.node_tree.nodes["World Output"].inputs["Volume"])

# luces
def light(kind, name, loc, rot, col, energy, size=None):
    ld = bpy.data.lights.new(name, kind); ld.color = col[:3]; ld.energy = energy
    if size: ld.size = size
    ld.specular_factor = 0.0 if kind == "AREA" else 1.0
    ob = bpy.data.objects.new(name, ld); ob.location = loc; ob.rotation_euler = rot
    sc.collection.objects.link(ob); return ob
light("SUN", "Sunset", (0, 0, 10), (math.radians(78), 0, math.radians(200)), ORANGE, 2.2)
light("AREA", "PinkFill", (-8, -10, 8), (math.radians(50), 0, math.radians(-35)), PINK, 600, 10)

# ---------------------------------------------------------------- regiones
REG = [  # id, juego, real, lon, lat, color
    ("vice",   "VICE CITY",       "≈ MIAMI",          -80.19, 25.77, PINK),
    ("keys",   "LEONIDA KEYS",    "≈ CAYOS DE FLORIDA", -81.09, 24.71, CYAN),
    ("grass",  "GRASSRIVERS",     "≈ EVERGLADES",     -80.95, 26.05, CYAN),
    ("ambro",  "AMBROSIA",        "≈ CENTRO DEL ESTADO", -81.05, 26.85, AMBER),
    ("kalaga", "MOUNT KALAGA",    "≈ NORTE",          -82.40, 30.35, CYAN),
    ("port",   "PORT GELLHORN",   "≈ ¿ ?",            -85.66, 30.16, AMBER),
]
FONT_A = bpy.data.fonts.load(os.path.join(FONTS, "Anton-Regular.ttf"))
FONT_B = bpy.data.fonts.load(os.path.join(FONTS, "BebasNeue-Regular.ttf"))

cam_d = bpy.data.cameras.new("Cam"); cam_d.lens = 30; cam_d.sensor_width = 36
cam = bpy.data.objects.new("Cam", cam_d); sc.collection.objects.link(cam); sc.camera = cam
tgt = bpy.data.objects.new("Target", None); sc.collection.objects.link(tgt)
tc_ = cam.constraints.new("TRACK_TO"); tc_.target = tgt; tc_.track_axis = "TRACK_NEGATIVE_Z"; tc_.up_axis = "UP_Y"

def pop(ob, f, dur=8, final=1.0):
    ob.scale = (0.001,) * 3; ob.keyframe_insert("scale", frame=max(1, f - 1))
    ob.scale = (final * 1.18,) * 3; ob.keyframe_insert("scale", frame=f + int(dur * .6))
    ob.scale = (final,) * 3; ob.keyframe_insert("scale", frame=f + dur)

def unpop(ob, f, dur=6, start=1.0):
    ob.scale = (start,) * 3; ob.keyframe_insert("scale", frame=f)
    ob.scale = (0.001,) * 3; ob.keyframe_insert("scale", frame=f + dur)

def text(body, font, size, col, strength, loc, name):
    td = bpy.data.curves.new(name, "FONT"); td.body = body; td.font = font
    td.size = size; td.align_x = "CENTER"; td.align_y = "CENTER"; td.extrude = 0.01
    ob = bpy.data.objects.new(name, td); ob.location = loc; sc.collection.objects.link(ob)
    td.materials.append(emission_mat(name + "M", col, strength))
    c = ob.constraints.new("COPY_ROTATION"); c.target = cam
    return ob

LOFF = {"vice": (0, 0, 1.9), "keys": (0, 0, 1.2), "grass": (0, 0, 3.0),
        "ambro": (0, 0, 3.6), "kalaga": (0, 0, 2.0), "port": (0, 0, 2.0)}
pos = {}; look = {}
seq_f = fr(T["ctx"]["start"] + 3.4)  # "seis regiones" -> aparecen los pilares
for i, (rid, game, real, lon, lat, col) in enumerate(REG):
    x, y = proj(lon, lat); pos[rid] = Vector((x, y, 0.12))
    h = LOFF[rid][2] - 0.45
    bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=h, location=(x, y, 0.12 + h / 2), vertices=12)
    beam = bpy.context.object; beam.data.materials.append(emission_mat(f"B{rid}", col, 18))
    # pivote del pilar en la base
    beam.data.transform(__import__("mathutils").Matrix.Translation((0, 0, h / 2)))
    beam.location.z = 0.12
    bpy.ops.mesh.primitive_torus_add(major_radius=0.18, minor_radius=0.018, location=(x, y, 0.13))
    ring = bpy.context.object; ring.data.materials.append(emission_mat(f"R{rid}", col, 14))
    f0 = seq_f + i * 4
    pop(beam, f0, 10); pop(ring, f0, 10)
    lf = fr(T[rid]["start"]) - 4
    ox, oy, oz = LOFF[rid]
    look[rid] = Vector((x, y, oz * 0.62))
    lab = text(game, FONT_A, 0.42, CREAM, 6, (x + ox, y + oy, oz + 0.05), f"L{rid}")
    sub = text(real, FONT_B, 0.30, col, 9, (x + ox, y + oy, oz - 0.28), f"S{rid}")
    pop(lab, lf, 9); pop(sub, lf + 5, 9)
    # en la panorámica final se ven más pequeñas
    rf = fr(T["reveal"]["start"]) - 6
    lab.scale = (1,) * 3; lab.keyframe_insert("scale", frame=rf)
    lab.scale = (1.6,) * 3; lab.keyframe_insert("scale", frame=rf + 12)
    unpop(sub, rf, 8)

c = sun_track_pending.constraints.new("TRACK_TO"); c.target = cam
c.track_axis = "TRACK_Z"; c.up_axis = "UP_Y"

# FLORIDA -> LEONIDA
center = Vector((0.4, 3.2, 0))
flo = text("FLORIDA", FONT_A, 2.1, CREAM, 3, (center.x, center.y, 6.5), "Florida")
leo = text("LEONIDA", FONT_A, 2.4, PINK, 16, (center.x, center.y, 6.5), "Leonida")
rv = fr(T["reveal"]["start"])
flo.scale = leo.scale = (0.001,) * 3
pop(flo, rv + 2, 8); unpop(flo, rv + fr(1.55), 6)
pop(leo, rv + fr(1.65), 10)

# ---------------------------------------------------------------- cámara
def key(f, cpos, tpos):
    cam.location = cpos; cam.keyframe_insert("location", frame=f)
    tgt.location = tpos; tgt.keyframe_insert("location", frame=f)

V = Vector
key(1,              V((8.6, -10.8, 0.9)),  V((3.8, -1.0, 0.2)))         # hook: rasante sobre el agua
key(fr(3.2),        V((7.4, -8.2, 1.6)),   V((3.0, 0.2, 0.2)))
key(fr(3.9),        V((6.0, -13.0, 7.0)),  V((0.4, 0.4, 0)))            # grúa a panorámica
key(fr(T["vice"]["start"] - 0.2), V((0.6, -12.2, 17.0)), V((0.4, 0.4, 0)))
OFF = V((0.9, -4.6, 3.4))
order = ["vice", "keys", "grass", "ambro", "kalaga", "port"]
for rid in order:
    s, d = T[rid]["start"], T[rid]["dur"]
    p = pos[rid]
    q = look[rid]
    key(fr(s + 0.15), q + OFF, q)
    key(fr(s + d + 0.1), q + OFF * 0.86 + V((0.25, 0, 0)), q)
rs = T["reveal"]["start"]
key(fr(rs + 0.5), V((1.0, -12.6, 17.6)), V((0.4, 0.6, 1.0)))
key(fr(T["cierre"]["start"]), V((0.2, -13.0, 17.0)), V((0.4, 0.6, 1.0)))
key(END, V((-0.8, -13.2, 16.2)), V((0.4, 0.6, 1.0)))

for ob in (cam, tgt):
    for fc in ob.animation_data.action.fcurves:
        for k in fc.keyframe_points:
            k.interpolation = "BEZIER"; k.easing = "AUTO"
            k.handle_left_type = k.handle_right_type = "AUTO_CLAMPED"
# temblor de cámara en mano
for i in range(3):
    fc = cam.animation_data.action.fcurves.find("location", index=i)
    n = fc.modifiers.new("NOISE"); n.scale = 40; n.strength = 0.06; n.phase = i * 13

# ---------------------------------------------------------------- render
r = sc.render
r.engine = "BLENDER_EEVEE"
r.resolution_x, r.resolution_y = 1080, 1920
r.resolution_percentage = int(arg("--scale", default="100"))
ee = sc.eevee
ee.taa_render_samples = int(arg("--samples", default="24"))
ee.use_bloom = True; ee.bloom_intensity = 0.09; ee.bloom_threshold = 0.9; ee.bloom_radius = 6.5
ee.use_ssr = True; ee.use_gtao = True
ee.volumetric_tile_size = "8"; ee.volumetric_end = 80
sc.view_settings.view_transform = "AgX"
try: sc.view_settings.look = "AgX - Punchy"
except Exception: pass
r.image_settings.file_format = "PNG"; r.image_settings.color_mode = "RGB"
r.filepath = arg("--out", default=os.path.join(B, "frames", "f_"))
fr_rng = arg("--frames", 2)
if fr_rng: sc.frame_start, sc.frame_end = int(fr_rng[0]), int(fr_rng[1])
if "--step" in argv: sc.frame_step = int(arg("--step"))
if "--save" in argv:
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(HERE, "EXP-001_mapa.blend"))
print("END FRAME", END)
