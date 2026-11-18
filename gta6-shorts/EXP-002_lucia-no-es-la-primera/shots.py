# EXP-002 · planos de Blender.  Uso:
#   blender -b -P shots.py -a -- --shot s1_titulo [--scale 66] [--samples 16]
import bpy, json, math, os, sys
from mathutils import Vector as V
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "kit"))
from kit import *

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
def arg(n, d=None): return argv[argv.index(n) + 1] if n in argv else d
SHOT = arg("--shot"); TEX = os.path.join(HERE, "build", "tex")
DUR = json.load(open(os.path.join(HERE, "build", "duraciones.json")))   # segundos por plano (incluye cola)
N = int(round(DUR[SHOT] * FPS))
def fr(frac): return max(1, int(round(frac * N)))      # momento relativo dentro del plano
R = math.radians

sc = reset(N)
A = font("Anton-Regular.ttf"); BB = font("BebasNeue-Regular.ttf"); PX = font("PressStart2P-Regular.ttf")

def floor(size=60, mat=None):
    bpy.ops.mesh.primitive_plane_add(size=size); f = bpy.context.object
    f.data.materials.append(mat or mat_wet_asphalt()); return f

def wall(y=6, w=40, h=20, mat=None):
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, y, h / 2), rotation=(R(90), 0, 0))
    o = bpy.context.object; o.scale = (w, h, 1); o.data.materials.append(mat or mat_brick())
    bpy.ops.object.transform_apply(scale=True)
    o.data.uv_layers.new() if not o.data.uv_layers else None
    return o

def tube(p0, p1, col, strength=14, r=0.035):
    p0, p1 = V(p0), V(p1); d = p1 - p0
    bpy.ops.mesh.primitive_cylinder_add(radius=r, depth=d.length, location=(p0 + p1) / 2, vertices=12)
    o = bpy.context.object; o.rotation_euler = d.to_track_quat("Z", "Y").to_euler()
    m = mat_emission("tube", col, strength); o.data.materials.append(m); return o, m

# =================================================================== S1 · título
if SHOT == "s1_titulo":
    floor(); wall(6)
    world_fog(density=0.035)
    mP = mat_emission("primera", PINK, 0)
    t1 = text("LA PRIMERA", A, 1.55, mP, (0, 5.9, 3.0), extrude=0.04)
    mC = mat_emission("prot", CREAM, 0)
    t2 = text("PROTAGONISTA DE GTA", BB, 0.62, mC, (0, 5.9, 4.3), extrude=0.02)
    mQ = mat_emission("q", CYAN, 0)
    q = text("?", A, 2.4, mQ, (0, 5.7, 1.35), extrude=0.05)
    q.rotation_euler = (R(90), 0, R(-8))
    neon_flicker_on(mC, 4, 6); neon_flicker_on(mP, 10, 12)
    # "...y no es verdad": LA PRIMERA se apaga y se enciende la interrogación
    off = fr(0.80); s = mP.node_tree.nodes["Emission"].inputs["Strength"]
    for f, v in [(off, 12), (off + 2, 1), (off + 4, 9), (off + 6, 0.4), (off + 9, 5), (off + 11, 0.25)]:
        s.default_value = v; s.keyframe_insert("default_value", frame=f)
    neon_flicker_on(mQ, off + 8, 16)
    for x, col in ((-2.5, CYAN), (2.5, PINK)):
        tube((x, 5.8, 0.3), (x, 5.8, 5.6), col, 10)
    light("AREA", "wash", (0, 2.5, 7.5), (R(25), 0, 0), hexcol("#B58CFF"), 600, 8, 0.2)
    light("AREA", "rim", (0, 3, 6), (R(30), 0, 0), PINK, 250, 6)
    light("POINT", "warm", (-4, 2, 1.5), (0, 0, 0), ORANGE, 300, 1)
    cam, tgt = camera(28)
    cam_keys(cam, tgt, [(1, V((0.5, -4.5, 0.5)), V((0, 5.8, 2.4))),
                        (N, V((0.05, -1.2, 1.3)), V((0, 5.8, 2.9)))], 0.02)

# =================================================================== S2 · CRT 1997
elif SHOT == "s2_crt":
    floor(60, mat_principled("desk", hexcol("#2A1A12"), 0.35))
    wall(3.2, 30, 14, mat_brick("wall", "#1C1626"))
    world_fog(density=0.015)
    # monitor CRT: carcasa beige + pantalla
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.45, 0.95)); body = bpy.context.object
    body.scale = (1.9, 1.5, 1.55); bpy.ops.object.transform_apply(scale=True)
    bv = body.modifiers.new("b", "BEVEL"); bv.width = 0.12; bv.segments = 4
    body.data.materials.append(mat_principled("beige", hexcol("#BDB39A"), 0.55))
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.95, 0.85)); back = bpy.context.object
    back.scale = (1.4, 1.0, 1.1); back.data.materials.append(body.data.materials[0])
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, -0.305, 1.02), rotation=(R(90), 0, 0)); scr = bpy.context.object
    scr.scale = (1.6, 1.2, 1)
    m, tnode = mat_image("screen", os.path.join(TEX, "select_a.png"), 2.2, True, 0.35)
    scr.data.materials.append(m)
    swap_image_at(tnode, os.path.join(TEX, "select_b.png"), fr(0.58))
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -0.95, 0.06)); kb = bpy.context.object
    kb.scale = (1.7, 0.55, 0.08); kb.data.materials.append(body.data.materials[0])
    m97 = mat_emission("y97", AMBER, 0)
    text("1997", A, 1.6, m97, (0, 3.1, 3.25), extrude=0.05)
    neon_flicker_on(m97, 3, 10)
    light("POINT", "screenglow", (0, -1.2, 1.1), (0, 0, 0), CYAN, 60, 0.8)
    light("AREA", "lamp", (-2.5, -1.5, 3.2), (R(40), 0, R(-50)), ORANGE, 220, 1.5)
    light("AREA", "rim", (2.5, 2.0, 3.0), (R(-30), 0, R(130)), PINK, 160, 3)
    cam, tgt = camera(30)
    cam_keys(cam, tgt, [(1, V((0.9, -6.2, 2.2)), V((0, 1.0, 1.9))),
                        (fr(0.45), V((0.35, -4.2, 1.35)), V((0, 0, 1.1))),
                        (N, V((0.0, -2.75, 1.05)), V((0, -0.3, 1.02)))], 0.012)

# =================================================================== S4 · portátil
elif SHOT == "s4_portatil":
    world_fog("#1A0B2A", 0.5, 0.0)
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, 4, 0), rotation=(R(90), 0, 0)); bg = bpy.context.object
    bg.scale = (30, 30, 1)
    gm = bpy.data.materials.new("bg"); gm.use_nodes = True; nt = gm.node_tree; nt.nodes.clear()
    o = nt.nodes.new("ShaderNodeOutputMaterial"); e = nt.nodes.new("ShaderNodeEmission")
    tc = nt.nodes.new("ShaderNodeTexCoord"); gr = nt.nodes.new("ShaderNodeTexGradient"); gr.gradient_type = "SPHERICAL"
    mp = nt.nodes.new("ShaderNodeMapping"); mp.inputs["Location"].default_value = (0.5, 0.5, 0); mp.inputs["Scale"].default_value = (2.6, 2.6, 1)
    nt.links.new(tc.outputs["UV"], mp.inputs[0])
    # centrar el degradado
    mp.inputs["Location"].default_value = (-0.0, -0.0, 0)
    sub = nt.nodes.new("ShaderNodeVectorMath"); sub.operation = "SUBTRACT"; sub.inputs[1].default_value = (0.5, 0.5, 0)
    nt.links.new(tc.outputs["UV"], sub.inputs[0]); sc2 = nt.nodes.new("ShaderNodeVectorMath"); sc2.operation = "SCALE"
    sc2.inputs["Scale"].default_value = 2.4; nt.links.new(sub.outputs[0], sc2.inputs[0]); nt.links.new(sc2.outputs[0], gr.inputs[0])
    rp = nt.nodes.new("ShaderNodeValToRGB"); rp.color_ramp.elements[0].color = hexcol("#0B0A12"); rp.color_ramp.elements[1].color = hexcol("#5A1E7E")
    nt.links.new(gr.outputs["Fac"], rp.inputs[0]); nt.links.new(rp.outputs[0], e.inputs[0]); e.inputs[1].default_value = 1.2
    nt.links.new(e.outputs[0], o.inputs[0]); bg.data.materials.append(gm)
    piv = link(bpy.data.objects.new("piv", None))
    bpy.ops.mesh.primitive_cube_add(size=1); body = bpy.context.object; body.scale = (1.0, 0.22, 1.65)
    bpy.ops.object.transform_apply(scale=True); bv = body.modifiers.new("b", "BEVEL"); bv.width = 0.12; bv.segments = 6
    body.data.materials.append(mat_principled("plastic", hexcol("#1F2A36"), 0.3, 0.2)); body.parent = piv
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -0.105, 0.36)); bez = bpy.context.object
    bez.scale = (0.84, 0.02, 0.74); bez.data.materials.append(mat_principled("bezel", hexcol("#22202A"), 0.4)); bez.parent = piv
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, -0.118, 0.36), rotation=(R(90), 0, 0)); scr = bpy.context.object
    scr.scale = (0.62, 0.56, 1); scr.parent = piv
    m, tnode = mat_image("gb", os.path.join(TEX, "gb_a.png"), 1.6, True, 0.15); scr.data.materials.append(m)
    swap_image_at(tnode, os.path.join(TEX, "gb_b.png"), fr(0.42))
    dk = mat_principled("btn", hexcol("#1A1820"), 0.4)
    for sx, sz in ((0.36, 0.1), (0.1, 0.36)):
        bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.3, -0.12, -0.35)); c = bpy.context.object
        c.scale = (sx, 0.05, sz); c.data.materials.append(dk); c.parent = piv
    for x, z in ((0.22, -0.4), (0.4, -0.28)):
        bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.06, location=(x, -0.12, z), rotation=(R(90), 0, 0))
        c = bpy.context.object; c.data.materials.append(mat_principled("ab", hexcol("#2EC8FF"), 0.3, 0, CYAN, 2)); c.parent = piv
    piv.rotation_euler = (R(4), 0, R(-16)); piv.keyframe_insert("rotation_euler", frame=1)
    piv.rotation_euler = (R(-2), 0, R(10)); piv.keyframe_insert("rotation_euler", frame=N)
    light("AREA", "key", (-2, -3, 2.5), (R(55), 0, R(-35)), CREAM, 120, 2)
    light("AREA", "rimP", (2.2, 1.2, 1.5), (R(-80), 0, R(120)), PINK, 260, 1.5)
    light("AREA", "rimC", (-2.2, 1.2, -0.5), (R(-100), 0, R(-120)), CYAN, 200, 1.5)
    cam, tgt = camera(50)
    cam_keys(cam, tgt, [(1, V((0.2, -5.4, 0.3)), V((0, 0, 0.05))), (N, V((0.05, -3.9, 0.35)), V((0, 0, 0.25)))], 0.01)

# =================================================================== S5 · creador (2013)
elif SHOT == "s5_creador":
    floor(60, mat_principled("glossy", hexcol("#07060E"), 0.12))
    world_fog(density=0.02)
    hol = mat_hologram("holo", CYAN, 5)
    nt = hol.node_tree; lw = nt.nodes["Layer Weight"]; mx = nt.nodes["Mix Shader"]
    mr = nt.nodes.new("ShaderNodeMapRange"); mr.inputs["To Min"].default_value = 0.35
    nt.links.new(lw.outputs["Facing"], mr.inputs["Value"]); nt.links.new(mr.outputs[0], mx.inputs[0])
    piv = link(bpy.data.objects.new("piv", None))
    def part(kind, loc, scale, rot=(0, 0, 0)):
        if kind == "cyl": bpy.ops.mesh.primitive_cylinder_add(vertices=24, location=loc, rotation=rot)
        else: bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=14, location=loc)
        o = bpy.context.object; o.scale = scale; o.data.materials.append(hol); o.parent = piv
        w = o.modifiers.new("w", "WIREFRAME"); w.thickness = 0.006; w.use_replace = False
        bpy.ops.object.shade_smooth(); return o
    part("sph", (0, 0, 1.68), (0.12, 0.13, 0.15))
    part("cyl", (0, 0, 1.5), (0.045, 0.045, 0.06))
    part("cyl", (0, 0, 1.22), (0.17, 0.11, 0.24))            # torso
    part("cyl", (0, 0, 0.92), (0.16, 0.1, 0.1))              # cadera
    for x in (-0.08, 0.08): part("cyl", (x, 0, 0.45), (0.06, 0.06, 0.42))
    for x, a in ((-0.24, -12), (0.24, 12)): part("cyl", (x, 0, 1.18), (0.04, 0.04, 0.3), (0, R(a), 0))
    for x in (-0.13, 0.13): part("sph", (x, 0, 0.98), (0.1, 0.09, 0.08))
    piv.rotation_euler = (0, 0, 0); piv.keyframe_insert("rotation_euler", frame=1)
    piv.rotation_euler = (0, 0, R(160)); piv.keyframe_insert("rotation_euler", frame=N)
    for fc in piv.animation_data.action.fcurves:
        for k in fc.keyframe_points: k.interpolation = "LINEAR"
    bpy.ops.mesh.primitive_torus_add(major_radius=0.55, minor_radius=0.012, location=(0, 0, 0.02))
    bpy.context.object.data.materials.append(mat_emission("ring", PINK, 14))
    bpy.ops.mesh.primitive_cylinder_add(radius=0.52, depth=0.03, location=(0, 0, 0.0))
    bpy.context.object.data.materials.append(mat_principled("base", hexcol("#141024"), 0.2))
    def panel(img, loc, rot):
        bpy.ops.mesh.primitive_plane_add(size=1, location=loc, rotation=rot); p = bpy.context.object
        p.scale = (0.9, 0.54, 1)
        m = bpy.data.materials.new(img); m.use_nodes = True; nt = m.node_tree; nt.nodes.clear()
        o = nt.nodes.new("ShaderNodeOutputMaterial"); t = nt.nodes.new("ShaderNodeTexImage"); t.image = bpy.data.images.load(os.path.join(TEX, img))
        e = nt.nodes.new("ShaderNodeEmission"); e.inputs[1].default_value = 1.8; tr = nt.nodes.new("ShaderNodeBsdfTransparent")
        mx = nt.nodes.new("ShaderNodeMixShader"); nt.links.new(t.outputs["Color"], e.inputs[0]); nt.links.new(t.outputs["Alpha"], mx.inputs[0])
        nt.links.new(tr.outputs[0], mx.inputs[1]); nt.links.new(e.outputs[0], mx.inputs[2]); nt.links.new(mx.outputs[0], o.inputs[0])
        m.blend_method = "BLEND"; p.data.materials.append(m); return p
    pa = panel("panel_a.png", (-0.95, 0.15, 1.25), (R(90), 0, R(18)))
    pb = panel("panel_b.png", (0.95, 0.15, 0.75), (R(90), 0, R(-18)))
    pop_scale(pa, 6, 10); pop_scale(pb, 12, 10)
    m13 = mat_emission("y13", AMBER, 0)
    text("2013", A, 0.9, m13, (0, 3.5, 3.45), extrude=0.04); neon_flicker_on(m13, 3, 9)
    mOn = mat_emission("on", CREAM, 0)
    text("GTA ONLINE", BB, 0.42, mOn, (0, 3.5, 2.85), extrude=0.02); neon_flicker_on(mOn, 8, 5)
    light("AREA", "rim", (0, 2, 3), (R(-40), 0, 0), PINK, 200, 3)
    cam, tgt = camera(35)
    cam_keys(cam, tgt, [(1, V((0.5, -3.6, 1.3)), V((0, 0.4, 1.15))), (N, V((-0.2, -3.0, 1.15)), V((0, 0.4, 1.1)))], 0.008)

# =================================================================== S6 · Lucía
elif SHOT == "s6_lucia":
    floor(); wall(5, 40, 20, mat_brick("wall", "#221628"))
    world_fog(density=0.03)
    letters = "LUCÍA"; mats = []
    x0 = -2.6
    for i, ch in enumerate(letters):
        m = mat_emission(f"L{i}", PINK, 0); mats.append(m)
        text(ch, A, 1.9, m, (x0 + i * 1.3, 4.9, 3.6), extrude=0.05, name=f"L{i}")
    for i, m in enumerate(mats): neon_flicker_on(m, fr(0.12) + i * 5, 15, flick=(i % 2 == 0))
    words = [("NOMBRE", CYAN, -2.3, 0.66), ("VOZ", AMBER, 0.0, 0.74), ("HISTORIA", CREAM, 2.4, 0.83)]
    for w, col, x, t in words:
        m = mat_emission(w, col, 0); text(w, BB, 0.62, m, (x, 4.9, 1.75), extrude=0.03)
        neon_flicker_on(m, fr(t), 10)
    tube((-3.6, 4.85, 2.55), (3.6, 4.85, 2.55), PINK, 8, 0.02)
    light("AREA", "glow", (0, 3, 4), (R(-60), 0, 0), PINK, 300, 5)
    light("AREA", "wash", (0, 1.5, 7.5), (R(20), 0, 0), hexcol("#B58CFF"), 500, 8, 0.2)
    light("POINT", "warm", (3.5, 1.0, 1.0), (0, 0, 0), ORANGE, 260, 1)
    cam, tgt = camera(26)
    cam_keys(cam, tgt, [(1, V((0.4, -3.2, 0.35)), V((0, 3.0, 0.4))),
                        (fr(0.3), V((0.2, -4.6, 1.4)), V((0, 4.9, 3.2))),
                        (N, V((0.0, -5.6, 2.2)), V((0, 4.9, 2.9)))], 0.015)

# =================================================================== S7 · línea temporal
elif SHOT == "s7_linea":
    floor(120, mat_principled("glossy", hexcol("#07060E"), 0.1))
    world_fog(density=0.025)
    K = 0.62
    marks = [(1997, "GTA", "1997", AMBER), (2000, "GTA 2 · GBC", "2000", AMBER),
             (2013, "GTA ONLINE", "2013", CYAN), (2026, "GTA VI · LUCÍA", "2026", PINK)]
    end_x = (2026 - 1997) * K
    cu = bpy.data.curves.new("line", "CURVE"); cu.dimensions = "3D"; sp = cu.splines.new("POLY"); sp.points.add(1)
    sp.points[0].co = (0, 0, 0.05, 1); sp.points[1].co = (end_x, 0, 0.05, 1)
    cu.bevel_depth = 0.03; ln = link(bpy.data.objects.new("line", cu)); cu.materials.append(mat_emission("ln", PINK, 12))
    MT = {1997: 4, 2000: fr(0.2), 2013: fr(0.42), 2026: fr(0.64)}     # momento en que la línea llega a cada año
    for y, f in MT.items():
        cu.bevel_factor_end = (y - 1997) * K / end_x; cu.keyframe_insert("bevel_factor_end", frame=f)
    for y, lab, yr, col in marks:
        x = (y - 1997) * K; f_on = MT[y]
        big = y == 2026
        o, m = tube((x, 0, 0.05), (x, 0, 1.4 if big else 0.9), col, 14, 0.03)
        pop_scale(o, f_on, 8)
        my = mat_emission("y" + yr, col, 0)
        text(yr, A, 0.75 if big else 0.5, my, (x, 0, (2.0 if big else 1.3)), extrude=0.03); neon_flicker_on(my, f_on, 12 if big else 8)
        ml = mat_emission("l" + yr, CREAM, 0)
        text(lab, BB, 0.36 if big else 0.27, ml, (x, 0, (1.55 if big else 1.0) + (0.0 if big else -0.0) - (0.0)), extrude=0.015).location.z = (2.55 if big else 1.68)
        neon_flicker_on(ml, f_on + 4, 5, flick=False)
    light("AREA", "rim", (end_x, 3, 3), (R(-50), 0, 0), PINK, 200, 4, 0.0)
    cam, tgt = camera(30)
    keys = []
    for y, *_ in marks:
        x = (y - 1997) * K
        keys.append((max(1, MT[y] + 4), V((x - 0.45, -4.2, 1.55)), V((x, 0, 0.95))))
    keys[0] = (1, V((-0.6, -4.0, 1.5)), V((0.2, 0, 0.9)))
    keys.append((N, V((end_x - 0.7, -4.3, 1.7)), V((end_x, 0, 1.6))))
    cam_keys(cam, tgt, keys, 0.01)

else:
    raise SystemExit("plano desconocido: %s" % SHOT)

render_setup(int(arg("--scale", "66")), int(arg("--samples", "16")),
             os.path.join(HERE, "build", "shots", SHOT, "f_"))
if "--frames" in argv:
    i = argv.index("--frames"); sc.frame_start, sc.frame_end = int(argv[i + 1]), int(argv[i + 2])
print("SHOT", SHOT, "frames", N)
