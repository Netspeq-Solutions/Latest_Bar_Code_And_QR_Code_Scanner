import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSheetsService {
  final String webAppUrl = "YOUR_EXEC_URL_HERE";

  Future<Map<String, dynamic>> callApi(
      String action, Map<String, dynamic> data) async {
    data['action'] = action;

    final response = await http.post(
      Uri.parse(webAppUrl),
      headers: {
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)", // <- Add this
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 302) {
      throw Exception(
          "Server returned 302 redirect. Make sure you are using the /exec URL.");
    } else {
      throw Exception(
          "Failed: ${response.statusCode} ${response.body.substring(0, 200)}");
    }
  }
}


/*// network_services/network_google_sheets_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSheetsService {
  final String webAppUrl =
      "https://script.google.com/macros/s/AKfycbyB4gdgK2AVSJwcwflULKF9zVj2Li5QSkMH1FLMtxc6XHyPcAs03bU2aKsH6RB0JANG/exec"; // Apps Script /exec URL

  // Singleton
  GoogleSheetsService._privateConstructor();
  static final GoogleSheetsService instance =
  GoogleSheetsService._privateConstructor();

  Future<Map<String, dynamic>> callApi(
      String action, Map<String, dynamic> data) async {
    data['action'] = action;

    final response = await http.post(
      Uri.parse(webAppUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    // Check for successful response
    if (response.statusCode == 200) {
      // Ensure the response is JSON
      if (response.headers['content-type'] != null &&
          response.headers['content-type']!.contains('application/json')) {
        print("Data Successfully Inserted");
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Expected JSON but got HTML or other content: ${jsonDecode(response.body)}");
      }
    } else if (response.statusCode == 302) {
      throw Exception(
          "Server returned 302 redirect. Check your Web App URL or deployment permissions.${response.body}");
    } else {
      throw Exception(
          "Failed: ${response.statusCode} ${response.body.substring(0, 200)}...");
    }
  }
}*/








/*// network_services/network_google_sheets_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSheetsService {
  final String webAppUrl = "https://script.google.com/macros/s/AKfycbyAh_VPvyifPKwKCRwsrXVbjRp5zcI201-wtzMTlD8ej93gdI8IVq0fD39apGNixWcB/exec"; // Apps Script /exec URL

  // Singleton
  GoogleSheetsService._privateConstructor();
  static final GoogleSheetsService instance = GoogleSheetsService._privateConstructor();

  Future<Map<String, dynamic>> callApi(String action, Map<String, dynamic> data) async {
    data['action'] = action;
    final response = await http.post(
      Uri.parse(webAppUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.statusCode} ${response.body}");
    }
  }
}*/



/*import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> callGoogleSheetAPI(String action, Map<String, dynamic> data) async {
  final url = Uri.parse("https://script.google.com/macros/s/AKfycbyAh_VPvyifPKwKCRwsrXVbjRp5zcI201-wtzMTlD8ej93gdI8IVq0fD39apGNixWcB/exec"); // Your exec URL
  data['action'] = action;

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  print("Status code: ${response.statusCode}");
  print("Response body: ${response.body}");

  if(response.statusCode == 200 || response.statusCode == 302) {
    final result = jsonDecode(response.body);
    print("Result: $result");
  } else {
    print("Error: Server returned ${response.statusCode}");
  }
}*/


/*import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> callGoogleSheetAPI(String action, Map<String, dynamic> data) async {
  try
      {
        final url = Uri.parse("https://script.google.com/macros/s/AKfycbxaIh_Zlzh2R47ju7P73gjppjW6RiafLbK7LKJyYQ3fB3Orpv_E7lH1BvQv-R-XDgg/exec");
        data['action'] = action;

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );

        if (response.statusCode != 200) {
          print(response.body);
          return "Error: ${response.statusCode} - ${response.reasonPhrase}";
        }
        print(response.body);
        return jsonDecode(response.body);
      }
  catch(e)
     {
          return "Error: $e";
     }
}*/
