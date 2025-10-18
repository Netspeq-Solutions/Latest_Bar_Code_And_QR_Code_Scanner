import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen/Home_Screen.dart';
import 'network_services/network_google_sheets_api_call.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async in main

  // // Example: Fetch initial data
  // try {
  //   final data = await GoogleSheetsService.instance.callApi('get', {});
  //   print("Initial Google Sheets data: $data");
  // } catch (e) {
  //   print("Error fetching initial data: $e");
  // }

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



/*
import 'package:flutter/material.dart';
import 'home_screen/Home_Screen.dart';


void main() {
  runApp(const ProfessionalBarcodeScannerApp());
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

*/
