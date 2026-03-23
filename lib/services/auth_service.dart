import 'package:adl_fono/models/access_log_entry.dart';
import 'package:adl_fono/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:adl_fono/firebase_options.dart';
import 'package:image_picker/image_picker.dart';

/// Serviço centralizado para gerenciar autenticação e usuários.
class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;
  static const _usersCollection = 'users';
  static const _accessLogsCollection = 'access_logs';

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
      if (!appUser.isActive) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'Conta desativada. Entre em contato com o suporte.',
        );
      }

      // Melhor esforço: falha ao salvar log não deve bloquear o login.
      try {
        await _saveAccessLog(appUser);
      } catch (_) {}

      return appUser;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  static Future<void> _saveAccessLog(AppUser user) async {
    await _firestore.collection(_accessLogsCollection).add({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? '',
      'role': user.role.value,
      'loginAt': Timestamp.now(),
    });
  }

  static Future<List<AccessLogEntry>> getAccessLogs() async {
    try {
      final snapshot = await _firestore
          .collection(_accessLogsCollection)
          .orderBy('loginAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => AccessLogEntry.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
          'Sem permissão para ler logs. Verifique se as regras do Firestore foram publicadas e se seu usuário é admin ativo.',
        );
      }
      throw Exception('Erro ao buscar logs de acesso: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Erro ao buscar logs de acesso: $e');
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

    final data = Map<String, dynamic>.from(doc.data()!);
    final uidValue = data['uid'];
    final emailValue = data['email'];
    final roleValue = data['role'];
    final isActiveValue = data['isActive'];
    final docDisplayName = (data['displayName'] as String?)?.trim() ?? '';
    final legacyName = (data['name'] as String?)?.trim() ?? '';
    final authDisplayName = (user.displayName ?? '').trim();
    final resolvedDisplayName = docDisplayName.isNotEmpty
      ? docDisplayName
      : (legacyName.isNotEmpty
          ? legacyName
          : (authDisplayName.isNotEmpty
            ? authDisplayName
            : _deriveDisplayNameFromEmail(email)));
    final docPhoto = (data['photoUrl'] as String?)?.trim() ?? '';
    final authPhoto = (user.photoURL ?? '').trim();
    final resolvedPhotoUrl = docPhoto.isNotEmpty ? docPhoto : authPhoto;

    final patched = <String, dynamic>{
      ...data,
      'uid': uidValue is String && uidValue.isNotEmpty ? uidValue : user.uid,
      'email': emailValue is String && emailValue.isNotEmpty
          ? emailValue
          : email,
      'displayName': resolvedDisplayName,
      // Campo legado mantido para compatibilidade com dados antigos.
      'name': resolvedDisplayName,
      'photoUrl': resolvedPhotoUrl,
      'role': roleValue is String && roleValue.isNotEmpty
          ? roleValue
          : UserRole.fonoaudiologo.value,
      'createdAt':
          data['createdAt'] ??
          (user.metadata.creationTime ?? DateTime.now()).toIso8601String(),
      'isActive': isActiveValue is bool ? isActiveValue : true,
    };

    final needsPatch =
        data['uid'] is! String ||
        data['email'] is! String ||
      docDisplayName.isEmpty ||
        data['role'] is! String ||
        data['createdAt'] == null ||
        data['isActive'] is! bool;

    // Se o documento foi criado manualmente sem campos obrigatórios, completa aqui.
    if (needsPatch) {
      await userRef.set(patched, SetOptions(merge: true));
    }

    if ((user.displayName ?? '').trim() != resolvedDisplayName) {
      try {
        await user.updateDisplayName(resolvedDisplayName);
      } catch (_) {}
    }

    return AppUser.fromJson(patched);
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

  /// Atualiza dados básicos do perfil do usuário atual.
  static Future<void> updateCurrentUserProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nenhum usuário autenticado.');
    }

    final normalizedName = displayName.trim();
    final normalizedPhoto = (photoUrl ?? '').trim();

    if (normalizedName.isEmpty) {
      throw Exception('Nome não pode ficar vazio.');
    }

    // Mantém Firestore e perfil do Firebase Auth alinhados para exibição.
    await user.updateDisplayName(normalizedName);
    await user.updatePhotoURL(normalizedPhoto.isEmpty ? null : normalizedPhoto);

    await _firestore.collection(_usersCollection).doc(user.uid).set({
      'uid': user.uid,
      'displayName': normalizedName,
      // Campo legado para telas antigas que ainda referenciem name.
      'name': normalizedName,
      'photoUrl': normalizedPhoto,
      'email': user.email ?? '',
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Faz upload da foto de perfil do usuário atual e retorna a URL pública.
  static Future<String> uploadCurrentUserProfilePhoto(XFile file) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nenhum usuário autenticado.');
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('Arquivo de imagem inválido.');
    }

    final extension = _extensionFromName(file.name);
    final path = 'profile_photos/${user.uid}/avatar.$extension';
    final ref = _storage.ref().child(path);

    final metadata = SettableMetadata(
      contentType: _contentTypeForExtension(extension),
      customMetadata: {
        'uid': user.uid,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }

  static String _extensionFromName(String name) {
    final normalized = name.trim().toLowerCase();
    final idx = normalized.lastIndexOf('.');
    if (idx == -1 || idx == normalized.length - 1) {
      return 'jpg';
    }
    final ext = normalized.substring(idx + 1);
    if (ext == 'jpeg' || ext == 'jpg' || ext == 'png' || ext == 'webp') {
      return ext;
    }
    return 'jpg';
  }

  static String _contentTypeForExtension(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }

  static String _deriveDisplayNameFromEmail(String email) {
    final normalized = email.trim();
    if (normalized.isEmpty) return 'Usuário';
    final at = normalized.indexOf('@');
    if (at <= 0) return normalized;
    return normalized.substring(0, at);
  }

  /// Cria novo usuário com role especificado.
  /// Obs: Requer permissão de Admin para executar via Cloud Function.
  static Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.fonoaudiologo,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      // Cria usuário em uma instância secundária para não trocar a sessão do admin.
      final appName = 'user-mgmt-${DateTime.now().microsecondsSinceEpoch}';
      secondaryApp = await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
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
          .set({...appUser.toJson(), 'name': displayName});
    } on FirebaseAuthException {
      rethrow;
    } finally {
      if (secondaryApp != null) {
        try {
          await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
        } catch (_) {}
        await secondaryApp.delete();
      }
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
