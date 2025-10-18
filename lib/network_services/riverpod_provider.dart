import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:latestversionscanner/modal/vendor_and_project_model.dart';

import 'network_google_sheets_api_call.dart';

final repositoryProvider = Provider<GoogleSheetsService>((ref) {
  return GoogleSheetsService();
});


final dataVendorAndProjectProvider = FutureProvider<List<VendorAndProjectModel>>((ref) async {
  final repository = ref.read(repositoryProvider);
  return await repository.fetchVendorAndProjectList();
});


/// Provider for calling `callApi` dynamically
final callApiProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
      (ref, Map<String, dynamic> params) async {
    final repository = ref.read(repositoryProvider);
    final action = params['action'] as String? ?? '';
    final data = Map<String, dynamic>.from(params); // clone to avoid mutating input
    return await repository.callApi(action, data);
  },
);


// Separate selected states
final selectedVendorProvider = StateProvider<VendorAndProjectModel?>((ref) => null);
final selectedProjectProvider = StateProvider<VendorAndProjectModel?>((ref) => null);