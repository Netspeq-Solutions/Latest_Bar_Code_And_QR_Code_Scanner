import 'package:latestversionscanner/vendor_project_service/riverpod/repository_provider.dart';
import 'package:riverpod/riverpod.dart';
import '../../modal/project_model.dart';
import '../../modal/vendor_model.dart';

final vendorDataProvider = FutureProvider<List<VendorModel>>((ref) async {
  final repository = ref.read(repositoryProvider);
  return await repository.vendorJsonLoadingData();
});

// ✅ FIXED: Changed to List<ProjectModel>
final projectDataProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final repository = ref.read(repositoryProvider);
  return await repository.projectJsonLoadingData();
});
