import 'package:adl_fono/adl.dart';
import 'package:adl_fono/adl_protocol_page.dart';
import 'package:adl_fono/admin/user_management_page.dart';
import 'package:adl_fono/firebase_options.dart';
import 'package:adl_fono/history_page.dart';
import 'package:adl_fono/home_page.dart';
import 'package:adl_fono/login.dart';
import 'package:adl_fono/models/adl_protocol.dart';
import 'package:adl_fono/models/paciente_ficha.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FichaRepository.init();
  await AdlProtocolRepository.init();
  } catch (e, stack) {
    debugPrint('Firebase init error: $e\n$stack');
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADL Fonoaudiologia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                                  as Map<String, dynamic>?;
          return HomePage(userData: args);
        },
        '/anamnese': (_) => const FichaPacientePage(),
        '/history': (_) => const HistoryPage(),
        '/adl': (context) {
          final args =
                      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final pacienteId = args['pacienteId']!;
          final protocolId = args['protocolId'];
          final protocol = protocolId == null
              ? null
              : AdlProtocolRepository.byId(protocolId);
          return AdlProtocolPage(pacienteId: pacienteId, protocol: protocol);
        },
        '/edit': (context) {
          final ficha =
              ModalRoute.of(context)!.settings.arguments as PacienteFicha;
          return FichaPacientePage(
            initialFicha: ficha,
            onSave: (updated) async {
              await FichaRepository.update(ficha, updated);
            },
          );
        },
        '/admin': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final isAdmin = args?['isAdmin'] as bool? ?? false;

          if (!isAdmin) {
            return _buildAccessDeniedPage(context);
          }
          return const UserManagementPage();
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
