import 'package:adl_fono/adl.dart';
import 'package:adl_fono/adl_protocol_page.dart';
import 'package:adl_fono/admin/access_logs_page.dart';
import 'package:adl_fono/admin/user_management_page.dart';
import 'package:adl_fono/firebase_options.dart';
import 'package:adl_fono/history_page.dart';
import 'package:adl_fono/home_page.dart';
import 'package:adl_fono/login.dart';
import 'package:adl_fono/models/adl_protocol.dart';
import 'package:adl_fono/models/app_user.dart';
import 'package:adl_fono/models/paciente_ficha.dart';
import 'package:adl_fono/report_page.dart';
import 'package:adl_fono/scores_page.dart';
import 'package:adl_fono/services/auth_service.dart';
import 'package:adl_fono/services/theme_service.dart';
import 'package:adl_fono/widgets/session_guard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FichaRepository.init();
    await AdlProtocolRepository.init();
  } catch (e, stack) {
    debugPrint('Firebase init error: $e\n$stack');
  }
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await ThemeService.loadThemeMode();
    if (!mounted) return;
    setState(() => _themeMode = mode);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    setState(() => _themeMode = mode);
    await ThemeService.saveThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avaliação do Desenvolvimento da Linguagem - 2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        pageTransitionsTheme: kIsWeb
            ? const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: _FadePageTransitionsBuilder(),
                  TargetPlatform.iOS: _FadePageTransitionsBuilder(),
                  TargetPlatform.macOS: _FadePageTransitionsBuilder(),
                  TargetPlatform.linux: _FadePageTransitionsBuilder(),
                  TargetPlatform.windows: _FadePageTransitionsBuilder(),
                  TargetPlatform.fuchsia: _FadePageTransitionsBuilder(),
                },
              )
            : const PageTransitionsTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        pageTransitionsTheme: kIsWeb
            ? const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: _FadePageTransitionsBuilder(),
                  TargetPlatform.iOS: _FadePageTransitionsBuilder(),
                  TargetPlatform.macOS: _FadePageTransitionsBuilder(),
                  TargetPlatform.linux: _FadePageTransitionsBuilder(),
                  TargetPlatform.windows: _FadePageTransitionsBuilder(),
                  TargetPlatform.fuchsia: _FadePageTransitionsBuilder(),
                },
              )
            : const PageTransitionsTheme(),
      ),
      themeMode: _themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return SessionGuard(
            child: HomePage(
              userData: args,
              currentThemeMode: _themeMode,
              onThemeModeChanged: _setThemeMode,
            ),
          );
        },
        '/anamnese': (_) => const SessionGuard(child: FichaPacientePage()),
        '/scores': (_) => const SessionGuard(child: ScoresPage()),
        '/report': (_) => const SessionGuard(child: ReportPage()),
        '/history': (_) => const SessionGuard(child: HistoryPage()),
        '/adl': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          final pacienteId = args['pacienteId']!;
          final protocolId = args['protocolId'];
          final protocol = protocolId == null
              ? null
              : AdlProtocolRepository.byId(protocolId);
          return SessionGuard(
            child: AdlProtocolPage(pacienteId: pacienteId, protocol: protocol),
          );
        },
        '/edit': (context) {
          final ficha =
              ModalRoute.of(context)!.settings.arguments as PacienteFicha;
          return SessionGuard(
            child: FichaPacientePage(
              initialFicha: ficha,
              onSave: (updated) async {
                await FichaRepository.update(ficha, updated);
              },
            ),
          );
        },
        '/admin': (context) {
          return SessionGuard(
            child: FutureBuilder<AppUser?>(
              future: AuthService.getCurrentUserProfile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final appUser = snapshot.data;
                if (appUser == null || !appUser.isAdmin) {
                  return _buildAccessDeniedPage(context);
                }
                return const UserManagementPage();
              },
            ),
          );
        },
        '/admin/logs': (context) {
          return SessionGuard(
            child: FutureBuilder<AppUser?>(
              future: AuthService.getCurrentUserProfile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final appUser = snapshot.data;
                if (appUser == null || !appUser.isAdmin) {
                  return _buildAccessDeniedPage(context);
                }
                return const AccessLogsPage();
              },
            ),
          );
        },
      },
    );
  }

  static Widget _buildAccessDeniedPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acesso Negado')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Acesso Negado',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você não tem permissão para acessar esta página.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text('Voltar ao Início'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transição de página rápida (fade simples) para melhor desempenho no Web.
class _FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
