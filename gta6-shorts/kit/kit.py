# VICE KIT · utilidades reutilizables para escenas de Blender (4.0+)
# Uso desde un script de plano:  sys.path.insert(0, ".../gta6-shorts/kit"); from kit import *
import bpy, math, os
from mathutils import Vector

KIT = os.path.dirname(os.path.abspath(__file__))
FONTS = os.path.join(KIT, "fonts")
FPS = 30

def hexcol(h, a=1.0):
    h = h.lstrip("#"); c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(((x / 12.92) if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4) for x in c) + (a,)

PINK, CYAN, ORANGE, PURPLE, AMBER, CREAM, INK = (hexcol(x) for x in
    ("#FF2E88", "#2EC8FF", "#FF7A2F", "#3B1E6E", "#FFB547", "#FFF4E6", "#0B0A12"))

def reset(frames, fps=FPS):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene; sc.render.fps = fps; sc.frame_start, sc.frame_end = 1, frames
    return sc

def link(ob):
    bpy.context.scene.collection.objects.link(ob); return ob

# ------------------------------------------------------------- materiales
def mat_emission(name, col, strength):
    m = bpy.data.materials.new(name); m.use_nodes = True; nt = m.node_tree; nt.nodes.clear()
    o = nt.nodes.new("ShaderNodeOutputMaterial"); e = nt.nodes.new("ShaderNodeEmission")
    e.inputs["Color"].default_value = col; e.inputs["Strength"].default_value = strength
    nt.links.new(e.outputs[0], o.inputs[0]); return m

def mat_principled(name, col, rough=0.5, metal=0.0, emis=None, emis_str=0.0):
    m = bpy.data.materials.new(name); m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = col; b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    if emis: b.inputs["Emission Color"].default_value = emis; b.inputs["Emission Strength"].default_value = emis_str
    return m

def mat_wet_asphalt(name="WetAsphalt"):
    """Asfalto mojado: charcos (roughness baja) mezclados con asfalto rugoso. Reflejos de neón gratis."""
    m = bpy.data.materials.new(name); m.use_nodes = True; nt = m.node_tree
    b = nt.nodes["Principled BSDF"]; b.inputs["Base Color"].default_value = hexcol("#0D0C14")
    n = nt.nodes.new("ShaderNodeTexNoise"); n.inputs["Scale"].default_value = 2.2; n.inputs["Detail"].default_value = 6
    r = nt.nodes.new("ShaderNodeValToRGB"); r.color_ramp.elements[0].position = 0.45; r.color_ramp.elements[1].position = 0.6
    r.color_ramp.elements[0].color = (0.03, 0.03, 0.03, 1); r.color_ramp.elements[1].color = (0.55, 0.55, 0.55, 1)
    nt.links.new(n.outputs[0], r.inputs[0]); nt.links.new(r.outputs[0], b.inputs["Roughness"])
    n2 = nt.nodes.new("ShaderNodeTexNoise"); n2.inputs["Scale"].default_value = 60
    bu = nt.nodes.new("ShaderNodeBump"); bu.inputs["Strength"].default_value = 0.15
    nt.links.new(n2.outputs[0], bu.inputs["Height"]); nt.links.new(bu.outputs[0], b.inputs["Normal"])
    return m

def mat_brick(name="Brick", tint="#1A1426"):
    m = bpy.data.materials.new(name); m.use_nodes = True; nt = m.node_tree
    b = nt.nodes["Principled BSDF"]
    br = nt.nodes.new("ShaderNodeTexBrick"); br.inputs["Scale"].default_value = 6
    br.inputs["Color1"].default_value = hexcol(tint); br.inputs["Color2"].default_value = hexcol("#120E1C")
    br.inputs["Mortar"].default_value = hexcol("#07060B"); br.inputs["Mortar Size"].default_value = 0.015
    nt.links.new(br.outputs["Color"], b.inputs["Base Color"]); b.inputs["Roughness"].default_value = 0.85
    bu = nt.nodes.new("ShaderNodeBump"); bu.inputs["Strength"].default_value = 0.4
    nt.links.new(br.outputs["Fac"], bu.inputs["Height"]); nt.links.new(bu.outputs[0], b.inputs["Normal"])
    return m

def mat_image(name, path, strength=1.0, pixel=True, scanlines=0.0):
    """Pantalla: imagen como emisión (Closest = píxel nítido) con scanlines opcionales."""
    m = bpy.data.materials.new(name); m.use_nodes = True; nt = m.node_tree; nt.nodes.clear()
    o = nt.nodes.new("ShaderNodeOutputMaterial"); e = nt.nodes.new("ShaderNodeEmission")
    t = nt.nodes.new("ShaderNodeTexImage"); t.image = bpy.data.images.load(path)
    t.interpolation = "Closest" if pixel else "Linear"
    col = t.outputs["Color"]
    if scanlines:
        tc = nt.nodes.new("ShaderNodeTexCoord"); w = nt.nodes.new("ShaderNodeTexWave")
        w.bands_direction = "Y"; w.inputs["Scale"].default_value = 120
        nt.links.new(tc.outputs["UV"], w.inputs["Vector"])
        mr = nt.nodes.new("ShaderNodeMapRange"); mr.inputs["To Min"].default_value = 1 - scanlines
        nt.links.new(w.outputs["Fac"], mr.inputs["Value"])
        mul = nt.nodes.new("ShaderNodeMixRGB"); mul.blend_type = "MULTIPLY"; mul.inputs["Fac"].default_value = 1
        nt.links.new(col, mul.inputs[1]); nt.links.new(mr.outputs[0], mul.inputs[2]); col = mul.outputs[0]
    nt.links.new(col, e.inputs["Color"]); e.inputs["Strength"].default_value = strength
    nt.links.new(e.outputs[0], o.inputs[0]); return m, t

def swap_image_at(tex_node, path_b, frame):
    """Cambia la imagen de una pantalla en un fotograma (con 'mix' entre dos nodos)."""
    m = tex_node.id_data; nt = m
    tb = nt.nodes.new("ShaderNodeTexImage"); tb.image = bpy.data.images.load(path_b); tb.interpolation = tex_node.interpolation
    mix = nt.nodes.new("ShaderNodeMixRGB")
    dest = tex_node.outputs["Color"].links[0].to_socket
    nt.links.new(tex_node.outputs["Color"], mix.inputs[1]); nt.links.new(tb.outputs["Color"], mix.inputs[2])
    nt.links.new(mix.outputs[0], dest)
    f = mix.inputs["Fac"]; f.default_value = 0; f.keyframe_insert("default_value", frame=frame - 1)
    f.default_value = 1; f.keyframe_insert("default_value", frame=frame)
    return mix

def mat_hologram(name, col=None, strength=4.0):
    col = col or CYAN
    m = bpy.data.materials.new(name); m.use_nodes = True; nt = m.node_tree; nt.nodes.clear()
    o = nt.nodes.new("ShaderNodeOutputMaterial"); e = nt.nodes.new("ShaderNodeEmission")
    tr = nt.nodes.new("ShaderNodeBsdfTransparent"); mx = nt.nodes.new("ShaderNodeMixShader")
    fr = nt.nodes.new("ShaderNodeLayerWeight"); fr.inputs["Blend"].default_value = 0.35
    e.inputs["Color"].default_value = col; e.inputs["Strength"].default_value = strength
    nt.links.new(fr.outputs["Facing"], mx.inputs[0]); nt.links.new(tr.outputs[0], mx.inputs[1])
    nt.links.new(e.outputs[0], mx.inputs[2]); nt.links.new(mx.outputs[0], o.inputs[0])
    m.blend_method = "BLEND"; return m

# ------------------------------------------------------------- objetos
def font(name): return bpy.data.fonts.load(os.path.join(FONTS, name))

def text(body, fnt, size, mat, loc=(0, 0, 0), rot=(math.radians(90), 0, 0), extrude=0.02, align="CENTER", name=None):
    td = bpy.data.curves.new(name or body, "FONT"); td.body = body; td.font = fnt; td.size = size
    td.align_x = align; td.align_y = "CENTER"; td.extrude = extrude
    ob = link(bpy.data.objects.new(name or body, td)); ob.location = loc; ob.rotation_euler = rot
    td.materials.append(mat); return ob

def neon_flicker_on(mat, f_on, strength, flick=True):
    """Encendido de neón con parpadeo en el fotograma f_on."""
    s = mat.node_tree.nodes["Emission"].inputs["Strength"]
    seq = [(f_on - 1, 0), (f_on, strength)]
    if flick: seq += [(f_on + 2, strength * 0.1), (f_on + 4, strength), (f_on + 5, strength * 0.3), (f_on + 7, strength)]
    for f, v in seq:
        s.default_value = v; s.keyframe_insert("default_value", frame=max(0, f))
    s.default_value = strength

def pop_scale(ob, f, dur=8, final=1.0):
    ob.scale = (0.001,) * 3; ob.keyframe_insert("scale", frame=max(1, f - 1))
    ob.scale = (final * 1.15,) * 3; ob.keyframe_insert("scale", frame=f + int(dur * .6))
    ob.scale = (final,) * 3; ob.keyframe_insert("scale", frame=f + dur)

def light(kind, name, loc, rot, col, energy, size=None, spec=1.0):
    ld = bpy.data.lights.new(name, kind); ld.color = col[:3]; ld.energy = energy; ld.specular_factor = spec
    if size is not None and kind == "AREA": ld.size = size
    if size is not None and kind in ("POINT", "SPOT"): ld.shadow_soft_size = size
    ob = link(bpy.data.objects.new(name, ld)); ob.location = loc; ob.rotation_euler = rot; return ob

def camera(lens=32, target=None):
    cd = bpy.data.cameras.new("Cam"); cd.lens = lens; cd.sensor_width = 36
    cam = link(bpy.data.objects.new("Cam", cd)); bpy.context.scene.camera = cam
    tgt = link(bpy.data.objects.new("Target", None))
    c = cam.constraints.new("TRACK_TO"); c.target = tgt; c.track_axis = "TRACK_NEGATIVE_Z"; c.up_axis = "UP_Y"
    return cam, tgt

def cam_keys(cam, tgt, keys, handheld=0.03):
    """keys = [(frame, cam_pos, target_pos), ...] con interpolación suave + temblor de mano."""
    for f, cp, tp in keys:
        cam.location = cp; cam.keyframe_insert("location", frame=f)
        tgt.location = tp; tgt.keyframe_insert("location", frame=f)
    for ob in (cam, tgt):
        for fc in ob.animation_data.action.fcurves:
            for k in fc.keyframe_points: k.interpolation = "BEZIER"; k.handle_left_type = k.handle_right_type = "AUTO_CLAMPED"
    if handheld:
        for i in range(3):
            fc = cam.animation_data.action.fcurves.find("location", index=i)
            n = fc.modifiers.new("NOISE"); n.scale = 45; n.strength = handheld; n.phase = i * 17

def world_fog(col="#140A26", strength=0.35, density=0.02, fog_col="#B58CFF"):
    w = bpy.data.worlds.new("W"); bpy.context.scene.world = w; w.use_nodes = True
    bg = w.node_tree.nodes["Background"]; bg.inputs["Color"].default_value = hexcol(col); bg.inputs["Strength"].default_value = strength
    if density:
        v = w.node_tree.nodes.new("ShaderNodeVolumePrincipled")
        v.inputs["Density"].default_value = density; v.inputs["Color"].default_value = hexcol(fog_col)
        w.node_tree.links.new(v.outputs[0], w.node_tree.nodes["World Output"].inputs["Volume"])

def render_setup(scale=66, samples=16, out="//frames/f_"):
    sc = bpy.context.scene; r = sc.render
    r.engine = "BLENDER_EEVEE"; r.resolution_x, r.resolution_y = 1080, 1920; r.resolution_percentage = scale
    ee = sc.eevee; ee.taa_render_samples = samples
    ee.use_bloom = True; ee.bloom_intensity = 0.08; ee.bloom_threshold = 0.9; ee.bloom_radius = 6.5
    ee.use_ssr = True; ee.use_ssr_halfres = False; ee.use_gtao = True
    ee.volumetric_tile_size = "8"; ee.volumetric_end = 60; ee.use_soft_shadows = True
    sc.view_settings.view_transform = "AgX"
    try: sc.view_settings.look = "AgX - Punchy"
    except Exception: pass
    r.image_settings.file_format = "PNG"; r.image_settings.color_mode = "RGB"; r.filepath = out
