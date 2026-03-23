import 'package:cloud_firestore/cloud_firestore.dart';

class AccessLogEntry {
  const AccessLogEntry({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.loginAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final String role;
  final DateTime loginAt;

  factory AccessLogEntry.fromJson(Map<String, dynamic> json) {
    final rawDate = json['loginAt'];
    DateTime parsed;
    if (rawDate is Timestamp) {
      parsed = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsed = rawDate;
    } else if (rawDate is String) {
      parsed = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsed = DateTime.now();
    }

    return AccessLogEntry(
      uid: (json['uid'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      displayName: (json['displayName'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'fonoaudiologo',
      loginAt: parsed,
    );
  }
}
