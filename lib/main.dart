import 'package:flutter/material.dart';
import 'package:otoport_mobile/features/splash/splash_page.dart';

void main() {
  runApp(const OtoportApp());
}

class OtoportApp extends StatelessWidget {
  const OtoportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Otoport Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}