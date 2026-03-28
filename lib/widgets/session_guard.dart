import 'dart:async';

import 'package:adl_fono/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SessionGuard extends StatefulWidget {
  const SessionGuard({super.key, required this.child});

  final Widget child;

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  Timer? _timer;
  StreamSubscription<User?>? _authSub;
  bool _handlingLogout = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _checkAccess());
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _redirectToLogin();
        return;
      }
      _checkAccess();
    });
  }

  Future<void> _checkAccess() async {
    if (!mounted || _handlingLogout) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        await _redirectToLogin();
        return;
      }

      final profile = await AuthService.getCurrentUserProfile();
      if (!mounted || _handlingLogout) return;

      if (profile == null) {
        await _redirectToLogin();
        return;
      }

      if (!profile.isActive) {
        await _redirectToLogin(
          signOut: true,
          message: 'Sua conta foi desativada. Entre em contato com o suporte.',
        );
        return;
      }

      if (_isChecking && mounted) {
        setState(() => _isChecking = false);
      }
    } catch (_) {
      // Erros transitórios de rede não devem forçar logout.
    }
  }

  Future<void> _redirectToLogin({bool signOut = false, String? message}) async {
    if (!mounted || _handlingLogout) return;

    _handlingLogout = true;
    _timer?.cancel();

    if (signOut) {
      try {
        await AuthService.signOut();
      } catch (_) {}
    }

    if (!mounted) return;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return widget.child;
  }
}
