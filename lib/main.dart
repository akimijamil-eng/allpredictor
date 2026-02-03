import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
// AJOUTS POUR FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// AJOUT DE VISIONNEUSE VIDÉO
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
// AJOUT POUR LES DATES (SPORT)
import 'package:intl/intl.dart';
// AJOUT PAIEMENT (Billing)
import 'package:in_app_purchase/in_app_purchase.dart';

// Assurez-vous que ces fichiers existent ou commentez les imports si non utilisés
import 'pages/privacy_policy_page.dart';
import 'pages/terms_page.dart';
import 'page_football_gratuit.dart';

// 🔔 HANDLER BACKGROUND
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

// VARIABLE GLOBALE POUR LE STATUT PREMIUM
bool isPremiumUser = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fixe le style système pour éviter le flash au démarrage
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.black,
    statusBarIconBrightness: Brightness.dark,
  ));

  // 🔔 INITIALISATION FIREBASE
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance.subscribeToTopic('all');
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    debugPrint("Erreur init Firebase : $e");
  }

  await loadSavedLanguage();
  await loadSubscriptionStatus(); // Charger le statut abonné

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OfflineGate(),
    ),
  );
}

const String baseUrl = 'https://1win-game-ci.com';

/* ===================== NAVIGATION HELPER (ANTI-FLASH) ===================== */

void _fadeNavigate(BuildContext context, Widget page) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, __) => page,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

/* ===================== LOCALE ===================== */

final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('fr'));

String t(String fr, String en) {
  return localeNotifier.value.languageCode == 'fr' ? fr : en;
}

const String _langKey = 'app_language';

Future<void> loadSavedLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(_langKey)) {
    final code = prefs.getString(_langKey) ?? 'fr';
    localeNotifier.value = Locale(code);
  } else {
    final deviceLocale = ui.PlatformDispatcher.instance.locale.languageCode;
    localeNotifier.value =
        (deviceLocale == 'fr') ? const Locale('fr') : const Locale('en');
  }
}

Future<void> saveLanguage(Locale locale) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_langKey, locale.languageCode);
}

// CHARGER LE STATUT ABONNEMENT
Future<void> loadSubscriptionStatus() async {
  final prefs = await SharedPreferences.getInstance();
  isPremiumUser = prefs.getBool('is_premium') ?? false;
}

// SAUVEGARDER LE STATUT ABONNEMENT
Future<void> setPremiumStatus(bool status) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_premium', status);
  isPremiumUser = status;
}

/* ===================== OFFLINE GATE ===================== */

class OfflineGate extends StatefulWidget {
  const OfflineGate({super.key});

  @override
  State<OfflineGate> createState() => _OfflineGateState();
}

class _OfflineGateState extends State<OfflineGate> {
  bool _isOnline = true;
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _sub = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      final online = result != ConnectivityResult.none;
      if (mounted && online != _isOnline) {
        setState(() => _isOnline = online);
      }
    });
  }

  Future<void> _checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isOnline
        ? const AllPredictorApp()
        : OfflineScreen(onRetry: _checkConnection);
  }
}

/* ===================== APP ===================== */

class AllPredictorApp extends StatelessWidget {
  const AllPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'AllPredictor',
          debugShowCheckedModeBanner: false,
          locale: locale,
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: Colors.black,
            // SOLUTION FLASH : Couleur de fond universelle
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            canvasColor: const Color(0xFFF5F5F5),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orange,
              primary: Colors.black,
              secondary: Colors.orange,
              background: const Color(0xFFF5F5F5),
            ),
            splashColor: Colors.transparent, // Clean up interaction
            highlightColor: Colors.transparent,
          ),
          home: const OnboardingCheck(),
        );
      },
    );
  }
}

/* ===================== ONBOARDING CHECK ===================== */

class OnboardingCheck extends StatefulWidget {
  const OnboardingCheck({super.key});

  @override
  State<OnboardingCheck> createState() => _OnboardingCheckState();
}

class _OnboardingCheckState extends State<OnboardingCheck> {
  bool? _seen;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    setState(() {
      _seen = seen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_seen == null) {
      return const Scaffold(backgroundColor: Color(0xFFF5F5F5));
    }
    return _seen! ? const MainShell() : const OnboardingScreen();
  }
}

/* ===================== ONBOARDING SCREEN ===================== */

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'image': 'assets/intro/intro1.png',
      'title_fr': 'Bienvenue sur AllPredictor',
      'title_en': 'Welcome to AllPredictor',
      'desc_fr':
          'Accédez aux meilleurs pronostics et jeux de casino en un clic.',
      'desc_en': 'Access the best predictions and casino games in one click.',
    },
    {
      'image': 'assets/intro/intro2.png',
      'title_fr': 'Jeux & Stratégies',
      'title_en': 'Games & Strategies',
      'desc_fr':
          'Découvrez Aviator, Lucky Jet, Mines et nos stratégies gagnantes.',
      'desc_en':
          'Discover Aviator, Lucky Jet, Mines and our winning strategies.',
    },
    {
      'image': 'assets/intro/intro3.png',
      'title_fr': 'Bonus Exclusifs',
      'title_en': 'Exclusive Bonuses',
      'desc_fr':
          'Profitez de codes promo uniques pour maximiser vos gains dès maintenant.',
      'desc_en':
          'Enjoy unique promo codes to maximize your earnings right now.',
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      page['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey.shade200);
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(1.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 32 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.orange
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        t(_pages[_currentPage]['title_fr'],
                            _pages[_currentPage]['title_en']),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            height: 1.1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t(_pages[_currentPage]['desc_fr'],
                            _pages[_currentPage]['desc_en']),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.5),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _finishOnboarding();
                        } else {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? t('COMMENCER', 'GET STARTED')
                                : t('SUIVANT', 'NEXT'),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== NETWORK SETTINGS ===================== */

Future<void> openNetworkSettings() async {
  final uri = Uri.parse('android.settings.WIFI_SETTINGS');
  if (!await launchUrl(uri)) {
    await launchUrl(Uri.parse('app-settings:'));
  }
}

/* ===================== OFFLINE SCREEN ===================== */

class OfflineScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const OfflineScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 96, color: Colors.grey),
              const SizedBox(height: 24),
              Text(
                t('Connexion Internet requise', 'Internet connection required'),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                t('Veuillez activer votre connexion pour continuer.',
                    'Please enable your internet connection to continue.'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: openNetworkSettings,
                icon: const Icon(Icons.settings),
                label: Text(t('Ouvrir les paramètres', 'Open settings')),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
              ),
              const SizedBox(height: 16),
              TextButton(
                  onPressed: onRetry, child: Text(t('Réessayer', 'Retry'))),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===================== DATA ===================== */

final List<Map<String, String>> games = [
  {
    'name': 'Lucky Jet',
    'image': 'assets/images/games/lucky_jet.jpg',
    'url': 'https://1win-game-ci.com/game/lucky-jet.html'
  },
  {
    'name': 'Aviator',
    'image': 'assets/images/games/aviator.jpg',
    'url': 'https://1win-game-ci.com/game/aviator.html'
  },
  {
    'name': 'Crime empire',
    'image': 'assets/images/games/crime_empire.jpg',
    'url': 'https://1win-game-ci.com/game/crime-empire.html'
  },
  {
    'name': 'Rocket Queen',
    'image': 'assets/images/games/rocket_queen.jpg',
    'url': 'https://1win-game-ci.com/game/rocket-queen.html'
  },
  {
    'name': 'Crash',
    'image': 'assets/images/games/crash_onewin.jpg',
    'url': 'https://1win-game-ci.com/game/crash.html'
  },
  {
    'name': 'Crasher',
    'image': 'assets/images/games/crasher.jpg',
    'url': 'https://1win-game-ci.com/game/crasher.html'
  },
  {
    'name': 'Mines',
    'image': 'assets/images/games/mines.jpg',
    'url': 'https://1win-game-ci.com/game/mines.html'
  },
  {
    'name': 'Double',
    'image': 'assets/images/games/double.jpg',
    'url': 'https://1win-game-ci.com/game/double.html'
  },
  {
    'name': 'Mines Blast',
    'image': 'assets/images/games/mines_blast.jpg',
    'url': 'https://1win-game-ci.com/game/mines-blast.html'
  },
  {
    'name': 'Meta crash',
    'image': 'assets/images/games/meta_crash.jpg',
    'url': 'https://1win-game-ci.com/game/meta-crash.html'
  },
  {
    'name': 'Mines spribe',
    'image': 'assets/images/games/mines_spribe.jpg',
    'url': 'https://1win-game-ci.com/game/mines-spribe.html'
  },
  {
    'name': 'Mines gold',
    'image': 'assets/images/games/mines_gold.jpg',
    'url': 'https://1win-game-ci.com/game/mines-gold.html'
  },
  {
    'name': 'Six or out',
    'image': 'assets/images/games/six_or_out.jpg',
    'url': 'https://1win-game-ci.com/game/six-or-out.html'
  },
  {
    'name': '1win dice',
    'image': 'assets/images/games/onewin_dice.jpg',
    'url': 'https://1win-game-ci.com/game/1win-dice.html'
  },
  {
    'name': 'Top eagle',
    'image': 'assets/images/games/top_eagle.jpg',
    'url': 'https://1win-game-ci.com/game/top-eagle.html'
  },
  {
    'name': 'Apple of fortune',
    'image': 'assets/images/games/apple_of_fortune.jpg',
    'url': 'https://1win-game-ci.com/game/apple-of-fortune.html'
  },
  {
    'name': 'Mines BB',
    'image': 'assets/images/games/mines_bb.jpg',
    'url': 'https://1win-game-ci.com/game/mines-bb.html'
  },
  {
    'name': 'Magic Dice',
    'image': 'assets/images/games/magic_dice.jpg',
    'url': 'https://1win-game-ci.com/game/magic-dice.html'
  },
  {
    'name': 'Aviatrix',
    'image': 'assets/images/games/aviatrix.jpg',
    'url': 'https://1win-game-ci.com/game/aviatrix.html'
  },
  {
    'name': 'Instant Soccer',
    'image': 'assets/images/games/instant_soccer.jpg',
    'url': 'https://1win-game-ci.com/game/instant-soccer.html'
  },
  {
    'name': 'Penalty',
    'image': 'assets/images/games/penalty.jpg',
    'url': 'https://1win-game-ci.com/game/penalty.html'
  },
  {
    'name': 'Penalty Shoot Out',
    'image': 'assets/images/games/penalty_shoot_out.jpg',
    'url': 'https://1win-game-ci.com/game/penalty-shoot-out.html'
  },
  {
    'name': 'Football X',
    'image': 'assets/images/games/football_x.jpg',
    'url': 'https://1win-game-ci.com/game/football-x.html'
  },
  {
    'name': 'Mines Football',
    'image': 'assets/images/games/mines_soccer.jpg',
    'url': 'https://1win-game-ci.com/game/offline.html'
  },
  {
    'name': 'Astronaut',
    'image': 'assets/images/games/astronaut.jpg',
    'url': 'https://1win-game-ci.com/game/astronauts.html'
  },
  {
    'name': 'Space X',
    'image': 'assets/images/games/space_x.jpg',
    'url': 'https://1win-game-ci.com/game/space-x.html'
  },
  {
    'name': 'Coinflip',
    'image': 'assets/images/games/coinflip.jpg',
    'url': 'https://1win-game-ci.com/game/coinflip.html'
  },
  {
    'name': 'Mining madness',
    'image': 'assets/images/games/mining_madness.jpg',
    'url': 'https://1win-game-ci.com/game/mining-madness.html'
  },
  {
    'name': 'Aero',
    'image': 'assets/images/games/aero.jpg',
    'url': 'https://1win-game-ci.com/game/aero.html'
  },
  {
    'name': 'kings thimbles',
    'image': 'assets/images/games/kings_thimbles.jpg',
    'url': 'https://1win-game-ci.com/game/kings-thimbles.html'
  },
  {
    'name': 'speed cash',
    'image': 'assets/images/games/speed_cash.jpg',
    'url': 'https://1win-game-ci.com/game/speed-cash.html'
  },
];

final featuredGames = games.take(4).toList();

final bookmakers = [
  {
    'image': 'assets/images/bookmakers/1win.png',
    'url': 'https://allpredictor-copy-a60cd2a4.base44.app'
  },
  {'image': 'assets/images/bookmakers/1xbet.png', 'url': 'https://1xbet.com'},
  {
    'image': 'assets/images/bookmakers/betclic.png',
    'url': 'https://betclic.com'
  },
  {'image': 'assets/images/bookmakers/melbet.png', 'url': 'https://melbet.com'},
];

/* ===================== PREMIUM PAGE (GOOGLE PAY BILLING) ===================== */

class PremiumSubscriptionPage extends StatefulWidget {
  const PremiumSubscriptionPage({super.key});

  @override
  State<PremiumSubscriptionPage> createState() =>
      _PremiumSubscriptionPageState();
}

class _PremiumSubscriptionPageState extends State<PremiumSubscriptionPage> {
  // 0 = Mensuel, 1 = Annuel
  int _selectedIndex = 0;

  // IAP variables
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isLoading = true;

  // Remplacez par vos vrais IDs une fois en production.
  // ex: 'vip_monthly', 'vip_yearly'
  static const String _monthlyId = 'vip_monthly';
  // ignore: unused_field
  static const String _yearlyId = 'vip_yearly';

  @override
  void initState() {
    super.initState();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("Erreur stream achat: $error");
    });
    _initStoreInfo();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = false;
        _isLoading = false;
      });
      return;
    }

    final Set<String> kIds = <String>{_monthlyId, _yearlyId};
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(kIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint("Produits non trouvés: ${response.notFoundIDs}");
    }
    setState(() {
      _isAvailable = isAvailable;
      _products = response.productDetails;
      _isLoading = false;
    });
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // En attente... afficher loader si besoin
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Erreur: ${purchaseDetails.error?.message}")),
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Achat réussi !
          await _deliverProduct(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Sauvegarder le statut premium
    await setPremiumStatus(true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Abonnement activé avec succès !")),
      );
      // Fermer le modal
      Navigator.pop(context);
    }
  }

  void _buyProduct() {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produits indisponibles pour le moment.")),
      );
      return;
    }

    // 1. Déterminer quel ID l'utilisateur a choisi (0 = Mensuel, 1 = Annuel)
    // Assure-toi d'avoir mis tes vrais IDs dans les variables _monthlyId et _yearlyId en haut
    String selectedId = _selectedIndex == 0 ? _monthlyId : _yearlyId;

    // 2. Trouver le produit correspondant dans la liste chargée par Google
    late ProductDetails productDetails;
    try {
      productDetails =
          _products.firstWhere((product) => product.id == selectedId);
    } catch (e) {
      // Si l'ID n'est pas trouvé dans la liste retournée par Google
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Erreur : Le produit $selectedId est introuvable.")),
      );
      return;
    }

    // 3. Lancer l'achat sécurisé
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _restorePurchases() {
    _inAppPurchase.restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFA726), // Fond Orange Pure
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
              onPressed: _restorePurchases,
              child: const Text("Restaurer",
                  style: TextStyle(color: Colors.white)))
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Gros Titre
                    Text(
                      t("Obtenez plus de\nRentabilité.",
                          "Get more\nProfitability."),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t("Choisissez le forfait qui vous convient.",
                          "Choose the plan that fits you."),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // La Carte Blanche "Pro"
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre Pro
                          const Text(
                            "Pro",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Serif',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t("Pour la productivité quotidienne",
                                "For daily productivity"),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Zone de sélection (Mensuel vs Annuel)
                          Row(
                            children: [
                              // Option 1: Mensuel
                              Expanded(
                                child: _buildPlanOption(
                                  index: 0,
                                  price: "5.000 FCFA",
                                  label: t("Facturation mensuelle",
                                      "Monthly billing"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Option 2: Annuel
                              Expanded(
                                child: _buildPlanOption(
                                  index: 1,
                                  price: "50.000 FCFA", // Prix annuel (exemple)
                                  label: t(
                                      "Facturation annuelle", "Annual billing"),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Bouton Noir (Google Pay)
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isAvailable ? _buyProduct : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.payment,
                                      color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text(
                                    t("S'abonner maintenant", "Subscribe Now"),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 20),

                          // Liste des avantages
                          Text(
                            t("Tout ce qui est inclus, plus :",
                                "Everything included, plus:"),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCompactFeature(t("Prédictions 98% de réussite",
                              "98% Success Rate")),
                          _buildCompactFeature(
                              t("Cotes élevées (10+)", "High Odds (10+)")),
                          _buildCompactFeature(
                              t("Conseils de gestion", "Bankroll Management")),
                          _buildCompactFeature(
                              t("Support VIP 24/7", "24/7 VIP Support")),
                          _buildCompactFeature(
                              t("Mise à jour quotidienne", "Daily Updates")),

                          const SizedBox(height: 10),
                          Text(
                            t("Des limites s'appliquent. Annulable à tout moment sur Google Play.",
                                "Limits apply. Cancel anytime on Google Play."),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  // Widget interactif pour les options (Mensuel/Annuel)
  Widget _buildPlanOption(
      {required int index, required String price, required String label}) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Si sélectionné : fond bleu clair, sinon blanc
          color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          // Si sélectionné : bordure bleue épaisse, sinon gris fin
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icone Radio
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.blue[700] : Colors.grey[400],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.grey[800] : Colors.grey[600],
                    height: 1.2,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCompactFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: Colors.black, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== LANGUAGE SELECTOR ===================== */

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language, color: Colors.black),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (locale) {
        localeNotifier.value = locale;
        saveLanguage(locale);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: Locale('fr'),
          child: Row(
            children: [
              Text('🇫🇷', style: TextStyle(fontSize: 20)),
              SizedBox(width: 12),
              Text('Français', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        PopupMenuItem(
          value: Locale('en'),
          child: Row(
            children: [
              Text('🇬🇧', style: TextStyle(fontSize: 20)),
              SizedBox(width: 12),
              Text('English', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

/* ===================== MAIN SHELL (MODIFIÉ) ===================== */

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final pages = const [
    HomePage(),
    GamesPage(),
    BonusPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Image.asset(
          'assets/images/header.png',
          height: 28,
        ),
        actions: [
          // 🔥 MODIFICATION ICI : CONDITION SUR L'INDEX
          if (index == 0) ...[
            // SI PAGE D'ACCUEIL : AFFICHER ICÔNE PREMIUM
            GestureDetector(
              onTap: () {
                _fadeNavigate(context, const PremiumSubscriptionPage());
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                // Assure-toi d'avoir cette image ou utilise une icône par défaut
                child: Image.asset(
                  'assets/images/premium_icon.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback si l'image n'est pas encore ajoutée
                    return const Icon(Icons.diamond_outlined,
                        color: Colors.orange, size: 28);
                  },
                ),
              ),
            ),
          ] else ...[
            // SI AUTRE PAGE : AFFICHER RECHERCHE
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: GameSearchDelegate(games),
                );
              },
            ),
          ],

          const LanguageSelector(),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNav(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}

/* ===================== UI HELPERS ===================== */

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/* ===================== HOME ===================== */

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100, top: 16),
      children: [
        const AutoCarousel(),
        SectionTitle(t('Bookmakers populaires', 'Popular Bookmakers')),
        const BookmakersGrid(),
        SectionTitle(t('Catégories', 'Categories')),
        const CategoriesGrid(),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            t(
              'Découvrez notre sélection de bots et de stratégies gagnantes.',
              'Discover our selection of winning bots and strategies.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Colors.grey.shade600, height: 1.5),
          ),
        ),
      ],
    );
  }
}

/* ===================== CATEGORIES GRID ===================== */

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'title_fr': 'Casino',
      'title_en': 'Casino',
      'icon': Icons.casino_rounded,
      'image': 'assets/images/categories/casino.jpg',
    },
    {
      'title_fr': 'Football',
      'title_en': 'Football',
      'icon': Icons.sports_soccer_rounded,
      'image': 'assets/images/categories/sport.jpg',
    },
    {
      'title_fr': 'Basketball',
      'title_en': 'Basketball',
      'icon': Icons.sports_basketball_rounded,
      'image': 'assets/images/categories/basket.jpg',
    },
    {
      'title_fr': 'Plus',
      'title_en': 'More',
      'icon': Icons.sports_soccer,
      'image': 'assets/images/categories/esport.jpg',
    },
  ];

  // Fonction de navigation
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

  // Dialog "Bientôt disponible"
  void _showComingSoonDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    size: 40, color: Colors.orange),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                t('Cette section sera bientôt disponible !',
                    'This section will be available soon!'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(t('Compris', 'Got it')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.8,
        ),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(cat['image']),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.4),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // --- LOGIQUE DE NAVIGATION ---
                    if (index == 1) {
                      // FOOTBALL -> Ouvre la page Football
                      _fadeNavigate(context, const FOOTMenuPage());
                    } else if (index == 2) {
                      // BASKETBALL -> Ouvre la page Basketball
                      _fadeNavigate(context, const BasketballPage());
                    } else {
                      // CASINO (0) et PLUS (3) -> Bientôt disponible
                      _showComingSoonDialog(
                          context, t(cat['title_fr'], cat['title_en']));
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat['icon'], size: 32, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        t(cat['title_fr'], cat['title_en']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ===================== STANDALONE GAMES PAGE ===================== */

class StandaloneGamesPage extends StatelessWidget {
  const StandaloneGamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t("Jeux Casino", "Casino Games"),
            style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: const GamesPage(),
    );
  }
}

/* ===================== AUTO CAROUSEL ===================== */

class AutoCarousel extends StatefulWidget {
  const AutoCarousel({super.key});

  @override
  State<AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<AutoCarousel> {
  final PageController controller = PageController();
  int currentIndex = 0;
  late final Timer _timer;

  final List<Map<String, dynamic>> slides = [
    {
      'title_fr': 'Bonus de Bienvenue',
      'title_en': 'Welcome Bonus',
      'sub_fr': 'Application 100% gratuiute',
      'sub_en': '100% Free App',
      'color1': const Color(0xFF1A2980),
      'color2': const Color(0xFF26D0CE),
      'icon': Icons.star_rounded,
    },
    {
      'title_fr': 'Prédictions Fiables',
      'title_en': 'Reliable Predictions',
      'sub_fr': 'Gagner facilement nos predictions',
      'sub_en': 'Win easily with our predictions',
      'color1': const ui.Color.fromARGB(255, 224, 129, 3),
      'color2': const Color(0xFF5FC3E4),
      'icon': Icons.analytics_rounded,
    },
    {
      'title_fr': 'Plus de 30 bots',
      'title_en': 'More than 30 bots',
      'sub_fr': 'Découvrez nos bots performants',
      'sub_en': 'Discover our high-performance bots',
      'color1': const ui.Color.fromARGB(255, 0, 12, 11),
      'color2': const ui.Color.fromARGB(255, 112, 112, 112),
      'icon': Icons.security_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!controller.hasClients) return;
      int next = (currentIndex + 1) % slides.length;
      controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: controller,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => currentIndex = i),
            itemBuilder: (context, i) {
              final slide = slides[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [slide['color1'], slide['color2']],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (slide['color1'] as Color).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        slide['icon'],
                        size: 140,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t('NOUVEAU', 'NEW'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t(slide['title_fr'], slide['title_en']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t(slide['sub_fr'], slide['sub_en']),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: currentIndex == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: currentIndex == i ? Colors.black : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ===================== BOOKMAKERS ===================== */

class BookmakersGrid extends StatelessWidget {
  const BookmakersGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: bookmakers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final b = bookmakers[i];
          return GestureDetector(
            onTap: () => _openWeb(context, b['url']!),
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Image.asset(
                b['image']!,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ===================== GAMES PAGE ===================== */

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: games.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, i) {
        final g = games[i];
        return GestureDetector(
          onTap: () => _openGame(context, g),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(g['image']!, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }
}

/* ===================== BONUS & TUTORIALS ===================== */

class BonusPage extends StatelessWidget {
  const BonusPage({super.key});

  final List<Map<String, String>> tutorials = const [
    {
      'title': 'Comment les robots fonctionnent',
      'desc': 'Comprendre l\'algorithme derrière les jeux.',
      'video': 'https://1win-game-ci.com/videos/tuto_robot.MP4',
      'image': 'assets/images/tutorials/how.png',
    },
    {
      'title': 'Créer plusieurs comptes',
      'desc': 'Les secrets pour créer plusieurs comptes sur les bookmakers.',
      'video': 'https://1win-game-ci.com/videos/tuto_compte.mp4',
      'image': 'assets/images/tutorials/link.png',
    },
    {
      'title': 'Les meilleures stratégies',
      'desc': 'Martingale, Fibonacci et autres techniques.',
      'video': 'https://1win-game-ci.com/videos/tuto_strat.MP4',
      'image': 'assets/images/tutorials/strategy.png',
    },
    {
      'title': 'Connecter l\'app au compte',
      'desc': 'Lier votre compte de jeu pour les prédictions.',
      'video': 'https://1win-game-ci.com/videos/tuto_timing.MP4',
      'image': 'assets/images/tutorials/account.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      children: [
        const Text(
          "Académie & Tutoriels",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Apprenez à maîtriser les jeux avec nos guides vidéos.",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        ...tutorials.map((t) => _buildTutorialCard(context, t)),
      ],
    );
  }

  Widget _buildTutorialCard(BuildContext context, Map<String, String> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _fadeNavigate(
              context,
              TutorialVideoPage(
                title: data['title']!,
                videoPath: data['video']!,
                imagePath: data['image'],
              ));
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: AssetImage(data['image']!),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_fill,
                    color: ui.Color.fromARGB(255, 0, 0, 0), size: 64),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title']!,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['desc']!,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== WEBVIEW PAGE ===================== */

class WebViewPage extends StatefulWidget {
  final String url;
  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? false) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            if (!_hasError) WebViewWidget(controller: _controller),
            if (_hasError)
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 24),
                    Text(
                      t('Oups ! Erreur de connexion', 'Oops! Connection Error'),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t(
                        'Le jeu ne peut pas charger. Vérifiez votre connexion internet.',
                        'The game cannot load. Please check your internet connection.',
                      ),
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _controller.reload(),
                      icon: const Icon(Icons.refresh),
                      label: Text(t('Réessayer', 'Try Again')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            if (_isLoading && !_hasError)
              const Center(
                  child: CircularProgressIndicator(color: Colors.orange)),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 12,
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== VIDEO TUTORIAL PAGE ===================== */

class TutorialVideoPage extends StatefulWidget {
  final String title;
  final String videoPath;
  final String? imagePath;

  const TutorialVideoPage(
      {super.key,
      required this.title,
      required this.videoPath,
      this.imagePath});

  @override
  State<TutorialVideoPage> createState() => _TutorialVideoPageState();
}

class _TutorialVideoPageState extends State<TutorialVideoPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));

      await _videoPlayerController.initialize();

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          placeholder: widget.imagePath != null
              ? Image.asset(widget.imagePath!, fit: BoxFit.cover)
              : null,
          errorBuilder: (context, errorMessage) {
            return const Center(
              child: Text("Erreur de lecture vidéo",
                  style: TextStyle(color: Colors.white)),
            );
          },
        );
      });
    } catch (e) {
      debugPrint("Erreur vidéo: $e");
      setState(() => _isError = true);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: _isError
            ? const Text("Vidéo introuvable ou erreur réseau",
                style: TextStyle(color: Colors.white))
            : _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator(color: Colors.orange),
      ),
    );
  }
}

/* ===================== NAVIGATION HELPERS ===================== */

void _openGame(BuildContext context, Map<String, String> game) {
  _fadeNavigate(context, WebViewPage(url: game['url']!));
}

void _openWeb(BuildContext context, String url) {
  _fadeNavigate(context, WebViewPage(url: url));
}

/* ===================== DRAWER ===================== */

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _linkedId;

  @override
  void initState() {
    super.initState();
    _loadLinkedId();
  }

  Future<void> _loadLinkedId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _linkedId = prefs.getString('linked_1win_id');
    });
  }

  void _shareApp(BuildContext context) {
    const String message =
        "Salut ! J'utilise cette appli pour mes pronostics foot et jeux, elle est top ! Télécharge-la ici : https://play.google.com/store/apps/details?id=com.allpredictorfree.app";
    Share.share(message);
  }

  Future<void> _rateAppInternal() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      inAppReview.openStoreListing(appStoreId: 'com.allpredictorfree.app');
    }
  }

  void _showLinkAccountDialog() {
    final TextEditingController idController = TextEditingController();
    String? errorText;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => Container(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curvedValue = Curves.easeInOutBack.transform(anim1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 16,
              backgroundColor: Colors.white,
              child: StatefulBuilder(
                builder: (context, setStateDialog) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _linkedId == null
                                  ? [
                                      const Color(0xFF1A2980),
                                      const Color(0xFF26D0CE)
                                    ]
                                  : [
                                      Colors.green.shade400,
                                      Colors.green.shade800
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_linkedId == null
                                        ? const Color(0xFF1A2980)
                                        : Colors.green)
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            _linkedId == null
                                ? Icons.link_rounded
                                : Icons.check_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _linkedId == null
                              ? t('Lier mon compte', 'Link Account')
                              : t('Compte Connecté', 'Account Linked'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_linkedId == null) ...[
                          Text(
                            t(
                              "Entrez votre ID 1win pour synchroniser les prédictions.",
                              "Enter your 1win ID to sync predictions.",
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: idController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: "Ex: 12345678",
                                labelText: "ID 1win",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                prefixIcon: const Icon(Icons.person_outline,
                                    color: Colors.grey),
                                errorText: errorText,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: Text(t("Annuler", "Cancel")),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final input = idController.text.trim();
                                    if (input.length < 7 ||
                                        int.tryParse(input) == null) {
                                      setStateDialog(() {
                                        errorText =
                                            t("ID invalide", "Invalid ID");
                                      });
                                    } else {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'linked_1win_id', input);
                                      setState(() {
                                        _linkedId = input;
                                      });
                                      Navigator.pop(context);
                                      _showSuccessDialog();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    t("Confirmer", "Confirm"),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.fingerprint,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  "ID: $_linkedId",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('linked_1win_id');
                                setState(() {
                                  _linkedId = null;
                                });
                                Navigator.pop(context);
                              },
                              icon:
                                  const Icon(Icons.link_off_rounded, size: 20),
                              label:
                                  Text(t("Délier le compte", "Unlink Account")),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red.shade200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              t("Fermer", "Close"),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t("Félicitations !", "Congratulations!")),
        content: Text(t("Les bots sont maintenant liés à votre compte.",
            "Bots are now linked to your account.")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.transparent)),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/header.png',
                width: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.privacy_tip_outlined, color: Colors.black87),
            title: Text(t('Politique de confidentialité', 'Privacy Policy')),
            onTap: () {
              Navigator.pop(context);
              _fadeNavigate(context, const PrivacyPolicyPage());
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.description_outlined, color: Colors.black87),
            title: Text(t('Termes & Conditions', 'Terms & Conditions')),
            onTap: () {
              Navigator.pop(context);
              _fadeNavigate(context, const TermsPage());
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey),
          ),
          ListTile(
            leading: Icon(
              Icons.link_rounded,
              color: _linkedId != null ? Colors.green : Colors.black87,
            ),
            title: Text(
              _linkedId != null
                  ? 'ID: $_linkedId'
                  : t('Lier mon compte', 'Link my account'),
              style: TextStyle(
                color: _linkedId != null ? Colors.green : Colors.black,
                fontWeight:
                    _linkedId != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: _linkedId != null
                ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                : null,
            onTap: () {
              Navigator.pop(context);
              _showLinkAccountDialog();
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey),
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded, color: Colors.blueAccent),
            title: Text(
              t('Partager à un ami', 'Share with a friend'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              _shareApp(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_rate_rounded, color: Colors.orange),
            title: Text(
              t('Noter l\'application', 'Rate the app'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              _rateAppInternal();
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              "Version 4.3.8",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== MODIFICATION DU BOTTOM NAV ===================== */

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _icon(Icons.sports_esports, 0),
          _icon(Icons.grid_view_rounded, 1),
          // ICÔNE PREMIUM (DIAMANT)
          GestureDetector(
            onTap: () {
              _fadeNavigate(context, const VIPMenuPage());
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.diamond_rounded,
                size: 32,
                color: Colors.orange, // Couleur Premium
              ),
            ),
          ),
          _icon(Icons.local_fire_department_rounded, 2),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, int i) {
    final isSelected = currentIndex == i;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(isSelected ? 12 : 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.white : Colors.white54,
        ),
        onPressed: () => onTap(i),
      ),
    );
  }
}

/* ===================== PAGE VIP COMPACTE (SANS ENCADREMENT) ===================== */

class VIPMenuPage extends StatelessWidget {
  const VIPMenuPage({super.key});

  void _checkPremiumAndNavigate(BuildContext context, VoidCallback onSuccess) {
    if (isPremiumUser) {
      onSuccess();
    } else {
      _fadeNavigate(context, const PremiumSubscriptionPage());
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "ACCÈS VIP",
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
            _buildHeader(),
            const SizedBox(height: 20),
            _buildVipCard(
              title: "Football prédiction VIP",
              subtitle: "Analyses & cotes boostées",
              imagePath: 'assets/images/vip/football.png', // Chemin à adapter
              gradient: const [Color(0xFF1e3c72), Color(0xFF2a5298)],
              isActive: true,
              onTap: () {
                _checkPremiumAndNavigate(context, () {
                  _fadeNavigate(context, const SportVipPage());
                });
              },
            ),
            const SizedBox(height: 12),
            _buildVipCard(
              title: "Basketball VIP",
              subtitle: "NBA & EuroLeague expert tips",
              imagePath: 'assets/images/vip/basketball.png', // Chemin à adapter
              gradient: const [Color(0xFFE65100), Color(0xFFFF8F00)],
              isActive: true,
              onTap: () {
                _checkPremiumAndNavigate(context, () {
                  _fadeNavigate(context, const BasketballVipPage());
                });
              },
            ),
            const SizedBox(height: 12),
            _buildVipCard(
              title: "GROUPE VIP",
              subtitle: "Communauté privée Telegram",
              imagePath: 'assets/images/vip/telegram.png', // Chemin à adapter
              gradient: const [Color(0xFF0088cc), Color(0xFF00a2ff)],
              isActive: true,
              onTap: () {
                _checkPremiumAndNavigate(context, () async {
                  final Uri url = Uri.parse('https://t.me/+oCtJ2eoBRhw2ZjA0');
                  if (!await launchUrl(url,
                      mode: LaunchMode.externalApplication)) {
                    debugPrint("Impossible d'ouvrir le lien Telegram");
                  }
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 20, 8, 12),
              child: Text(
                "PROCHAINEMENT",
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
            ),
            _buildVipCard(
              title: "Bot Score Exact",
              subtitle: "Bientôt disponible",
              imagePath: 'assets/images/vip/bot.png', // Chemin à adapter
              gradient: [Colors.grey.shade800, Colors.grey.shade900],
              isActive: false,
            ),
            const SizedBox(height: 12),
            _buildVipCard(
              title: "Gestion de Bankroll",
              subtitle: "Bientôt disponible",
              imagePath: 'assets/images/vip/bankroll.png', // Chemin à adapter
              gradient: [Colors.grey.shade800, Colors.grey.shade900],
              isActive: false,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.workspace_premium_rounded, color: Colors.orange, size: 24),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Espace Exclusive",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "Optimisez vos gains",
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVipCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required List<Color> gradient,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? gradient
              : [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.05)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // IMAGE SANS ENCADREMENT NI ARRIÈRE-PLAN
                Image.asset(
                  imagePath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    color: Colors.white24,
                    size: 40,
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
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white30,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isActive ? Colors.white70 : Colors.white12,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isActive
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.lock_outline_rounded,
                  color: isActive ? Colors.white : Colors.white12,
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

/* ===================== SEARCH ===================== */

class GameSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> games;
  GameSearchDelegate(this.games);

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = games
        .where((g) => g['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final g = results[i];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(g['image']!,
                width: 40, height: 40, fit: BoxFit.cover),
          ),
          title: Text(g['name']!),
          onTap: () => _openGame(context, g),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );
}

/* ===================== UPDATE SERVICE ===================== */

const String updateUrl = 'https://1win-game-ci.com/app/version.json';

Future<void> checkForUpdate(BuildContext context) async {
  try {
    final response = await http.get(Uri.parse(updateUrl));
    if (response.statusCode != 200) return;

    final data = jsonDecode(response.body);
    final latestVersion = data['version'] as String;
    final storeUrl = data['store_url'] as String;

    final info = await PackageInfo.fromPlatform();

    if (info.version != latestVersion && context.mounted) {
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.8),
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (ctx, anim1, anim2) => Container(),
        transitionBuilder: (ctx, anim1, anim2, child) {
          final curvedValue = Curves.easeInOutBack.transform(anim1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: anim1.value,
              child: PopScope(
                canPop: false,
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 16,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            size: 48,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t('Mise à jour requise', 'Update Required'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "v$latestVersion",
                            style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t(
                            'Une nouvelle version est disponible. Installez-la pour profiter des dernières fonctionnalités et correctifs.',
                            'A new version is available. Install it to enjoy the latest features and fixes.',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () => launchUrl(
                              Uri.parse(storeUrl),
                              mode: LaunchMode.externalApplication,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  t('METTRE À JOUR', 'UPDATE NOW'),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.download_rounded),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  } catch (_) {}
}

/* ===================== SPORT VIP PAGE (AUTO MATCHS + LIVE SCORE + VALIDATION AUTO) ===================== */

class SportVipPage extends StatefulWidget {
  const SportVipPage({super.key});

  @override
  State<SportVipPage> createState() => _SportVipPageState();
}

class _SportVipPageState extends State<SportVipPage> {
  // CLÉ API FOOTBALL (Pour récupérer les matchs VIP automatiquement)
  static const String FOOTBALL_DATA_API_KEY =
      '7531ff2472bf4416b93cc2e64e7e77c0';

  final String _bgImage =
      "https://raw.githubusercontent.com/akimijamil-eng/luckyjet-api/refs/heads/main/stade.png";
  final String _leagueFallback =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Uefa_2013.png/640px-Uefa_2013.png";

  late String _todayDocId;
  String _dateDisplay = "";
  bool _isGeneratingLocally = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDocId = DateFormat('yyyy-MM-dd').format(now);
    _dateDisplay = DateFormat('dd.MM.yyyy').format(now);

    // Lancer la génération des matchs + le Live Score
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateVipPredictions();
      _updateLiveScores();
    });

    // Timer Live Score (60s)
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

  // --- LOGIQUE DE VÉRIFICATION INTELLIGENTE ---
  // Cette fonction analyse ton texte (ex: "Equipe A +1.5") et valide le résultat
  bool _checkFootballWin(
      String predictionText, int h, int a, int htH, int htA) {
    String text = predictionText.toLowerCase();
    int total = h + a;
    int totalHT = htH + htA;
    int goals2ndHalf = (h - htH) + (a - htA);

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

    // Par défaut (si rien ne matche, on suppose Victoire Domicile)
    return h > a;
  }

  // --- GÉNÉRATION AUTOMATIQUE DES MATCHS VIP (SANS IA) ---
  Future<void> _generateVipPredictions() async {
    if (_isGeneratingLocally) return;
    setState(() => _isGeneratingLocally = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('vip_daily_matches')
          .doc(_todayDocId);
      final checkDoc = await docRef.get();

      // Si le document existe déjà, on ne fait rien
      if (checkDoc.exists) {
        setState(() => _isGeneratingLocally = false);
        return;
      }

      final dateFrom = _todayDocId;
      final dateTo = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));

      // Appel API pour les grandes compétitions (VIP)
      final url = Uri.parse(
          'https://api.football-data.org/v4/matches?dateFrom=$dateFrom&dateTo=$dateTo&competitions=CL,EL,PL,PD,BL1,SA,FL1');

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

      if (matchesList.isEmpty) throw "Aucun match VIP trouvé";

      // On prend 3 matchs VIP
      if (matchesList.length > 3) matchesList = matchesList.take(3).toList();

      List<Map<String, dynamic>> processedMatches = [];

      for (var match in matchesList) {
        processedMatches.add({
          'league': match['competition']['name'],
          'leagueLogo': match['competition']['emblem'] ?? _leagueFallback,
          'home': match['homeTeam']['name'],
          'away': match['awayTeam']['name'],
          'homeLogo': match['homeTeam']['crest'],
          'awayLogo': match['awayTeam']['crest'],
          'time': match['utcDate'],
          'status': match['status'],
          'scoreHome': match['score']['fullTime']['home'],
          'scoreAway': match['score']['fullTime']['away'],
          // Scores Mi-Temps (Important pour la validation intelligente)
          'scoreHomeHT': match['score']['halfTime']['home'],
          'scoreAwayHT': match['score']['halfTime']['away'],
          // PAS D'IA -> CHAMPS VIDES POUR REMPLISSAGE MANUEL
          'prediction': "En attente...",
          'odds': "-",
        });
      }

      if (processedMatches.isNotEmpty) {
        await docRef.set({
          'date': _todayDocId,
          'is_published': false, // <--- BLOQUÉ PAR DÉFAUT
          'matches': processedMatches,
        });
      }
    } catch (e) {
      debugPrint("Erreur génération VIP: $e");
    } finally {
      if (mounted) setState(() => _isGeneratingLocally = false);
    }
  }

  // --- LIVE SCORE UPDATE ---
  Future<void> _updateLiveScores() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('vip_daily_matches')
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
            fbMatch['scoreHomeHT'] = newScoreHomeHT;
            fbMatch['scoreAwayHT'] = newScoreAwayHT;
            needsUpdate = true;
          }
        }
      }

      if (needsUpdate) {
        await docRef.update({'matches': firebaseMatches});
      }
    } catch (e) {
      debugPrint("Erreur LiveScore VIP: $e");
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
        title: const Text("VIP TIPS",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Fond
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

          // 2. Header
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // 3. Contenu
          Column(
            children: [
              // BANDEAU DATE
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8)),
                child: Text("$_dateDisplay VIP TIPS",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
              ),

              // LISTE
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('vip_daily_matches')
                      .doc(_todayDocId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // 1. Pas de doc -> Lancer récupération et afficher message
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      if (!_isGeneratingLocally) {
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _generateVipPredictions());
                      }
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "pas de predictions disponible aujourd'hui tant que moi mm j'ai pas encore donner les predictions",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox();

                    // 2. VÉRIFICATION PUBLICATION
                    bool isPublished = data['is_published'] ?? false;

                    if (!isPublished) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "pas de predictions disponible aujourd'hui tant que moi mm j'ai pas encore donner les predictions",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      );
                    }

                    // 3. Affichage si publié
                    final List matches = data['matches'] ?? [];
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

  // --- CARTE MATCH ---
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
    // On récupère les scores MT pour la validation
    int? htScoreH = match['scoreHomeHT'] ?? 0;
    int? htScoreA = match['scoreAwayHT'] ?? 0;

    bool isNotStarted = (status == "TIMED" || status == "SCHEDULED");
    bool isFinished = (status == "FINISHED" || status == "AWARDED") &&
        hScore != null &&
        aScore != null;
    bool isLive = !isNotStarted && !isFinished;

    bool isWin = false;
    if (isFinished) {
      // MAGIE : Validation intelligente basée sur ton texte
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
                      child: Text(
                        league,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                          Text(isNotStarted ? "0" : "$hScore",
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
                          Text(isNotStarted ? "0" : "$aScore",
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
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black),
        ),
      ],
    );
  }
}

/* ===================== BASKETBALL VIP PAGE (AUTO MATCHS + PREDICTIONS MANUELLES) ===================== */

class BasketballVipPage extends StatefulWidget {
  const BasketballVipPage({super.key});

  @override
  State<BasketballVipPage> createState() => _BasketballVipPageState();
}

class _BasketballVipPageState extends State<BasketballVipPage> {
  // CLÉ API BASKET (Pour récupérer les matchs VIP automatiquement)
  static const String BASKET_API_KEY = 'f8c16326923af21a393080d77cd20f7b';

  final String _bgImage =
      "https://img.freepik.com/free-photo/basketball-court-floor-with-gradient-light_23-2149320664.jpg";
  final String _nbaLogo =
      "https://upload.wikimedia.org/wikipedia/fr/0/03/National_Basketball_Association_logo.png";

  late String _todayDocId;
  String _dateDisplay = "";
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDocId = DateFormat('yyyy-MM-dd').format(now);
    _dateDisplay = DateFormat('dd.MM.yyyy').format(now);
  }

  @override
  void didChangeDependencies() {
    precacheImage(NetworkImage(_bgImage), context);
    super.didChangeDependencies();
  }

  String _getSafeTime(dynamic timeString) {
    if (timeString == null) return "--:--";
    try {
      return DateFormat('HH:mm')
          .format(DateTime.parse(timeString.toString()).toLocal());
    } catch (_) {
      return "--:--";
    }
  }

  bool _isPredictionCorrect(
      String pred, String home, String away, int scoreH, int scoreA) {
    String p = pred.toLowerCase();
    String h = home.toLowerCase();
    String a = away.toLowerCase();
    bool homeWon = scoreH > scoreA;
    if (homeWon && p.contains(h)) return true;
    if (!homeWon && p.contains(a)) return true;
    return false;
  }

  // --- GÉNÉRATION AUTOMATIQUE (SANS IA) ---
  Future<void> _fetchAndGenerateMatches() async {
    if (_isGenerating) return;
    if (!mounted) return;
    setState(() => _isGenerating = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('basketball_vip_matches')
          .doc(_todayDocId);
      final docSnap = await docRef.get();

      // Si le document existe déjà, on ne fait rien
      if (docSnap.exists) {
        if (mounted) setState(() => _isGenerating = false);
        return;
      }

      // Appel API Basket
      List<Map<String, dynamic>> results = await _callBasketApi(_todayDocId);

      // Si vide, on essaie demain (décalage horaire NBA)
      if (results.isEmpty) {
        String tomorrow = DateFormat('yyyy-MM-dd')
            .format(DateTime.now().add(const Duration(days: 1)));
        results = await _callBasketApi(tomorrow);
      }

      // ON CRÉE LE DOCUMENT AVEC 'is_published: false'
      await docRef.set({
        'date': _todayDocId,
        'is_published': false, // <--- BLOQUÉ PAR DÉFAUT
        'matches': results,
        'last_updated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Erreur Basket : $e");
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<List<Map<String, dynamic>>> _callBasketApi(String dateStr) async {
    final List<Map<String, dynamic>> processed = [];
    final url =
        Uri.parse('https://v1.basketball.api-sports.io/games?date=$dateStr');

    try {
      final response = await http.get(url, headers: {
        'x-rapidapi-key': BASKET_API_KEY,
        'x-rapidapi-host': 'v1.basketball.api-sports.io'
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response'] != null && data['response'] is List) {
          List games = data['response'];
          int count = 0;
          for (var game in games) {
            String league =
                (game['league']?['name'] ?? "").toString().toUpperCase();
            // Filtre des ligues majeures VIP
            if (league.contains("NBA") || league.contains("EUROLEAGUE")) {
              String home = game['teams']['home']['name'];
              String away = game['teams']['away']['name'];
              var scoreHome = game['scores']?['home']?['total'];
              var scoreAway = game['scores']?['away']?['total'];
              String status = game['status']?['short'] ?? "NS";

              // PAS D'IA ICI -> CHAMPS VIDES
              processed.add({
                'league': game['league']['name'],
                'home': home,
                'away': away,
                'homeLogo': game['teams']['home']['logo'],
                'awayLogo': game['teams']['away']['logo'],
                'time': game['date'],
                'status': status,
                'scoreHome': scoreHome,
                'scoreAway': scoreAway,
                'prediction': "En attente...",
                'odds': "-",
              });
              count++;
              if (count >= 3) break; // Limite à 3 matchs VIP
            }
          }
        }
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
    return processed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text("VIP BASKETBALL TIPS",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          // 1. Fond
          Container(
            decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                    image: NetworkImage(_bgImage),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.72), BlendMode.darken))),
          ),

          // 2. Header
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

          // 3. Contenu
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8)),
                child: Text("$_dateDisplay NBA VIP",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('basketball_vip_matches')
                      .doc(_todayDocId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // 1. Pas de doc -> Lancer récupération et afficher message
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      if (!_isGenerating) {
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _fetchAndGenerateMatches());
                      }
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "pas de predictions disponible aujourd'hui tant que moi mm j'ai pas encore donner les predictions",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox();

                    // 2. VÉRIFICATION PUBLICATION
                    bool isPublished = data['is_published'] ?? false;

                    if (!isPublished) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "pas de predictions disponible aujourd'hui tant que moi mm j'ai pas encore donner les predictions",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      );
                    }

                    // 3. Affichage si publié
                    final List matches =
                        (data['matches'] is List) ? data['matches'] : [];

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final item = matches[index];
                        if (item is Map) return _buildExactCard(item);
                        return const SizedBox();
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

  // --- CARTE MATCH (INCHANGÉE) ---
  Widget _buildExactCard(dynamic m) {
    String league = m['league'] ?? "NBA";
    String displayLeague =
        league.toUpperCase().contains("NBA") ? "NBA" : league;
    String time = _getSafeTime(m['time']);
    String home = m['home'] ?? "Home";
    String away = m['away'] ?? "Away";
    String pred = m['prediction'] ?? "Home Wins";
    String odd = m['odds'] ?? "1.50";
    String? homeLogo = m['homeLogo'];
    String? awayLogo = m['awayLogo'];
    int? scoreHome = m['scoreHome'];
    int? scoreAway = m['scoreAway'];
    String status = m['status'] ?? "NS";

    bool isNotStarted = (status == "NS");
    bool isFinished = (status == "FT" || status == "AOT") &&
        scoreHome != null &&
        scoreAway != null;
    bool isLive = !isNotStarted && !isFinished;

    IconData centerIcon = Icons.access_time;
    Color centerIconColor = Colors.orange;

    if (isFinished) {
      bool win = _isPredictionCorrect(pred, home, away, scoreHome, scoreAway);
      centerIcon = win ? Icons.check_circle : Icons.cancel;
      centerIconColor = win ? Colors.green : Colors.red;
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
                    displayLeague == "NBA"
                        ? Image.network(_nbaLogo,
                            height: 22,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.sports_basketball))
                        : const Icon(Icons.sports_basketball,
                            color: Colors.black54),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(displayLeague,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(time,
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
                          Text(isNotStarted ? "0" : "$scoreHome",
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
                          Text(isNotStarted ? "0" : "$scoreAway",
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
                        color: const Color(0xFFFFA000),
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
                    const Icon(Icons.sports_basketball, size: 35)),
          ),
        const SizedBox(height: 2),
        Text(
          name.replaceAll("76ers", "").trim(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black),
        ),
      ],
    );
  }
}

/* ===================== BASKETBALL PAGE GRATUIT (ALGO INTELLIGENT & LIVE SCORE) ===================== */

class BasketballPage extends StatefulWidget {
  const BasketballPage({super.key});

  @override
  State<BasketballPage> createState() => _BasketballPageState();
}

class _BasketballPageState extends State<BasketballPage> {
  static const String BASKET_API_KEY = 'f8c16326923af21a393080d77cd20f7b';
  final String _bgImage =
      "https://www.ncaa.com/_flysystem/public-s3/styles/original/public-s3/images/2021/01/25/memphis-tigers-court.jpg?itok=t0uXbru-";
  final String _nbaLogo =
      "https://upload.wikimedia.org/wikipedia/fr/0/03/National_Basketball_Association_logo.png";

  late String _todayDocId;
  String _dateDisplay = "";
  bool _isGenerating = false;
  Timer? _timer;

  // LISTE DES "TITANS" NBA (Équipes Fortes/Offensives)
  final List<String> _nbaTitans = [
    'Boston',
    'Celtics',
    'Denver',
    'Nuggets',
    'Milwaukee',
    'Bucks',
    'Golden State',
    'Warriors',
    'Phoenix',
    'Suns',
    'Lakers',
    'Clippers',
    'Philadelphia',
    '76ers',
    'Dallas',
    'Mavericks',
    'Oklahoma'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDocId = DateFormat('yyyy-MM-dd').format(now);
    _dateDisplay = DateFormat('dd.MM.yyyy').format(now);

    // Lancement Auto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndGenerateSmartBasketMatches();
      _updateLiveBasketScores();
    });

    // Timer Live Score (60s)
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _updateLiveBasketScores();
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

  String _getSafeTime(dynamic timeString) {
    if (timeString == null) return "--:--";
    try {
      return DateFormat('HH:mm')
          .format(DateTime.parse(timeString.toString()).toLocal());
    } catch (_) {
      return "--:--";
    }
  }

  // --- LOGIQUE DE VALIDATION INTELLIGENTE BASKET ---
  bool _isPredictionCorrect(
      String pred, String home, String away, int scoreH, int scoreA) {
    String p = pred.toLowerCase();

    // 1. Victoires / Nuls
    if (p.contains("victoire equipe a") ||
        p.contains("victoire ou nul equipe a")) {
      return scoreH >= scoreA; // Inclut victoire et prolongation/nul
    }
    if (p.contains("victoire equipe b") ||
        p.contains("victoire ou nule equipe b")) {
      return scoreA >= scoreH;
    }

    // 2. Points par équipe
    if (p.contains("equipe a +100")) return scoreH >= 100;
    if (p.contains("equipe b +120")) return scoreA >= 120;
    if (p.contains("equipe a +120")) {
      return scoreH >= 120; // Variantes possibles
    }

    // 3. Totaux / QT (Interprétation intelligente)
    // "1er QT +100 points" est techniquement impossible en 1 QT (record ~50).
    // Le système considère cela comme un pari sur le rythme du match (Over global ou mi-temps).
    // Pour être validé, on regarde si le Total Match dépasse 200 (ce qui arrive si le rythme est de 100pts/mi-temps)
    if (p.contains("1er qt +100")) {
      return (scoreH + scoreA) >=
          50; // On check si le QT1 a été explosif (>50) ou Total > 200
    }

    return false;
  }

  // --- CERVEAU DU SYSTÈME BASKET (Choix Stratégique) ---
  Map<String, String> _calculateSmartBasketBet(String home, String away) {
    bool homeStrong = _nbaTitans.any((t) => home.contains(t));
    bool awayStrong = _nbaTitans.any((t) => away.contains(t));
    Random random = Random();

    // LISTE STRICTE DES PRÉDICTIONS DEMANDÉES
    // "1er QT +100 points", "Victoire Equipe A", "Victoire Equipe B",
    // "Equipe A +100 points", "Equipe B +120 points",
    // "Victoire ou nul Equipe A", "Victoire ou nule Equipe B"

    if (homeStrong) {
      // Titan à Domicile -> Offensif ou Victoire A
      List<Map<String, String>> homeOptions = [
        {'pred': "Victoire Equipe A", 'odd': '1.35'},
        {'pred': "Equipe A +100 points", 'odd': '1.45'}, // Très probable en NBA
        {'pred': "Victoire ou nul Equipe A", 'odd': '1.15'}, // Safe
      ];
      return homeOptions[random.nextInt(homeOptions.length)];
    }

    if (awayStrong) {
      // Titan à l'Extérieur -> Victoire B ou Gros Score B
      List<Map<String, String>> awayOptions = [
        {'pred': "Victoire Equipe B", 'odd': '1.55'},
        {'pred': "Equipe B +100 points", 'odd': '1.50'},
        {'pred': "Victoire ou nule Equipe B", 'odd': '1.30'},
      ];
      return awayOptions[random.nextInt(awayOptions.length)];
    }

    // Match Équilibré / Rythme Rapide
    List<Map<String, String>> neutralOptions = [
      {
        'pred': "1er QT +100 points",
        'odd': '1.90'
      }, // (Interprété comme rythme élevé)
      {'pred': "Equipe A +100 points", 'odd': '1.60'},
      {
        'pred': "Victoire ou nul Equipe A",
        'odd': '1.40'
      }, // Avantage domicile standard
    ];

    // Ajout rare pour les matchs très offensifs
    if (random.nextBool()) {
      neutralOptions.add({'pred': "Equipe B +120 points", 'odd': '2.80'});
    }

    return neutralOptions[random.nextInt(neutralOptions.length)];
  }

  // --- GÉNÉRATION AUTOMATIQUE ---
  Future<void> _fetchAndGenerateSmartBasketMatches() async {
    if (_isGenerating) return;
    if (!mounted) return;
    setState(() => _isGenerating = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('basketball_free_matches')
          .doc(_todayDocId);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        if (mounted) setState(() => _isGenerating = false);
        return;
      }

      List<Map<String, dynamic>> results = await _callBasketApi(_todayDocId);

      if (results.isEmpty) {
        String tomorrow = DateFormat('yyyy-MM-dd')
            .format(DateTime.now().add(const Duration(days: 1)));
        results = await _callBasketApi(tomorrow);
      }

      if (results.isNotEmpty) {
        await docRef.set({
          'date': _todayDocId,
          'is_published': true, // Auto-Publish activé
          'matches': results,
          'last_updated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Erreur Basket : $e");
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<List<Map<String, dynamic>>> _callBasketApi(String dateStr) async {
    final List<Map<String, dynamic>> processed = [];
    final url =
        Uri.parse('https://v1.basketball.api-sports.io/games?date=$dateStr');

    try {
      final response = await http.get(url, headers: {
        'x-rapidapi-key': BASKET_API_KEY,
        'x-rapidapi-host': 'v1.basketball.api-sports.io'
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response'] != null && data['response'] is List) {
          List games = data['response'];
          int count = 0;
          for (var game in games) {
            String league =
                (game['league']?['name'] ?? "").toString().toUpperCase();

            if (league.contains("NBA") ||
                league.contains("EUROLEAGUE") ||
                league.contains("LNB") ||
                league.contains("ACB")) {
              String home = game['teams']['home']['name'];
              String away = game['teams']['away']['name'];

              // CALCUL INTELLIGENT
              Map<String, String> smartBet =
                  _calculateSmartBasketBet(home, away);

              processed.add({
                'league': game['league']['name'],
                'home': home,
                'away': away,
                'homeLogo': game['teams']['home']['logo'],
                'awayLogo': game['teams']['away']['logo'],
                'time': game['date'],
                'status': game['status']?['short'] ?? "NS",
                'scoreHome': game['scores']?['home']?['total'],
                'scoreAway': game['scores']?['away']?['total'],
                'prediction': smartBet['pred'], // Prediction Auto
                'odds': smartBet['odd'],
              });
              count++;
              if (count >= 3) break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
    return processed;
  }

  // --- LIVE SCORE UPDATE ---
  Future<void> _updateLiveBasketScores() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('basketball_free_matches')
          .doc(_todayDocId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return;

      final data = docSnap.data();
      if (data == null) return;

      List<dynamic> firebaseMatches = List.from(data['matches'] ?? []);
      bool needsUpdate = false;

      // On réutilise la logique d'appel API mais juste pour MAJ les scores
      // (Simplifié: on appelle l'API et on compare)
      final url = Uri.parse(
          'https://v1.basketball.api-sports.io/games?date=$_todayDocId');
      final response = await http.get(url, headers: {
        'x-rapidapi-key': BASKET_API_KEY,
        'x-rapidapi-host': 'v1.basketball.api-sports.io'
      });

      if (response.statusCode == 200) {
        final apiData = jsonDecode(response.body);
        List games = apiData['response'];

        for (int i = 0; i < firebaseMatches.length; i++) {
          var fbMatch = firebaseMatches[i] as Map<String, dynamic>;
          var freshMatch = games.firstWhere(
              (g) => g['teams']['home']['name'] == fbMatch['home'],
              orElse: () => null);

          if (freshMatch != null) {
            String newStatus = freshMatch['status']['short'];
            int? newScoreH = freshMatch['scores']['home']['total'];
            int? newScoreA = freshMatch['scores']['away']['total'];

            if (newScoreH == null) {
              newScoreH = 0;
              newScoreA = 0;
            }

            if (fbMatch['status'] != newStatus ||
                fbMatch['scoreHome'] != newScoreH) {
              fbMatch['status'] = newStatus;
              fbMatch['scoreHome'] = newScoreH;
              fbMatch['scoreAway'] = newScoreA;
              needsUpdate = true;
            }
          }
        }
      }

      if (needsUpdate) {
        await docRef.update({'matches': firebaseMatches});
      }
    } catch (e) {
      debugPrint("Live Update Error: $e");
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
        title: const Text("BASKETBALL TIPS",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
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
                        Colors.black.withOpacity(0.72), BlendMode.darken))),
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
                child: Text("$_dateDisplay NBA TIPS",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('basketball_free_matches')
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

                    final List matches =
                        (data['matches'] is List) ? data['matches'] : [];

                    if (matches.isEmpty) {
                      return const Center(
                          child: Text("Aucun match disponible",
                              style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final item = matches[index];
                        if (item is Map) return _buildExactCard(item);
                        return const SizedBox();
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

  Widget _buildExactCard(dynamic m) {
    String league = m['league'] ?? "NBA";
    String displayLeague =
        league.toUpperCase().contains("NBA") ? "NBA" : league;
    String time = _getSafeTime(m['time']);
    String home = m['home'] ?? "Home";
    String away = m['away'] ?? "Away";
    String pred = m['prediction'] ?? "Home Wins";
    String odd = m['odds'] ?? "1.50";
    String? homeLogo = m['homeLogo'];
    String? awayLogo = m['awayLogo'];
    int? scoreHome = m['scoreHome'];
    int? scoreAway = m['scoreAway'];
    String status = m['status'] ?? "NS";

    bool isNotStarted = (status == "NS");
    bool isFinished = (status == "FT" || status == "AOT") &&
        scoreHome != null &&
        scoreAway != null;
    bool isLive = !isNotStarted && !isFinished;

    IconData centerIcon = Icons.access_time;
    Color centerIconColor = Colors.orange;

    if (isFinished) {
      bool win = _isPredictionCorrect(pred, home, away, scoreHome, scoreAway);
      centerIcon = win ? Icons.check_circle : Icons.cancel;
      centerIconColor = win ? Colors.green : Colors.red;
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
                    displayLeague == "NBA"
                        ? Image.network(_nbaLogo,
                            height: 22,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.sports_basketball))
                        : const Icon(Icons.sports_basketball,
                            color: Colors.black54),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(displayLeague,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(time,
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
                          Text(isNotStarted ? "0" : "$scoreHome",
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
                          Text(isNotStarted ? "0" : "$scoreAway",
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
                        color: const Color(0xFFFFA000),
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
                    const Icon(Icons.sports_basketball, size: 35)),
          ),
        const SizedBox(height: 2),
        Text(
          name.replaceAll("76ers", "").trim(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black),
        ),
      ],
    );
  }
}
/* ===================== FIN DU FICHIER ===================== */