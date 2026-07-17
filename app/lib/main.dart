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
  Team('MILÁN ROSSONERO', Color(0xFFb01722), Color(0xFF2a0a0d), Color(0xFFffffff), [
    Pl('Maignàn', 85), Pl('Emersón R.', 79), Pl('Tomorì', 81), Pl('Gabbià', 78),
    Pl('Teo H.', 84), Pl('Puleisic', 84), Pl('Reijndé', 82), Pl('Fofanà', 82),
    Pl('Leào', 86), Pl('Morata J.', 82), Pl('Chuqui', 79),
  ]),
  Team('MILÁN NERAZZURRI', Color(0xFF1c2b6b), Color(0xFF0c1436), Color(0xFFffffff), [
    Pl('Sómer', 82), Pl('Dumfrí', 82), Pl('Pavà', 80), Pl('Acerbì', 81),
    Pl('Dimarcò', 84), Pl('Barellà', 85), Pl('Chalanó', 84), Pl('Mkhitá', 81),
    Pl('Bastonì', 84), Pl('Lautà', 88), Pl('Tuhràm M.', 85),
  ]),
  Team('NÁPOLES AZZURRO', Color(0xFF12a5e8), Color(0xFF0a6a95), Color(0xFFffffff), [
    Pl('Meret A.', 80), Pl('Di Lorè', 82), Pl('Rrahmà', 80), Pl('Buongió', 82),
    Pl('Oliverà', 79), Pl('Polità', 81), Pl('Lobotká', 83), Pl('Anguisà', 83),
    Pl('Kvarà', 86), Pl('Lukakù R.', 83), Pl('Neres D.', 81),
  ]),
  Team('DORTMUND AMBAR', Color(0xFFf1d600), Color(0xFF161616), Color(0xFF1a1a1a), [
    Pl('Kobél', 82), Pl('Ryersón', 78), Pl('Schlotb', 80), Pl('Hummés', 80),
    Pl('Marató', 78), Pl('Brandt J.', 82), Pl('Zabitzé', 79), Pl('Can E.', 79),
    Pl('Adeyemà', 81), Pl('Guirasí', 83), Pl('Gittèns', 79),
  ]),
  Team('ÁMSTERDAM AJÁ', Color(0xFFd11a2a), Color(0xFF7a0f18), Color(0xFFffffff), [
    Pl('Ramà', 76), Pl('Rensch', 75), Pl('Sutalò', 76), Pl('Ható', 78),
    Pl('Wijndá', 75), Pl('Berghà', 77), Pl('Taylà K.', 76), Pl('Henderson', 79),
    Pl('Bergwì', 78), Pl('Brobbé', 76), Pl('Akpom', 76),
  ]),
  Team('ARGENTINA ALBI', Color(0xFF75c2e8), Color(0xFF3f8fbf), Color(0xFF0a2a40), [
    Pl('Martines E.', 86), Pl('Molinà N.', 82), Pl('Romerò C.', 84), Pl('Otamén', 82),
    Pl('Taglià', 82), Pl('De Paùl', 84), Pl('Fernándz E.', 84), Pl('Mac Alí', 85),
    Pl('Di Marí', 84), Pl('Messias', 92), Pl('Álvares J.', 85),
  ]),
  Team('FRANCIA BLEU', Color(0xFF1a3a8f), Color(0xFF0d1e4d), Color(0xFFffffff), [
    Pl('Maignán', 85), Pl('Coumán', 82), Pl('Saliba W.', 85), Pl('Upamé', 84),
    Pl('T. Hernán', 84), Pl('Chuamé', 84), Pl('Camavín', 85), Pl('Grizmán', 86),
    Pl('Barcolà', 82), Pl('Mbabé', 91), Pl('Dembelè', 84),
  ]),
  Team('BRASIL VERDEAMA', Color(0xFFf7d716), Color(0xFF0a7d3a), Color(0xFF0a3a1a), [
    Pl('Alissón', 88), Pl('Danilò', 80), Pl('Marquiñ', 85), Pl('Gabriél M.', 84),
    Pl('Wendèl', 79), Pl('Bruno G.', 83), Pl('Casemì', 82), Pl('Lucas P.', 82),
    Pl('Rodrigró', 85), Pl('Vinísius', 91), Pl('Rafinià', 84),
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

String teamInitials(String name) {
  final parts = name.split(' ');
  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return name.substring(0, name.length >= 3 ? 3 : name.length).toUpperCase();
}

class TeamCrest extends StatelessWidget {
  final Team team;
  final double size;
  const TeamCrest(this.team, {this.size = 20, super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: size,
      height: size * 1.15,
      child: CustomPaint(painter: _CrestPainter(team)));
}

class _CrestPainter extends CustomPainter {
  final Team team;
  _CrestPainter(this.team);
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final path = Path()
      ..moveTo(w * 0.12, h * 0.06)
      ..lineTo(w * 0.88, h * 0.06)
      ..lineTo(w * 0.88, h * 0.55)
      ..quadraticBezierTo(w * 0.88, h * 0.86, w * 0.5, h * 0.98)
      ..quadraticBezierTo(w * 0.12, h * 0.86, w * 0.12, h * 0.55)
      ..close();
    canvas.drawPath(path, Paint()..color = team.color);
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(Rect.fromLTWH(w * 0.42, 0, w * 0.16, h),
        Paint()..color = team.dark.withOpacity(0.55));
    canvas.restore();
    canvas.drawPath(
        path,
        Paint()
          ..color = team.dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.06);
    final tp = TextPainter(
      text: TextSpan(
          text: teamInitials(team.name),
          style: TextStyle(
              color: team.text,
              fontSize: h * 0.4,
              fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, h * 0.42 - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CrestPainter old) => old.team != team;
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
  int mode = 0; // 0 amistoso, 1 liga, 2 copa

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
                      _label('Modo'),
                      _opts(const ['Amistoso', 'Liga', 'Copa'], mode,
                          (i) => setState(() => mode = i)),
                      const SizedBox(height: 12),
                      _teamPicker('Tu equipo', cfg.homeIdx, (v) {
                        setState(() {
                          cfg.homeIdx = v;
                          if (cfg.awayIdx == v) {
                            cfg.awayIdx = (v + 1) % kTeams.length;
                          }
                        });
                      }),
                      if (mode == 0) const SizedBox(height: 8),
                      if (mode == 0)
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
                      if (mode == 0) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => GameScreen(
                                cfg: MatchConfig(
                                    homeIdx: cfg.homeIdx,
                                    awayIdx: cfg.awayIdx,
                                    diff: cfg.diff,
                                    matchLen: cfg.matchLen))));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => TournamentScreen(
                                userTeam: cfg.homeIdx,
                                isCup: mode == 2,
                                diff: cfg.diff,
                                matchLen: cfg.matchLen)));
                      }
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
                      TeamCrest(tt, size: 16),
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

  Player? _secondClosest(String team, Player? ex) {
    Player? best;
    double bd = 1e9;
    for (final p in players) {
      if (p.team != team || p.role == 'GK' || p == ex) continue;
      final d = _dist(p.x, p.y, ball.x, ball.y);
      if (d < bd) {
        bd = d;
        best = p;
      }
    }
    return best;
  }

  Player? _nearestOpponent(Player p) {
    Player? best;
    double bd = 1e9;
    for (final o in players) {
      if (o.team == p.team) continue;
      final d = _dist(p.x, p.y, o.x, o.y);
      if (d < bd) {
        bd = d;
        best = o;
      }
    }
    return best;
  }

  void _ai(Player p) {
    final hasBall = ball.owner == p;
    final myTeam = p.team;
    final atkY = _targetGoalY(myTeam);
    final ownY = _ownGoalY(myTeam);
    final gAttX = _goalX;
    final dir = myTeam == 'home' ? -1.0 : 1.0; // hacia porteria rival

    // ---- Portero ----
    if (p.role == 'GK') {
      final gy = ownY + (myTeam == 'home' ? -50 : 50);
      final tx =
          _clamp(ball.x, gAttX - kGoalW / 2 + 10, gAttX + kGoalW / 2 - 10);
      final near = _dist(p.x, p.y, ball.x, ball.y);
      if (near < 160 && (ball.y - ownY).abs() < 240 && ball.owner == null) {
        _moveToward(p, ball.x, ball.y, 1.05); // sale a despejar
      } else {
        _moveToward(p, tx, gy, 0.75);
      }
      if (hasBall) {
        final mate = _bestPassTarget(p);
        final tgtX = mate?.x ?? gAttX;
        final tgtY = mate?.y ?? atkY;
        final a = math.atan2(tgtY - p.y, tgtX - p.x);
        _shoot(p, mate != null ? 6.5 : 8.0, math.cos(a), math.sin(a));
      }
      return;
    }

    // ---- Con balon ----
    if (hasBall) {
      final dGoal = _dist(p.x, p.y, gAttX, atkY);
      final opp = _nearestOpponent(p);
      final pressDist = opp != null ? _dist(p.x, p.y, opp.x, opp.y) : 999.0;
      final pressed = pressDist < 62;

      if (dGoal < 330 && pressDist > 26) {
        final a = math.atan2(atkY - p.y,
            (gAttX + (rnd.nextDouble() - 0.5) * kGoalW * 0.55) - p.x);
        _shoot(p, 9.5, math.cos(a), math.sin(a));
        return;
      }
      final mate = _bestPassTarget(p);
      if (mate != null) {
        final mateAdvance = dir * (mate.y - p.y) > 20;
        final wantPass = pressed
            ? rnd.nextDouble() < 0.5
            : (mateAdvance && rnd.nextDouble() < 0.03);
        if (wantPass) {
          final a = math.atan2(mate.y - p.y, mate.x - p.x);
          _shoot(p, 6.0 + _dist(p.x, p.y, mate.x, mate.y) * 0.013, math.cos(a),
              math.sin(a));
          return;
        }
      }
      // regate hacia porteria, esquivando al rival mas cercano
      double tx = gAttX + (p.x - gAttX) * 0.4;
      if (opp != null && pressDist < 95) {
        final away = (p.x - opp.x).sign;
        tx = _clamp(p.x + (away == 0 ? 1.0 : away) * 70, kMargin, kMargin + kW);
      }
      _moveToward(p, tx, atkY, 0.95 + cfg.diff * 0.05);
      return;
    }

    // ---- Sin balon ----
    final weHaveBall = ball.owner != null && ball.owner!.team == myTeam;
    final chaser = _closestToBall(myTeam);
    final second = _secondClosest(myTeam, chaser);
    final f = kFormation[p.slot];
    final baseX = _teamHomeX(f);
    final baseY = _teamHomeY(myTeam, f);

    if (!weHaveBall && chaser == p) {
      _moveToward(p, ball.x, ball.y, 0.85 + cfg.diff * 0.08); // presiona
      return;
    }
    if (!weHaveBall && second == p) {
      _moveToward(p, ball.x, ball.y - dir * 70, 0.82); // cobertura por detras
      return;
    }

    if (weHaveBall) {
      final fwd = 0.5 + f.y * 1.7; // delanteros hacen desmarques mas arriba
      final ty = baseY + dir * (140 * fwd);
      final tx = baseX + (ball.x - gAttX) * 0.20;
      _moveToward(p, _clamp(tx, kMargin, kMargin + kW),
          _clamp(ty, kMargin, kMargin + kH), 0.8);
    } else {
      final ty = baseY + dir * -20; // linea compacta, algo adelantada al balon
      final tx = baseX + (ball.x - gAttX) * 0.22;
      _moveToward(p, _clamp(tx, kMargin, kMargin + kW),
          _clamp(ty, kMargin, kMargin + kH), 0.72);
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
  final bool tournament;
  const GameScreen({super.key, required this.cfg, this.tournament = false});
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
            TeamCrest(h, size: 16),
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
            TeamCrest(a, size: 16),
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
            if (widget.tournament)
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16c172),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14)),
                onPressed: () => Navigator.of(context)
                    .pop(<int>[world.homeScore, world.awayScore]),
                child: const Text('CONTINUAR ▶',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              )
            else ...[
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16c172),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14)),
                onPressed: () {
                  setState(() {
                    world.restart();
                    _last = Duration.zero;
                  });
                },
                child: const Text('REVANCHA 🔁',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('MENÚ',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
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

/* ============================================================
   Modo Torneo: Liga (round-robin) y Copa (eliminatorias)
   ============================================================ */
class TMatch {
  int a, b;
  bool played = false;
  int sa = 0, sb = 0;
  List<int>? pens;
  int? winner;
  TMatch(this.a, this.b);
}

class TournamentScreen extends StatefulWidget {
  final int userTeam;
  final bool isCup;
  final int diff;
  final int matchLen;
  const TournamentScreen(
      {super.key,
      required this.userTeam,
      required this.isCup,
      required this.diff,
      required this.matchLen});
  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  final rnd = math.Random();
  List<int> pool = [];
  List<List<TMatch>> rounds = [];
  int roundIdx = 0;
  int? champion;
  bool eliminated = false;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    final others = List.generate(kTeams.length, (i) => i)..remove(widget.userTeam);
    others.shuffle(rnd);
    if (widget.isCup) {
      pool = [widget.userTeam, ...others.take(7)];
      pool.shuffle(rnd);
      final r0 = <TMatch>[];
      for (int i = 0; i < pool.length; i += 2) {
        r0.add(TMatch(pool[i], pool[i + 1]));
      }
      rounds = [r0];
    } else {
      pool = [widget.userTeam, ...others.take(5)];
      rounds = _leagueSchedule(pool);
    }
  }

  List<List<TMatch>> _leagueSchedule(List<int> teams) {
    final n = teams.length;
    final arr = List<int>.from(teams);
    final rs = <List<TMatch>>[];
    for (int r = 0; r < n - 1; r++) {
      final pairs = <TMatch>[];
      for (int i = 0; i < n ~/ 2; i++) {
        pairs.add(TMatch(arr[i], arr[n - 1 - i]));
      }
      rs.add(pairs);
      final last = arr.removeAt(n - 1);
      arr.insert(1, last);
    }
    return rs;
  }

  TMatch? _userMatch() {
    for (final m in rounds[roundIdx]) {
      if ((m.a == widget.userTeam || m.b == widget.userTeam) && !m.played) {
        return m;
      }
    }
    return null;
  }

  List<int> _sim(int a, int b) {
    final ra = kTeams[a].rating, rb = kTeams[b].rating;
    int g(int me, int op) =>
        (1.15 + (me - op) / 16.0 + (rnd.nextDouble() * 2.2 - 0.9))
            .round()
            .clamp(0, 6)
            .toInt();
    return [g(ra, rb), g(rb, ra)];
  }

  void _resolveCup(TMatch m) {
    m.played = true;
    if (m.sa > m.sb) {
      m.winner = m.a;
    } else if (m.sb > m.sa) {
      m.winner = m.b;
    } else {
      int pa = rnd.nextInt(5) + 1, pb = rnd.nextInt(5) + 1;
      if (pa == pb) {
        if (rnd.nextBool()) {
          pa++;
        } else {
          pb++;
        }
      }
      m.pens = [pa, pb];
      m.winner = pa > pb ? m.a : m.b;
    }
  }

  Map<int, List<int>> _standings() {
    final st = {for (final t in pool) t: [0, 0, 0, 0, 0, 0]};
    for (final round in rounds) {
      for (final m in round) {
        if (!m.played) continue;
        final A = st[m.a]!, B = st[m.b]!;
        A[0]++;
        B[0]++;
        A[4] += m.sa;
        A[5] += m.sb;
        B[4] += m.sb;
        B[5] += m.sa;
        if (m.sa > m.sb) {
          A[1]++;
          B[3]++;
        } else if (m.sb > m.sa) {
          B[1]++;
          A[3]++;
        } else {
          A[2]++;
          B[2]++;
        }
      }
    }
    return st;
  }

  int _pts(List<int> s) => s[1] * 3 + s[2];
  int _dg(List<int> s) => s[4] - s[5];

  List<int> _sortedPool() {
    final st = _standings();
    final order = List<int>.from(pool);
    order.sort((x, y) {
      final sx = st[x]!, sy = st[y]!;
      if (_pts(sy) != _pts(sx)) return _pts(sy) - _pts(sx);
      if (_dg(sy) != _dg(sx)) return _dg(sy) - _dg(sx);
      return sy[4] - sx[4];
    });
    return order;
  }

  Future<void> _playNext() async {
    final m = _userMatch();
    if (m == null) return;
    final opp = m.a == widget.userTeam ? m.b : m.a;
    final res = await Navigator.of(context).push<List<int>>(MaterialPageRoute(
        builder: (_) => GameScreen(
            cfg: MatchConfig(
                homeIdx: widget.userTeam,
                awayIdx: opp,
                diff: widget.diff,
                matchLen: widget.matchLen),
            tournament: true)));
    if (res == null) return;
    if (m.a == widget.userTeam) {
      m.sa = res[0];
      m.sb = res[1];
    } else {
      m.sa = res[1];
      m.sb = res[0];
    }
    if (widget.isCup) {
      _resolveCup(m);
    } else {
      m.played = true;
    }
    for (final om in rounds[roundIdx]) {
      if (om.played) continue;
      final s = _sim(om.a, om.b);
      om.sa = s[0];
      om.sb = s[1];
      if (widget.isCup) {
        _resolveCup(om);
      } else {
        om.played = true;
      }
    }
    _advance();
    if (mounted) setState(() {});
  }

  void _advance() {
    if (widget.isCup) {
      final um = rounds[roundIdx].firstWhere(
          (x) => x.a == widget.userTeam || x.b == widget.userTeam,
          orElse: () => rounds[roundIdx].first);
      if (um.winner != widget.userTeam) {
        eliminated = true;
        champion = um.winner;
        finished = true;
        return;
      }
      if (rounds[roundIdx].length == 1) {
        champion = widget.userTeam;
        finished = true;
      } else {
        final winners = rounds[roundIdx].map((x) => x.winner!).toList();
        final next = <TMatch>[];
        for (int i = 0; i < winners.length; i += 2) {
          next.add(TMatch(winners[i], winners[i + 1]));
        }
        rounds.add(next);
        roundIdx++;
      }
    } else {
      if (roundIdx < rounds.length - 1) {
        roundIdx++;
      } else {
        champion = _sortedPool().first;
        finished = true;
      }
    }
  }

  String _cupRoundName(int matches) => matches >= 4
      ? 'CUARTOS'
      : matches == 2
          ? 'SEMIFINALES'
          : 'FINAL';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCup ? '🏆 COPA MOIN' : '🏅 LIGA MOIN'),
        backgroundColor: const Color(0xFF063a26),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (finished) _finishBanner(),
              if (widget.isCup) _cupView() else _leagueView(),
              const SizedBox(height: 18),
              if (!finished)
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16c172),
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: _playNext,
                  child: Text(_nextLabel(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 18)),
                )
              else
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3a4a55),
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('VOLVER AL MENÚ',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _nextLabel() {
    if (widget.isCup) {
      return 'JUGAR ${_cupRoundName(rounds[roundIdx].length)} ▶';
    }
    return 'JUGAR JORNADA ${roundIdx + 1} ▶';
  }

  Widget _finishBanner() {
    String title, msg;
    if (champion == widget.userTeam) {
      title = '🏆 ¡CAMPEONES!';
      msg = '¡${kTeams[widget.userTeam].name} levanta el título!';
    } else if (eliminated) {
      title = '😞 ELIMINADOS';
      msg = 'Campeón: ${champion != null ? kTeams[champion!].name : "-"}.';
    } else {
      title = '🏁 FIN DE LA LIGA';
      msg = 'Campeón: ${champion != null ? kTeams[champion!].name : "-"}.';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9fbdb0))),
        ],
      ),
    );
  }

  Widget _teamRow(int idx, {bool bold = false}) {
    final t = kTeams[idx];
    final me = idx == widget.userTeam;
    return Row(
      children: [
        TeamCrest(t, size: 15),
        const SizedBox(width: 6),
        Expanded(
          child: Text(t.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: me || bold ? FontWeight.w900 : FontWeight.w600,
                  color: me ? const Color(0xFF7CFC8A) : Colors.white,
                  fontSize: 13)),
        ),
      ],
    );
  }

  Widget _leagueView() {
    final order = _sortedPool();
    final st = _standings();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Row(
            children: const [
              SizedBox(width: 22, child: Text('#', style: _thdr)),
              Expanded(child: Text('EQUIPO', style: _thdr)),
              SizedBox(width: 30, child: Text('PJ', style: _thdr, textAlign: TextAlign.center)),
              SizedBox(width: 34, child: Text('DG', style: _thdr, textAlign: TextAlign.center)),
              SizedBox(width: 34, child: Text('PTS', style: _thdr, textAlign: TextAlign.center)),
            ],
          ),
          const Divider(color: Colors.white24, height: 14),
          ...List.generate(order.length, (i) {
            final idx = order[i];
            final s = st[idx]!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                      width: 22,
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: i == 0
                                  ? const Color(0xFFffe27a)
                                  : Colors.white70))),
                  Expanded(child: _teamRow(idx)),
                  SizedBox(
                      width: 30,
                      child: Text('${s[0]}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70))),
                  SizedBox(
                      width: 34,
                      child: Text('${_dg(s) >= 0 ? '+' : ''}${_dg(s)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70))),
                  SizedBox(
                      width: 34,
                      child: Text('${_pts(s)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _cupView() {
    final next = finished ? null : _userMatch();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int ri = 0; ri < rounds.length; ri++) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4, left: 2),
            child: Text(_cupRoundName(rounds[ri].length),
                style: const TextStyle(
                    color: Color(0xFF7fd6a8),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    fontSize: 12)),
          ),
          ...rounds[ri].map((m) => _cupMatch(m, m == next)),
        ],
      ],
    );
  }

  Widget _cupMatch(TMatch m, bool live) {
    String score;
    if (m.played) {
      score = '${m.sa} - ${m.sb}';
      if (m.pens != null) score += '  (p ${m.pens![0]}-${m.pens![1]})';
    } else {
      score = 'vs';
    }
    Color? bg = live ? const Color(0x2021d4fd) : Colors.white.withOpacity(0.05);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: live
              ? Border.all(color: const Color(0xFF21d4fd), width: 2)
              : null),
      child: Row(
        children: [
          Expanded(
              child: _teamRow(m.a, bold: m.played && m.winner == m.a)),
          SizedBox(
              width: 96,
              child: Text(score,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 13))),
          Expanded(
              child: _teamRow(m.b, bold: m.played && m.winner == m.b)),
        ],
      ),
    );
  }
}

const TextStyle _thdr = TextStyle(
    color: Color(0xFF7fd6a8), fontWeight: FontWeight.w800, fontSize: 11);
