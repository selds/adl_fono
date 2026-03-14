import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PacienteFicha {
  PacienteFicha({
    String? id,
    required this.nomeCrianca,
    required this.dataNascimento,
    required this.sexo,
    required this.diagnostico,
    required this.responsavel,
    required this.dataAvaliacao,
    required this.avaliador,
    required this.especialidade,
    required this.atividades,
    required this.ambienteFamiliar,
    required this.demandaFamiliar,
    DateTime? savedAt,
  }) : id = id ?? const Uuid().v4(),
       savedAt = savedAt ?? DateTime.now();

  final String id;
  final String nomeCrianca;
  final String dataNascimento;
  final String sexo;
  final String diagnostico;
  final String responsavel;
  final String dataAvaliacao;
  final String avaliador;
  final String especialidade;
  final String atividades;
  final String ambienteFamiliar;
  final String demandaFamiliar;
  final DateTime savedAt;

  // Método para converter para JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'nomeCrianca': nomeCrianca,
    'dataNascimento': dataNascimento,
    'sexo': sexo,
    'diagnostico': diagnostico,
    'responsavel': responsavel,
    'dataAvaliacao': dataAvaliacao,
    'avaliador': avaliador,
    'especialidade': especialidade,
    'atividades': atividades,
    'ambienteFamiliar': ambienteFamiliar,
    'demandaFamiliar': demandaFamiliar,
    'savedAt': savedAt.toIso8601String(),
  };

  // Método para criar a partir de JSON
  factory PacienteFicha.fromJson(Map<String, dynamic> json) => PacienteFicha(
    id: json['id'],
    nomeCrianca: json['nomeCrianca'],
    dataNascimento: json['dataNascimento'],
    sexo: json['sexo'],
    diagnostico: json['diagnostico'],
    responsavel: json['responsavel'],
    dataAvaliacao: json['dataAvaliacao'],
    avaliador: json['avaliador'],
    especialidade: json['especialidade'],
    atividades: json['atividades'],
    ambienteFamiliar: json['ambienteFamiliar'],
    demandaFamiliar: json['demandaFamiliar'],
    savedAt: DateTime.parse(json['savedAt']),
  );
}

/// Repositório para manter os registros salvos com persistência em disco.
///
class FichaRepository {
  FichaRepository._();

  static const String _key = 'paciente_fichas';
  static List<PacienteFicha> _entries = [];

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List;
      _entries = jsonList.map((e) => PacienteFicha.fromJson(e)).toList();
    }
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _entries.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static List<PacienteFicha> get all => List.unmodifiable(_entries);

  static Future<void> add(PacienteFicha ficha) async {
    _entries.add(ficha);
    await _save();
  }

  static Future<void> update(
    PacienteFicha original,
    PacienteFicha updated,
  ) async {
    final index = _entries.indexWhere((e) => e.id == original.id);
    if (index != -1) {
      _entries[index] = updated;
      await _save();
    }
  }

  static Future<void> clear() async {
    _entries.clear();
    await _save();
  }

  static Future<void> remove(PacienteFicha ficha) async {
    _entries.removeWhere((e) => e.id == ficha.id);
    await _save();
  }
}
