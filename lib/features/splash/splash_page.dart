import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otoport_mobile/core/storage/token_storage.dart';
import 'package:otoport_mobile/features/auth/pages/login_page.dart';
import 'package:otoport_mobile/features/auth/services/auth_service.dart';

import '../admin/pages/admin_home_page.dart';
import '../client/pages/client_home_page.dart';
import '../store/pages/store_home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    debugPrint('Splash: _checkSession başladı');

    try {
      final token = await _tokenStorage.getAccessToken();
      debugPrint('Splash: token var mı = ${token != null && token.isNotEmpty}');

      if (token == null || token.trim().isEmpty) {
        _goToLogin();
        return;
      }

      final me = await _authService.me().timeout(
        const Duration(seconds: 12),
      );

      debugPrint(
        'Splash: me authenticated=${me.authenticated}, role=${me.role}',
      );

      if (!me.authenticated || me.role == null || me.role!.trim().isEmpty) {
        await _tokenStorage.clearAll();
        _goToLogin();
        return;
      }

      final role = me.role!.trim().toUpperCase().replaceFirst('ROLE_', '');

      if (role == 'ADMIN') {
        _goToAdmin();
        return;
      }

      if (role == 'STORE') {
        _goToStore();
        return;
      }

      if (role == 'CLIENT') {
        _goToClient();
        return;
      }

      await _tokenStorage.clearAll();
      _goToLogin();
    } on TimeoutException {
      debugPrint('Splash: session check timeout');
      await _tokenStorage.clearAll();
      _goToLogin();
    } catch (e, st) {
      debugPrint('Splash error: $e');
      debugPrint('$st');
      await _tokenStorage.clearAll();
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (!mounted || _navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _goToAdmin() {
    if (!mounted || _navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AdminHomePage()),
    );
  }

  void _goToStore() {
    if (!mounted || _navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const StoreHomePage()),
    );
  }

  void _goToClient() {
    if (!mounted || _navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ClientHomePage(isGuest: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}