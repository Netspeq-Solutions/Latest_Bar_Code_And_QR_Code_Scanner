import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen/Home_Screen.dart';



void main() {
  runApp(ProviderScope(child: const ProfessionalBarcodeScannerApp()));
}
class ProfessionalBarcodeScannerApp extends StatelessWidget {
  const ProfessionalBarcodeScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

