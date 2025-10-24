import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latestversionscanner/modal/vendor_and_project_model.dart';

class GoogleSheetsService {
  final String webAppUrl =
      "https://script.google.com/macros/s/AKfycby7lD-Ik6ovsPzsZo-buIQvQdUuYx5UkGa9vKl0VjS5g1V0VVwWEOmCUNeWf-EdgJWO/exec";
  final String webAppUrlToGetVendorAndProjectList =
      "https://script.google.com/macros/s/AKfycbyYovYWTRB6MkZD3--oMPt0k6luRnxUrCg-WqP7kg5jRMHI1Pi37vOW6UvJ-3xgDa_R/exec";

  Future<Map<String, dynamic>> callApi(String action, Map<String, dynamic> data) async {
    data['action'] = action;

    var response = await http.post(
      Uri.parse(webAppUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    // Handle 302 redirect manually
    if (response.statusCode == 302 || response.statusCode == 301) {
      final redirectUrl = _extractRedirectUrl(response.body);

      if (redirectUrl != null) {
        print("Following redirect to: $redirectUrl");
        response = await http.get(Uri.parse(redirectUrl));
        print("Redirect Status Code: ${response.statusCode}");
        print("Redirect Response Body: ${response.body}");
      }
    }

    // Process the final response
    if (response.statusCode >= 200 && response.statusCode < 400) {
      try {
        if (response.body.isNotEmpty && !response.body.startsWith('<')) {
          // Parse JSON string to Map
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
      } catch (e) {
        print("Could not parse JSON: $e");
      }

      // Return generic success if parsing fails
      return {
        "status": "success",
        "message": "Data stored successfully",
        "statusCode": response.statusCode,
      };
    } else {
      throw Exception("Failed: ${response.statusCode}\nBody: ${response.body}");
    }
  }

  String? _extractRedirectUrl(String html) {
    final match = RegExp(r'HREF="([^"]+)"').firstMatch(html);
    return match?.group(1)?.replaceAll('&amp;', '&');
  }

  Future<List<VendorModel>> fetchAllVendor() async {
    try {
      const String action = "GetAllVendor";
      final uri = Uri.parse(webAppUrlToGetVendorAndProjectList).replace(
        queryParameters: {
          'action': action,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => VendorModel.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Failed to load vendor and project list. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("Error fetching vendor and project list: $e");
      return [];
    }
  }

  Future<List<ProjectModel>> fetchAllSpecificProjectName(int vendorId) async {
    try {
      const String action = "GetAllProjectByID";
      final uri = Uri.parse(webAppUrlToGetVendorAndProjectList).replace(
        queryParameters: {
          'action': action,
          'vendor_id': vendorId.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        // Map JSON to ProjectModel
        return jsonData
            .map((jsonItem) => ProjectModel.fromJson(jsonItem))
            .toList();
      } else {
        throw Exception(
            'Failed to load vendor and project list. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching vendor and project list: $e");
      return [];
    }
  }
}

/*
import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSheetsService {
  final String webAppUrl = "https://script.google.com/macros/s/AKfycbyB4gdgK2AVSJwcwflULKF9zVj2Li5QSkMH1FLMtxc6XHyPcAs03bU2aKsH6RB0JANG/exec";

  Future<Map<String, dynamic>> callApi(
      String action, Map<String, dynamic> data) async {
    data['action'] = action;

    var response = await http.post(
      Uri.parse(webAppUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    // Handle 302 redirect manually
    if (response.statusCode == 302 || response.statusCode == 301) {
      // Extract redirect URL from HTML response
      final redirectUrl = _extractRedirectUrl(response.body);

      if (redirectUrl != null) {
        print("Following redirect to: $redirectUrl");

        // Make GET request to the redirect URL
        response = await http.get(Uri.parse(redirectUrl));

        print("Redirect Status Code: ${response.statusCode}");
        print("Redirect Response Body: ${response.body}");
      }
    }

    // Process the final response
    if (response.statusCode >= 200 && response.statusCode < 400) {
      try {
        if (response.body.isNotEmpty && !response.body.startsWith('<')) {
          return jsonDecode(response.body);
        }
      } catch (e) {
        print("Could not parse JSON: $e");
      }

      // Return generic success if parsing fails
      return {
        "status": "success",
        "message": "Data stored successfully",
        "statusCode": response.statusCode
      };
    } else {
      throw Exception(
          "Failed: ${response.statusCode}\nBody: ${response.body}");
    }
  }

  // Extract redirect URL from HTML response
  String? _extractRedirectUrl(String html) {
    final hrefRegex = RegExp(r'HREF="([^"]+)"');
    final match = hrefRegex.firstMatch(html);
    if (match != null && match.groupCount >= 1) {
      var url = match.group(1)!;
      // Decode HTML entities
      url = url.replaceAll('&amp;', '&');
      return url;
    }
    return null;
  }
}*/
