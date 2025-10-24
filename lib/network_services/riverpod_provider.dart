import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:latestversionscanner/modal/vendor_and_project_model.dart';

import 'network_google_sheets_api_call.dart';

final repositoryProvider = Provider<GoogleSheetsService>((ref) {
  return GoogleSheetsService();
});

final dataVendorAndProjectProvider =
    FutureProvider<List<VendorAndProjectModel>>((ref) async {
      final repository = ref.read(repositoryProvider);
      return await repository.fetchVendorAndProjectList();
    });

// Separate selected states
final selectedVendorProvider = StateProvider<VendorAndProjectModel?>(
  (ref) => null,
);
final selectedProjectProvider = StateProvider<VendorAndProjectModel?>(
  (ref) => null,
);
