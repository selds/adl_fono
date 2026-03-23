import 'package:cloud_firestore/cloud_firestore.dart';

/// Define os papéis/roles disponíveis na aplicação.
enum UserRole {
  admin('admin'),
  fonoaudiologo('fonoaudiologo');

  final String value;
  const UserRole(this.value);

  factory UserRole.fromString(String? value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.fonoaudiologo,
    );
  }
}

/// Representa um usuário da aplicação com informações de autenticação e role.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;

  /// Verifica se o usuário tem permissão de admin.
  bool get isAdmin => role == UserRole.admin;

  /// Converte para JSON para salvar no Firestore.
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'role': role.value,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };

  /// Cria AppUser a partir de JSON.
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: (json['uid'] as String?) ?? '',
    email: (json['email'] as String?) ?? '',
    displayName: (json['displayName'] as String?) ?? (json['name'] as String?),
    photoUrl: json['photoUrl'] as String?,
    role: UserRole.fromString(json['role'] as String?),
    createdAt: _parseCreatedAt(json['createdAt']),
    isActive: (json['isActive'] ?? true) as bool,
  );

  static DateTime _parseCreatedAt(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Retorna cópia com mudanças aplicadas.
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
  }) => AppUser(
    uid: uid ?? this.uid,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
    isActive: isActive ?? this.isActive,
  );
}
