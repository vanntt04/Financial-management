// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_management/providers/auth_provider.dart';
import 'package:financial_management/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.mainLayout);
    } else if (auth.status == AuthStatus.unauthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      auth.addListener(() {
        if (!mounted) return;
        if (auth.isAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.mainLayout);
        } else if (auth.status == AuthStatus.unauthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: c.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: c.onPrimary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet_rounded,
                  size: 64, color: c.onPrimary),
            ),
            const SizedBox(height: 20),
            Text('Finance Manager',
                style: TextStyle(
                    color: c.onPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Quản lý tài chính thông minh',
                style:
                    TextStyle(color: c.onPrimary.withOpacity(0.7), fontSize: 14)),
            const SizedBox(height: 48),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: c.onPrimary.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
