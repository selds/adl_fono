import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AdlProtocol {
  AdlProtocol({
    String? id,
    required this.pacienteId,
    required this.receptiveAnswers,
    required this.expressiveAnswers,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String pacienteId;
  final Map<String, dynamic> receptiveAnswers;
  final Map<String, dynamic> expressiveAnswers;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'pacienteId': pacienteId,
    'receptiveAnswers': receptiveAnswers,
    'expressiveAnswers': expressiveAnswers,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AdlProtocol.fromJson(Map<String, dynamic> json) => AdlProtocol(
    id: json['id'],
    pacienteId: json['pacienteId'],
    receptiveAnswers: Map<String, dynamic>.from(
      (json['receptiveAnswers'] as Map?) ?? {},
    ),
    expressiveAnswers: _parseExpressiveAnswers(json),
    createdAt: DateTime.parse(json['createdAt']),
  );

  static Map<String, dynamic> _parseExpressiveAnswers(
    Map<String, dynamic> json,
  ) {
    final fromMap = Map<String, dynamic>.from(
      (json['expressiveAnswers'] as Map?) ?? {},
    );

    if (fromMap.isNotEmpty) return fromMap;

    // Retrocompatibilidade com o formato antigo.
    return {
      'q1Score': '',
      'q1Text': json['produzSons'] as String? ?? '',
      'q2Score': '',
      'q2Text': json['vocabulario'] as String? ?? '',
      'q3Score': '',
      'q3Text': json['comunicacaoNaoVerbal'] as String? ?? '',
      'q4Score': '',
      'q4Text': json['imitaPalavra'] as String? ?? '',
    };
  }
}

/// Repositório para protocolos ADL — persistência via Cloud Firestore.
class AdlProtocolRepository {
  AdlProtocolRepository._();

  static const _collection = 'adl_protocols';
  static List<AdlProtocol> _entries = [];
  static final _db = FirebaseFirestore.instance;

  static Future<void> init() async {
    final snapshot = await _db.collection(_collection).get();
    _entries = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AdlProtocol.fromJson(data);
    }).toList();
  }

  static List<AdlProtocol> get all => List.unmodifiable(_entries);

  static List<AdlProtocol> forPaciente(String pacienteId) {
    return _entries.where((e) => e.pacienteId == pacienteId).toList();
  }

  static AdlProtocol? byId(String id) {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> add(AdlProtocol protocol) async {
    final data = protocol.toJson()..remove('id');
    await _db.collection(_collection).doc(protocol.id).set(data);
    _entries.add(protocol);
  }

  static Future<void> update(AdlProtocol original, AdlProtocol updated) async {
    final data = updated.toJson()..remove('id');
    await _db.collection(_collection).doc(original.id).update(data);
    final index = _entries.indexWhere((e) => e.id == original.id);
    if (index != -1) {
      _entries[index] = updated;
    }
  }

  static Future<void> remove(AdlProtocol protocol) async {
    await _db.collection(_collection).doc(protocol.id).delete();
    _entries.removeWhere((e) => e.id == protocol.id);
  }
}
