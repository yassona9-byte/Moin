extends Node3D
# ============================================================
# Moin Soccer 3D - partido de futbol 11v11 en 3D (Godot 4.3)
# Campo, porterias, balon y jugadores en 3D con camara detras.
# Controles tactiles: joystick + botones TIRO / PASE / CORRER.
# ============================================================

# --- Medidas del campo (metros) ---
const HALF_W = 22.0   # ancho/2 (eje X)
const HALF_L = 33.0   # largo/2 (eje Z)
const GOAL_HW = 4.0   # media porteria
const PR = 0.5        # radio jugador
const PH = 2.0        # altura jugador
const BR = 0.4        # radio balon
const SPEED = 7.5     # velocidad base m/s
const MATCH_REAL = 180.0  # segundos reales de partido

# Formacion 4-4-2 -> [rol, nx(-1..1), nz(0..1 desde porteria propia al centro)]
const FORM = [
	["GK", 0.0, 0.05],
	["DF", 0.70, 0.22], ["DF", 0.24, 0.16], ["DF", -0.24, 0.16], ["DF", -0.70, 0.22],
	["MF", 0.66, 0.40], ["MF", 0.22, 0.34], ["MF", -0.22, 0.34], ["MF", -0.66, 0.40],
	["FW", 0.28, 0.48], ["FW", -0.28, 0.48],
]
const NUM = [1, 2, 5, 4, 3, 7, 6, 8, 11, 9, 10]

const HOME_NAME = "BLANCOS"
const AWAY_NAME = "ROJOS"
const HOME_COL = Color(0.94, 0.94, 0.94)
const AWAY_COL = Color(0.88, 0.20, 0.20)
const HOME_SQUAD = ["Cortés","Carvajo","Militón","Rudigo","Mendi","Valverdi","Chuamé","Bellinghо","Vinisu","Mbabo","Rodrigo"]
const AWAY_SQUAD = ["Alison","Alexande","Konato","Van Dei","Roberto","Sobosla","Mac Ali","Graven","Diaz L","Salo","Nuñe"]

var players = []      # Array de Dictionary
var ball = {}         # Dictionary: node, vel(Vector2), owner(int idx o -1), last(-1)
var cam: Camera3D
var home_score = 0
var away_score = 0
var clock = 0.0
var state = "kickoff"  # kickoff | play | goal | end
var state_t = 0.0
var kickoff_team = "home"
var poss = "home"
var shoot_hold = 0.0
var user_idx = -1

# --- Input tactil ---
var joy_id = -1
var joy_origin = Vector2.ZERO
var joy_cur = Vector2.ZERO
const JOY_R = 90.0
var in_shoot = false
var in_sprint = false
var pass_edge = false
var btn_touch = {}    # index -> nombre boton

# --- UI ---
var ui: CanvasLayer
var joy_base: Panel
var joy_knob: Panel
var b_shoot: Panel
var b_pass: Panel
var b_sprint: Panel
var lbl_score: Label
var lbl_time: Label
var lbl_name: Label
var lbl_msg: Label
var rect_shoot = Rect2()
var rect_pass = Rect2()
var rect_sprint = Rect2()

func _ready() -> void:
	_build_world()
	_build_ui()
	_update_layout()
	_setup_match()

# ============================================================
# Construccion del mundo 3D
# ============================================================
func _build_world() -> void:
	var env = WorldEnvironment.new()
	var e = Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -40, 0)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	add_child(sun)

	cam = Camera3D.new()
	cam.fov = 70
	cam.position = Vector3(0, 16, -26)
	add_child(cam)
	cam.look_at(Vector3(0, 0, 0), Vector3.UP)
	cam.current = true

	# Cesped
	var pitch = MeshInstance3D.new()
	var pm = PlaneMesh.new()
	pm.size = Vector2(HALF_W * 2 + 8, HALF_L * 2 + 8)
	pitch.mesh = pm
	pitch.material_override = _mat(Color(0.12, 0.62, 0.28))
	add_child(pitch)

	# Lineas
	var lc = Color(1, 1, 1, 0.85)
	_add_box(Vector3(0, 0.02, 0), Vector3(HALF_W * 2, 0.04, 0.3), lc)          # medio campo
	_add_box(Vector3(0, 0.02, HALF_L), Vector3(HALF_W * 2, 0.04, 0.3), lc)     # fondo +
	_add_box(Vector3(0, 0.02, -HALF_L), Vector3(HALF_W * 2, 0.04, 0.3), lc)    # fondo -
	_add_box(Vector3(HALF_W, 0.02, 0), Vector3(0.3, 0.04, HALF_L * 2), lc)     # banda der
	_add_box(Vector3(-HALF_W, 0.02, 0), Vector3(0.3, 0.04, HALF_L * 2), lc)    # banda izq
	var circle = MeshInstance3D.new()
	var tm = TorusMesh.new()
	tm.inner_radius = 8.4
	tm.outer_radius = 9.0
	circle.mesh = tm
	circle.position = Vector3(0, 0.03, 0)
	circle.material_override = _mat(lc)
	add_child(circle)

	# Porterias
	_add_goal(HALF_L)
	_add_goal(-HALF_L)

	# Balon
	var bnode = MeshInstance3D.new()
	var sm = SphereMesh.new()
	sm.radius = BR
	sm.height = BR * 2
	bnode.mesh = sm
	bnode.material_override = _mat(Color(1, 1, 1))
	add_child(bnode)
	ball = {"node": bnode, "vel": Vector2.ZERO, "owner": -1, "last": -1}

	# Jugadores
	for team in ["home", "away"]:
		for s in range(FORM.size()):
			players.append(_make_player(team, s))

func _mat(c: Color) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = c
	if c.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _add_box(pos: Vector3, size: Vector3, c: Color) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var bm = BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = pos
	mi.material_override = _mat(c)
	add_child(mi)
	return mi

func _add_goal(z: float) -> void:
	var col = Color(0.95, 0.95, 0.95)
	var dir = signf(z)
	_add_box(Vector3(GOAL_HW, 1.2, z), Vector3(0.25, 2.4, 0.25), col)
	_add_box(Vector3(-GOAL_HW, 1.2, z), Vector3(0.25, 2.4, 0.25), col)
	_add_box(Vector3(0, 2.4, z), Vector3(GOAL_HW * 2, 0.25, 0.25), col)
	# red (una caja fina detras, semitransparente)
	_add_box(Vector3(0, 1.2, z + dir * 1.2), Vector3(GOAL_HW * 2, 2.4, 0.08), Color(1, 1, 1, 0.18))

func _make_player(team: String, slot: int) -> Dictionary:
	var node = MeshInstance3D.new()
	var cm = CapsuleMesh.new()
	cm.radius = PR
	cm.height = PH
	node.mesh = cm
	var is_gk = FORM[slot][0] == "GK"
	var col: Color = Color(0.15, 0.15, 0.15) if is_gk else (HOME_COL if team == "home" else AWAY_COL)
	node.material_override = _mat(col)
	add_child(node)
	# etiqueta con el dorsal encima
	var lab = Label3D.new()
	lab.text = str(NUM[slot])
	lab.font_size = 48
	lab.pixel_size = 0.012
	lab.position = Vector3(0, 1.7, 0)
	lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lab.modulate = Color(0, 0, 0) if (team == "home" and not is_gk) else Color(1, 1, 1)
	node.add_child(lab)
	var squad: Array = HOME_SQUAD if team == "home" else AWAY_SQUAD
	return {
		"node": node, "team": team, "role": FORM[slot][0], "slot": slot,
		"vel": Vector2.ZERO, "cooldown": 0.0, "user": false,
		"pname": squad[slot], "number": NUM[slot],
	}

# ============================================================
# Posiciones / helpers de campo
# ============================================================
func base_pos(team: String, slot: int) -> Vector2:
	var nx: float = FORM[slot][1]
	var nz: float = FORM[slot][2]
	var x = nx * (HALF_W - 3.0)
	var z: float
	if team == "home":
		z = -HALF_L + nz * HALF_L * 2.0
	else:
		z = HALF_L - nz * HALF_L * 2.0
	return Vector2(x, z)

func attack_z(team: String) -> float:
	return HALF_L if team == "home" else -HALF_L

func own_z(team: String) -> float:
	return -HALF_L if team == "home" else HALF_L

func p2(p: Dictionary) -> Vector2:
	return Vector2(p.node.position.x, p.node.position.z)

func set_xz(node: Node3D, v: Vector2, y: float) -> void:
	node.position = Vector3(v.x, y, v.y)

# ============================================================
# Preparacion del partido
# ============================================================
func _setup_match() -> void:
	home_score = 0
	away_score = 0
	clock = 0.0
	_reset_positions("home")

func _reset_positions(ko: String) -> void:
	kickoff_team = ko
	for p in players:
		var bp = base_pos(p.team, p.slot)
		set_xz(p.node, bp, 1.0)
		p.vel = Vector2.ZERO
		p.cooldown = 0.0
	set_xz(ball.node, Vector2.ZERO, BR)
	ball.vel = Vector2.ZERO
	ball.owner = -1
	ball.last = -1
	# el que saca
	for i in range(players.size()):
		if players[i].team == ko and players[i].role == "FW":
			set_xz(players[i].node, Vector2(-2, (2.0 if ko == "home" else -2.0)), 1.0)
			break
	state = "kickoff"
	state_t = 1.0
	poss = ko

# ============================================================
# Bucle principal
# ============================================================
func _physics_process(delta: float) -> void:
	_update_layout()
	if state == "end":
		_update_ui()
		return

	if state == "play":
		clock += delta
		if clock >= MATCH_REAL:
			state = "end"
			_update_ui()
			return
	elif state == "kickoff":
		state_t -= delta
		if state_t <= 0.0:
			state = "play"
	elif state == "goal":
		state_t -= delta
		if state_t <= 0.0:
			_reset_positions(kickoff_team)

	_pick_user()
	for p in players:
		if p.cooldown > 0.0:
			p.cooldown = max(0.0, p.cooldown - delta)

	# Movimiento del usuario
	var mv = _joy_vec()
	var has_input = mv.length() > 0.05
	if user_idx >= 0 and (state == "play" or state == "kickoff") and has_input:
		var up: Dictionary = players[user_idx]
		var spr = (1.35 if in_sprint else 1.0)
		up.vel = mv * SPEED * spr
		if abs(mv.y) > 0.01:
			pass
	_handle_user(delta)

	# IA
	for i in range(players.size()):
		if i == user_idx and has_input:
			continue
		if state == "play" or state == "kickoff" or state == "goal":
			_ai(i, delta)
	if state == "kickoff":
		for i in range(players.size()):
			if i != user_idx:
				players[i].vel *= 0.2

	# Integrar jugadores
	for p in players:
		var np = p2(p) + p.vel * delta
		np.x = clampf(np.x, -HALF_W - 1.0, HALF_W + 1.0)
		np.y = clampf(np.y, -HALF_L - 1.5, HALF_L + 1.5)
		set_xz(p.node, np, 1.0)
		p.vel = p.vel.lerp(Vector2.ZERO, clampf(delta * 8.0, 0, 1))
	_separate()
	_update_ball(delta)
	_update_camera(delta)
	_update_ui()

func _pick_user() -> void:
	if ball.owner >= 0 and players[ball.owner].team == "home":
		user_idx = ball.owner
	else:
		var best = -1
		var bd = 1e9
		var bp = Vector2(ball.node.position.x, ball.node.position.z)
		for i in range(players.size()):
			var p: Dictionary = players[i]
			if p.team != "home" or p.role == "GK":
				continue
			var d = p2(p).distance_to(bp)
			if d < bd:
				bd = d
				best = i
		user_idx = best
	for i in range(players.size()):
		players[i].user = (i == user_idx)

func _handle_user(delta: float) -> void:
	if user_idx < 0:
		return
	var up: Dictionary = players[user_idx]
	var has_ball = ball.owner == user_idx
	if has_ball:
		if in_shoot:
			shoot_hold = min(1.4, shoot_hold + delta * 1.6)
		elif shoot_hold > 0.0:
			var power = 18.0 + shoot_hold * 20.0
			var dir = _joy_vec()
			if dir.length() < 0.05:
				dir = Vector2(0, attack_z("home")) - p2(up)
			_shoot(user_idx, power, dir.normalized())
			shoot_hold = 0.0
		if pass_edge:
			var mate = _best_pass(user_idx)
			if mate >= 0:
				var d = p2(players[mate]) - p2(up)
				_shoot(user_idx, 16.0 + d.length() * 0.4, d.normalized())
	else:
		shoot_hold = 0.0
		if pass_edge:
			var bp = Vector2(ball.node.position.x, ball.node.position.z)
			up.vel += (bp - p2(up)).normalized() * SPEED * 1.4
	pass_edge = false

# ============================================================
# IA
# ============================================================
func _closest_to_ball(team: String, exclude: int) -> int:
	var best = -1
	var bd = 1e9
	var bp = Vector2(ball.node.position.x, ball.node.position.z)
	for i in range(players.size()):
		var p: Dictionary = players[i]
		if p.team != team or p.role == "GK" or i == exclude:
			continue
		var d = p2(p).distance_to(bp)
		if d < bd:
			bd = d
			best = i
	return best

func _nearest_opp(p: Dictionary) -> int:
	var best = -1
	var bd = 1e9
	for i in range(players.size()):
		var o: Dictionary = players[i]
		if o.team == p.team:
			continue
		var d = p2(o).distance_to(p2(p))
		if d < bd:
			bd = d
			best = i
	return best

func _best_pass(from_idx: int) -> int:
	var from: Dictionary = players[from_idx]
	var best = -1
	var bs = -1e9
	var az = attack_z(from.team)
	for i in range(players.size()):
		if i == from_idx:
			continue
		var m: Dictionary = players[i]
		if m.team != from.team or m.role == "GK":
			continue
		var d = p2(from).distance_to(p2(m))
		if d > 26.0:
			continue
		var adv = (m.node.position.z - from.node.position.z) * signf(az)
		var open = 1e9
		for j in range(players.size()):
			if players[j].team == from.team:
				continue
			open = min(open, p2(players[j]).distance_to(p2(m)))
		var sc = adv + open * 0.6 - d * 0.05
		if sc > bs:
			bs = sc
			best = i
	return best

func _move_toward(p: Dictionary, target: Vector2, mul: float) -> void:
	var d = target - p2(p)
	if d.length() < 0.15:
		return
	p.vel = d.normalized() * SPEED * mul

func _ai(idx: int, _delta: float) -> void:
	var p: Dictionary = players[idx]
	var has_ball = ball.owner == idx
	var az = attack_z(p.team)
	var oz = own_z(p.team)
	var dir = signf(az)  # +1 hacia porteria rival en Z
	var bp = Vector2(ball.node.position.x, ball.node.position.z)

	# Portero
	if p.role == "GK":
		var gx = clampf(bp.x, -GOAL_HW + 0.5, GOAL_HW - 0.5)
		var gz = oz - dir * 2.0
		var near = p2(p).distance_to(bp)
		if near < 8.0 and absf(bp.y - oz) < 11.0 and ball.owner < 0:
			_move_toward(p, bp, 1.1)
		else:
			_move_toward(p, Vector2(gx, gz), 0.8)
		if has_ball:
			var mate = _best_pass(idx)
			var tgt = (p2(players[mate]) if mate >= 0 else Vector2(0, az))
			_shoot(idx, 20.0, (tgt - p2(p)).normalized())
		return

	# Con balon
	if has_ball:
		var goal = Vector2(0, az)
		var dgoal = p2(p).distance_to(goal)
		var opp = _nearest_opp(p)
		var pd = (p2(players[opp]).distance_to(p2(p)) if opp >= 0 else 999.0)
		if dgoal < 16.0 and pd > 1.5:
			var aim = Vector2(randf_range(-GOAL_HW, GOAL_HW) * 0.6, az)
			_shoot(idx, 26.0, (aim - p2(p)).normalized())
			return
		var mate = _best_pass(idx)
		if mate >= 0:
			var adv = (players[mate].node.position.z - p.node.position.z) * dir > 1.5
			var want = (pd < 3.5 and randf() < 0.5) or (adv and randf() < 0.03)
			if want:
				var dd = p2(players[mate]) - p2(p)
				_shoot(idx, 16.0 + dd.length() * 0.4, dd.normalized())
				return
		var tx = p2(p).x * 0.4
		if opp >= 0 and pd < 4.5:
			var away = signf(p2(p).x - p2(players[opp]).x)
			tx = clampf(p2(p).x + (away if away != 0 else 1.0) * 4.0, -HALF_W, HALF_W)
		_move_toward(p, Vector2(tx, az), 1.0)
		return

	# Sin balon
	var we_have = ball.owner >= 0 and players[ball.owner].team == p.team
	var chaser = _closest_to_ball(p.team, -1)
	var second = _closest_to_ball(p.team, chaser)
	var bpos = base_pos(p.team, p.slot)

	if not we_have and idx == chaser:
		_move_toward(p, bp, 1.0)
		return
	if not we_have and idx == second:
		_move_toward(p, bp - Vector2(0, dir * 4.0), 0.9)
		return

	var nz: float = FORM[p.slot][2]
	if we_have:
		var fwd = 0.5 + nz * 1.7
		var tz = bpos.y + dir * (7.0 * fwd)
		var tx2 = bpos.x + (bp.x) * 0.2
		_move_toward(p, Vector2(clampf(tx2, -HALF_W, HALF_W), clampf(tz, -HALF_L, HALF_L)), 0.85)
	else:
		var tz2 = bpos.y - dir * 1.0
		var tx3 = bpos.x + bp.x * 0.22
		_move_toward(p, Vector2(clampf(tx3, -HALF_W, HALF_W), clampf(tz2, -HALF_L, HALF_L)), 0.8)

# ============================================================
# Balon
# ============================================================
func _shoot(idx: int, power: float, dir: Vector2) -> void:
	ball.owner = -1
	ball.last = idx
	players[idx].cooldown = 0.5
	ball.vel = dir.normalized() * power

func _try_capture() -> void:
	if ball.owner >= 0:
		return
	var bp = Vector2(ball.node.position.x, ball.node.position.z)
	var best = -1
	var bd = PR + BR + 0.5
	for i in range(players.size()):
		if players[i].cooldown > 0.0:
			continue
		var d = p2(players[i]).distance_to(bp)
		if d < bd:
			bd = d
			best = i
	if best >= 0:
		ball.owner = best
		ball.last = best
		poss = players[best].team

func _update_ball(delta: float) -> void:
	if ball.owner >= 0:
		var o: Dictionary = players[ball.owner]
		var d = o.vel
		if d.length() > 0.5:
			d = d.normalized()
		else:
			d = Vector2(0, signf(attack_z(o.team)))
		var lead = PR + BR + 0.2
		var target = p2(o) + d * lead
		var cur = Vector2(ball.node.position.x, ball.node.position.z)
		cur = cur.lerp(target, clampf(delta * 18.0, 0, 1))
		set_xz(ball.node, cur, BR)
		ball.vel = Vector2.ZERO
	else:
		var cur = Vector2(ball.node.position.x, ball.node.position.z)
		cur += ball.vel * delta
		ball.vel = ball.vel.lerp(Vector2.ZERO, clampf(delta * 0.9, 0, 1))
		if ball.vel.length() < 0.1:
			ball.vel = Vector2.ZERO
		set_xz(ball.node, cur, BR)
		_try_capture()
	# rodar visualmente
	ball.node.rotate_x(delta * 3.0)

	var b = Vector2(ball.node.position.x, ball.node.position.z)
	if absf(b.x) > HALF_W - BR:
		b.x = clampf(b.x, -HALF_W + BR, HALF_W - BR)
		ball.vel.x = -ball.vel.x * 0.5
		set_xz(ball.node, b, BR)
	if b.y > HALF_L - BR:
		if absf(b.x) < GOAL_HW and state == "play":
			_goal("home")
			return
		b.y = HALF_L - BR
		ball.vel.y = -ball.vel.y * 0.5
		set_xz(ball.node, b, BR)
	elif b.y < -HALF_L + BR:
		if absf(b.x) < GOAL_HW and state == "play":
			_goal("away")
			return
		b.y = -HALF_L + BR
		ball.vel.y = -ball.vel.y * 0.5
		set_xz(ball.node, b, BR)

func _separate() -> void:
	var mind = PR * 2.0
	for i in range(players.size()):
		for j in range(i + 1, players.size()):
			var a = p2(players[i])
			var b = p2(players[j])
			var diff = b - a
			var d = diff.length()
			if d > 0.001 and d < mind:
				var push = (mind - d) * 0.5
				var u = diff / d
				set_xz(players[i].node, a - u * push, 1.0)
				set_xz(players[j].node, b + u * push, 1.0)

func _goal(team: String) -> void:
	if team == "home":
		home_score += 1
	else:
		away_score += 1
	state = "goal"
	state_t = 2.0
	kickoff_team = "away" if team == "home" else "home"
	var scorer = ball.last
	var who = players[scorer].pname if scorer >= 0 else ""
	if team == "home":
		lbl_msg.text = "GOOOL!  " + who
	else:
		lbl_msg.text = "GOL RIVAL"

# ============================================================
# Camara
# ============================================================
func _update_camera(delta: float) -> void:
	var focus = Vector2(ball.node.position.x, ball.node.position.z)
	if user_idx >= 0:
		focus = focus.lerp(p2(players[user_idx]), 0.4)
	# el usuario (home) ataca +Z, camara detras en -Z
	var desired = Vector3(focus.x * 0.6, 15.0, focus.y - 20.0)
	cam.position = cam.position.lerp(desired, clampf(delta * 3.0, 0, 1))
	var look = Vector3(focus.x * 0.4, 0.0, focus.y + 6.0)
	cam.look_at(look, Vector3.UP)

# ============================================================
# UI
# ============================================================
func _build_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)

	joy_base = _circle_panel(Color(1, 1, 1, 0.10), 180)
	joy_base.visible = false
	ui.add_child(joy_base)
	joy_knob = _circle_panel(Color(1, 1, 1, 0.45), 90)
	joy_knob.visible = false
	ui.add_child(joy_knob)

	b_shoot = _button_panel("TIRO", Color(0.84, 0.15, 0.10))
	b_pass = _button_panel("PASE", Color(0.08, 0.40, 0.84))
	b_sprint = _button_panel("CORRER", Color(0.88, 0.63, 0.08))
	ui.add_child(b_shoot)
	ui.add_child(b_pass)
	ui.add_child(b_sprint)

	lbl_score = _label(40, Color.WHITE)
	lbl_time = _label(26, Color(0.9, 0.95, 0.9))
	lbl_name = _label(26, Color(1, 0.9, 0.5))
	lbl_msg = _label(60, Color.WHITE)
	lbl_msg.text = ""
	ui.add_child(lbl_score)
	ui.add_child(lbl_time)
	ui.add_child(lbl_name)
	ui.add_child(lbl_msg)

func _circle_panel(c: Color, d: float) -> Panel:
	var p = Panel.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = c
	sb.corner_radius_top_left = int(d)
	sb.corner_radius_top_right = int(d)
	sb.corner_radius_bottom_left = int(d)
	sb.corner_radius_bottom_right = int(d)
	p.add_theme_stylebox_override("panel", sb)
	p.size = Vector2(d, d)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p

func _button_panel(txt: String, c: Color) -> Panel:
	var p = _circle_panel(c, 100)
	var l = Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", 26)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	return p

func _label(sz: int, c: Color) -> Label:
	var l = Label.new()
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", c)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 6)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _update_layout() -> void:
	var vp = get_viewport().get_visible_rect().size
	var w = vp.x
	var h = vp.y
	var d_shoot = 150.0
	var d_pass = 120.0
	var d_sprint = 105.0
	var c_shoot = Vector2(w - 130, h - 200)
	var c_pass = Vector2(w - 300, h - 130)
	var c_sprint = Vector2(w - 110, h - 400)
	_place(b_shoot, c_shoot, d_shoot)
	_place(b_pass, c_pass, d_pass)
	_place(b_sprint, c_sprint, d_sprint)
	rect_shoot = Rect2(c_shoot - Vector2(d_shoot, d_shoot) * 0.5, Vector2(d_shoot, d_shoot))
	rect_pass = Rect2(c_pass - Vector2(d_pass, d_pass) * 0.5, Vector2(d_pass, d_pass))
	rect_sprint = Rect2(c_sprint - Vector2(d_sprint, d_sprint) * 0.5, Vector2(d_sprint, d_sprint))

	lbl_score.size = Vector2(w, 60)
	lbl_score.position = Vector2(0, 30)
	lbl_time.size = Vector2(w, 40)
	lbl_time.position = Vector2(0, 90)
	lbl_name.size = Vector2(w, 40)
	lbl_name.position = Vector2(0, h - 60)
	lbl_msg.size = Vector2(w, 80)
	lbl_msg.position = Vector2(0, h * 0.4)

func _place(p: Panel, center: Vector2, d: float) -> void:
	# ajustar tamano del boton al diametro deseado
	var sb = p.get_theme_stylebox("panel") as StyleBoxFlat
	sb.corner_radius_top_left = int(d)
	sb.corner_radius_top_right = int(d)
	sb.corner_radius_bottom_left = int(d)
	sb.corner_radius_bottom_right = int(d)
	p.size = Vector2(d, d)
	p.position = center - Vector2(d, d) * 0.5

func _update_ui() -> void:
	lbl_score.text = "%s  %d - %d  %s" % [HOME_NAME, home_score, away_score, AWAY_NAME]
	var mn = int(clock / MATCH_REAL * 90.0)
	lbl_time.text = "%02d min" % mn
	if ball.owner >= 0:
		lbl_name.text = players[ball.owner].pname
	else:
		lbl_name.text = ""
	if state == "goal":
		pass
	elif state == "end":
		var res = "VICTORIA" if home_score > away_score else ("DERROTA" if home_score < away_score else "EMPATE")
		lbl_msg.text = res + "  %d-%d\n(toca para revancha)" % [home_score, away_score]
	elif state == "kickoff":
		lbl_msg.text = ""
	elif lbl_msg.text != "" and state == "play":
		# limpiar mensaje de gol al reanudar
		lbl_msg.text = ""

# ============================================================
# Input tactil
# ============================================================
func _joy_vec() -> Vector2:
	if joy_id == -1:
		return Vector2.ZERO
	var d = joy_cur - joy_origin
	if d.length() > JOY_R:
		d = d.normalized() * JOY_R
	# Camara mira hacia +Z: en pantalla, derecha = -X mundo, arriba = +Z mundo
	return Vector2(-d.x / JOY_R, -d.y / JOY_R)

func _input(event: InputEvent) -> void:
	if state == "end":
		if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
			_setup_match()
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_down(event.index, event.position)
		else:
			_touch_up(event.index)
	elif event is InputEventScreenDrag:
		if event.index == joy_id:
			joy_cur = event.position

func _touch_down(index: int, pos: Vector2) -> void:
	if rect_shoot.has_point(pos):
		btn_touch[index] = "shoot"
		in_shoot = true
		return
	if rect_sprint.has_point(pos):
		btn_touch[index] = "sprint"
		in_sprint = true
		return
	if rect_pass.has_point(pos):
		btn_touch[index] = "pass"
		pass_edge = true
		return
	var vp = get_viewport().get_visible_rect().size
	if joy_id == -1 and pos.x < vp.x * 0.55:
		joy_id = index
		joy_origin = pos
		joy_cur = pos
		joy_base.visible = true
		joy_knob.visible = true

func _touch_up(index: int) -> void:
	if index == joy_id:
		joy_id = -1
		joy_base.visible = false
		joy_knob.visible = false
	if btn_touch.has(index):
		var b: String = btn_touch[index]
		if b == "shoot":
			in_shoot = false
		elif b == "sprint":
			in_sprint = false
		btn_touch.erase(index)

func _process(_delta: float) -> void:
	# posicion visual del joystick
	if joy_id != -1:
		joy_base.position = joy_origin - joy_base.size * 0.5
		var d = joy_cur - joy_origin
		if d.length() > JOY_R:
			d = d.normalized() * JOY_R
		joy_knob.position = joy_origin + d - joy_knob.size * 0.5
