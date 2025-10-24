import 'dart:convert';
import 'package:flutter/services.dart' as rootbundle;
import 'package:latestversionscanner/modal/project_model.dart';
import 'package:latestversionscanner/modal/vendor_model.dart';

class Repositotyprovider {
  Future<List<VendorModel>> vendorJsonLoadingData() async {
    // ✅ Load from vendor_model.json
    final response = await rootbundle.rootBundle.loadString(
      'asserts/json/vendor_model.json',
    );

    // Parse as List directly
    final List<dynamic> jsonData = jsonDecode(response);

    // Map to VendorModel list
    return jsonData.map((json) => VendorModel.fromjson(json)).toList();
  }

  Future<List<ProjectModel>> projectJsonLoadingData() async {
    // ✅ Load from projects_model.json
    final response = await rootbundle.rootBundle.loadString(
      'asserts/json/projects_model.json',
    );

    // Parse as List directly
    final List<dynamic> jsonData = jsonDecode(response);

    // Map to ProjectModel list
    return jsonData.map((json) => ProjectModel.fromJson(json)).toList();
  }
}
