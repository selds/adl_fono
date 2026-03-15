import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

class AdlProtocolRepository {
  AdlProtocolRepository._();

  static const _key = 'adl_protocols';
  static List<AdlProtocol> _entries = [];

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List;
      _entries = jsonList.map((e) => AdlProtocol.fromJson(e)).toList();
    }
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _entries.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
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
    _entries.add(protocol);
    await _save();
  }

  static Future<void> update(AdlProtocol original, AdlProtocol updated) async {
    final index = _entries.indexWhere((e) => e.id == original.id);
    if (index != -1) {
      _entries[index] = updated;
      await _save();
    }
  }

  static Future<void> remove(AdlProtocol protocol) async {
    _entries.removeWhere((e) => e.id == protocol.id);
    await _save();
  }
}
