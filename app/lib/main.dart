import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MoinSoccerApp());
}

class MoinSoccerApp extends StatelessWidget {
  const MoinSoccerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moin Soccer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0b8a3c), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF05241a),
      ),
      home: const MenuScreen(),
    );
  }
}

/* ============================================================
   Equipos y configuracion
   ============================================================ */
class TeamColor {
  final String name;
  final Color color;
  final Color dark;
  const TeamColor(this.name, this.color, this.dark);
}

const List<TeamColor> kColors = [
  TeamColor('VERDES', Color(0xFF19c463), Color(0xFF0c7d3d)),
  TeamColor('ROJOS', Color(0xFFe23b3b), Color(0xFF9c1f1f)),
  TeamColor('AZULES', Color(0xFF2f7bff), Color(0xFF143f9c)),
  TeamColor('NEGROS', Color(0xFF2b2b34), Color(0xFF000000)),
  TeamColor('AMARILLOS', Color(0xFFffcf33), Color(0xFFc79600)),
  TeamColor('BLANCOS', Color(0xFFf1f1f1), Color(0xFF9aa0a6)),
];

class MatchConfig {
  int homeIdx;
  int awayIdx;
  int diff; // 0 facil, 1 normal, 2 dificil
  int matchLen; // minutos por mitad
  MatchConfig(
      {this.homeIdx = 0, this.awayIdx = 1, this.diff = 1, this.matchLen = 3});
}

/* ============================================================
   Pantalla de menu
   ============================================================ */
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final cfg = MatchConfig();

  @override
  Widget build(BuildContext context) {
    if (cfg.awayIdx == cfg.homeIdx) {
      cfg.awayIdx = (cfg.homeIdx + 1) % kColors.length;
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                          colors: [Color(0xFF7CFC8A), Color(0xFF21d4fd)])
                      .createShader(r),
                  child: const Text('MOIN SOCCER',
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1)),
                ),
                const SizedBox(height: 4),
                const Text('⚽ FÚTBOL MÓVIL',
                    style: TextStyle(
                        color: Color(0xFF9fe8c0),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4)),
                const SizedBox(height: 20),
                _card(
                  child: Column(
                    children: [
                      _label('Tu equipo'),
                      _swatches(cfg.homeIdx, (i) {
                        setState(() {
                          cfg.homeIdx = i;
                          if (cfg.awayIdx == i) {
                            cfg.awayIdx = (i + 1) % kColors.length;
                          }
                        });
                      }),
                      const SizedBox(height: 10),
                      _label('Rival'),
                      _swatches(cfg.awayIdx, (i) {
                        setState(() {
                          if (i != cfg.homeIdx) cfg.awayIdx = i;
                        });
                      }),
                      const SizedBox(height: 14),
                      _label('Dificultad'),
                      _opts(['Fácil', 'Normal', 'Difícil'], cfg.diff,
                          (i) => setState(() => cfg.diff = i)),
                      const SizedBox(height: 14),
                      _label('Duración'),
                      _opts(['Corto', 'Medio', 'Largo'],
                          {3: 0, 5: 1, 8: 2}[cfg.matchLen] ?? 0, (i) {
                        setState(() => cfg.matchLen = [3, 5, 8][i]);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF16c172),
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => GameScreen(
                              cfg: MatchConfig(
                                  homeIdx: cfg.homeIdx,
                                  awayIdx: cfg.awayIdx,
                                  diff: cfg.diff,
                                  matchLen: cfg.matchLen))));
                    },
                    child: const Text('JUGAR ▶',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Joystick (izq) para moverte · TIRO dispara (mantén para potencia) · PASE pasa / roba · CORRER esprinta',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9fbdb0), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
        child: child,
      );

  Widget _label(String t) => Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                color: Color(0xFFcfeede), fontWeight: FontWeight.w600)),
      ));

  Widget _swatches(int sel, ValueChanged<int> onTap) => Wrap(
        spacing: 8,
        children: List.generate(kColors.length, (i) {
          final c = kColors[i];
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: c.color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: i == sel ? Colors.white : Colors.transparent,
                    width: 3),
              ),
            ),
          );
        }),
      );

  Widget _opts(List<String> labels, int sel, ValueChanged<int> onTap) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(labels.length, (i) {
          final s = i == sel;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: s
                      ? const Color(0x3021d4fd)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: s ? const Color(0xFF21d4fd) : Colors.transparent,
                      width: 2),
                ),
                child: Text(labels[i],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          );
        }),
      );
}

/* ============================================================
   Modelo del partido
   ============================================================ */
const double kW = 680, kH = 1180, kMargin = 60;
const double kGoalW = 200, kPlayerR = 15, kBallR = 9;
const double kSpeed = 2.5;
const double kSecondsPerHalf = 75; // segundos reales por mitad

class Slot {
  final String role;
  final double x, y;
  const Slot(this.role, this.x, this.y);
}

const List<Slot> kFormation = [
  Slot('GK', 0.50, 0.04),
  Slot('DF', 0.27, 0.22),
  Slot('DF', 0.73, 0.22),
  Slot('MF', 0.40, 0.40),
  Slot('MF', 0.60, 0.40),
];

class Player {
  final String team; // home / away
  final String role;
  final int slot;
  double x, y, vx = 0, vy = 0;
  double facing;
  double cooldown = 0;
  bool user = false;
  Player(this.team, this.role, this.slot, this.x, this.y, this.facing);
}

class Ball {
  double x, y, vx = 0, vy = 0;
  Player? owner;
  Player? lastTouch;
  Ball(this.x, this.y);
}

class GameInput {
  double moveX = 0, moveY = 0;
  bool shootDown = false;
  bool passEdge = false;
  bool sprint = false;
}

double _dist(double ax, double ay, double bx, double by) {
  final dx = ax - bx, dy = ay - by;
  return math.sqrt(dx * dx + dy * dy);
}

double _clamp(double v, double a, double b) => v < a ? a : (v > b ? b : v);

class World {
  final MatchConfig cfg;
  List<Player> players = [];
  late Ball ball;
  int homeScore = 0, awayScore = 0;
  double matchClock = 0; // segundos de partido
  int half = 1;
  String state = 'kickoff'; // kickoff | play | goal | end
  double kickoffTimer = 0;
  String kickoffTeam = 'home';
  String possessionTeam = 'home';
  double camY = kH / 2;
  double shootHold = 0;
  String goalText = '';
  final rnd = math.Random();

  World(this.cfg) {
    _setup();
  }

  double _teamHomeY(String team, Slot f) {
    final y =
        team == 'home' ? kH + kMargin - f.y * kH : kMargin + f.y * kH;
    return _clamp(y, kMargin, kH + kMargin);
  }

  double _teamHomeX(Slot f) => kMargin + f.x * kW;
  double _ownGoalY(String team) => team == 'home' ? kH + kMargin : kMargin;
  double _targetGoalY(String team) => team == 'home' ? kMargin : kH + kMargin;
  double get _goalX => kMargin + kW / 2;

  void _setup() {
    players = [];
    for (final team in ['home', 'away']) {
      for (int s = 0; s < kFormation.length; s++) {
        final f = kFormation[s];
        players.add(Player(team, f.role, s, _teamHomeX(f),
            _teamHomeY(team, f), team == 'home' ? -1 : 1));
      }
    }
    ball = Ball(kMargin + kW / 2, kMargin + kH / 2);
    homeScore = 0;
    awayScore = 0;
    matchClock = 0;
    half = 1;
    _resetPositions('home');
  }

  void _resetPositions(String koTeam) {
    kickoffTeam = koTeam;
    for (final p in players) {
      final f = kFormation[p.slot];
      p.x = _teamHomeX(f);
      p.y = _teamHomeY(p.team, f);
      p.vx = 0;
      p.vy = 0;
      p.cooldown = 0;
    }
    ball
      ..x = kMargin + kW / 2
      ..y = kMargin + kH / 2
      ..vx = 0
      ..vy = 0
      ..owner = null
      ..lastTouch = null;
    final taker = players
        .firstWhere((p) => p.team == koTeam && p.role == 'MF', orElse: () => players.first);
    taker.x = kMargin + kW / 2 - 16;
    taker.y = kMargin + kH / 2 + (koTeam == 'home' ? 22 : -22);
    state = 'kickoff';
    kickoffTimer = 1.0;
    possessionTeam = koTeam;
  }

  Player? get userPlayer {
    if (ball.owner != null && ball.owner!.team == 'home') return ball.owner;
    Player? best;
    double bd = 1e9;
    for (final p in players) {
      if (p.team != 'home' || p.role == 'GK') continue;
      final d = _dist(p.x, p.y, ball.x, ball.y);
      if (d < bd) {
        bd = d;
        best = p;
      }
    }
    return best;
  }

  void _shoot(Player p, double power, double dx, double dy) {
    ball.owner = null;
    ball.lastTouch = p;
    p.cooldown = 0.5;
    ball.vx = dx * power;
    ball.vy = dy * power;
  }

  void _tryCapture() {
    if (ball.owner != null) return;
    Player? best;
    double bd = kPlayerR + kBallR + 6;
    for (final p in players) {
      if (p.cooldown > 0) continue;
      final d = _dist(p.x, p.y, ball.x, ball.y);
      if (d < bd) {
        bd = d;
        best = p;
      }
    }
    if (best != null) {
      ball.owner = best;
      ball.lastTouch = best;
      possessionTeam = best.team;
    }
  }

  Player? _closestToBall(String team) {
    Player? best;
    double bd = 1e9;
    for (final p in players) {
      if (p.team != team || p.role == 'GK') continue;
      final d = _dist(p.x, p.y, ball.x, ball.y);
      if (d < bd) {
        bd = d;
        best = p;
      }
    }
    return best;
  }

  Player? _bestPassTarget(Player from) {
    Player? best;
    double bs = -1e9;
    for (final m in players) {
      if (m.team != from.team || m == from || m.role == 'GK') continue;
      final adv = from.team == 'home' ? (from.y - m.y) : (m.y - from.y);
      double open = 999;
      for (final o in players) {
        if (o.team == from.team) continue;
        open = math.min(open, _dist(o.x, o.y, m.x, m.y));
      }
      final sc = adv + open * 0.6 - _dist(from.x, from.y, m.x, m.y) * 0.05;
      if (sc > bs) {
        bs = sc;
        best = m;
      }
    }
    return best;
  }

  void _moveToward(Player p, double tx, double ty, double mul) {
    final dx = tx - p.x, dy = ty - p.y;
    final d = math.sqrt(dx * dx + dy * dy);
    if (d < 2) return;
    final base = kSpeed * mul;
    p.vx = dx / d * base;
    p.vy = dy / d * base;
    if (p.vy.abs() > 0.1) p.facing = p.vy.sign;
  }

  void _ai(Player p) {
    final hasBall = ball.owner == p;
    final myTeam = p.team;
    final atkY = _targetGoalY(myTeam);
    final ownY = _ownGoalY(myTeam);
    final gAttX = _goalX;

    if (p.role == 'GK') {
      final gy = ownY + (myTeam == 'home' ? -50 : 50);
      double tx = _clamp(ball.x, gAttX - kGoalW / 2 + 10, gAttX + kGoalW / 2 - 10);
      final near = _dist(p.x, p.y, ball.x, ball.y);
      if (near < 150 && (ball.y - ownY).abs() < 220 && ball.owner == null) {
        tx = ball.x;
        _moveToward(p, ball.x, ball.y, 1.0);
      } else {
        _moveToward(p, tx, gy, 0.7);
      }
      if (hasBall) {
        final mate = _bestPassTarget(p);
        final tgtX = mate?.x ?? gAttX;
        final tgtY = mate?.y ?? atkY;
        final a = math.atan2(tgtY - p.y, tgtX - p.x);
        _shoot(p, 7.5, math.cos(a), math.sin(a));
      }
      return;
    }

    if (hasBall) {
      final dGoal = _dist(p.x, p.y, gAttX, atkY);
      final pressed =
          players.any((o) => o.team != myTeam && _dist(o.x, o.y, p.x, p.y) < 70);
      if (dGoal < 300) {
        final a = math.atan2(
            atkY - p.y, (gAttX + (rnd.nextDouble() - 0.5) * kGoalW * 0.6) - p.x);
        _shoot(p, 9.5, math.cos(a), math.sin(a));
        return;
      }
      if (pressed && rnd.nextDouble() < 0.04) {
        final mate = _bestPassTarget(p);
        if (mate != null) {
          final a = math.atan2(mate.y - p.y, mate.x - p.x);
          _shoot(p, 6.5 + _dist(p.x, p.y, mate.x, mate.y) * 0.012, math.cos(a),
              math.sin(a));
          return;
        }
      }
      final tx = gAttX + (p.x - gAttX) * 0.4;
      _moveToward(p, tx, atkY, 0.95 + cfg.diff * 0.06);
      return;
    }

    final chaser = _closestToBall(myTeam);
    final weAttack = possessionTeam == myTeam;
    if (chaser == p && !(ball.owner != null && ball.owner!.team == myTeam)) {
      _moveToward(p, ball.x, ball.y, 0.85 + cfg.diff * 0.08);
    } else {
      final f = kFormation[p.slot];
      final baseX = _teamHomeX(f);
      final baseY = _teamHomeY(myTeam, f);
      final ty = baseY +
          (myTeam == 'home' ? -1 : 1) * (weAttack ? 160 : -40);
      final tx = baseX + (ball.x - gAttX) * 0.18;
      _moveToward(p, _clamp(tx, kMargin, kMargin + kW),
          _clamp(ty, kMargin, kMargin + kH), 0.7);
    }
  }

  void _handleUser(GameInput inp, Player? up) {
    if (up == null) return;
    final hasBall = ball.owner == up;
    if (hasBall) {
      if (inp.shootDown) {
        shootHold = math.min(1.4, shootHold + 0.024);
      } else if (shootHold > 0) {
        final power = 7 + shootHold * 7;
        double dx, dy;
        if (inp.moveX != 0 || inp.moveY != 0) {
          final d = math.sqrt(inp.moveX * inp.moveX + inp.moveY * inp.moveY);
          dx = inp.moveX / d;
          dy = inp.moveY / d;
        } else {
          final a = math.atan2(_targetGoalY('home') - up.y, _goalX - up.x);
          dx = math.cos(a);
          dy = math.sin(a);
        }
        _shoot(up, power, dx, dy);
        shootHold = 0;
      }
      if (inp.passEdge) {
        final mate = _bestPassTarget(up);
        if (mate != null) {
          final a = math.atan2(mate.y - up.y, mate.x - up.x);
          final pw = 6 + _dist(up.x, up.y, mate.x, mate.y) * 0.014;
          _shoot(up, pw, math.cos(a), math.sin(a));
        }
      }
    } else {
      shootHold = 0;
      if (inp.passEdge) {
        final a = math.atan2(ball.y - up.y, ball.x - up.x);
        up.vx += math.cos(a) * kSpeed * 1.6;
        up.vy += math.sin(a) * kSpeed * 1.6;
      }
    }
  }

  void update(double dt, GameInput inp) {
    if (state == 'end') return;

    if (state == 'play') {
      matchClock += dt * (cfg.matchLen * 2 * 60) / (kSecondsPerHalf * 2);
      final total = cfg.matchLen * 2 * 60;
      if (matchClock >= cfg.matchLen * 60 && half == 1) {
        half = 2;
        _resetPositions('away');
      } else if (matchClock >= total) {
        state = 'end';
        return;
      }
    }
    if (state == 'kickoff') {
      kickoffTimer -= dt;
      if (kickoffTimer <= 0) state = 'play';
    }
    if (state == 'goal') {
      kickoffTimer -= dt;
      if (kickoffTimer <= 0) _resetPositions(kickoffTeam);
    }

    final up = userPlayer;
    for (final p in players) {
      p.user = false;
    }
    if (up != null) up.user = true;
    for (final p in players) {
      if (p.cooldown > 0) p.cooldown = math.max(0, p.cooldown - dt);
    }

    // Movimiento del usuario
    final hasInput = inp.moveX != 0 || inp.moveY != 0;
    if (up != null && (state == 'play' || state == 'kickoff') && hasInput) {
      final mag = math.min(
          1.0, math.sqrt(inp.moveX * inp.moveX + inp.moveY * inp.moveY));
      final spr = (inp.sprint ? 1.35 : 1.0) * (mag < 1 ? mag : 1.0);
      up.vx = inp.moveX * kSpeed * spr;
      up.vy = inp.moveY * kSpeed * spr;
      if (inp.moveY != 0) up.facing = inp.moveY.sign;
    }

    _handleUser(inp, up);

    // IA para el resto (y para el usuario si no da input)
    for (final p in players) {
      if (p == up && hasInput) continue;
      if (state == 'play' || state == 'kickoff' || state == 'goal') {
        _ai(p);
      }
    }
    if (state == 'kickoff') {
      for (final p in players) {
        if (p != up) {
          p.vx *= 0.2;
          p.vy *= 0.2;
        }
      }
    }

    // Integracion
    for (final p in players) {
      p.x += p.vx;
      p.y += p.vy;
      p.x = _clamp(p.x, kMargin - 10, kMargin + kW + 10);
      p.y = _clamp(p.y, kMargin - 10, kMargin + kH + 10);
      p.vx *= 0.6;
      p.vy *= 0.6;
    }
    _separate();
    _updateBall();

    final target = _clamp(ball.y, 0, kH + 2 * kMargin);
    camY += (target - camY) * math.min(1.0, dt * 6);
  }

  void _separate() {
    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        final a = players[i], b = players[j];
        final dx = b.x - a.x, dy = b.y - a.y;
        final d = math.sqrt(dx * dx + dy * dy);
        const minD = kPlayerR * 2 - 4;
        if (d > 0 && d < minD) {
          final push = (minD - d) / 2;
          final ux = dx / d, uy = dy / d;
          a.x -= ux * push;
          a.y -= uy * push;
          b.x += ux * push;
          b.y += uy * push;
        }
      }
    }
  }

  void _updateBall() {
    final o = ball.owner;
    if (o != null) {
      double dx = o.vx, dy = o.vy;
      final sp = math.sqrt(dx * dx + dy * dy);
      if (sp > 0.2) {
        dx /= sp;
        dy /= sp;
      } else {
        dx = 0;
        dy = o.facing;
      }
      const lead = kPlayerR + kBallR + 2;
      ball.x += ((o.x + dx * lead) - ball.x) * 0.5;
      ball.y += ((o.y + dy * lead) - ball.y) * 0.5;
      ball.vx = 0;
      ball.vy = 0;
    } else {
      ball.x += ball.vx;
      ball.y += ball.vy;
      ball.vx *= 0.985;
      ball.vy *= 0.985;
      if (math.sqrt(ball.vx * ball.vx + ball.vy * ball.vy) < 0.05) {
        ball.vx = 0;
        ball.vy = 0;
      }
      _tryCapture();
    }

    const left = kMargin, right = kMargin + kW, top = kMargin, bot = kMargin + kH;
    final gxL = _goalX - kGoalW / 2, gxR = _goalX + kGoalW / 2;

    if (ball.x < left + kBallR) {
      ball.x = left + kBallR;
      ball.vx = ball.vx.abs() * 0.6;
    }
    if (ball.x > right - kBallR) {
      ball.x = right - kBallR;
      ball.vx = -ball.vx.abs() * 0.6;
    }
    if (ball.y < top + kBallR) {
      if (ball.x > gxL && ball.x < gxR && state == 'play') {
        _goal('home');
        return;
      } else {
        ball.y = top + kBallR;
        ball.vy = ball.vy.abs() * 0.6;
      }
    }
    if (ball.y > bot - kBallR) {
      if (ball.x > gxL && ball.x < gxR && state == 'play') {
        _goal('away');
        return;
      } else {
        ball.y = bot - kBallR;
        ball.vy = -ball.vy.abs() * 0.6;
      }
    }
  }

  void _goal(String team) {
    if (team == 'home') {
      homeScore++;
    } else {
      awayScore++;
    }
    state = 'goal';
    kickoffTimer = 1.8;
    kickoffTeam = team == 'home' ? 'away' : 'home';
    goalText = team == 'home' ? '¡GOOOL!' : '¡GOL RIVAL!';
  }

  void restart() => _setup();
}

/* ============================================================
   Pantalla de juego
   ============================================================ */
class GameScreen extends StatefulWidget {
  final MatchConfig cfg;
  const GameScreen({super.key, required this.cfg});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late World world;
  late Ticker _ticker;
  Duration _last = Duration.zero;

  // Input
  int? _joyId;
  Offset _joyOrigin = Offset.zero;
  Offset _joyCurrent = Offset.zero;
  final Map<int, String> _btnPointers = {}; // pointerId -> button
  bool _shootDown = false, _sprintDown = false, _passQueued = false;
  Size _screen = const Size(360, 720);

  @override
  void initState() {
    super.initState();
    world = World(widget.cfg);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    double dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0) dt = 0.016;
    if (dt > 0.05) dt = 0.05;

    final inp = GameInput();
    if (_joyId != null) {
      final maxR = _joyRadius;
      var d = _joyCurrent - _joyOrigin;
      final len = d.distance;
      if (len > maxR) d = d * (maxR / len);
      inp.moveX = d.dx / maxR;
      inp.moveY = d.dy / maxR;
    }
    inp.shootDown = _shootDown;
    inp.sprint = _sprintDown;
    inp.passEdge = _passQueued;
    _passQueued = false;

    world.update(dt, inp);
    if (mounted) setState(() {});
  }

  // Geometria de controles
  double get _joyRadius => 52;
  Rect _shootRect() => Rect.fromCircle(
      center: Offset(_screen.width - 60, _screen.height - 90), radius: 46);
  Rect _passRect() => Rect.fromCircle(
      center: Offset(_screen.width - 150, _screen.height - 60), radius: 38);
  Rect _sprintRect() => Rect.fromCircle(
      center: Offset(_screen.width - 46, _screen.height - 200), radius: 34);

  String? _hitButton(Offset p) {
    if (_shootRect().contains(p)) return 'shoot';
    if (_passRect().contains(p)) return 'pass';
    if (_sprintRect().contains(p)) return 'sprint';
    return null;
  }

  void _onDown(PointerDownEvent e) {
    final p = e.localPosition;
    final btn = _hitButton(p);
    if (btn != null) {
      _btnPointers[e.pointer] = btn;
      if (btn == 'shoot') _shootDown = true;
      if (btn == 'sprint') _sprintDown = true;
      if (btn == 'pass') _passQueued = true;
      return;
    }
    if (_joyId == null && p.dx < _screen.width * 0.55) {
      _joyId = e.pointer;
      _joyOrigin = p;
      _joyCurrent = p;
    }
  }

  void _onMove(PointerMoveEvent e) {
    if (e.pointer == _joyId) _joyCurrent = e.localPosition;
  }

  void _onUp(int pointer) {
    if (pointer == _joyId) {
      _joyId = null;
      _joyOrigin = Offset.zero;
      _joyCurrent = Offset.zero;
    }
    final btn = _btnPointers.remove(pointer);
    if (btn == 'shoot') _shootDown = false;
    if (btn == 'sprint') _sprintDown = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, c) {
        _screen = Size(c.maxWidth, c.maxHeight);
        return Listener(
          onPointerDown: _onDown,
          onPointerMove: _onMove,
          onPointerUp: (e) => _onUp(e.pointer),
          onPointerCancel: (e) => _onUp(e.pointer),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: FieldPainter(
                    world: world,
                    joyId: _joyId,
                    joyOrigin: _joyOrigin,
                    joyCurrent: _joyCurrent,
                    joyRadius: _joyRadius,
                    shootRect: _shootRect(),
                    passRect: _passRect(),
                    sprintRect: _sprintRect(),
                  ),
                ),
              ),
              // HUD marcador
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(child: _scoreboard()),
              ),
              if (world.state == 'goal') Positioned.fill(child: _goalOverlay()),
              if (world.state == 'end') Positioned.fill(child: _endOverlay()),
            ],
          ),
        );
      }),
    );
  }

  Widget _scoreboard() {
    final h = kColors[widget.cfg.homeIdx];
    final a = kColors[widget.cfg.awayIdx];
    final mins = (world.matchClock ~/ 60).toString().padLeft(2, '0');
    final secs = (world.matchClock % 60).floor().toString().padLeft(2, '0');
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(h.color),
            const SizedBox(width: 6),
            Text(h.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(width: 10),
            Text('${world.homeScore} - ${world.awayScore}',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 22)),
            const SizedBox(width: 10),
            Text(a.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(width: 6),
            _dot(a.color),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('$mins:$secs',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c) => Container(
      width: 13,
      height: 13,
      decoration:
          BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)));

  Widget _goalOverlay() => IgnorePointer(
        child: Center(
          child: Text(
            world.goalText,
            style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(color: Color(0xFF21d4fd), blurRadius: 22),
                ]),
          ),
        ),
      );

  Widget _endOverlay() {
    final hs = world.homeScore, as = world.awayScore;
    String title, msg;
    if (hs > as) {
      title = '🏆 ¡VICTORIA!';
      msg = '¡${kColors[widget.cfg.homeIdx].name} ganan el partido!';
    } else if (hs < as) {
      title = '😞 DERROTA';
      msg = '${kColors[widget.cfg.awayIdx].name} se llevan la victoria.';
    } else {
      title = '🤝 EMPATE';
      msg = 'Repartieron los puntos.';
    }
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text('$hs - $as',
                style: const TextStyle(
                    fontSize: 52, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(msg,
                style: const TextStyle(color: Color(0xFF9fbdb0))),
            const SizedBox(height: 22),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16c172),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
              onPressed: () {
                setState(() {
                  world.restart();
                  _last = Duration.zero;
                });
              },
              child: const Text('REVANCHA 🔁',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('MENÚ',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   Render del campo
   ============================================================ */
class FieldPainter extends CustomPainter {
  final World world;
  final int? joyId;
  final Offset joyOrigin, joyCurrent;
  final double joyRadius;
  final Rect shootRect, passRect, sprintRect;

  FieldPainter({
    required this.world,
    required this.joyId,
    required this.joyOrigin,
    required this.joyCurrent,
    required this.joyRadius,
    required this.shootRect,
    required this.passRect,
    required this.sprintRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / (kW + 2 * kMargin)).clamp(0.1, 1.4).toDouble();
    canvas.drawColor(const Color(0xFF0a3d22), BlendMode.src);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(-(kMargin + kW / 2), -world.camY);

    _pitch(canvas);
    _nets(canvas);

    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.25);
    for (final p in world.players) {
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(p.x, p.y + kPlayerR * 0.7),
              width: kPlayerR * 1.8,
              height: kPlayerR * 0.9),
          shadow);
    }
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(world.ball.x, world.ball.y + kBallR * 0.6),
            width: kBallR * 2,
            height: kBallR),
        shadow);

    for (final p in world.players) {
      _drawPlayer(canvas, p);
    }
    _drawBall(canvas);
    canvas.restore();

    // flecha del jugador del usuario
    final up = world.userPlayer;
    if (up != null) {
      final sx = (up.x - (kMargin + kW / 2)) * scale + size.width / 2;
      final sy = (up.y - world.camY) * scale + size.height / 2 -
          (kPlayerR + 14) * scale;
      final tri = Path()
        ..moveTo(sx, sy + 10)
        ..lineTo(sx - 8, sy - 2)
        ..lineTo(sx + 8, sy - 2)
        ..close();
      canvas.drawPath(tri, Paint()..color = Colors.white);
    }

    _controls(canvas);
  }

  void _pitch(Canvas canvas) {
    const left = kMargin, top = kMargin;
    const stripe = 70.0;
    for (double y = top - kMargin; y < kH + 2 * kMargin; y += stripe) {
      final even = ((y / stripe).floor() % 2) == 0;
      canvas.drawRect(
          Rect.fromLTWH(left - kMargin, y, kW + 2 * kMargin, stripe),
          Paint()
            ..color = even ? const Color(0xFF15a04a) : const Color(0xFF129143));
    }
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final fill = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawRect(const Rect.fromLTWH(left, top, kW, kH), line);
    canvas.drawLine(const Offset(left, top + kH / 2),
        const Offset(left + kW, top + kH / 2), line);
    canvas.drawCircle(const Offset(left + kW / 2, top + kH / 2), 80, line);
    canvas.drawCircle(const Offset(left + kW / 2, top + kH / 2), 5, fill);
    const aw = 320.0, ah = 150.0, sw = 140.0, sh = 64.0;
    canvas.drawRect(Rect.fromLTWH(left + kW / 2 - aw / 2, top, aw, ah), line);
    canvas.drawRect(Rect.fromLTWH(left + kW / 2 - sw / 2, top, sw, sh), line);
    canvas.drawRect(
        Rect.fromLTWH(left + kW / 2 - aw / 2, top + kH - ah, aw, ah), line);
    canvas.drawRect(
        Rect.fromLTWH(left + kW / 2 - sw / 2, top + kH - sh, sw, sh), line);
  }

  void _nets(Canvas canvas) {
    final gxL = kMargin + kW / 2 - kGoalW / 2;
    const depth = 34.0;
    final frame = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(
        Rect.fromLTWH(gxL, kMargin - depth, kGoalW, depth), frame);
    canvas.drawRect(
        Rect.fromLTWH(gxL, kMargin + kH, kGoalW, depth), frame);
    final net = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double i = 0; i <= kGoalW; i += 14) {
      canvas.drawLine(Offset(gxL + i, kMargin - depth),
          Offset(gxL + i, kMargin), net);
      canvas.drawLine(Offset(gxL + i, kMargin + kH),
          Offset(gxL + i, kMargin + kH + depth), net);
    }
  }

  void _drawPlayer(Canvas canvas, Player p) {
    final isGK = p.role == 'GK';
    final tc = p.team == 'home'
        ? kColors[world.cfg.homeIdx]
        : kColors[world.cfg.awayIdx];
    final body = Paint()..color = isGK ? const Color(0xFF222222) : tc.color;
    final edge = Paint()
      ..color = isGK ? const Color(0xFF111111) : tc.dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(p.x, p.y), kPlayerR, body);
    canvas.drawCircle(Offset(p.x, p.y), kPlayerR, edge);
    if (p.user) {
      canvas.drawCircle(
          Offset(p.x, p.y),
          kPlayerR + 5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);
    }
    final light = tc.color.computeLuminance() > 0.6 && !isGK;
    _text(canvas, isGK ? 'P' : '${p.slot}', Offset(p.x, p.y), 13,
        light ? const Color(0xFF222222) : Colors.white);
  }

  void _drawBall(Canvas canvas) {
    canvas.drawCircle(Offset(world.ball.x, world.ball.y), kBallR,
        Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(world.ball.x, world.ball.y),
        kBallR,
        Paint()
          ..color = const Color(0xFF333333)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    canvas.drawCircle(Offset(world.ball.x, world.ball.y), kBallR * 0.4,
        Paint()..color = const Color(0xFF222222));
  }

  void _controls(Canvas canvas) {
    // Joystick
    final base = joyId != null ? joyOrigin : null;
    if (base != null) {
      canvas.drawCircle(
          base,
          60,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.08));
      canvas.drawCircle(
          base,
          60,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
      var d = joyCurrent - joyOrigin;
      if (d.distance > joyRadius) d = d * (joyRadius / d.distance);
      canvas.drawCircle(base + d, 28,
          Paint()..color = Colors.white.withValues(alpha: 0.55));
    }
    // Botones
    _button(canvas, sprintRect, const Color(0xFFe0a013), 'CORRER',
        const Color(0xFF3a2a00));
    _button(canvas, passRect, const Color(0xFF1466d6), 'PASE', Colors.white);
    _button(canvas, shootRect, const Color(0xFFd6261a), 'TIRO', Colors.white);
  }

  void _button(Canvas canvas, Rect r, Color color, String label, Color tcol) {
    canvas.drawCircle(r.center, r.width / 2, Paint()..color = color);
    canvas.drawCircle(
        r.center,
        r.width / 2,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    _text(canvas, label, r.center, r.width > 80 ? 13 : 11, tcol);
  }

  void _text(Canvas canvas, String s, Offset c, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              color: color, fontSize: size, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant FieldPainter oldDelegate) => true;
}
