import 'package:adl_fono/adl.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADL Fonoaudiologia',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FichaPacientePage(),
    );
  }
}
