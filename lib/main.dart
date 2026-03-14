import 'package:adl_fono/adl.dart';
import 'package:adl_fono/history_page.dart';
import 'package:adl_fono/models/paciente_ficha.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FichaRepository.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADL Fonoaudiologia',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (_) => const FichaPacientePage(),
        '/history': (_) => const HistoryPage(),
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
