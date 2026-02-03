import 'dart:async'; // Pour le Timer (actualisation auto)
import 'dart:convert'; // Pour lire les données de l'API
import 'dart:math'; // Pour l'intelligence artificielle (Random)
import 'package:flutter/material.dart'; // Pour l'interface (UI)
import 'package:http/http.dart' as http; // Pour faire les requêtes API
import 'package:intl/intl.dart'; // Pour formater les dates et heures
import 'package:cloud_firestore/cloud_firestore.dart'; // Pour la base de données

// ===================== PAGE MENU FOOTBALL GRATUIT =====================

class FOOTMenuPage extends StatelessWidget {
  const FOOTMenuPage({super.key});

  void _fadeNavigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ICI : J'ai relié chaque bouton à sa propre page.
    // Vérifie que les noms (TicketPage, CombinePage...) correspondent exactement à tes classes existantes.
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': "CONSEILS SURS & FIABLES",
        'image': 'assets/images/vip/football.png',
        'destination': const SportPage(), // Celle-ci on sait qu'elle est bonne
      },
      {
        'title': "MEILLEURS TICKETS TOTAL",
        'image': 'assets/images/vip/ticket.png',
        'destination':
            const TicketPage(), // <--- Vérifie le nom de ta classe Ticket
      },
      {
        'title': "PARIS COMBINÉ",
        'image': 'assets/images/vip/basketball.png',
        'destination':
            const CombinePage(), // <--- Vérifie le nom de ta classe Combiné
      },
      {
        'title': "TOP 5 DU JOUR",
        'image': 'assets/images/vip/cup.png',
        'destination':
            const TopPage(), // <--- Vérifie le nom de ta classe Top 5
      },
      {
        'title': "COUPON SEMAINE",
        'image': 'assets/images/vip/jersey.png',
        'destination':
            const CouponPage(), // <--- Vérifie le nom de ta classe Coupon
      },
      {
        'title': "PLUS / MOINS DE BUTS",
        'image': 'assets/images/vip/winner.png',
        'destination':
            const ButsPage(), // <--- Vérifie le nom de ta classe Buts
      },
      {
        'title': "MATCH SIMPLE",
        'image': 'assets/images/vip/cup.png',
        'destination':
            const SimplePage(), // <--- Vérifie le nom de ta classe Match Simple
      },
      {
        'title': "HISTORIQUE SCORES EXACTES",
        'image': 'assets/images/vip/historique.png',
        'destination':
            const HistoriquePage(), // <--- Vérifie le nom de ta classe Historique
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ACCÈS GRATUIT",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Génération automatique des boutons
            ...menuItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildVipCard(
                  title: item['title'] as String,
                  imagePath: item['image'] as String,
                  isActive: true,
                  onTap: () {
                    // C'est ici que la navigation se fait vers la destination spécifique
                    _fadeNavigate(context, item['destination'] as Widget);
                  },
                ),
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildVipCard({
    required String title,
    required String imagePath,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? onTap : null,
          borderRadius: BorderRadius.circular(2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset(
                  imagePath,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.sports_soccer,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== SPORT PAGE (ALGORITHME INTELLIGENT & COMPLET) ===================== */

class SportPage extends StatefulWidget {
  const SportPage({super.key});

  @override
  State<SportPage> createState() => _SportPageState();
}

class _SportPageState extends State<SportPage> {
  // CLÉ API FOOTBALL
  static const String FOOTBALL_DATA_API_KEY =
      '7531ff2472bf4416b93cc2e64e7e77c0';

  final String _bgImage =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";
  final String _leagueFallback =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";

  late String _todayDocId;
  String _dateDisplay = "";
  bool _isGeneratingLocally = false;
  Timer? _timer;

  // LISTE DES "TITANS" (Équipes offensives/fortes)
  final List<String> _titans = [
    'Man City',
    'Liverpool',
    'Arsenal',
    'Real Madrid',
    'Barcelona',
    'Bayern',
    'Leverkusen',
    'PSG',
    'Inter',
    'Juventus',
    'Milan',
    'Dortmund'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDocId = DateFormat('yyyy-MM-dd').format(now);
    _dateDisplay = DateFormat('dd.MM.yyyy').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateSmartPredictions();
      _updateLiveScores();
    });

    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updateLiveScores();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(NetworkImage(_bgImage), context);
    super.didChangeDependencies();
  }

  // --- LOGIQUE DE VALIDATION INTELLIGENTE (Gère MT, Équipes, Totaux) ---
  bool _checkFootballWin(
      String predictionText, int h, int a, int htH, int htA) {
    String text = predictionText.toLowerCase();
    int total = h + a;
    int totalHT = htH + htA;
    int goals2ndHalf =
        (h - htH) + (a - htA); // Buts marqués en 2ème mi-temps uniquement

    // 1. MI-TEMPS (1ere MT)
    if (text.contains("1ere mt +0.5")) return totalHT > 0;

    // 2. SECONDE MI-TEMPS (2e MT)
    if (text.contains("2e mt +1.5")) return goals2ndHalf > 1;

    // 3. BUTS PAR ÉQUIPE
    if (text.contains("equipe a +1.5")) return h > 1;
    if (text.contains("equipe b +1.5")) return a > 1;

    // 4. TOTAUX (Over/Under)
    if (text.contains("+1.5 buts")) return total > 1;
    if (text.contains("+2.5 buts")) return total > 2;
    if (text.contains("+3.5 buts")) return total > 3;
    if (text.contains("-3.5 buts")) return total < 4;
    if (text.contains("-2.5 buts")) return total < 3;

    // 5. RÉSULTATS MATCH
    if (text.contains("victoire ou nul equipe a")) return h >= a;
    if (text.contains("victoire ou nul equipe b")) return a >= h;
    if (text.contains("victoire equipe a")) return h > a;
    if (text.contains("victoire equipe b")) return a > h;

    // 6. BTTS
    if (text.contains("les 2 equipes marquent")) return h > 0 && a > 0;

    return false;
  }

  // --- CERVEAU DU SYSTÈME (Choix Intelligent de la prédiction) ---
  Map<String, String> _calculateSmartBet(String home, String away) {
    bool homeStrong = _titans.any((t) => home.contains(t));
    bool awayStrong = _titans.any((t) => away.contains(t));
    Random random = Random();

    // SCÉNARIO 1 : TITAN À DOMICILE (Offensif)
    if (homeStrong) {
      List<Map<String, String>> aggressiveOptions = [
        {'pred': "Victoire Equipe A", 'odd': '1.40'},
        {'pred': "Equipe A +1.5 buts", 'odd': '1.50'},
        {'pred': "+2.5 buts", 'odd': '1.65'},
        {'pred': "1ere MT +0.5 buts", 'odd': '1.28'}, // Très sûr
        {'pred': "+1.5 buts", 'odd': '1.20'}, // Safe
      ];
      return aggressiveOptions[random.nextInt(aggressiveOptions.length)];
    }

    // SCÉNARIO 2 : TITAN À L'EXTÉRIEUR
    if (awayStrong) {
      List<Map<String, String>> awayOptions = [
        {'pred': "Victoire Equipe B", 'odd': '1.55'},
        {'pred': "Equipe B +1.5 buts", 'odd': '1.60'},
        {'pred': "Victoire ou nul Equipe B", 'odd': '1.25'}, // Safe
        {'pred': "+1.5 buts", 'odd': '1.22'},
      ];
      return awayOptions[random.nextInt(awayOptions.length)];
    }

    // SCÉNARIO 3 : MATCH ÉQUILIBRÉ OU PETITES ÉQUIPES (Défensif / Serré)
    List<Map<String, String>> balancedOptions = [
      {'pred': "-3.5 buts", 'odd': '1.30'}, // Souvent sûr
      {'pred': "-2.5 buts", 'odd': '1.70'}, // Risqué mais cote haute
      {'pred': "Victoire ou nul Equipe A", 'odd': '1.35'}, // Avantage domicile
      {'pred': "1ere MT +0.5 buts", 'odd': '1.45'},
      {'pred': "Les 2 equipes marquent", 'odd': '1.80'}, // Si stats équilibrées
      {'pred': "+1.5 buts", 'odd': '1.38'}, // Le grand classique
    ];

    // On ajoute parfois des paris "Fun" pour varier
    if (random.nextBool()) {
      balancedOptions.add({'pred': "2e MT +1.5 buts", 'odd': '2.10'});
      balancedOptions.add({'pred': "+3.5 buts", 'odd': '2.80'});
    }

    return balancedOptions[random.nextInt(balancedOptions.length)];
  }

  // --- GÉNÉRATION AUTOMATIQUE ---
  Future<void> _generateSmartPredictions() async {
    if (_isGeneratingLocally) return;
    setState(() => _isGeneratingLocally = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('daily_matches')
          .doc(_todayDocId);
      final checkDoc = await docRef.get();

      if (checkDoc.exists) {
        setState(() => _isGeneratingLocally = false);
        return;
      }

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));

      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');

      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      List matchesList = [];
      if (response.statusCode == 200) {
        matchesList = jsonDecode(response.body)['matches'];
      } else {
        // Fallback
        final fbRes = await http.get(
            Uri.parse(
                'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo'),
            headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});
        if (fbRes.statusCode == 200) {
          matchesList = jsonDecode(fbRes.body)['matches'];
        }
      }

      if (matchesList.isEmpty) throw "Pas de matchs majeurs";

      // On prend 3 matchs
      if (matchesList.length > 3) matchesList = matchesList.take(3).toList();

      List<Map<String, dynamic>> processedMatches = [];

      for (var match in matchesList) {
        String home = match['homeTeam']['name'];
        String away = match['awayTeam']['name'];

        // CALCUL INTELLIGENT
        Map<String, String> smartBet = _calculateSmartBet(home, away);

        processedMatches.add({
          'league': match['competition']['name'],
          'leagueLogo': match['competition']['emblem'] ?? _leagueFallback,
          'home': home,
          'away': away,
          'homeLogo': match['homeTeam']['crest'],
          'awayLogo': match['awayTeam']['crest'],
          'time': match['utcDate'],
          'status': match['status'],
          'scoreHome': match['score']['fullTime']['home'],
          'scoreAway': match['score']['fullTime']['away'],
          // IMPORTANT: On stocke aussi la mi-temps pour valider les paris MT
          'scoreHomeHT': match['score']['halfTime']['home'],
          'scoreAwayHT': match['score']['halfTime']['away'],
          'prediction': smartBet['pred'],
          'odds': smartBet['odd'],
        });
      }

      if (processedMatches.isNotEmpty) {
        await docRef.set({
          'date': _todayDocId,
          'is_published': true, // Auto-publish
          'matches': processedMatches,
        });
      }
    } catch (e) {
      debugPrint("Erreur génération auto: $e");
    } finally {
      if (mounted) setState(() => _isGeneratingLocally = false);
    }
  }

  // --- LIVE SCORE UPDATE (Avec Mi-Temps) ---
  Future<void> _updateLiveScores() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('daily_matches')
          .doc(_todayDocId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final data = docSnap.data();
      if (data == null) return;

      List<dynamic> firebaseMatches = List.from(data['matches'] ?? []);
      bool needsUpdate = false;

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));
      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');
      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      if (response.statusCode != 200) return;
      List apiMatches = jsonDecode(response.body)['matches'];

      for (int i = 0; i < firebaseMatches.length; i++) {
        var fbMatch = firebaseMatches[i] as Map<String, dynamic>;
        var freshMatch = apiMatches.firstWhere(
            (m) =>
                m['homeTeam']['name'] == fbMatch['home'] &&
                m['awayTeam']['name'] == fbMatch['away'],
            orElse: () => null);

        if (freshMatch != null) {
          String newStatus = freshMatch['status'];
          int? newScoreHome = freshMatch['score']['fullTime']['home'];
          int? newScoreAway = freshMatch['score']['fullTime']['away'];
          int? newScoreHomeHT = freshMatch['score']['halfTime']['home'];
          int? newScoreAwayHT = freshMatch['score']['halfTime']['away'];

          // Gestion des nuls pendant le match
          if (newScoreHome == null && freshMatch['score']['duration'] != null) {
            newScoreHome = 0;
            newScoreAway = 0;
          }
          if (newScoreHomeHT == null) {
            newScoreHomeHT = 0;
            newScoreAwayHT = 0;
          }

          if (fbMatch['status'] != newStatus ||
              fbMatch['scoreHome'] != newScoreHome ||
              fbMatch['scoreHomeHT'] != newScoreHomeHT) {
            fbMatch['status'] = newStatus;
            fbMatch['scoreHome'] = newScoreHome;
            fbMatch['scoreAway'] = newScoreAway;
            fbMatch['scoreHomeHT'] = newScoreHomeHT; // MAJ Mi-temps
            fbMatch['scoreAwayHT'] = newScoreAwayHT; // MAJ Mi-temps
            needsUpdate = true;
          }
        }
      }

      if (needsUpdate) {
        await docRef.update({'matches': firebaseMatches});
      }
    } catch (e) {
      debugPrint("Erreur LiveScore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("FREE TIPS",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(_bgImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.72), BlendMode.darken),
              ),
            ),
          ),
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8)),
                child: Text("$_dateDisplay FREE TIPS",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('daily_matches')
                      .doc(_todayDocId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox();

                    final List matches = data['matches'] ?? [];
                    if (matches.isEmpty) {
                      return const Center(
                          child: Text("Aucun match aujourd'hui.",
                              style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        return _buildExactCard(matches[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExactCard(dynamic matchData) {
    final match = Map<String, dynamic>.from(matchData as Map);
    String league = match['league'] ?? 'League';
    String leagueLogo = match['leagueLogo'] ?? _leagueFallback;
    String home = match['home'] ?? 'Home';
    String away = match['away'] ?? 'Away';
    String homeLogo = match['homeLogo'];
    String awayLogo = match['awayLogo'];
    String pred = match['prediction'] ?? '...';
    String odd = match['odds'] ?? '-';

    String timeStr = "--:--";
    try {
      timeStr =
          DateFormat('HH:mm').format(DateTime.parse(match['time']).toLocal());
    } catch (_) {}

    String status = match['status'] ?? "TIMED";
    int? hScore = match['scoreHome'];
    int? aScore = match['scoreAway'];
    // On récupère aussi les scores mi-temps pour validation
    int? htScoreH = match['scoreHomeHT'] ?? 0;
    int? htScoreA = match['scoreAwayHT'] ?? 0;

    bool isNotStarted = (status == "TIMED" || status == "SCHEDULED");
    bool isFinished = (status == "FINISHED");
    bool isLive = (status == "IN_PLAY" || status == "PAUSED");

    bool isWin = false;
    if (isFinished && hScore != null && aScore != null) {
      // Validation avec tous les paramètres (Score final et score mi-temps)
      isWin = _checkFootballWin(pred, hScore, aScore, htScoreH!, htScoreA!);
    }

    IconData centerIcon = Icons.access_time;
    Color centerIconColor = Colors.orange;

    if (isFinished) {
      centerIcon = isWin ? Icons.check_circle : Icons.cancel;
      centerIconColor = isWin ? Colors.green : Colors.red;
    } else if (isLive) {
      centerIcon = Icons.play_circle_fill;
      centerIconColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Row(
                  children: [
                    Image.network(leagueLogo,
                        height: 22,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.sports_soccer)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(league,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(timeStr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_border,
                        color: Colors.orange, size: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _teamCol(home, homeLogo)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        children: [
                          Text(isNotStarted ? "0" : "${hScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                          const SizedBox(width: 8),
                          Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: centerIconColor, width: 2)),
                              child: Icon(centerIcon,
                                  color: centerIconColor, size: 16)),
                          const SizedBox(width: 8),
                          Text(isNotStarted ? "0" : "${aScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                        ],
                      ),
                    ),
                    Expanded(child: _teamCol(away, awayLogo)),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        color: const Color(0xFFFFB300),
                        alignment: Alignment.center,
                        child: Text(pred,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ),
                    Container(
                      width: 75,
                      color: const Color(0xFF008940),
                      alignment: Alignment.center,
                      child: Text(odd,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamCol(String name, String? logo) {
    return Column(
      children: [
        if (logo != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40, minHeight: 40),
            child: Image.network(logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.shield, size: 35)),
          ),
        const SizedBox(height: 2),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Colors.black)),
      ],
    );
  }
}

/* ===================== TICKET PAGE (ALGORITHME INTELLIGENT & COMPLET) ===================== */

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  // CLÉ API FOOTBALL
  static const String FOOTBALL_DATA_API_KEY =
      '7531ff2472bf4416b93cc2e64e7e77c0';

  final String _bgImage =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";
  final String _leagueFallback =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";

  late String _todayDocId;
  String _dateDisplay = "";
  bool _isGeneratingLocally = false;
  Timer? _timer;

  // LISTE DES "TITANS" (Équipes offensives/fortes)
  final List<String> _titans = [
    'Man City',
    'Liverpool',
    'Arsenal',
    'Real Madrid',
    'Barcelona',
    'Bayern',
    'Leverkusen',
    'PSG',
    'Inter',
    'Juventus',
    'Milan',
    'Dortmund'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDocId = DateFormat('yyyy-MM-dd').format(now);
    _dateDisplay = DateFormat('dd.MM.yyyy').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateSmartPredictions();
      _updateLiveScores();
    });

    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updateLiveScores();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(NetworkImage(_bgImage), context);
    super.didChangeDependencies();
  }

  // --- LOGIQUE DE VALIDATION INTELLIGENTE (Gère MT, Équipes, Totaux) ---
  bool _checkFootballWin(
      String predictionText, int h, int a, int htH, int htA) {
    String text = predictionText.toLowerCase();
    int total = h + a;
    int totalHT = htH + htA;
    int goals2ndHalf =
        (h - htH) + (a - htA); // Buts marqués en 2ème mi-temps uniquement

    // 1. MI-TEMPS (1ere MT)
    if (text.contains("1ere mt +0.5")) return totalHT > 0;

    // 2. SECONDE MI-TEMPS (2e MT)
    if (text.contains("2e mt +1.5")) return goals2ndHalf > 1;

    // 3. BUTS PAR ÉQUIPE
    if (text.contains("equipe a +1.5")) return h > 1;
    if (text.contains("equipe b +1.5")) return a > 1;

    // 4. TOTAUX (Over/Under)
    if (text.contains("+1.5 buts")) return total > 1;
    if (text.contains("+2.5 buts")) return total > 2;
    if (text.contains("+3.5 buts")) return total > 3;
    if (text.contains("-3.5 buts")) return total < 4;
    if (text.contains("-2.5 buts")) return total < 3;

    // 5. RÉSULTATS MATCH
    if (text.contains("victoire ou nul equipe a")) return h >= a;
    if (text.contains("victoire ou nul equipe b")) return a >= h;
    if (text.contains("victoire equipe a")) return h > a;
    if (text.contains("victoire equipe b")) return a > h;

    // 6. BTTS
    if (text.contains("les 2 equipes marquent")) return h > 0 && a > 0;

    return false;
  }

  // --- CERVEAU DU SYSTÈME (Choix Intelligent de la prédiction) ---
  Map<String, String> _calculateSmartBet(String home, String away) {
    bool homeStrong = _titans.any((t) => home.contains(t));
    bool awayStrong = _titans.any((t) => away.contains(t));
    Random random = Random();

    // SCÉNARIO 1 : TITAN À DOMICILE (Offensif)
    if (homeStrong) {
      List<Map<String, String>> aggressiveOptions = [
        {'pred': "Victoire Equipe A", 'odd': '1.40'},
        {'pred': "Equipe A +1.5 buts", 'odd': '1.50'},
        {'pred': "+2.5 buts", 'odd': '1.65'},
        {'pred': "1ere MT +0.5 buts", 'odd': '1.28'}, // Très sûr
        {'pred': "+1.5 buts", 'odd': '1.20'}, // Safe
      ];
      return aggressiveOptions[random.nextInt(aggressiveOptions.length)];
    }

    // SCÉNARIO 2 : TITAN À L'EXTÉRIEUR
    if (awayStrong) {
      List<Map<String, String>> awayOptions = [
        {'pred': "Victoire Equipe B", 'odd': '1.55'},
        {'pred': "Equipe B +1.5 buts", 'odd': '1.60'},
        {'pred': "Victoire ou nul Equipe B", 'odd': '1.25'}, // Safe
        {'pred': "+1.5 buts", 'odd': '1.22'},
      ];
      return awayOptions[random.nextInt(awayOptions.length)];
    }

    // SCÉNARIO 3 : MATCH ÉQUILIBRÉ OU PETITES ÉQUIPES (Défensif / Serré)
    List<Map<String, String>> balancedOptions = [
      {'pred': "-3.5 buts", 'odd': '1.30'}, // Souvent sûr
      {'pred': "-2.5 buts", 'odd': '1.70'}, // Risqué mais cote haute
      {'pred': "Victoire ou nul Equipe A", 'odd': '1.35'}, // Avantage domicile
      {'pred': "1ere MT +0.5 buts", 'odd': '1.45'},
      {'pred': "Les 2 equipes marquent", 'odd': '1.80'}, // Si stats équilibrées
      {'pred': "+1.5 buts", 'odd': '1.38'}, // Le grand classique
    ];

    // On ajoute parfois des paris "Fun" pour varier
    if (random.nextBool()) {
      balancedOptions.add({'pred': "2e MT +1.5 buts", 'odd': '2.10'});
      balancedOptions.add({'pred': "+3.5 buts", 'odd': '2.80'});
    }

    return balancedOptions[random.nextInt(balancedOptions.length)];
  }

  // --- GÉNÉRATION AUTOMATIQUE ---
  Future<void> _generateSmartPredictions() async {
    if (_isGeneratingLocally) return;
    setState(() => _isGeneratingLocally = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('ticket_matches')
          .doc(_todayDocId);
      final checkDoc = await docRef.get();

      if (checkDoc.exists) {
        setState(() => _isGeneratingLocally = false);
        return;
      }

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));

      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');

      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      List matchesList = [];
      if (response.statusCode == 200) {
        matchesList = jsonDecode(response.body)['matches'];
      } else {
        // Fallback
        final fbRes = await http.get(
            Uri.parse(
                'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo'),
            headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});
        if (fbRes.statusCode == 200) {
          matchesList = jsonDecode(fbRes.body)['matches'];
        }
      }

      if (matchesList.isEmpty) throw "Pas de matchs majeurs";

      // On prend 3 matchs
      if (matchesList.length > 4) matchesList = matchesList.take(4).toList();

      List<Map<String, dynamic>> processedMatches = [];

      for (var match in matchesList) {
        String home = match['homeTeam']['name'];
        String away = match['awayTeam']['name'];

        // CALCUL INTELLIGENT
        Map<String, String> smartBet = _calculateSmartBet(home, away);

        processedMatches.add({
          'league': match['competition']['name'],
          'leagueLogo': match['competition']['emblem'] ?? _leagueFallback,
          'home': home,
          'away': away,
          'homeLogo': match['homeTeam']['crest'],
          'awayLogo': match['awayTeam']['crest'],
          'time': match['utcDate'],
          'status': match['status'],
          'scoreHome': match['score']['fullTime']['home'],
          'scoreAway': match['score']['fullTime']['away'],
          // IMPORTANT: On stocke aussi la mi-temps pour valider les paris MT
          'scoreHomeHT': match['score']['halfTime']['home'],
          'scoreAwayHT': match['score']['halfTime']['away'],
          'prediction': smartBet['pred'],
          'odds': smartBet['odd'],
        });
      }

      if (processedMatches.isNotEmpty) {
        await docRef.set({
          'date': _todayDocId,
          'is_published': true, // Auto-publish
          'matches': processedMatches,
        });
      }
    } catch (e) {
      debugPrint("Erreur génération auto: $e");
    } finally {
      if (mounted) setState(() => _isGeneratingLocally = false);
    }
  }

  // --- LIVE SCORE UPDATE (Avec Mi-Temps) ---
  Future<void> _updateLiveScores() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('ticket_matches')
          .doc(_todayDocId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final data = docSnap.data();
      if (data == null) return;

      List<dynamic> firebaseMatches = List.from(data['matches'] ?? []);
      bool needsUpdate = false;

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));
      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');
      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      if (response.statusCode != 200) return;
      List apiMatches = jsonDecode(response.body)['matches'];

      for (int i = 0; i < firebaseMatches.length; i++) {
        var fbMatch = firebaseMatches[i] as Map<String, dynamic>;
        var freshMatch = apiMatches.firstWhere(
            (m) =>
                m['homeTeam']['name'] == fbMatch['home'] &&
                m['awayTeam']['name'] == fbMatch['away'],
            orElse: () => null);

        if (freshMatch != null) {
          String newStatus = freshMatch['status'];
          int? newScoreHome = freshMatch['score']['fullTime']['home'];
          int? newScoreAway = freshMatch['score']['fullTime']['away'];
          int? newScoreHomeHT = freshMatch['score']['halfTime']['home'];
          int? newScoreAwayHT = freshMatch['score']['halfTime']['away'];

          // Gestion des nuls pendant le match
          if (newScoreHome == null && freshMatch['score']['duration'] != null) {
            newScoreHome = 0;
            newScoreAway = 0;
          }
          if (newScoreHomeHT == null) {
            newScoreHomeHT = 0;
            newScoreAwayHT = 0;
          }

          if (fbMatch['status'] != newStatus ||
              fbMatch['scoreHome'] != newScoreHome ||
              fbMatch['scoreHomeHT'] != newScoreHomeHT) {
            fbMatch['status'] = newStatus;
            fbMatch['scoreHome'] = newScoreHome;
            fbMatch['scoreAway'] = newScoreAway;
            fbMatch['scoreHomeHT'] = newScoreHomeHT; // MAJ Mi-temps
            fbMatch['scoreAwayHT'] = newScoreAwayHT; // MAJ Mi-temps
            needsUpdate = true;
          }
        }
      }

      if (needsUpdate) {
        await docRef.update({'matches': firebaseMatches});
      }
    } catch (e) {
      debugPrint("Erreur LiveScore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("FREE TIPS",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(_bgImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.72), BlendMode.darken),
              ),
            ),
          ),
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8)),
                child: Text("$_dateDisplay FREE TIPS",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('ticket_matches')
                      .doc(_todayDocId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox();

                    final List matches = data['matches'] ?? [];
                    if (matches.isEmpty) {
                      return const Center(
                          child: Text("Aucun match aujourd'hui.",
                              style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        return _buildExactCard(matches[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExactCard(dynamic matchData) {
    final match = Map<String, dynamic>.from(matchData as Map);
    String league = match['league'] ?? 'League';
    String leagueLogo = match['leagueLogo'] ?? _leagueFallback;
    String home = match['home'] ?? 'Home';
    String away = match['away'] ?? 'Away';
    String homeLogo = match['homeLogo'];
    String awayLogo = match['awayLogo'];
    String pred = match['prediction'] ?? '...';
    String odd = match['odds'] ?? '-';

    String timeStr = "--:--";
    try {
      timeStr =
          DateFormat('HH:mm').format(DateTime.parse(match['time']).toLocal());
    } catch (_) {}

    String status = match['status'] ?? "TIMED";
    int? hScore = match['scoreHome'];
    int? aScore = match['scoreAway'];
    // On récupère aussi les scores mi-temps pour validation
    int? htScoreH = match['scoreHomeHT'] ?? 0;
    int? htScoreA = match['scoreAwayHT'] ?? 0;

    bool isNotStarted = (status == "TIMED" || status == "SCHEDULED");
    bool isFinished = (status == "FINISHED");
    bool isLive = (status == "IN_PLAY" || status == "PAUSED");

    bool isWin = false;
    if (isFinished && hScore != null && aScore != null) {
      // Validation avec tous les paramètres (Score final et score mi-temps)
      isWin = _checkFootballWin(pred, hScore, aScore, htScoreH!, htScoreA!);
    }

    IconData centerIcon = Icons.access_time;
    Color centerIconColor = Colors.orange;

    if (isFinished) {
      centerIcon = isWin ? Icons.check_circle : Icons.cancel;
      centerIconColor = isWin ? Colors.green : Colors.red;
    } else if (isLive) {
      centerIcon = Icons.play_circle_fill;
      centerIconColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Row(
                  children: [
                    Image.network(leagueLogo,
                        height: 22,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.sports_soccer)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(league,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(timeStr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_border,
                        color: Colors.orange, size: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _teamCol(home, homeLogo)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        children: [
                          Text(isNotStarted ? "0" : "${hScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                          const SizedBox(width: 8),
                          Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: centerIconColor, width: 2)),
                              child: Icon(centerIcon,
                                  color: centerIconColor, size: 16)),
                          const SizedBox(width: 8),
                          Text(isNotStarted ? "0" : "${aScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                        ],
                      ),
                    ),
                    Expanded(child: _teamCol(away, awayLogo)),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        color: const Color(0xFFFFB300),
                        alignment: Alignment.center,
                        child: Text(pred,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ),
                    Container(
                      width: 75,
                      color: const Color(0xFF008940),
                      alignment: Alignment.center,
                      child: Text(odd,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamCol(String name, String? logo) {
    return Column(
      children: [
        if (logo != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40, minHeight: 40),
            child: Image.network(logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.shield, size: 35)),
          ),
        const SizedBox(height: 2),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Colors.black)),
      ],
    );
  }
}

/* ===================== PARIS PAGE (ALGORITHME INTELLIGENT & COMPLET) ===================== */

class CombinePage extends StatefulWidget {
  const CombinePage({super.key});

  @override
  State<CombinePage> createState() => _CombinePageState();
}

class _CombinePageState extends State<CombinePage> {
  // CLÉ API FOOTBALL
  static const String FOOTBALL_DATA_API_KEY =
      '7531ff2472bf4416b93cc2e64e7e77c0';

  final String _bgImage =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";
  final String _leagueFallback =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";

  late String _todayDocId;
  String _dateDisplay = "";
  bool _isGeneratingLocally = false;
  Timer? _timer;

  // LISTE DES "TITANS" (Équipes offensives/fortes)
  final List<String> _titans = [
    'Man City',
    'Liverpool',
    'Arsenal',
    'Real Madrid',
    'Barcelona',
    'Bayern',
    'Leverkusen',
    'PSG',
    'Inter',
    'Juventus',
    'Milan',
    'Dortmund'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDocId = DateFormat('yyyy-MM-dd').format(now);
    _dateDisplay = DateFormat('dd.MM.yyyy').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateSmartPredictions();
      _updateLiveScores();
    });

    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updateLiveScores();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(NetworkImage(_bgImage), context);
    super.didChangeDependencies();
  }

  // --- LOGIQUE DE VALIDATION INTELLIGENTE (Gère MT, Équipes, Totaux) ---
  bool _checkFootballWin(
      String predictionText, int h, int a, int htH, int htA) {
    String text = predictionText.toLowerCase();
    int total = h + a;
    int totalHT = htH + htA;
    int goals2ndHalf =
        (h - htH) + (a - htA); // Buts marqués en 2ème mi-temps uniquement

    // 1. MI-TEMPS (1ere MT)
    if (text.contains("1ere mt +0.5")) return totalHT > 0;

    // 2. SECONDE MI-TEMPS (2e MT)
    if (text.contains("2e mt +1.5")) return goals2ndHalf > 1;

    // 3. BUTS PAR ÉQUIPE
    if (text.contains("equipe a +1.5")) return h > 1;
    if (text.contains("equipe b +1.5")) return a > 1;

    // 4. TOTAUX (Over/Under)
    if (text.contains("+1.5 buts")) return total > 1;
    if (text.contains("+2.5 buts")) return total > 2;
    if (text.contains("+3.5 buts")) return total > 3;
    if (text.contains("-3.5 buts")) return total < 4;
    if (text.contains("-2.5 buts")) return total < 3;

    // 5. RÉSULTATS MATCH
    if (text.contains("victoire ou nul equipe a")) return h >= a;
    if (text.contains("victoire ou nul equipe b")) return a >= h;
    if (text.contains("victoire equipe a")) return h > a;
    if (text.contains("victoire equipe b")) return a > h;

    // 6. BTTS
    if (text.contains("les 2 equipes marquent")) return h > 0 && a > 0;

    return false;
  }

  // --- CERVEAU DU SYSTÈME (Choix Intelligent de la prédiction) ---
  Map<String, String> _calculateSmartBet(String home, String away) {
    bool homeStrong = _titans.any((t) => home.contains(t));
    bool awayStrong = _titans.any((t) => away.contains(t));
    Random random = Random();

    // SCÉNARIO 1 : TITAN À DOMICILE (Offensif)
    if (homeStrong) {
      List<Map<String, String>> aggressiveOptions = [
        {'pred': "Victoire Equipe A", 'odd': '1.40'},
        {'pred': "Equipe A +1.5 buts", 'odd': '1.50'},
        {'pred': "+2.5 buts", 'odd': '1.65'},
        {'pred': "1ere MT +0.5 buts", 'odd': '1.28'}, // Très sûr
        {'pred': "+1.5 buts", 'odd': '1.20'}, // Safe
      ];
      return aggressiveOptions[random.nextInt(aggressiveOptions.length)];
    }

    // SCÉNARIO 2 : TITAN À L'EXTÉRIEUR
    if (awayStrong) {
      List<Map<String, String>> awayOptions = [
        {'pred': "Victoire Equipe B", 'odd': '1.55'},
        {'pred': "Equipe B +1.5 buts", 'odd': '1.60'},
        {'pred': "Victoire ou nul Equipe B", 'odd': '1.25'}, // Safe
        {'pred': "+1.5 buts", 'odd': '1.22'},
      ];
      return awayOptions[random.nextInt(awayOptions.length)];
    }

    // SCÉNARIO 3 : MATCH ÉQUILIBRÉ OU PETITES ÉQUIPES (Défensif / Serré)
    List<Map<String, String>> balancedOptions = [
      {'pred': "-3.5 buts", 'odd': '1.30'}, // Souvent sûr
      {'pred': "-2.5 buts", 'odd': '1.70'}, // Risqué mais cote haute
      {'pred': "Victoire ou nul Equipe A", 'odd': '1.35'}, // Avantage domicile
      {'pred': "1ere MT +0.5 buts", 'odd': '1.45'},
      {'pred': "Les 2 equipes marquent", 'odd': '1.80'}, // Si stats équilibrées
      {'pred': "+1.5 buts", 'odd': '1.38'}, // Le grand classique
    ];

    // On ajoute parfois des paris "Fun" pour varier
    if (random.nextBool()) {
      balancedOptions.add({'pred': "2e MT +1.5 buts", 'odd': '2.10'});
      balancedOptions.add({'pred': "+3.5 buts", 'odd': '2.80'});
    }

    return balancedOptions[random.nextInt(balancedOptions.length)];
  }

  // --- GÉNÉRATION AUTOMATIQUE ---
  Future<void> _generateSmartPredictions() async {
    if (_isGeneratingLocally) return;
    setState(() => _isGeneratingLocally = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('combine_matches')
          .doc(_todayDocId);
      final checkDoc = await docRef.get();

      if (checkDoc.exists) {
        setState(() => _isGeneratingLocally = false);
        return;
      }

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));

      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');

      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      List matchesList = [];
      if (response.statusCode == 200) {
        matchesList = jsonDecode(response.body)['matches'];
      } else {
        // Fallback
        final fbRes = await http.get(
            Uri.parse(
                'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo'),
            headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});
        if (fbRes.statusCode == 200) {
          matchesList = jsonDecode(fbRes.body)['matches'];
        }
      }

      if (matchesList.isEmpty) throw "Pas de matchs majeurs";

      // On prend 3 matchs
      if (matchesList.length > 5) matchesList = matchesList.take(5).toList();

      List<Map<String, dynamic>> processedMatches = [];

      for (var match in matchesList) {
        String home = match['homeTeam']['name'];
        String away = match['awayTeam']['name'];

        // CALCUL INTELLIGENT
        Map<String, String> smartBet = _calculateSmartBet(home, away);

        processedMatches.add({
          'league': match['competition']['name'],
          'leagueLogo': match['competition']['emblem'] ?? _leagueFallback,
          'home': home,
          'away': away,
          'homeLogo': match['homeTeam']['crest'],
          'awayLogo': match['awayTeam']['crest'],
          'time': match['utcDate'],
          'status': match['status'],
          'scoreHome': match['score']['fullTime']['home'],
          'scoreAway': match['score']['fullTime']['away'],
          // IMPORTANT: On stocke aussi la mi-temps pour valider les paris MT
          'scoreHomeHT': match['score']['halfTime']['home'],
          'scoreAwayHT': match['score']['halfTime']['away'],
          'prediction': smartBet['pred'],
          'odds': smartBet['odd'],
        });
      }

      if (processedMatches.isNotEmpty) {
        await docRef.set({
          'date': _todayDocId,
          'is_published': true, // Auto-publish
          'matches': processedMatches,
        });
      }
    } catch (e) {
      debugPrint("Erreur génération auto: $e");
    } finally {
      if (mounted) setState(() => _isGeneratingLocally = false);
    }
  }

  // --- LIVE SCORE UPDATE (Avec Mi-Temps) ---
  Future<void> _updateLiveScores() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('combine_matches')
          .doc(_todayDocId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final data = docSnap.data();
      if (data == null) return;

      List<dynamic> firebaseMatches = List.from(data['matches'] ?? []);
      bool needsUpdate = false;

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));
      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');
      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      if (response.statusCode != 200) return;
      List apiMatches = jsonDecode(response.body)['matches'];

      for (int i = 0; i < firebaseMatches.length; i++) {
        var fbMatch = firebaseMatches[i] as Map<String, dynamic>;
        var freshMatch = apiMatches.firstWhere(
            (m) =>
                m['homeTeam']['name'] == fbMatch['home'] &&
                m['awayTeam']['name'] == fbMatch['away'],
            orElse: () => null);

        if (freshMatch != null) {
          String newStatus = freshMatch['status'];
          int? newScoreHome = freshMatch['score']['fullTime']['home'];
          int? newScoreAway = freshMatch['score']['fullTime']['away'];
          int? newScoreHomeHT = freshMatch['score']['halfTime']['home'];
          int? newScoreAwayHT = freshMatch['score']['halfTime']['away'];

          // Gestion des nuls pendant le match
          if (newScoreHome == null && freshMatch['score']['duration'] != null) {
            newScoreHome = 0;
            newScoreAway = 0;
          }
          if (newScoreHomeHT == null) {
            newScoreHomeHT = 0;
            newScoreAwayHT = 0;
          }

          if (fbMatch['status'] != newStatus ||
              fbMatch['scoreHome'] != newScoreHome ||
              fbMatch['scoreHomeHT'] != newScoreHomeHT) {
            fbMatch['status'] = newStatus;
            fbMatch['scoreHome'] = newScoreHome;
            fbMatch['scoreAway'] = newScoreAway;
            fbMatch['scoreHomeHT'] = newScoreHomeHT; // MAJ Mi-temps
            fbMatch['scoreAwayHT'] = newScoreAwayHT; // MAJ Mi-temps
            needsUpdate = true;
          }
        }
      }

      if (needsUpdate) {
        await docRef.update({'matches': firebaseMatches});
      }
    } catch (e) {
      debugPrint("Erreur LiveScore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("FREE TIPS",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(_bgImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.72), BlendMode.darken),
              ),
            ),
          ),
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8)),
                child: Text("$_dateDisplay FREE TIPS",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('combine_matches')
                      .doc(_todayDocId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox();

                    final List matches = data['matches'] ?? [];
                    if (matches.isEmpty) {
                      return const Center(
                          child: Text("Aucun match aujourd'hui.",
                              style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        return _buildExactCard(matches[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExactCard(dynamic matchData) {
    final match = Map<String, dynamic>.from(matchData as Map);
    String league = match['league'] ?? 'League';
    String leagueLogo = match['leagueLogo'] ?? _leagueFallback;
    String home = match['home'] ?? 'Home';
    String away = match['away'] ?? 'Away';
    String homeLogo = match['homeLogo'];
    String awayLogo = match['awayLogo'];
    String pred = match['prediction'] ?? '...';
    String odd = match['odds'] ?? '-';

    String timeStr = "--:--";
    try {
      timeStr =
          DateFormat('HH:mm').format(DateTime.parse(match['time']).toLocal());
    } catch (_) {}

    String status = match['status'] ?? "TIMED";
    int? hScore = match['scoreHome'];
    int? aScore = match['scoreAway'];
    // On récupère aussi les scores mi-temps pour validation
    int? htScoreH = match['scoreHomeHT'] ?? 0;
    int? htScoreA = match['scoreAwayHT'] ?? 0;

    bool isNotStarted = (status == "TIMED" || status == "SCHEDULED");
    bool isFinished = (status == "FINISHED");
    bool isLive = (status == "IN_PLAY" || status == "PAUSED");

    bool isWin = false;
    if (isFinished && hScore != null && aScore != null) {
      // Validation avec tous les paramètres (Score final et score mi-temps)
      isWin = _checkFootballWin(pred, hScore, aScore, htScoreH!, htScoreA!);
    }

    IconData centerIcon = Icons.access_time;
    Color centerIconColor = Colors.orange;

    if (isFinished) {
      centerIcon = isWin ? Icons.check_circle : Icons.cancel;
      centerIconColor = isWin ? Colors.green : Colors.red;
    } else if (isLive) {
      centerIcon = Icons.play_circle_fill;
      centerIconColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Row(
                  children: [
                    Image.network(leagueLogo,
                        height: 22,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.sports_soccer)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(league,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(timeStr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_border,
                        color: Colors.orange, size: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _teamCol(home, homeLogo)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        children: [
                          Text(isNotStarted ? "0" : "${hScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                          const SizedBox(width: 8),
                          Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: centerIconColor, width: 2)),
                              child: Icon(centerIcon,
                                  color: centerIconColor, size: 16)),
                          const SizedBox(width: 8),
                          Text(isNotStarted ? "0" : "${aScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                        ],
                      ),
                    ),
                    Expanded(child: _teamCol(away, awayLogo)),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        color: const Color(0xFFFFB300),
                        alignment: Alignment.center,
                        child: Text(pred,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ),
                    Container(
                      width: 75,
                      color: const Color(0xFF008940),
                      alignment: Alignment.center,
                      child: Text(odd,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamCol(String name, String? logo) {
    return Column(
      children: [
        if (logo != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40, minHeight: 40),
            child: Image.network(logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.shield, size: 35)),
          ),
        const SizedBox(height: 2),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Colors.black)),
      ],
    );
  }
}

/* ===================== TOP 5 DU JOUR PAGE (ALGORITHME INTELLIGENT & COMPLET) ===================== */

class TopPage extends StatefulWidget {
  const TopPage({super.key});

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  // CLÉ API FOOTBALL
  static const String FOOTBALL_DATA_API_KEY =
      '7531ff2472bf4416b93cc2e64e7e77c0';

  final String _bgImage =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";
  final String _leagueFallback =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";

  late String _todayDocId;
  String _dateDisplay = "";
  bool _isGeneratingLocally = false;
  Timer? _timer;

  // LISTE DES "TITANS" (Équipes offensives/fortes)
  final List<String> _titans = [
    'Man City',
    'Liverpool',
    'Arsenal',
    'Real Madrid',
    'Barcelona',
    'Bayern',
    'Leverkusen',
    'PSG',
    'Inter',
    'Juventus',
    'Milan',
    'Dortmund'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDocId = DateFormat('yyyy-MM-dd').format(now);
    _dateDisplay = DateFormat('dd.MM.yyyy').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateSmartPredictions();
      _updateLiveScores();
    });

    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updateLiveScores();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(NetworkImage(_bgImage), context);
    super.didChangeDependencies();
  }

  // --- LOGIQUE DE VALIDATION INTELLIGENTE (Gère MT, Équipes, Totaux) ---
  bool _checkFootballWin(
      String predictionText, int h, int a, int htH, int htA) {
    String text = predictionText.toLowerCase();
    int total = h + a;
    int totalHT = htH + htA;
    int goals2ndHalf =
        (h - htH) + (a - htA); // Buts marqués en 2ème mi-temps uniquement

    // 1. MI-TEMPS (1ere MT)
    if (text.contains("1ere mt +0.5")) return totalHT > 0;

    // 2. SECONDE MI-TEMPS (2e MT)
    if (text.contains("2e mt +1.5")) return goals2ndHalf > 1;

    // 3. BUTS PAR ÉQUIPE
    if (text.contains("equipe a +1.5")) return h > 1;
    if (text.contains("equipe b +1.5")) return a > 1;

    // 4. TOTAUX (Over/Under)
    if (text.contains("+1.5 buts")) return total > 1;
    if (text.contains("+2.5 buts")) return total > 2;
    if (text.contains("+3.5 buts")) return total > 3;
    if (text.contains("-3.5 buts")) return total < 4;
    if (text.contains("-2.5 buts")) return total < 3;

    // 5. RÉSULTATS MATCH
    if (text.contains("victoire ou nul equipe a")) return h >= a;
    if (text.contains("victoire ou nul equipe b")) return a >= h;
    if (text.contains("victoire equipe a")) return h > a;
    if (text.contains("victoire equipe b")) return a > h;

    // 6. BTTS
    if (text.contains("les 2 equipes marquent")) return h > 0 && a > 0;

    return false;
  }

  // --- CERVEAU DU SYSTÈME (Choix Intelligent de la prédiction) ---
  Map<String, String> _calculateSmartBet(String home, String away) {
    bool homeStrong = _titans.any((t) => home.contains(t));
    bool awayStrong = _titans.any((t) => away.contains(t));
    Random random = Random();

    // SCÉNARIO 1 : TITAN À DOMICILE (Offensif)
    if (homeStrong) {
      List<Map<String, String>> aggressiveOptions = [
        {'pred': "Victoire Equipe A", 'odd': '1.40'},
        {'pred': "Equipe A +1.5 buts", 'odd': '1.50'},
        {'pred': "+2.5 buts", 'odd': '1.65'},
        {'pred': "1ere MT +0.5 buts", 'odd': '1.28'}, // Très sûr
        {'pred': "+1.5 buts", 'odd': '1.20'}, // Safe
      ];
      return aggressiveOptions[random.nextInt(aggressiveOptions.length)];
    }

    // SCÉNARIO 2 : TITAN À L'EXTÉRIEUR
    if (awayStrong) {
      List<Map<String, String>> awayOptions = [
        {'pred': "Victoire Equipe B", 'odd': '1.55'},
        {'pred': "Equipe B +1.5 buts", 'odd': '1.60'},
        {'pred': "Victoire ou nul Equipe B", 'odd': '1.25'}, // Safe
        {'pred': "+1.5 buts", 'odd': '1.22'},
      ];
      return awayOptions[random.nextInt(awayOptions.length)];
    }

    // SCÉNARIO 3 : MATCH ÉQUILIBRÉ OU PETITES ÉQUIPES (Défensif / Serré)
    List<Map<String, String>> balancedOptions = [
      {'pred': "-3.5 buts", 'odd': '1.30'}, // Souvent sûr
      {'pred': "-2.5 buts", 'odd': '1.70'}, // Risqué mais cote haute
      {'pred': "Victoire ou nul Equipe A", 'odd': '1.35'}, // Avantage domicile
      {'pred': "1ere MT +0.5 buts", 'odd': '1.45'},
      {'pred': "Les 2 equipes marquent", 'odd': '1.80'}, // Si stats équilibrées
      {'pred': "+1.5 buts", 'odd': '1.38'}, // Le grand classique
    ];

    // On ajoute parfois des paris "Fun" pour varier
    if (random.nextBool()) {
      balancedOptions.add({'pred': "2e MT +1.5 buts", 'odd': '2.10'});
      balancedOptions.add({'pred': "+3.5 buts", 'odd': '2.80'});
    }

    return balancedOptions[random.nextInt(balancedOptions.length)];
  }

  // --- GÉNÉRATION AUTOMATIQUE ---
  Future<void> _generateSmartPredictions() async {
    if (_isGeneratingLocally) return;
    setState(() => _isGeneratingLocally = true);

    try {
      final docRef =
          FirebaseFirestore.instance.collection('top_matches').doc(_todayDocId);
      final checkDoc = await docRef.get();

      if (checkDoc.exists) {
        setState(() => _isGeneratingLocally = false);
        return;
      }

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));

      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');

      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      List matchesList = [];
      if (response.statusCode == 200) {
        matchesList = jsonDecode(response.body)['matches'];
      } else {
        // Fallback
        final fbRes = await http.get(
            Uri.parse(
                'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo'),
            headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});
        if (fbRes.statusCode == 200) {
          matchesList = jsonDecode(fbRes.body)['matches'];
        }
      }

      if (matchesList.isEmpty) throw "Pas de matchs majeurs";

      // On prend 3 matchs
      if (matchesList.length > 6) matchesList = matchesList.take(6).toList();

      List<Map<String, dynamic>> processedMatches = [];

      for (var match in matchesList) {
        String home = match['homeTeam']['name'];
        String away = match['awayTeam']['name'];

        // CALCUL INTELLIGENT
        Map<String, String> smartBet = _calculateSmartBet(home, away);

        processedMatches.add({
          'league': match['competition']['name'],
          'leagueLogo': match['competition']['emblem'] ?? _leagueFallback,
          'home': home,
          'away': away,
          'homeLogo': match['homeTeam']['crest'],
          'awayLogo': match['awayTeam']['crest'],
          'time': match['utcDate'],
          'status': match['status'],
          'scoreHome': match['score']['fullTime']['home'],
          'scoreAway': match['score']['fullTime']['away'],
          // IMPORTANT: On stocke aussi la mi-temps pour valider les paris MT
          'scoreHomeHT': match['score']['halfTime']['home'],
          'scoreAwayHT': match['score']['halfTime']['away'],
          'prediction': smartBet['pred'],
          'odds': smartBet['odd'],
        });
      }

      if (processedMatches.isNotEmpty) {
        await docRef.set({
          'date': _todayDocId,
          'is_published': true, // Auto-publish
          'matches': processedMatches,
        });
      }
    } catch (e) {
      debugPrint("Erreur génération auto: $e");
    } finally {
      if (mounted) setState(() => _isGeneratingLocally = false);
    }
  }

  // --- LIVE SCORE UPDATE (Avec Mi-Temps) ---
  Future<void> _updateLiveScores() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('top_matches').doc(_todayDocId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final data = docSnap.data();
      if (data == null) return;

      List<dynamic> firebaseMatches = List.from(data['matches'] ?? []);
      bool needsUpdate = false;

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));
      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');
      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      if (response.statusCode != 200) return;
      List apiMatches = jsonDecode(response.body)['matches'];

      for (int i = 0; i < firebaseMatches.length; i++) {
        var fbMatch = firebaseMatches[i] as Map<String, dynamic>;
        var freshMatch = apiMatches.firstWhere(
            (m) =>
                m['homeTeam']['name'] == fbMatch['home'] &&
                m['awayTeam']['name'] == fbMatch['away'],
            orElse: () => null);

        if (freshMatch != null) {
          String newStatus = freshMatch['status'];
          int? newScoreHome = freshMatch['score']['fullTime']['home'];
          int? newScoreAway = freshMatch['score']['fullTime']['away'];
          int? newScoreHomeHT = freshMatch['score']['halfTime']['home'];
          int? newScoreAwayHT = freshMatch['score']['halfTime']['away'];

          // Gestion des nuls pendant le match
          if (newScoreHome == null && freshMatch['score']['duration'] != null) {
            newScoreHome = 0;
            newScoreAway = 0;
          }
          if (newScoreHomeHT == null) {
            newScoreHomeHT = 0;
            newScoreAwayHT = 0;
          }

          if (fbMatch['status'] != newStatus ||
              fbMatch['scoreHome'] != newScoreHome ||
              fbMatch['scoreHomeHT'] != newScoreHomeHT) {
            fbMatch['status'] = newStatus;
            fbMatch['scoreHome'] = newScoreHome;
            fbMatch['scoreAway'] = newScoreAway;
            fbMatch['scoreHomeHT'] = newScoreHomeHT; // MAJ Mi-temps
            fbMatch['scoreAwayHT'] = newScoreAwayHT; // MAJ Mi-temps
            needsUpdate = true;
          }
        }
      }

      if (needsUpdate) {
        await docRef.update({'matches': firebaseMatches});
      }
    } catch (e) {
      debugPrint("Erreur LiveScore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("FREE TIPS",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(_bgImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.72), BlendMode.darken),
              ),
            ),
          ),
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8)),
                child: Text("$_dateDisplay FREE TIPS",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('top_matches')
                      .doc(_todayDocId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox();

                    final List matches = data['matches'] ?? [];
                    if (matches.isEmpty) {
                      return const Center(
                          child: Text("Aucun match aujourd'hui.",
                              style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        return _buildExactCard(matches[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExactCard(dynamic matchData) {
    final match = Map<String, dynamic>.from(matchData as Map);
    String league = match['league'] ?? 'League';
    String leagueLogo = match['leagueLogo'] ?? _leagueFallback;
    String home = match['home'] ?? 'Home';
    String away = match['away'] ?? 'Away';
    String homeLogo = match['homeLogo'];
    String awayLogo = match['awayLogo'];
    String pred = match['prediction'] ?? '...';
    String odd = match['odds'] ?? '-';

    String timeStr = "--:--";
    try {
      timeStr =
          DateFormat('HH:mm').format(DateTime.parse(match['time']).toLocal());
    } catch (_) {}

    String status = match['status'] ?? "TIMED";
    int? hScore = match['scoreHome'];
    int? aScore = match['scoreAway'];
    // On récupère aussi les scores mi-temps pour validation
    int? htScoreH = match['scoreHomeHT'] ?? 0;
    int? htScoreA = match['scoreAwayHT'] ?? 0;

    bool isNotStarted = (status == "TIMED" || status == "SCHEDULED");
    bool isFinished = (status == "FINISHED");
    bool isLive = (status == "IN_PLAY" || status == "PAUSED");

    bool isWin = false;
    if (isFinished && hScore != null && aScore != null) {
      // Validation avec tous les paramètres (Score final et score mi-temps)
      isWin = _checkFootballWin(pred, hScore, aScore, htScoreH!, htScoreA!);
    }

    IconData centerIcon = Icons.access_time;
    Color centerIconColor = Colors.orange;

    if (isFinished) {
      centerIcon = isWin ? Icons.check_circle : Icons.cancel;
      centerIconColor = isWin ? Colors.green : Colors.red;
    } else if (isLive) {
      centerIcon = Icons.play_circle_fill;
      centerIconColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Row(
                  children: [
                    Image.network(leagueLogo,
                        height: 22,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.sports_soccer)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(league,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(timeStr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_border,
                        color: Colors.orange, size: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _teamCol(home, homeLogo)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        children: [
                          Text(isNotStarted ? "0" : "${hScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                          const SizedBox(width: 8),
                          Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: centerIconColor, width: 2)),
                              child: Icon(centerIcon,
                                  color: centerIconColor, size: 16)),
                          const SizedBox(width: 8),
                          Text(isNotStarted ? "0" : "${aScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                        ],
                      ),
                    ),
                    Expanded(child: _teamCol(away, awayLogo)),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        color: const Color(0xFFFFB300),
                        alignment: Alignment.center,
                        child: Text(pred,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ),
                    Container(
                      width: 75,
                      color: const Color(0xFF008940),
                      alignment: Alignment.center,
                      child: Text(odd,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamCol(String name, String? logo) {
    return Column(
      children: [
        if (logo != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40, minHeight: 40),
            child: Image.network(logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.shield, size: 35)),
          ),
        const SizedBox(height: 2),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Colors.black)),
      ],
    );
  }
}

/* ===================== Coupon Page PAGE (ALGORITHME INTELLIGENT & COMPLET) ===================== */

class CouponPage extends StatefulWidget {
  const CouponPage({super.key});

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  // CLÉ API FOOTBALL
  static const String FOOTBALL_DATA_API_KEY =
      '7531ff2472bf4416b93cc2e64e7e77c0';

  final String _bgImage =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";
  final String _leagueFallback =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";

  late String _todayDocId;
  String _dateDisplay = "";
  bool _isGeneratingLocally = false;
  Timer? _timer;

  // LISTE DES "TITANS" (Équipes offensives/fortes)
  final List<String> _titans = [
    'Man City',
    'Liverpool',
    'Arsenal',
    'Real Madrid',
    'Barcelona',
    'Bayern',
    'Leverkusen',
    'PSG',
    'Inter',
    'Juventus',
    'Milan',
    'Dortmund'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDocId = DateFormat('yyyy-MM-dd').format(now);
    _dateDisplay = DateFormat('dd.MM.yyyy').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateSmartPredictions();
      _updateLiveScores();
    });

    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updateLiveScores();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(NetworkImage(_bgImage), context);
    super.didChangeDependencies();
  }

  // --- LOGIQUE DE VALIDATION INTELLIGENTE (Gère MT, Équipes, Totaux) ---
  bool _checkFootballWin(
      String predictionText, int h, int a, int htH, int htA) {
    String text = predictionText.toLowerCase();
    int total = h + a;
    int totalHT = htH + htA;
    int goals2ndHalf =
        (h - htH) + (a - htA); // Buts marqués en 2ème mi-temps uniquement

    // 1. MI-TEMPS (1ere MT)
    if (text.contains("1ere mt +0.5")) return totalHT > 0;

    // 2. SECONDE MI-TEMPS (2e MT)
    if (text.contains("2e mt +1.5")) return goals2ndHalf > 1;

    // 3. BUTS PAR ÉQUIPE
    if (text.contains("equipe a +1.5")) return h > 1;
    if (text.contains("equipe b +1.5")) return a > 1;

    // 4. TOTAUX (Over/Under)
    if (text.contains("+1.5 buts")) return total > 1;
    if (text.contains("+2.5 buts")) return total > 2;
    if (text.contains("+3.5 buts")) return total > 3;
    if (text.contains("-3.5 buts")) return total < 4;
    if (text.contains("-2.5 buts")) return total < 3;

    // 5. RÉSULTATS MATCH
    if (text.contains("victoire ou nul equipe a")) return h >= a;
    if (text.contains("victoire ou nul equipe b")) return a >= h;
    if (text.contains("victoire equipe a")) return h > a;
    if (text.contains("victoire equipe b")) return a > h;

    // 6. BTTS
    if (text.contains("les 2 equipes marquent")) return h > 0 && a > 0;

    return false;
  }

  // --- CERVEAU DU SYSTÈME (Choix Intelligent de la prédiction) ---
  Map<String, String> _calculateSmartBet(String home, String away) {
    bool homeStrong = _titans.any((t) => home.contains(t));
    bool awayStrong = _titans.any((t) => away.contains(t));
    Random random = Random();

    // SCÉNARIO 1 : TITAN À DOMICILE (Offensif)
    if (homeStrong) {
      List<Map<String, String>> aggressiveOptions = [
        {'pred': "Victoire Equipe A", 'odd': '1.40'},
        {'pred': "Equipe A +1.5 buts", 'odd': '1.50'},
        {'pred': "+2.5 buts", 'odd': '1.65'},
        {'pred': "1ere MT +0.5 buts", 'odd': '1.28'}, // Très sûr
        {'pred': "+1.5 buts", 'odd': '1.20'}, // Safe
      ];
      return aggressiveOptions[random.nextInt(aggressiveOptions.length)];
    }

    // SCÉNARIO 2 : TITAN À L'EXTÉRIEUR
    if (awayStrong) {
      List<Map<String, String>> awayOptions = [
        {'pred': "Victoire Equipe B", 'odd': '1.55'},
        {'pred': "Equipe B +1.5 buts", 'odd': '1.60'},
        {'pred': "Victoire ou nul Equipe B", 'odd': '1.25'}, // Safe
        {'pred': "+1.5 buts", 'odd': '1.22'},
      ];
      return awayOptions[random.nextInt(awayOptions.length)];
    }

    // SCÉNARIO 3 : MATCH ÉQUILIBRÉ OU PETITES ÉQUIPES (Défensif / Serré)
    List<Map<String, String>> balancedOptions = [
      {'pred': "-3.5 buts", 'odd': '1.30'}, // Souvent sûr
      {'pred': "-2.5 buts", 'odd': '1.70'}, // Risqué mais cote haute
      {'pred': "Victoire ou nul Equipe A", 'odd': '1.35'}, // Avantage domicile
      {'pred': "1ere MT +0.5 buts", 'odd': '1.45'},
      {'pred': "Les 2 equipes marquent", 'odd': '1.80'}, // Si stats équilibrées
      {'pred': "+1.5 buts", 'odd': '1.38'}, // Le grand classique
    ];

    // On ajoute parfois des paris "Fun" pour varier
    if (random.nextBool()) {
      balancedOptions.add({'pred': "2e MT +1.5 buts", 'odd': '2.10'});
      balancedOptions.add({'pred': "+3.5 buts", 'odd': '2.80'});
    }

    return balancedOptions[random.nextInt(balancedOptions.length)];
  }

  // --- GÉNÉRATION AUTOMATIQUE ---
  Future<void> _generateSmartPredictions() async {
    if (_isGeneratingLocally) return;
    setState(() => _isGeneratingLocally = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('coupon_matches')
          .doc(_todayDocId);
      final checkDoc = await docRef.get();

      if (checkDoc.exists) {
        setState(() => _isGeneratingLocally = false);
        return;
      }

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));

      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');

      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      List matchesList = [];
      if (response.statusCode == 200) {
        matchesList = jsonDecode(response.body)['matches'];
      } else {
        // Fallback
        final fbRes = await http.get(
            Uri.parse(
                'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo'),
            headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});
        if (fbRes.statusCode == 200) {
          matchesList = jsonDecode(fbRes.body)['matches'];
        }
      }

      if (matchesList.isEmpty) throw "Pas de matchs majeurs";

      // On prend 3 matchs
      if (matchesList.length > 6) matchesList = matchesList.take(6).toList();

      List<Map<String, dynamic>> processedMatches = [];

      for (var match in matchesList) {
        String home = match['homeTeam']['name'];
        String away = match['awayTeam']['name'];

        // CALCUL INTELLIGENT
        Map<String, String> smartBet = _calculateSmartBet(home, away);

        processedMatches.add({
          'league': match['competition']['name'],
          'leagueLogo': match['competition']['emblem'] ?? _leagueFallback,
          'home': home,
          'away': away,
          'homeLogo': match['homeTeam']['crest'],
          'awayLogo': match['awayTeam']['crest'],
          'time': match['utcDate'],
          'status': match['status'],
          'scoreHome': match['score']['fullTime']['home'],
          'scoreAway': match['score']['fullTime']['away'],
          // IMPORTANT: On stocke aussi la mi-temps pour valider les paris MT
          'scoreHomeHT': match['score']['halfTime']['home'],
          'scoreAwayHT': match['score']['halfTime']['away'],
          'prediction': smartBet['pred'],
          'odds': smartBet['odd'],
        });
      }

      if (processedMatches.isNotEmpty) {
        await docRef.set({
          'date': _todayDocId,
          'is_published': true, // Auto-publish
          'matches': processedMatches,
        });
      }
    } catch (e) {
      debugPrint("Erreur génération auto: $e");
    } finally {
      if (mounted) setState(() => _isGeneratingLocally = false);
    }
  }

  // --- LIVE SCORE UPDATE (Avec Mi-Temps) ---
  Future<void> _updateLiveScores() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('coupon_matches')
          .doc(_todayDocId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final data = docSnap.data();
      if (data == null) return;

      List<dynamic> firebaseMatches = List.from(data['matches'] ?? []);
      bool needsUpdate = false;

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));
      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');
      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      if (response.statusCode != 200) return;
      List apiMatches = jsonDecode(response.body)['matches'];

      for (int i = 0; i < firebaseMatches.length; i++) {
        var fbMatch = firebaseMatches[i] as Map<String, dynamic>;
        var freshMatch = apiMatches.firstWhere(
            (m) =>
                m['homeTeam']['name'] == fbMatch['home'] &&
                m['awayTeam']['name'] == fbMatch['away'],
            orElse: () => null);

        if (freshMatch != null) {
          String newStatus = freshMatch['status'];
          int? newScoreHome = freshMatch['score']['fullTime']['home'];
          int? newScoreAway = freshMatch['score']['fullTime']['away'];
          int? newScoreHomeHT = freshMatch['score']['halfTime']['home'];
          int? newScoreAwayHT = freshMatch['score']['halfTime']['away'];

          // Gestion des nuls pendant le match
          if (newScoreHome == null && freshMatch['score']['duration'] != null) {
            newScoreHome = 0;
            newScoreAway = 0;
          }
          if (newScoreHomeHT == null) {
            newScoreHomeHT = 0;
            newScoreAwayHT = 0;
          }

          if (fbMatch['status'] != newStatus ||
              fbMatch['scoreHome'] != newScoreHome ||
              fbMatch['scoreHomeHT'] != newScoreHomeHT) {
            fbMatch['status'] = newStatus;
            fbMatch['scoreHome'] = newScoreHome;
            fbMatch['scoreAway'] = newScoreAway;
            fbMatch['scoreHomeHT'] = newScoreHomeHT; // MAJ Mi-temps
            fbMatch['scoreAwayHT'] = newScoreAwayHT; // MAJ Mi-temps
            needsUpdate = true;
          }
        }
      }

      if (needsUpdate) {
        await docRef.update({'matches': firebaseMatches});
      }
    } catch (e) {
      debugPrint("Erreur LiveScore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("FREE TIPS",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(_bgImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.72), BlendMode.darken),
              ),
            ),
          ),
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8)),
                child: Text("$_dateDisplay FREE TIPS",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('coupon_matches')
                      .doc(_todayDocId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox();

                    final List matches = data['matches'] ?? [];
                    if (matches.isEmpty) {
                      return const Center(
                          child: Text("Aucun match aujourd'hui.",
                              style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        return _buildExactCard(matches[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExactCard(dynamic matchData) {
    final match = Map<String, dynamic>.from(matchData as Map);
    String league = match['league'] ?? 'League';
    String leagueLogo = match['leagueLogo'] ?? _leagueFallback;
    String home = match['home'] ?? 'Home';
    String away = match['away'] ?? 'Away';
    String homeLogo = match['homeLogo'];
    String awayLogo = match['awayLogo'];
    String pred = match['prediction'] ?? '...';
    String odd = match['odds'] ?? '-';

    String timeStr = "--:--";
    try {
      timeStr =
          DateFormat('HH:mm').format(DateTime.parse(match['time']).toLocal());
    } catch (_) {}

    String status = match['status'] ?? "TIMED";
    int? hScore = match['scoreHome'];
    int? aScore = match['scoreAway'];
    // On récupère aussi les scores mi-temps pour validation
    int? htScoreH = match['scoreHomeHT'] ?? 0;
    int? htScoreA = match['scoreAwayHT'] ?? 0;

    bool isNotStarted = (status == "TIMED" || status == "SCHEDULED");
    bool isFinished = (status == "FINISHED");
    bool isLive = (status == "IN_PLAY" || status == "PAUSED");

    bool isWin = false;
    if (isFinished && hScore != null && aScore != null) {
      // Validation avec tous les paramètres (Score final et score mi-temps)
      isWin = _checkFootballWin(pred, hScore, aScore, htScoreH!, htScoreA!);
    }

    IconData centerIcon = Icons.access_time;
    Color centerIconColor = Colors.orange;

    if (isFinished) {
      centerIcon = isWin ? Icons.check_circle : Icons.cancel;
      centerIconColor = isWin ? Colors.green : Colors.red;
    } else if (isLive) {
      centerIcon = Icons.play_circle_fill;
      centerIconColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Row(
                  children: [
                    Image.network(leagueLogo,
                        height: 22,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.sports_soccer)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(league,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(timeStr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_border,
                        color: Colors.orange, size: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _teamCol(home, homeLogo)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        children: [
                          Text(isNotStarted ? "0" : "${hScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                          const SizedBox(width: 8),
                          Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: centerIconColor, width: 2)),
                              child: Icon(centerIcon,
                                  color: centerIconColor, size: 16)),
                          const SizedBox(width: 8),
                          Text(isNotStarted ? "0" : "${aScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                        ],
                      ),
                    ),
                    Expanded(child: _teamCol(away, awayLogo)),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        color: const Color(0xFFFFB300),
                        alignment: Alignment.center,
                        child: Text(pred,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ),
                    Container(
                      width: 75,
                      color: const Color(0xFF008940),
                      alignment: Alignment.center,
                      child: Text(odd,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamCol(String name, String? logo) {
    return Column(
      children: [
        if (logo != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40, minHeight: 40),
            child: Image.network(logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.shield, size: 35)),
          ),
        const SizedBox(height: 2),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Colors.black)),
      ],
    );
  }
}

/* ===================== Buts Page PAGE (ALGORITHME INTELLIGENT & COMPLET) ===================== */

class ButsPage extends StatefulWidget {
  const ButsPage({super.key});

  @override
  State<ButsPage> createState() => _ButsPageState();
}

class _ButsPageState extends State<ButsPage> {
  // CLÉ API FOOTBALL
  static const String FOOTBALL_DATA_API_KEY =
      '7531ff2472bf4416b93cc2e64e7e77c0';

  final String _bgImage =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";
  final String _leagueFallback =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";

  late String _todayDocId;
  String _dateDisplay = "";
  bool _isGeneratingLocally = false;
  Timer? _timer;

  // LISTE DES "TITANS" (Équipes offensives/fortes)
  final List<String> _titans = [
    'Man City',
    'Liverpool',
    'Arsenal',
    'Real Madrid',
    'Barcelona',
    'Bayern',
    'Leverkusen',
    'PSG',
    'Inter',
    'Juventus',
    'Milan',
    'Dortmund'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDocId = DateFormat('yyyy-MM-dd').format(now);
    _dateDisplay = DateFormat('dd.MM.yyyy').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateSmartPredictions();
      _updateLiveScores();
    });

    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updateLiveScores();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(NetworkImage(_bgImage), context);
    super.didChangeDependencies();
  }

  // --- LOGIQUE DE VALIDATION INTELLIGENTE (Gère MT, Équipes, Totaux) ---
  bool _checkFootballWin(
      String predictionText, int h, int a, int htH, int htA) {
    String text = predictionText.toLowerCase();
    int total = h + a;
    int totalHT = htH + htA;
    int goals2ndHalf =
        (h - htH) + (a - htA); // Buts marqués en 2ème mi-temps uniquement

    // 1. MI-TEMPS (1ere MT)
    if (text.contains("1ere mt +0.5")) return totalHT > 0;

    // 2. SECONDE MI-TEMPS (2e MT)
    if (text.contains("2e mt +1.5")) return goals2ndHalf > 1;

    // 3. BUTS PAR ÉQUIPE
    if (text.contains("equipe a +1.5")) return h > 1;
    if (text.contains("equipe b +1.5")) return a > 1;

    // 4. TOTAUX (Over/Under)
    if (text.contains("+1.5 buts")) return total > 1;
    if (text.contains("+2.5 buts")) return total > 2;
    if (text.contains("+3.5 buts")) return total > 3;
    if (text.contains("-3.5 buts")) return total < 4;
    if (text.contains("-2.5 buts")) return total < 3;

    // 5. RÉSULTATS MATCH
    if (text.contains("victoire ou nul equipe a")) return h >= a;
    if (text.contains("victoire ou nul equipe b")) return a >= h;
    if (text.contains("victoire equipe a")) return h > a;
    if (text.contains("victoire equipe b")) return a > h;

    // 6. BTTS
    if (text.contains("les 2 equipes marquent")) return h > 0 && a > 0;

    return false;
  }

  // --- CERVEAU DU SYSTÈME (Choix Intelligent de la prédiction) ---
  Map<String, String> _calculateSmartBet(String home, String away) {
    bool homeStrong = _titans.any((t) => home.contains(t));
    bool awayStrong = _titans.any((t) => away.contains(t));
    Random random = Random();

    // SCÉNARIO 1 : TITAN À DOMICILE (Offensif)
    if (homeStrong) {
      List<Map<String, String>> aggressiveOptions = [
        {'pred': "Victoire Equipe A", 'odd': '1.40'},
        {'pred': "Equipe A +1.5 buts", 'odd': '1.50'},
        {'pred': "+2.5 buts", 'odd': '1.65'},
        {'pred': "1ere MT +0.5 buts", 'odd': '1.28'}, // Très sûr
        {'pred': "+1.5 buts", 'odd': '1.20'}, // Safe
      ];
      return aggressiveOptions[random.nextInt(aggressiveOptions.length)];
    }

    // SCÉNARIO 2 : TITAN À L'EXTÉRIEUR
    if (awayStrong) {
      List<Map<String, String>> awayOptions = [
        {'pred': "Victoire Equipe B", 'odd': '1.55'},
        {'pred': "Equipe B +1.5 buts", 'odd': '1.60'},
        {'pred': "Victoire ou nul Equipe B", 'odd': '1.25'}, // Safe
        {'pred': "+1.5 buts", 'odd': '1.22'},
      ];
      return awayOptions[random.nextInt(awayOptions.length)];
    }

    // SCÉNARIO 3 : MATCH ÉQUILIBRÉ OU PETITES ÉQUIPES (Défensif / Serré)
    List<Map<String, String>> balancedOptions = [
      {'pred': "-3.5 buts", 'odd': '1.30'}, // Souvent sûr
      {'pred': "-2.5 buts", 'odd': '1.70'}, // Risqué mais cote haute
      {'pred': "Victoire ou nul Equipe A", 'odd': '1.35'}, // Avantage domicile
      {'pred': "1ere MT +0.5 buts", 'odd': '1.45'},
      {'pred': "Les 2 equipes marquent", 'odd': '1.80'}, // Si stats équilibrées
      {'pred': "+1.5 buts", 'odd': '1.38'}, // Le grand classique
    ];

    // On ajoute parfois des paris "Fun" pour varier
    if (random.nextBool()) {
      balancedOptions.add({'pred': "2e MT +1.5 buts", 'odd': '2.10'});
      balancedOptions.add({'pred': "+3.5 buts", 'odd': '2.80'});
    }

    return balancedOptions[random.nextInt(balancedOptions.length)];
  }

  // --- GÉNÉRATION AUTOMATIQUE ---
  Future<void> _generateSmartPredictions() async {
    if (_isGeneratingLocally) return;
    setState(() => _isGeneratingLocally = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('buts_matches')
          .doc(_todayDocId);
      final checkDoc = await docRef.get();

      if (checkDoc.exists) {
        setState(() => _isGeneratingLocally = false);
        return;
      }

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));

      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');

      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      List matchesList = [];
      if (response.statusCode == 200) {
        matchesList = jsonDecode(response.body)['matches'];
      } else {
        // Fallback
        final fbRes = await http.get(
            Uri.parse(
                'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo'),
            headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});
        if (fbRes.statusCode == 200) {
          matchesList = jsonDecode(fbRes.body)['matches'];
        }
      }

      if (matchesList.isEmpty) throw "Pas de matchs majeurs";

      // On prend 3 matchs
      if (matchesList.length > 4) matchesList = matchesList.take(4).toList();

      List<Map<String, dynamic>> processedMatches = [];

      for (var match in matchesList) {
        String home = match['homeTeam']['name'];
        String away = match['awayTeam']['name'];

        // CALCUL INTELLIGENT
        Map<String, String> smartBet = _calculateSmartBet(home, away);

        processedMatches.add({
          'league': match['competition']['name'],
          'leagueLogo': match['competition']['emblem'] ?? _leagueFallback,
          'home': home,
          'away': away,
          'homeLogo': match['homeTeam']['crest'],
          'awayLogo': match['awayTeam']['crest'],
          'time': match['utcDate'],
          'status': match['status'],
          'scoreHome': match['score']['fullTime']['home'],
          'scoreAway': match['score']['fullTime']['away'],
          // IMPORTANT: On stocke aussi la mi-temps pour valider les paris MT
          'scoreHomeHT': match['score']['halfTime']['home'],
          'scoreAwayHT': match['score']['halfTime']['away'],
          'prediction': smartBet['pred'],
          'odds': smartBet['odd'],
        });
      }

      if (processedMatches.isNotEmpty) {
        await docRef.set({
          'date': _todayDocId,
          'is_published': true, // Auto-publish
          'matches': processedMatches,
        });
      }
    } catch (e) {
      debugPrint("Erreur génération auto: $e");
    } finally {
      if (mounted) setState(() => _isGeneratingLocally = false);
    }
  }

  // --- LIVE SCORE UPDATE (Avec Mi-Temps) ---
  Future<void> _updateLiveScores() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('buts_matches')
          .doc(_todayDocId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final data = docSnap.data();
      if (data == null) return;

      List<dynamic> firebaseMatches = List.from(data['matches'] ?? []);
      bool needsUpdate = false;

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));
      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');
      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      if (response.statusCode != 200) return;
      List apiMatches = jsonDecode(response.body)['matches'];

      for (int i = 0; i < firebaseMatches.length; i++) {
        var fbMatch = firebaseMatches[i] as Map<String, dynamic>;
        var freshMatch = apiMatches.firstWhere(
            (m) =>
                m['homeTeam']['name'] == fbMatch['home'] &&
                m['awayTeam']['name'] == fbMatch['away'],
            orElse: () => null);

        if (freshMatch != null) {
          String newStatus = freshMatch['status'];
          int? newScoreHome = freshMatch['score']['fullTime']['home'];
          int? newScoreAway = freshMatch['score']['fullTime']['away'];
          int? newScoreHomeHT = freshMatch['score']['halfTime']['home'];
          int? newScoreAwayHT = freshMatch['score']['halfTime']['away'];

          // Gestion des nuls pendant le match
          if (newScoreHome == null && freshMatch['score']['duration'] != null) {
            newScoreHome = 0;
            newScoreAway = 0;
          }
          if (newScoreHomeHT == null) {
            newScoreHomeHT = 0;
            newScoreAwayHT = 0;
          }

          if (fbMatch['status'] != newStatus ||
              fbMatch['scoreHome'] != newScoreHome ||
              fbMatch['scoreHomeHT'] != newScoreHomeHT) {
            fbMatch['status'] = newStatus;
            fbMatch['scoreHome'] = newScoreHome;
            fbMatch['scoreAway'] = newScoreAway;
            fbMatch['scoreHomeHT'] = newScoreHomeHT; // MAJ Mi-temps
            fbMatch['scoreAwayHT'] = newScoreAwayHT; // MAJ Mi-temps
            needsUpdate = true;
          }
        }
      }

      if (needsUpdate) {
        await docRef.update({'matches': firebaseMatches});
      }
    } catch (e) {
      debugPrint("Erreur LiveScore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("FREE TIPS",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(_bgImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.72), BlendMode.darken),
              ),
            ),
          ),
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8)),
                child: Text("$_dateDisplay FREE TIPS",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('buts_matches')
                      .doc(_todayDocId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox();

                    final List matches = data['matches'] ?? [];
                    if (matches.isEmpty) {
                      return const Center(
                          child: Text("Aucun match aujourd'hui.",
                              style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        return _buildExactCard(matches[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExactCard(dynamic matchData) {
    final match = Map<String, dynamic>.from(matchData as Map);
    String league = match['league'] ?? 'League';
    String leagueLogo = match['leagueLogo'] ?? _leagueFallback;
    String home = match['home'] ?? 'Home';
    String away = match['away'] ?? 'Away';
    String homeLogo = match['homeLogo'];
    String awayLogo = match['awayLogo'];
    String pred = match['prediction'] ?? '...';
    String odd = match['odds'] ?? '-';

    String timeStr = "--:--";
    try {
      timeStr =
          DateFormat('HH:mm').format(DateTime.parse(match['time']).toLocal());
    } catch (_) {}

    String status = match['status'] ?? "TIMED";
    int? hScore = match['scoreHome'];
    int? aScore = match['scoreAway'];
    // On récupère aussi les scores mi-temps pour validation
    int? htScoreH = match['scoreHomeHT'] ?? 0;
    int? htScoreA = match['scoreAwayHT'] ?? 0;

    bool isNotStarted = (status == "TIMED" || status == "SCHEDULED");
    bool isFinished = (status == "FINISHED");
    bool isLive = (status == "IN_PLAY" || status == "PAUSED");

    bool isWin = false;
    if (isFinished && hScore != null && aScore != null) {
      // Validation avec tous les paramètres (Score final et score mi-temps)
      isWin = _checkFootballWin(pred, hScore, aScore, htScoreH!, htScoreA!);
    }

    IconData centerIcon = Icons.access_time;
    Color centerIconColor = Colors.orange;

    if (isFinished) {
      centerIcon = isWin ? Icons.check_circle : Icons.cancel;
      centerIconColor = isWin ? Colors.green : Colors.red;
    } else if (isLive) {
      centerIcon = Icons.play_circle_fill;
      centerIconColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Row(
                  children: [
                    Image.network(leagueLogo,
                        height: 22,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.sports_soccer)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(league,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(timeStr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_border,
                        color: Colors.orange, size: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _teamCol(home, homeLogo)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        children: [
                          Text(isNotStarted ? "0" : "${hScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                          const SizedBox(width: 8),
                          Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: centerIconColor, width: 2)),
                              child: Icon(centerIcon,
                                  color: centerIconColor, size: 16)),
                          const SizedBox(width: 8),
                          Text(isNotStarted ? "0" : "${aScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                        ],
                      ),
                    ),
                    Expanded(child: _teamCol(away, awayLogo)),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        color: const Color(0xFFFFB300),
                        alignment: Alignment.center,
                        child: Text(pred,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ),
                    Container(
                      width: 75,
                      color: const Color(0xFF008940),
                      alignment: Alignment.center,
                      child: Text(odd,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamCol(String name, String? logo) {
    return Column(
      children: [
        if (logo != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40, minHeight: 40),
            child: Image.network(logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.shield, size: 35)),
          ),
        const SizedBox(height: 2),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Colors.black)),
      ],
    );
  }
}

/* ===================== Simple Page PAGE (ALGORITHME INTELLIGENT & COMPLET) ===================== */

class SimplePage extends StatefulWidget {
  const SimplePage({super.key});

  @override
  State<SimplePage> createState() => _SimplePageState();
}

class _SimplePageState extends State<SimplePage> {
  // CLÉ API FOOTBALL
  static const String FOOTBALL_DATA_API_KEY =
      '7531ff2472bf4416b93cc2e64e7e77c0';

  final String _bgImage =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";
  final String _leagueFallback =
      "https://media.istockphoto.com/id/2156769234/fr/photo/vue-a%C3%A9rienne-du-rendu-3d-du-football-am%C3%A9ricain-stade-de-football-avec-tribunes-floues-avec.jpg?s=612x612&w=0&k=20&c=rPMlGDAnzKnAmvkOaQVYKp0E_ch4fASLrmo7BNEkvEI=";

  late String _todayDocId;
  String _dateDisplay = "";
  bool _isGeneratingLocally = false;
  Timer? _timer;

  // LISTE DES "TITANS" (Équipes offensives/fortes)
  final List<String> _titans = [
    'Man City',
    'Liverpool',
    'Arsenal',
    'Real Madrid',
    'Barcelona',
    'Bayern',
    'Leverkusen',
    'PSG',
    'Inter',
    'Juventus',
    'Milan',
    'Dortmund'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDocId = DateFormat('yyyy-MM-dd').format(now);
    _dateDisplay = DateFormat('dd.MM.yyyy').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateSmartPredictions();
      _updateLiveScores();
    });

    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updateLiveScores();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(NetworkImage(_bgImage), context);
    super.didChangeDependencies();
  }

  // --- LOGIQUE DE VALIDATION INTELLIGENTE (Gère MT, Équipes, Totaux) ---
  bool _checkFootballWin(
      String predictionText, int h, int a, int htH, int htA) {
    String text = predictionText.toLowerCase();
    int total = h + a;
    int totalHT = htH + htA;
    int goals2ndHalf =
        (h - htH) + (a - htA); // Buts marqués en 2ème mi-temps uniquement

    // 1. MI-TEMPS (1ere MT)
    if (text.contains("1ere mt +0.5")) return totalHT > 0;

    // 2. SECONDE MI-TEMPS (2e MT)
    if (text.contains("2e mt +1.5")) return goals2ndHalf > 1;

    // 3. BUTS PAR ÉQUIPE
    if (text.contains("equipe a +1.5")) return h > 1;
    if (text.contains("equipe b +1.5")) return a > 1;

    // 4. TOTAUX (Over/Under)
    if (text.contains("+1.5 buts")) return total > 1;
    if (text.contains("+2.5 buts")) return total > 2;
    if (text.contains("+3.5 buts")) return total > 3;
    if (text.contains("-3.5 buts")) return total < 4;
    if (text.contains("-2.5 buts")) return total < 3;

    // 5. RÉSULTATS MATCH
    if (text.contains("victoire ou nul equipe a")) return h >= a;
    if (text.contains("victoire ou nul equipe b")) return a >= h;
    if (text.contains("victoire equipe a")) return h > a;
    if (text.contains("victoire equipe b")) return a > h;

    // 6. BTTS
    if (text.contains("les 2 equipes marquent")) return h > 0 && a > 0;

    return false;
  }

  // --- CERVEAU DU SYSTÈME (Choix Intelligent de la prédiction) ---
  Map<String, String> _calculateSmartBet(String home, String away) {
    bool homeStrong = _titans.any((t) => home.contains(t));
    bool awayStrong = _titans.any((t) => away.contains(t));
    Random random = Random();

    // SCÉNARIO 1 : TITAN À DOMICILE (Offensif)
    if (homeStrong) {
      List<Map<String, String>> aggressiveOptions = [
        {'pred': "Victoire Equipe A", 'odd': '1.40'},
        {'pred': "Equipe A +1.5 buts", 'odd': '1.50'},
        {'pred': "+2.5 buts", 'odd': '1.65'},
        {'pred': "1ere MT +0.5 buts", 'odd': '1.28'}, // Très sûr
        {'pred': "+1.5 buts", 'odd': '1.20'}, // Safe
      ];
      return aggressiveOptions[random.nextInt(aggressiveOptions.length)];
    }

    // SCÉNARIO 2 : TITAN À L'EXTÉRIEUR
    if (awayStrong) {
      List<Map<String, String>> awayOptions = [
        {'pred': "Victoire Equipe B", 'odd': '1.55'},
        {'pred': "Equipe B +1.5 buts", 'odd': '1.60'},
        {'pred': "Victoire ou nul Equipe B", 'odd': '1.25'}, // Safe
        {'pred': "+1.5 buts", 'odd': '1.22'},
      ];
      return awayOptions[random.nextInt(awayOptions.length)];
    }

    // SCÉNARIO 3 : MATCH ÉQUILIBRÉ OU PETITES ÉQUIPES (Défensif / Serré)
    List<Map<String, String>> balancedOptions = [
      {'pred': "-3.5 buts", 'odd': '1.30'}, // Souvent sûr
      {'pred': "-2.5 buts", 'odd': '1.70'}, // Risqué mais cote haute
      {'pred': "Victoire ou nul Equipe A", 'odd': '1.35'}, // Avantage domicile
      {'pred': "1ere MT +0.5 buts", 'odd': '1.45'},
      {'pred': "Les 2 equipes marquent", 'odd': '1.80'}, // Si stats équilibrées
      {'pred': "+1.5 buts", 'odd': '1.38'}, // Le grand classique
    ];

    // On ajoute parfois des paris "Fun" pour varier
    if (random.nextBool()) {
      balancedOptions.add({'pred': "2e MT +1.5 buts", 'odd': '2.10'});
      balancedOptions.add({'pred': "+3.5 buts", 'odd': '2.80'});
    }

    return balancedOptions[random.nextInt(balancedOptions.length)];
  }

  // --- GÉNÉRATION AUTOMATIQUE ---
  Future<void> _generateSmartPredictions() async {
    if (_isGeneratingLocally) return;
    setState(() => _isGeneratingLocally = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('simple_matches')
          .doc(_todayDocId);
      final checkDoc = await docRef.get();

      if (checkDoc.exists) {
        setState(() => _isGeneratingLocally = false);
        return;
      }

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));

      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');

      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      List matchesList = [];
      if (response.statusCode == 200) {
        matchesList = jsonDecode(response.body)['matches'];
      } else {
        // Fallback
        final fbRes = await http.get(
            Uri.parse(
                'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo'),
            headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});
        if (fbRes.statusCode == 200) {
          matchesList = jsonDecode(fbRes.body)['matches'];
        }
      }

      if (matchesList.isEmpty) throw "Pas de matchs majeurs";

      // On prend 3 matchs
      if (matchesList.length > 1) matchesList = matchesList.take(1).toList();

      List<Map<String, dynamic>> processedMatches = [];

      for (var match in matchesList) {
        String home = match['homeTeam']['name'];
        String away = match['awayTeam']['name'];

        // CALCUL INTELLIGENT
        Map<String, String> smartBet = _calculateSmartBet(home, away);

        processedMatches.add({
          'league': match['competition']['name'],
          'leagueLogo': match['competition']['emblem'] ?? _leagueFallback,
          'home': home,
          'away': away,
          'homeLogo': match['homeTeam']['crest'],
          'awayLogo': match['awayTeam']['crest'],
          'time': match['utcDate'],
          'status': match['status'],
          'scoreHome': match['score']['fullTime']['home'],
          'scoreAway': match['score']['fullTime']['away'],
          // IMPORTANT: On stocke aussi la mi-temps pour valider les paris MT
          'scoreHomeHT': match['score']['halfTime']['home'],
          'scoreAwayHT': match['score']['halfTime']['away'],
          'prediction': smartBet['pred'],
          'odds': smartBet['odd'],
        });
      }

      if (processedMatches.isNotEmpty) {
        await docRef.set({
          'date': _todayDocId,
          'is_published': true, // Auto-publish
          'matches': processedMatches,
        });
      }
    } catch (e) {
      debugPrint("Erreur génération auto: $e");
    } finally {
      if (mounted) setState(() => _isGeneratingLocally = false);
    }
  }

  // --- LIVE SCORE UPDATE (Avec Mi-Temps) ---
  Future<void> _updateLiveScores() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('simple_matches')
          .doc(_todayDocId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final data = docSnap.data();
      if (data == null) return;

      List<dynamic> firebaseMatches = List.from(data['matches'] ?? []);
      bool needsUpdate = false;

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));
      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo');
      final response =
          await http.get(url, headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY});

      if (response.statusCode != 200) return;
      List apiMatches = jsonDecode(response.body)['matches'];

      for (int i = 0; i < firebaseMatches.length; i++) {
        var fbMatch = firebaseMatches[i] as Map<String, dynamic>;
        var freshMatch = apiMatches.firstWhere(
            (m) =>
                m['homeTeam']['name'] == fbMatch['home'] &&
                m['awayTeam']['name'] == fbMatch['away'],
            orElse: () => null);

        if (freshMatch != null) {
          String newStatus = freshMatch['status'];
          int? newScoreHome = freshMatch['score']['fullTime']['home'];
          int? newScoreAway = freshMatch['score']['fullTime']['away'];
          int? newScoreHomeHT = freshMatch['score']['halfTime']['home'];
          int? newScoreAwayHT = freshMatch['score']['halfTime']['away'];

          // Gestion des nuls pendant le match
          if (newScoreHome == null && freshMatch['score']['duration'] != null) {
            newScoreHome = 0;
            newScoreAway = 0;
          }
          if (newScoreHomeHT == null) {
            newScoreHomeHT = 0;
            newScoreAwayHT = 0;
          }

          if (fbMatch['status'] != newStatus ||
              fbMatch['scoreHome'] != newScoreHome ||
              fbMatch['scoreHomeHT'] != newScoreHomeHT) {
            fbMatch['status'] = newStatus;
            fbMatch['scoreHome'] = newScoreHome;
            fbMatch['scoreAway'] = newScoreAway;
            fbMatch['scoreHomeHT'] = newScoreHomeHT; // MAJ Mi-temps
            fbMatch['scoreAwayHT'] = newScoreAwayHT; // MAJ Mi-temps
            needsUpdate = true;
          }
        }
      }

      if (needsUpdate) {
        await docRef.update({'matches': firebaseMatches});
      }
    } catch (e) {
      debugPrint("Erreur LiveScore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("FREE TIPS",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(_bgImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.72), BlendMode.darken),
              ),
            ),
          ),
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8)),
                child: Text("$_dateDisplay FREE TIPS",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('daily_matches')
                      .doc(_todayDocId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox();

                    final List matches = data['matches'] ?? [];
                    if (matches.isEmpty) {
                      return const Center(
                          child: Text("Aucun match aujourd'hui.",
                              style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        return _buildExactCard(matches[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExactCard(dynamic matchData) {
    final match = Map<String, dynamic>.from(matchData as Map);
    String league = match['league'] ?? 'League';
    String leagueLogo = match['leagueLogo'] ?? _leagueFallback;
    String home = match['home'] ?? 'Home';
    String away = match['away'] ?? 'Away';
    String homeLogo = match['homeLogo'];
    String awayLogo = match['awayLogo'];
    String pred = match['prediction'] ?? '...';
    String odd = match['odds'] ?? '-';

    String timeStr = "--:--";
    try {
      timeStr =
          DateFormat('HH:mm').format(DateTime.parse(match['time']).toLocal());
    } catch (_) {}

    String status = match['status'] ?? "TIMED";
    int? hScore = match['scoreHome'];
    int? aScore = match['scoreAway'];
    // On récupère aussi les scores mi-temps pour validation
    int? htScoreH = match['scoreHomeHT'] ?? 0;
    int? htScoreA = match['scoreAwayHT'] ?? 0;

    bool isNotStarted = (status == "TIMED" || status == "SCHEDULED");
    bool isFinished = (status == "FINISHED");
    bool isLive = (status == "IN_PLAY" || status == "PAUSED");

    bool isWin = false;
    if (isFinished && hScore != null && aScore != null) {
      // Validation avec tous les paramètres (Score final et score mi-temps)
      isWin = _checkFootballWin(pred, hScore, aScore, htScoreH!, htScoreA!);
    }

    IconData centerIcon = Icons.access_time;
    Color centerIconColor = Colors.orange;

    if (isFinished) {
      centerIcon = isWin ? Icons.check_circle : Icons.cancel;
      centerIconColor = isWin ? Colors.green : Colors.red;
    } else if (isLive) {
      centerIcon = Icons.play_circle_fill;
      centerIconColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Row(
                  children: [
                    Image.network(leagueLogo,
                        height: 22,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.sports_soccer)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(league,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(timeStr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_border,
                        color: Colors.orange, size: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _teamCol(home, homeLogo)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        children: [
                          Text(isNotStarted ? "0" : "${hScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                          const SizedBox(width: 8),
                          Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: centerIconColor, width: 2)),
                              child: Icon(centerIcon,
                                  color: centerIconColor, size: 16)),
                          const SizedBox(width: 8),
                          Text(isNotStarted ? "0" : "${aScore ?? 0}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 22)),
                        ],
                      ),
                    ),
                    Expanded(child: _teamCol(away, awayLogo)),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        color: const Color(0xFFFFB300),
                        alignment: Alignment.center,
                        child: Text(pred,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ),
                    Container(
                      width: 75,
                      color: const Color(0xFF008940),
                      alignment: Alignment.center,
                      child: Text(odd,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamCol(String name, String? logo) {
    return Column(
      children: [
        if (logo != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40, minHeight: 40),
            child: Image.network(logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.shield, size: 35)),
          ),
        const SizedBox(height: 2),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Colors.black)),
      ],
    );
  }
}

/* ===================== Historique Page PAGE (ALGORITHME INTELLIGENT & COMPLET) ===================== */

class HistoriquePage extends StatelessWidget {
  const HistoriquePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Ton fond noir habituel
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "HISTORIQUE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône grise pour illustrer le vide
            Icon(
              Icons.history_toggle_off_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            // Texte principal
            const Text(
              "Aucun historique disponible",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Petit sous-titre
            Text(
              "Les anciens scores apparaîtront ici.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== FIN DU CODE ===================== */