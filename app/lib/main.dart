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
   Datos de equipos y jugadores (nombres PARODIADOS, sin licencia)
   ============================================================ */
class Pl {
  final String n; // nombre
  final int r; // valoracion
  const Pl(this.n, this.r);
}

class Team {
  final String name;
  final Color color;
  final Color dark;
  final Color text;
  final List<Pl> squad; // 11, en orden de formacion
  const Team(this.name, this.color, this.dark, this.text, this.squad);
  int get rating {
    var s = 0;
    for (final p in squad) {
      s += p.r;
    }
    return (s / squad.length).round();
  }
}

// Orden de formacion (4-4-2): GK, RB, RCB, LCB, LB, RM, RCM, LCM, LM, RF, LF
const List<int> kNum = [1, 2, 5, 4, 3, 7, 6, 8, 11, 9, 10];

const List<Team> kTeams = [
  Team('MADRID BLANCOS', Color(0xFFf5f5f5), Color(0xFFb4b4b4), Color(0xFF1a1a1a), [
    Pl('Courtuá', 87), Pl('Carvayal', 84), Pl('Militán', 84), Pl('Rudigá', 85),
    Pl('Mendi', 80), Pl('Valverdi', 88), Pl('Chuameni', 84), Pl('Bellinghan', 90),
    Pl('Vinísius', 91), Pl('Mbabé', 91), Pl('Rodrigró', 86),
  ]),
  Team('BARNA BLAUGRANA', Color(0xFF243b7a), Color(0xFF152347), Color(0xFFffffff), [
    Pl('Ter Stègan', 87), Pl('Kundé', 84), Pl('Cubarsí', 82), Pl('Iñigó', 82),
    Pl('Baldé', 81), Pl('Pedrí', 86), Pl('De Yong', 86), Pl('Gaví', 84),
    Pl('Yamàl', 88), Pl('Levandoski', 88), Pl('Rafiña', 85),
  ]),
  Team('MÁNCHESTER CIELO', Color(0xFF6cb4e4), Color(0xFF3d7fb0), Color(0xFF0a2a40), [
    Pl('Edersson', 88), Pl('Walká', 84), Pl('Diás R.', 87), Pl('Akanyí', 82),
    Pl('Gvardiol', 85), Pl('Silva B.', 88), Pl('Rodrí', 91), Pl('De Bruino', 90),
    Pl('Doku', 83), Pl('Haalund', 92), Pl('Foden', 88),
  ]),
  Team('LIVERPÚL ROJO', Color(0xFFd00027), Color(0xFF8a0019), Color(0xFFffffff), [
    Pl('Alissón', 89), Pl('Alexandà', 84), Pl('Konaté', 83), Pl('Van Deik', 89),
    Pl('Robertson', 84), Pl('Sobóslai', 83), Pl('Mac Alisté', 85), Pl('Gravenber', 80),
    Pl('Días L.', 85), Pl('Salà', 89), Pl('Núñes', 81),
  ]),
  Team('MÚNICH BÁVARO', Color(0xFFdc052d), Color(0xFF93001e), Color(0xFFffffff), [
    Pl('Nóier', 88), Pl('Kimmiš', 87), Pl('Kim M.', 83), Pl('Upamecà', 84),
    Pl('Davís A.', 84), Pl('Sané L.', 85), Pl('Goretzca', 83), Pl('Musiala', 87),
    Pl('Coman', 84), Pl('Kane H.', 90), Pl('Olisé', 84),
  ]),
  Team('PARÍS SAINT', Color(0xFF0b1b3a), Color(0xFF050d1f), Color(0xFFffffff), [
    Pl('Donaruma', 87), Pl('Hakimì', 86), Pl('Marquiños', 85), Pl('Skriniá', 84),
    Pl('Mendès N.', 82), Pl('Zaire E.', 80), Pl('Vitiña', 84), Pl('Ruís F.', 83),
    Pl('Kvaratsj', 86), Pl('Dembelé', 85), Pl('Barcolá', 82),
  ]),
  Team('LONDRES AZUL', Color(0xFF1f63c4), Color(0xFF123a73), Color(0xFFffffff), [
    Pl('Sànchez R.', 80), Pl('Gustó', 79), Pl('Colwil', 82), Pl('Badiashi', 80),
    Pl('Cucureya', 80), Pl('Madueke', 79), Pl('Caicedó', 84), Pl('Encsó', 81),
    Pl('Palmà', 86), Pl('Jacksón N.', 80), Pl('Nkunkú', 82),
  ]),
  Team('TURÍN CEBRA', Color(0xFF1c1c1c), Color(0xFF000000), Color(0xFFffffff), [
    Pl('Di Gregorì', 81), Pl('Cambiá M.', 80), Pl('Bremà', 83), Pl('Gatti', 81),
    Pl('Cambiasó', 80), Pl('Mc Kenì', 80), Pl('Locatelì', 82), Pl('Tudó', 79),
    Pl('Yildís', 82), Pl('Vlahovç', 84), Pl('Conceiçá', 81),
  ]),
];

class MatchConfig {
  int homeIdx;
  int awayIdx;
  int diff;
  int matchLen;
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
      cfg.awayIdx = (cfg.homeIdx + 1) % kTeams.length;
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                          colors: [Color(0xFF7CFC8A), Color(0xFF21d4fd)])
                      .createShader(r),
                  child: const Text('MOIN SOCCER',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1)),
                ),
                const SizedBox(height: 2),
                const Text('⚽ 11 vs 11',
                    style: TextStyle(
                        color: Color(0xFF9fe8c0),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4)),
                const SizedBox(height: 16),
                _card(
                  child: Column(
                    children: [
                      _teamPicker('Tu equipo', cfg.homeIdx, (v) {
                        setState(() {
                          cfg.homeIdx = v;
                          if (cfg.awayIdx == v) {
                            cfg.awayIdx = (v + 1) % kTeams.length;
                          }
                        });
                      }),
                      const SizedBox(height: 8),
                      _teamPicker('Rival', cfg.awayIdx, (v) {
                        setState(() {
                          if (v != cfg.homeIdx) cfg.awayIdx = v;
                        });
                      }),
                      const SizedBox(height: 14),
                      _label('Dificultad'),
                      _opts(['Fácil', 'Normal', 'Difícil'], cfg.diff,
                          (i) => setState(() => cfg.diff = i)),
                      const SizedBox(height: 12),
                      _label('Duración'),
                      _opts(['Corto', 'Medio', 'Largo'],
                          {3: 0, 5: 1, 8: 2}[cfg.matchLen] ?? 0, (i) {
                        setState(() => cfg.matchLen = [3, 5, 8][i]);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 12),
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
        constraints: const BoxConstraints(maxWidth: 390),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.12))),
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

  Widget _teamPicker(String label, int sel, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFcfeede),
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: sel,
              dropdownColor: const Color(0xFF0c2a1e),
              isDense: true,
              borderRadius: BorderRadius.circular(12),
              items: List.generate(kTeams.length, (i) {
                final tt = kTeams[i];
                return DropdownMenuItem<int>(
                  value: i,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: tt.color,
                              borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 8),
                      Text('${tt.name}  (${tt.rating})',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                );
              }),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _opts(List<String> labels, int sel, ValueChanged<int> onTap) => Row(
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
                      : Colors.white.withOpacity(0.08),
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
   Modelo del partido (11 vs 11)
   ============================================================ */
const double kW = 700, kH = 1500, kMargin = 60;
const double kGoalW = 210, kPlayerR = 12.5, kBallR = 8;
const double kSpeed = 2.6;
const double kSecondsPerHalf = 80;

class Slot {
  final String role;
  final double x, y;
  const Slot(this.role, this.x, this.y);
}

// 4-4-2 en la propia mitad (y: 0 portería propia -> 0.5 centro)
const List<Slot> kFormation = [
  Slot('GK', 0.50, 0.04),
  Slot('DF', 0.84, 0.18),
  Slot('DF', 0.62, 0.13),
  Slot('DF', 0.38, 0.13),
  Slot('DF', 0.16, 0.18),
  Slot('MF', 0.82, 0.33),
  Slot('MF', 0.60, 0.29),
  Slot('MF', 0.40, 0.29),
  Slot('MF', 0.18, 0.33),
  Slot('FW', 0.58, 0.46),
  Slot('FW', 0.42, 0.46),
];

double ratingFactor(int r) => (0.85 + r / 100 * 0.32).clamp(0.9, 1.22).toDouble();
double shotFactor(int r) => 0.9 + r / 100 * 0.25;

class Player {
  final String team;
  final String role;
  final int slot;
  final String name;
  final int number;
  final int rating;
  double x, y, vx = 0, vy = 0;
  double facing;
  double cooldown = 0;
  bool user = false;
  Player(this.team, this.role, this.slot, this.name, this.number, this.rating,
      this.x, this.y, this.facing);
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
  double matchClock = 0;
  int half = 1;
  String state = 'kickoff';
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
    final y = team == 'home' ? kH + kMargin - f.y * kH : kMargin + f.y * kH;
    return _clamp(y, kMargin, kH + kMargin);
  }

  double _teamHomeX(Slot f) => kMargin + f.x * kW;
  double _ownGoalY(String team) => team == 'home' ? kH + kMargin : kMargin;
  double _targetGoalY(String team) => team == 'home' ? kMargin : kH + kMargin;
  double get _goalX => kMargin + kW / 2;

  void _setup() {
    players = [];
    final home = kTeams[cfg.homeIdx];
    final away = kTeams[cfg.awayIdx];
    for (final entry in [
      ['home', home],
      ['away', away]
    ]) {
      final tname = entry[0] as String;
      final team = entry[1] as Team;
      for (int s = 0; s < kFormation.length; s++) {
        final f = kFormation[s];
        final pl = team.squad[s];
        players.add(Player(tname, f.role, s, pl.n, kNum[s], pl.r,
            _teamHomeX(f), _teamHomeY(tname, f), tname == 'home' ? -1 : 1));
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
    final taker = players.firstWhere(
        (p) => p.team == koTeam && p.role == 'FW',
        orElse: () => players.first);
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
    final pw = power * shotFactor(p.rating);
    ball.vx = dx * pw;
    ball.vy = dy * pw;
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
      final d = _dist(from.x, from.y, m.x, m.y);
      if (d > 360) continue; // pase realista, no a la otra punta
      final sc = adv + open * 0.6 - d * 0.05;
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
    final base = kSpeed * mul * ratingFactor(p.rating);
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
      double tx =
          _clamp(ball.x, gAttX - kGoalW / 2 + 10, gAttX + kGoalW / 2 - 10);
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
      if (dGoal < 320) {
        final a = math.atan2(
            atkY - p.y, (gAttX + (rnd.nextDouble() - 0.5) * kGoalW * 0.6) - p.x);
        _shoot(p, 9.5, math.cos(a), math.sin(a));
        return;
      }
      if (pressed && rnd.nextDouble() < 0.05) {
        final mate = _bestPassTarget(p);
        if (mate != null) {
          final a = math.atan2(mate.y - p.y, mate.x - p.x);
          _shoot(p, 6.5 + _dist(p.x, p.y, mate.x, mate.y) * 0.012, math.cos(a),
              math.sin(a));
          return;
        }
      }
      final tx = gAttX + (p.x - gAttX) * 0.4;
      _moveToward(p, tx, atkY, 0.95 + cfg.diff * 0.05);
      return;
    }

    final chaser = _closestToBall(myTeam);
    final weAttack = possessionTeam == myTeam;
    if (chaser == p && !(ball.owner != null && ball.owner!.team == myTeam)) {
      _moveToward(p, ball.x, ball.y, 0.82 + cfg.diff * 0.07);
    } else {
      final f = kFormation[p.slot];
      final baseX = _teamHomeX(f);
      final baseY = _teamHomeY(myTeam, f);
      final fwd = 0.4 + f.y * 1.7; // los delanteros suben mas
      final push = weAttack ? 150 * fwd : -30.0;
      final ty = baseY + (myTeam == 'home' ? -1 : 1) * push;
      final tx = baseX + (ball.x - gAttX) * 0.16;
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
      if (p.cooldown > 0) p.cooldown = math.max(0.0, p.cooldown - dt);
    }

    final hasInput = inp.moveX != 0 || inp.moveY != 0;
    if (up != null && (state == 'play' || state == 'kickoff') && hasInput) {
      final mag = math.min(
          1.0, math.sqrt(inp.moveX * inp.moveX + inp.moveY * inp.moveY));
      final spr = (inp.sprint ? 1.35 : 1.0) *
          (mag < 1 ? mag : 1.0) *
          ratingFactor(up.rating);
      up.vx = inp.moveX * kSpeed * spr;
      up.vy = inp.moveY * kSpeed * spr;
      if (inp.moveY != 0) up.facing = inp.moveY.sign;
    }

    _handleUser(inp, up);

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
        const minD = kPlayerR * 2 - 3;
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
    final scorer = ball.lastTouch;
    final who = scorer != null ? scorer.name : '';
    goalText = team == 'home' ? '¡GOOOL!  $who' : '¡GOL RIVAL!';
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

  int? _joyId;
  Offset _joyOrigin = Offset.zero;
  Offset _joyCurrent = Offset.zero;
  final Map<int, String> _btnPointers = {};
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
              Positioned(
                  top: 0, left: 0, right: 0, child: SafeArea(child: _scoreboard())),
              if (world.state == 'goal') Positioned.fill(child: _goalOverlay()),
              if (world.state == 'end') Positioned.fill(child: _endOverlay()),
            ],
          ),
        );
      }),
    );
  }

  Widget _scoreboard() {
    final h = kTeams[widget.cfg.homeIdx];
    final a = kTeams[widget.cfg.awayIdx];
    final mins = (world.matchClock ~/ 60).toString().padLeft(2, '0');
    final secs = (world.matchClock % 60).floor().toString().padLeft(2, '0');
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(h.color),
            const SizedBox(width: 5),
            Text(h.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(width: 8),
            Text('${world.homeScore} - ${world.awayScore}',
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 21)),
            const SizedBox(width: 8),
            Text(a.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(width: 5),
            _dot(a.color),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
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
      width: 12,
      height: 12,
      decoration:
          BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)));

  Widget _goalOverlay() => IgnorePointer(
        child: Center(
          child: Text(
            world.goalText,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Color(0xFF21d4fd), blurRadius: 22)]),
          ),
        ),
      );

  Widget _endOverlay() {
    final hs = world.homeScore, as = world.awayScore;
    final hn = kTeams[widget.cfg.homeIdx].name, an = kTeams[widget.cfg.awayIdx].name;
    String title, msg;
    if (hs > as) {
      title = '🏆 ¡VICTORIA!';
      msg = '¡$hn gana el partido!';
    } else if (hs < as) {
      title = '😞 DERROTA';
      msg = '$an se lleva la victoria.';
    } else {
      title = '🤝 EMPATE';
      msg = 'Repartieron los puntos.';
    }
    return Container(
      color: Colors.black.withOpacity(0.8),
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
                textAlign: TextAlign.center,
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

    final shadow = Paint()..color = Colors.black.withOpacity(0.25);
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

    double sx(double wx) => (wx - (kMargin + kW / 2)) * scale + size.width / 2;
    double sy(double wy) => (wy - world.camY) * scale + size.height / 2;

    final up = world.userPlayer;
    final owner = world.ball.owner;
    if (up != null) {
      final ax = sx(up.x), ay = sy(up.y - kPlayerR - 14);
      final tri = Path()
        ..moveTo(ax, ay + 10)
        ..lineTo(ax - 8, ay - 2)
        ..lineTo(ax + 8, ay - 2)
        ..close();
      canvas.drawPath(tri, Paint()..color = Colors.white);
    }
    if (owner != null) {
      _nameTag(canvas, owner.name, sx(owner.x), sy(owner.y - kPlayerR - 22),
          const Color(0xFFffe27a));
    }
    if (up != null && up != owner) {
      _nameTag(canvas, up.name, sx(up.x), sy(up.y - kPlayerR - 22), Colors.white);
    }

    _controls(canvas);
  }

  void _nameTag(Canvas canvas, String s, double x, double y, Color col) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              color: col, fontSize: 12, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = tp.width + 10, h = tp.height + 4;
    final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: w, height: h),
        const Radius.circular(5));
    canvas.drawRRect(r, Paint()..color = Colors.black.withOpacity(0.6));
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _pitch(Canvas canvas) {
    const left = kMargin, top = kMargin;
    const stripe = 75.0;
    for (double y = top - kMargin; y < kH + 2 * kMargin; y += stripe) {
      final even = ((y / stripe).floor() % 2) == 0;
      canvas.drawRect(
          Rect.fromLTWH(left - kMargin, y, kW + 2 * kMargin, stripe),
          Paint()
            ..color = even ? const Color(0xFF15a04a) : const Color(0xFF129143));
    }
    final line = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final fill = Paint()..color = Colors.white.withOpacity(0.85);
    canvas.drawRect(Rect.fromLTWH(left, top, kW, kH), line);
    canvas.drawLine(Offset(left, top + kH / 2),
        Offset(left + kW, top + kH / 2), line);
    canvas.drawCircle(Offset(left + kW / 2, top + kH / 2), 90, line);
    canvas.drawCircle(Offset(left + kW / 2, top + kH / 2), 5, fill);
    const aw = 360.0, ah = 175.0, sw = 160.0, sh = 70.0;
    canvas.drawRect(Rect.fromLTWH(left + kW / 2 - aw / 2, top, aw, ah), line);
    canvas.drawRect(Rect.fromLTWH(left + kW / 2 - sw / 2, top, sw, sh), line);
    canvas.drawRect(
        Rect.fromLTWH(left + kW / 2 - aw / 2, top + kH - ah, aw, ah), line);
    canvas.drawRect(
        Rect.fromLTWH(left + kW / 2 - sw / 2, top + kH - sh, sw, sh), line);
  }

  void _nets(Canvas canvas) {
    final gxL = kMargin + kW / 2 - kGoalW / 2;
    const depth = 36.0;
    final frame = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(Rect.fromLTWH(gxL, kMargin - depth, kGoalW, depth), frame);
    canvas.drawRect(Rect.fromLTWH(gxL, kMargin + kH, kGoalW, depth), frame);
    final net = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double i = 0; i <= kGoalW; i += 14) {
      canvas.drawLine(
          Offset(gxL + i, kMargin - depth), Offset(gxL + i, kMargin), net);
      canvas.drawLine(Offset(gxL + i, kMargin + kH),
          Offset(gxL + i, kMargin + kH + depth), net);
    }
  }

  void _drawPlayer(Canvas canvas, Player p) {
    final isGK = p.role == 'GK';
    final t = p.team == 'home'
        ? kTeams[world.cfg.homeIdx]
        : kTeams[world.cfg.awayIdx];
    final body = Paint()..color = isGK ? const Color(0xFF2a2a2a) : t.color;
    final edge = Paint()
      ..color = isGK ? const Color(0xFF111111) : t.dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(p.x, p.y), kPlayerR, body);
    canvas.drawCircle(Offset(p.x, p.y), kPlayerR, edge);
    if (p.user) {
      canvas.drawCircle(
          Offset(p.x, p.y),
          kPlayerR + 4,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);
    }
    _text(canvas, '${p.number}', Offset(p.x, p.y), 11,
        isGK ? Colors.white : t.text);
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
    if (joyId != null) {
      final base = joyOrigin;
      canvas.drawCircle(
          base, 60, Paint()..color = Colors.white.withOpacity(0.08));
      canvas.drawCircle(
          base,
          60,
          Paint()
            ..color = Colors.white.withOpacity(0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
      var d = joyCurrent - joyOrigin;
      if (d.distance > joyRadius) d = d * (joyRadius / d.distance);
      canvas.drawCircle(
          base + d, 28, Paint()..color = Colors.white.withOpacity(0.55));
    }
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
          ..color = Colors.white.withOpacity(0.35)
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
