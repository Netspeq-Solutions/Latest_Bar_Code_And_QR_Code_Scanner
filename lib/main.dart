import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen/Home_Screen.dart';
import 'network_services/network_google_sheets_api_call.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Example: Optional initialization
  // try {
  //   final data = await GoogleSheetsService.instance.callApi('get', {});
  //   print("Initial Google Sheets data: $data");
  // } catch (e) {
  //   print("Error fetching initial data: $e");
  // }

  // ✅ Wrap app with ProviderScope for Riverpod
  runApp(const ProviderScope(child: ProfessionalBarcodeScannerApp()));
}

class ProfessionalBarcodeScannerApp extends StatelessWidget {
  const ProfessionalBarcodeScannerApp({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}
