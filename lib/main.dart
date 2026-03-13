import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EA), // Tông màu tím/xanh hiện đại
          background: const Color(0xFFF5F7FA),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // Đã tách riêng 2 dòng này ra để không bị vướng vào comment
      initialRoute: AppRoutes.login,
      routes: AppRoutes.define(),

      debugShowCheckedModeBanner: false,
    );
  }
}