import 'package:adl_fono/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Serviço centralizado para gerenciar autenticação e usuários.
class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static const _usersCollection = 'users';

  /// Faz login com e-mail e senha, retorna AppUser com role.
  static Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;

      // Garante perfil no Firestore e lê role persistida.
      final appUser = await _ensureUserProfile(user);
      return appUser;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  static Future<AppUser> _ensureUserProfile(User user) async {
    final email = (user.email ?? '').trim();

    final userRef = _firestore.collection(_usersCollection).doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      final createdUser = AppUser(
        uid: user.uid,
        email: email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        role: UserRole.fonoaudiologo,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
      await userRef.set(createdUser.toJson());
      return createdUser;
    }

    return AppUser.fromJson(doc.data()!);
  }

  /// Retorna o usuário atualmente logado.
  static AppUser? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;
    // Para usuário atual, sempre temos displayName/email/photoURL do Firebase
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      role: UserRole.fonoaudiologo,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Retorna o perfil atual com role persistida no Firestore.
  static Future<AppUser?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _ensureUserProfile(user);
  }

  /// Cria novo usuário com role especificado.
  /// Obs: Requer permissão de Admin para executar via Cloud Function.
  static Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.fonoaudiologo,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Falha ao criar usuário');

      // Atualiza displayName
      await user.updateDisplayName(displayName);

      // Salva dados do usuário no Firestore
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        role: role,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(appUser.toJson());
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Lista todos os usuários (recupera do Firestore).
  static Future<List<AppUser>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_usersCollection).get();
      return snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList()
        ..sort((a, b) => a.email.compareTo(b.email));
    } catch (e) {
      throw Exception('Erro ao buscar usuários: $e');
    }
  }

  /// Obtém um usuário específico por UID.
  static Future<AppUser?> getUserByUid(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  /// Atualiza role de um usuário (apenas admin pode executar).
  /// Obs: Em produção, isso deve ser feito via Cloud Function.
  static Future<void> updateUserRole({
    required String uid,
    required UserRole role,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'role': role.value,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar role: $e');
    }
  }

  /// Ativa/desativa um usuário.
  static Future<void> setUserActive({
    required String uid,
    required bool isActive,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'isActive': isActive,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar status do usuário: $e');
    }
  }

  /// Faz logout do usuário atual.
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  /// Envia e-mail de recuperação de senha.
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
