import 'package:adl_fono/adl.dart';
import 'package:adl_fono/adl_protocol_page.dart';
import 'package:adl_fono/history_page.dart';
import 'package:adl_fono/home_page.dart';
import 'package:adl_fono/login.dart';
import 'package:adl_fono/models/adl_protocol.dart';
import 'package:adl_fono/models/paciente_ficha.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FichaRepository.init();
  await AdlProtocolRepository.init();
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
                  as Map<String, String>?;
          return HomePage(userData: args);
        },
        '/anamnese': (_) => const FichaPacientePage(),
        '/history': (_) => const HistoryPage(),
        '/adl': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;
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
      },
    );
  }
}
