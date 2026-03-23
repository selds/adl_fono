import 'dart:async';

import 'package:adl_fono/services/auth_service.dart';
import 'package:flutter/material.dart';

class SessionGuard extends StatefulWidget {
  const SessionGuard({super.key, required this.child});

  final Widget child;

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  Timer? _timer;
  bool _handlingLogout = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _checkAccess());
  }

  Future<void> _checkAccess() async {
    if (!mounted || _handlingLogout) return;

    try {
      final profile = await AuthService.getCurrentUserProfile();
      if (!mounted || _handlingLogout) return;

      if (profile == null || !profile.isActive) {
        _handlingLogout = true;
        _timer?.cancel();
        await AuthService.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sua conta foi desativada. Entre em contato com o suporte.',
            ),
          ),
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (_) {
      // Erros transitórios de rede não devem forçar logout.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
