import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../modal/project_model.dart';
import '../../modal/vendor_model.dart';
import '../api_call/api_call.dart';


final repositoryProvider = Provider<Repositotyprovider>((ref) {
  return Repositotyprovider();
});


final vendorDataProvider = FutureProvider<List<VendorModel>>((ref) async {
  final repository = ref.read(repositoryProvider);
  return await repository.vendorJsonLoadingData();
});

// ✅ FIXED: Changed to List<ProjectModel>
final projectDataProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final repository = ref.read(repositoryProvider);
  return await repository.projectJsonLoadingData();
});


// ✅ ADD THESE TWO NEW PROVIDERS
final selectedVendorProvider = StateProvider<VendorModel?>((ref) => null);
final selectedProjectProvider = StateProvider<ProjectModel?>((ref) => null);