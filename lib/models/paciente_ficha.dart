import 'package:cloud_firestore/cloud_firestore.dart';
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

/// Repositório para fichas de pacientes — persistência via Cloud Firestore.
class FichaRepository {
  FichaRepository._();

  static const _collection = 'pacientes';
  static List<PacienteFicha> _entries = [];
  static final _db = FirebaseFirestore.instance;

  static Future<void> init() async {
    final snapshot = await _db.collection(_collection).get();
    _entries = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PacienteFicha.fromJson(data);
    }).toList();
    _entries.sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  static List<PacienteFicha> get all => List.unmodifiable(_entries);

  static Future<void> add(PacienteFicha ficha) async {
    final data = ficha.toJson()..remove('id');
    await _db.collection(_collection).doc(ficha.id).set(data);
    _entries.add(ficha);
  }

  static Future<void> update(
    PacienteFicha original,
    PacienteFicha updated,
  ) async {
    final data = updated.toJson()..remove('id');
    await _db.collection(_collection).doc(original.id).update(data);
    final index = _entries.indexWhere((e) => e.id == original.id);
    if (index != -1) {
      _entries[index] = updated;
    }
  }

  static Future<void> clear() async {
    final batch = _db.batch();
    for (final e in _entries) {
      batch.delete(_db.collection(_collection).doc(e.id));
    }
    await batch.commit();
    _entries.clear();
  }

  static Future<void> remove(PacienteFicha ficha) async {
    await _db.collection(_collection).doc(ficha.id).delete();
    _entries.removeWhere((e) => e.id == ficha.id);
  }
}
