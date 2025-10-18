import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latestversionscanner/Device_Info_Module/device_info_app.dart';
import 'package:latestversionscanner/home_screen/custom_button.dart';

import '../component_serialnumber_discription_photo.dart';
import '../components/drop_down_conponent.dart';
import '../image_upload_module/image_upload_module.dart';
import '../modal/project_model.dart';
import '../modal/scanned_item_modal.dart';
import '../modal/vendor_model.dart';
import '../network_services/network_google_sheets_api_call.dart';
import '../scanner_module/scanner_module.dart';
import '../sqlite_manager/database_helper.dart';
import 'package:flutter/services.dart';
import '../services/riverpod/provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<ScannedItemModal> scannedList = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadScannedData();
  }

  Future<void> _loadScannedData() async {
    final List<Map<String, dynamic>> rawData =
    await _databaseHelper.readData('SerialNumberStoreTable');

    final List<ScannedItemModal> allData =
    rawData.map((row) => ScannedItemModal.fromJson(row)).toList();

    setState(() {
      scannedList.clear();
      scannedList.addAll(allData);
    });
  }

  Future<void> _deleteScanned(String serialNumber) async {
    await _databaseHelper.deleteData('SerialNumberStoreTable', serialNumber);
    _loadScannedData();
  }

  @override
  Widget build(BuildContext context) {
    final vendorsAsync = ref.watch(vendorDataProvider);
    final projectsAsync = ref.watch(projectDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Scanned List")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Scan Buttons Row
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScannerModule(),
                          ),
                        ).then((_) {
                          _loadScannedData();
                        });
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.qr_code, size: 40),
                          SizedBox(height: 8),
                          Text("Scan QR or Bar",
                              style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final ListOfScannedDataAndResponseMessage
                          scanResponse = await uploadImageAndScan();

                          if (scanResponse.listOfScannedData != null &&
                              scanResponse.listOfScannedData!.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(scanResponse.responseMessage),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 5)),
                            );

                            final List<Map<String, dynamic>> codeMaps =
                            scanResponse.listOfScannedData!
                                .map((code) => code.mapToJson())
                                .toList();

                            final dbResponse = await _databaseHelper
                                .insertDataList(
                                "SerialNumberStoreTable", codeMaps);
                            _loadScannedData();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(dbResponse),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 5)),
                            );

                            print("Insert response: $dbResponse");
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(scanResponse.responseMessage),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        } catch (e) {
                          print("Error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Error: $e"),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5)),
                          );
                        }
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.image_outlined, size: 40),
                          SizedBox(height: 8),
                          Text("Upload Image", style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // ✅ Scanned Items List - Extracted to separate widget
              SizedBox(
                height: 390,
                width: double.infinity,
                child: ScannedItemsList(
                  key: ValueKey(scannedList.length),
                  scannedList: scannedList,
                  onDelete: _deleteScanned,
                  formKey: _formKey,
                ),
              ),

              // Vendor Dropdown
              vendorsAsync.when(
                data: (vendorList) {
                  final selectedVendor = ref.watch(selectedVendorProvider);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GenericDropdownWidget<VendorModel>(
                      title: 'Vendor',
                      items: vendorList,
                      selectedItem: selectedVendor,
                      displayText: (v) => v.vendorName ?? 'Unknown Vendor',
                      hint: 'Choose a vendor',
                      prefixIcon: Icons.business,
                      onChanged: (value) {
                        ref.read(selectedVendorProvider.notifier).state = value;
                        debugPrint(value == null
                            ? 'Vendor cleared'
                            : 'Selected Vendor: ${value.vendorName}');
                      },
                    ),
                  );
                },
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text(
                  'Error loading vendors: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),

              // Project Dropdown
              projectsAsync.when(
                data: (projectList) {
                  final selectedProject = ref.watch(selectedProjectProvider);

                  return Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: GenericDropdownWidget<ProjectModel>(
                      title: 'Project',
                      items: projectList,
                      selectedItem: selectedProject,
                      displayText: (p) => p.projectName ?? 'Unknown Project',
                      hint: 'Choose a project',
                      prefixIcon: Icons.folder,
                      onChanged: (value) {
                        ref.read(selectedProjectProvider.notifier).state =
                            value;
                        debugPrint(value == null
                            ? 'Project cleared'
                            : 'Selected Project: ${value.projectName}');
                      },
                    ),
                  );
                },
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text(
                  'Error loading projects: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),

              const SizedBox(height: 20),

              // Store Data Button
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ScanButtonWidget(
                    text: "Store Data",
                    onPressed: () => _handleStoreData(context),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Extracted store data logic
  Future<void> _handleStoreData(BuildContext context) async {
    try {
      final selectedVendor = ref.read(selectedVendorProvider);
      final selectedProject = ref.read(selectedProjectProvider);

      // Validate selections
      if (selectedVendor == null) {
        _showSnackBar(
          context,
          "⚠️ Please select a Vendor before storing data!",
          Colors.orange,
        );
        return;
      }

      if (selectedProject == null) {
        _showSnackBar(
          context,
          "⚠️ Please select a Project before storing data!",
          Colors.orange,
        );
        return;
      }

      if (!(_formKey.currentState?.validate() ?? false)) {
        _showSnackBar(
          context,
          "Please fix the errors in the form",
          Colors.red,
        );
        return;
      }

      final List<Map<String, dynamic>> rawData =
      await _databaseHelper.readData('SerialNumberStoreTable');

      String deviceID = await getDeviceId();
      print("Device ID: $deviceID");

      if (rawData.isEmpty) {
        _showSnackBar(context, "No data to store!", Colors.red);
        return;
      }

      print("📦 Raw data from database (${rawData.length} items): $rawData");

      _showSnackBar(
        context,
        "Storing ${rawData.length} records...",
        null,
        duration: 2,
      );

      final List<ScannedItemModal> allData =
      rawData.map((row) => ScannedItemModal.fromJson(row)).toList();

      print("✅ Converted to models: ${allData.length} items");

      // Get description controllers from the ScannedItemsList widget
      final scannedItemsListState = _formKey.currentState?.context
          .findAncestorStateOfType<_ScannedItemsListState>();

      List<Map<String, dynamic>> dataToSend = [];
      for (int i = 0; i < allData.length; i++) {
        String description = "";
        if (scannedItemsListState != null &&
            i < scannedItemsListState._descriptionControllers.length) {
          description =
              scannedItemsListState._descriptionControllers[i].text.trim();
        }

        dataToSend.add({
          "id": allData[i].id ?? "",
          "vendorName": selectedVendor.vendorName ?? "",
          "projectName": selectedProject.projectName ?? "",
          "deviceID": deviceID,
          "serialNumber": allData[i].serialNumber,
          "productDescription": description,
          "scanned_type": allData[i].format,
          "timestamp": allData[i].scannedAt,
        });
      }

      print("📤 Data to send to Google Sheets:");

      var response =
      await GoogleSheetsService().callApi('store', {'data': dataToSend});

      print("📥 Google Sheets Response: $response");

      if (!context.mounted) return;

      _showSnackBar(
        context,
        "✓ ${response['message'] ?? 'Data stored successfully'}",
        Colors.green,
      );

      await _databaseHelper.clearTable('SerialNumberStoreTable');
      _loadScannedData();

      // Clear selections after success
      ref.read(selectedVendorProvider.notifier).state = null;
      ref.read(selectedProjectProvider.notifier).state = null;
    } catch (e, stackTrace) {
      print("❌ Error storing data: $e");
      print("Stack trace: $stackTrace");

      if (!context.mounted) return;
      _showSnackBar(context, "✗ Error: ${e.toString()}", Colors.red,
          duration: 5);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color? color,
      {int duration = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: duration),
      ),
    );
  }
}

// ✅ Separate StatefulWidget for Scanned Items List
class ScannedItemsList extends StatefulWidget {
  final List<ScannedItemModal> scannedList;
  final Function(String) onDelete;
  final GlobalKey<FormState> formKey;

  const ScannedItemsList({
    Key? key,
    required this.scannedList,
    required this.onDelete,
    required this.formKey,
  }) : super(key: key);

  @override
  State<ScannedItemsList> createState() => _ScannedItemsListState();
}

class _ScannedItemsListState extends State<ScannedItemsList> {
  final List<TextEditingController> _serialControllers = [];
  final List<TextEditingController> _descriptionControllers = [];
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(ScannedItemsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize only if the list length changed
    if (widget.scannedList.length != oldWidget.scannedList.length) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    // Dispose old controllers
    if (_controllersInitialized) {
      for (var controller in _serialControllers) {
        controller.dispose();
      }
      for (var controller in _descriptionControllers) {
        controller.dispose();
      }
    }

    _serialControllers.clear();
    _descriptionControllers.clear();

    // Create new controllers
    for (var item in widget.scannedList) {
      _serialControllers.add(TextEditingController(text: item.serialNumber));
      _descriptionControllers.add(TextEditingController());
    }

    _controllersInitialized = true;
  }

  @override
  void dispose() {
    for (var controller in _serialControllers) {
      controller.dispose();
    }
    for (var controller in _descriptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleDelete(int index) async {
    if (index < widget.scannedList.length) {
      await widget.onDelete(widget.scannedList[index].serialNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scannedList.isEmpty && _serialControllers.isEmpty) {
      return const Center(child: Text("No Scanned Data found"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: _serialControllers.length,
      itemBuilder: (context, index) {
        final bool isScannedData = index < widget.scannedList.length;
        return GenerateComponentSerialDescriptionPhoto(
          _serialControllers[index],
          _descriptionControllers[index],
          index,
              () async {
            if (isScannedData) {
              await _handleDelete(index);
            }
          },
        );
      },
    );
  }
}

// Helper function
Widget GenerateComponentSerialDescriptionPhoto(
    TextEditingController _controllerSerialNumber,
    TextEditingController _controllerDescription,
    int index,
    void Function()? onDelete,
    ) {
  return ComponentSerialnumberDiscriptionPhoto(
    showDelete: index != -1,
    onDelete: onDelete,
    serialController: _controllerSerialNumber,
    descriptionController: _controllerDescription,
    serialValidator: (index) => _controllerSerialNumber.text.trim().isEmpty
        ? 'Serial number cannot be empty'
        : null,
    descriptionValidator: (index) =>
    _controllerDescription.text.trim().isEmpty
        ? 'Description cannot be empty'
        : null,
  );
}


/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latestversionscanner/Device_Info_Module/device_info_app.dart';
import 'package:latestversionscanner/home_screen/custom_button.dart';

import '../component_serialnumber_discription_photo.dart';
import '../components/drop_down_conponent.dart';
import '../image_upload_module/image_upload_module.dart';
import '../modal/project_model.dart';
import '../modal/scanned_item_modal.dart';
import '../modal/vendor_model.dart';
import '../network_services/network_google_sheets_api_call.dart';
import '../scanner_module/scanner_module.dart';
import '../sqlite_manager/database_helper.dart';
import 'package:flutter/services.dart';
import '../services/riverpod/provider.dart';


class HomeScreen extends ConsumerStatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<ScannedItemModal> scannedList = [];
  final List<ScannedItemModal> addNewScannedData = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final List<TextEditingController> _serialControllers = [];
  final List<TextEditingController> _descriptionControllers = [];

  VendorModel? selectedVendor;
  ProjectModel? selectedProject;

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    // 2️⃣ Load all scanned data from DB
    _loadScannedData();
  }

  Future<void> _loadScannedData() async {
    final List<Map<String, dynamic>> rawData = await _databaseHelper.readData('SerialNumberStoreTable');

    final List<ScannedItemModal> allData =
    rawData.map((row) => ScannedItemModal.fromJson(row)).toList();

    setState(() {
      scannedList.clear();
      scannedList.addAll(allData);
    });
  }




  Future<void> _deleteScanned(String serialNumber) async {
    await _databaseHelper.deleteData('SerialNumberStoreTable', serialNumber);
    _loadScannedData();
  }

  @override
  Widget build(BuildContext context) {
    final vendorsAsync = ref.watch(vendorDataProvider);
    final projectsAsync = ref.watch(projectDataProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Scanned List")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
             Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScannerModule(),
                            ),
                          ).then((_) {
                            _loadScannedData();

                          });
                        },
                        child: Column(children: [
                          Icon(Icons.qr_code, size: 40),
                          SizedBox(height: 8),
                          Text("Scan QR or Bar", style: TextStyle(fontSize: 18)),
                        ],),
                      ),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: () async {
                          try {
                            final ListOfScannedDataAndResponseMessage scanResponse =
                            await uploadImageAndScan();

                            if (scanResponse.listOfScannedData != null && scanResponse.listOfScannedData!.isNotEmpty)
                            {

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(scanResponse.responseMessage), backgroundColor: Colors.green, duration: const Duration(seconds: 5)),
                              );

                              // Convert ScannedItemModal → Map<String, dynamic>
                              final List<Map<String, dynamic>> codeMaps = scanResponse.listOfScannedData!.map((code) => code.mapToJson()).toList();
                              // Database insert response
                              final dbResponse = await _databaseHelper.insertDataList("SerialNumberStoreTable", codeMaps);
                              _loadScannedData();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(dbResponse), backgroundColor: Colors.green, duration: const Duration(seconds: 5)),
                              );

                              print("Insert response: $dbResponse");

                            }
                            else
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(scanResponse.responseMessage), backgroundColor: Colors.red, duration: const Duration(seconds: 5),),
                                );
                              }
                          } catch (e) {
                            print("Error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${e}"), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            Icon(Icons.image_outlined, size: 40),
                            SizedBox(height: 8),
                            Text("Upload Image", style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
              SizedBox(
                height: 390,
                width: double.infinity,
                child: FutureBuilder<List<ScannedItemModal>>(
                  future: Future.value(scannedList),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }else if ((snapshot.data == null || snapshot.data!.isEmpty) && _serialControllers.isEmpty) {
                      return Center(child: Text("No Scanned Data found"));
                    }


                    // Inside FutureBuilder builder:
                    final scannedListData = snapshot.data ?? [];

// Remove default controllers if scanned data exists
                    if (scannedListData.isNotEmpty &&
                        _serialControllers.isNotEmpty &&
                        _descriptionControllers.isNotEmpty) {
                      _serialControllers.removeAt(0);
                      _descriptionControllers.removeAt(0);
                    }

// Ensure controller lists include scanned data
                    while (_serialControllers.length < scannedListData.length) {
                      _serialControllers.add(TextEditingController());
                      _descriptionControllers.add(TextEditingController());
                    }

// Initialize controllers with scanned data
                    for (int i = 0; i < scannedListData.length; i++) {
                      _serialControllers[i].text = scannedListData[i].serialNumber;
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: _serialControllers.length,
                      itemBuilder: (context, index) {
                        final bool isScannedData = index < scannedListData.length;
                        return GenerateComponentSerialDescriptionPhoto(
                          _serialControllers[index],
                          _descriptionControllers[index],
                          index,
                              () async {
                            setState(() {
                              _serialControllers.removeAt(index);
                              _descriptionControllers.removeAt(index);
                            });
                            if (isScannedData) {
                              await _deleteScanned(scannedListData[index].serialNumber);
                            }
                          },
                        );
                      },
                    );

                  },
                ),
              ),
              // Vendor Dropdown (Optional)
              vendorsAsync.when(
                data: (vendorList) {
                  // ✅ Watch the provider
                  final selectedVendor = ref.watch(selectedVendorProvider);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GenericDropdownWidget<VendorModel>(
                      title: 'Vendor',
                      items: vendorList,
                      selectedItem: selectedVendor, // ✅ From provider
                      displayText: (v) => v.vendorName ?? 'Unknown Vendor',
                      hint: 'Choose a vendor',
                      prefixIcon: Icons.business,
                      onChanged: (value) {
                        // ✅ Update provider - NO setState needed!
                        ref.read(selectedVendorProvider.notifier).state = value;
                        debugPrint(value == null ? 'Vendor cleared' : 'Selected Vendor: ${value.vendorName}');
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text(
                  'Error loading vendors: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              projectsAsync.when(
                data: (projectList) {
                  // ✅ Watch the provider
                  final selectedProject = ref.watch(selectedProjectProvider);

                  return Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: GenericDropdownWidget<ProjectModel>(
                      title: 'Project',
                      items: projectList,
                      selectedItem: selectedProject, // ✅ From provider
                      displayText: (p) => p.projectName ?? 'Unknown Project',
                      hint: 'Choose a project',
                      prefixIcon: Icons.folder,
                      onChanged: (value) {
                        // ✅ Update provider - NO setState needed!
                        ref.read(selectedProjectProvider.notifier).state = value;
                        debugPrint(value == null ? 'Project cleared' : 'Selected Project: ${value.projectName}');
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text(
                  'Error loading projects: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ScanButtonWidget(
                    text: "Store Data",
                    onPressed: () async {
                      try {
                        // ✅ Read values from providers
                        final selectedVendor = ref.read(selectedVendorProvider);
                        final selectedProject = ref.read(selectedProjectProvider);

                        // Validate selections
                        if (selectedVendor == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("⚠️ Please select a Vendor before storing data!"),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        if (selectedProject == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("⚠️ Please select a Project before storing data!"),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        if (_formKey.currentState?.validate() ?? false) {
                          final List<Map<String, dynamic>> rawData =
                          await _databaseHelper.readData('SerialNumberStoreTable');

                          String deviceID = await getDeviceId();
                          print("Device ID: $deviceID");

                          if (rawData.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("No data to store!"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          print("📦 Raw data from database (${rawData.length} items): $rawData");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Storing ${rawData.length} records..."),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          final List<ScannedItemModal> allData =
                          rawData.map((row) => ScannedItemModal.fromJson(row)).toList();

                          print("✅ Converted to models: ${allData.length} items");

                          List<Map<String, dynamic>> dataToSend = allData.map((item) {
                            return {
                              "id": item.id ?? "",
                              "vendorName": selectedVendor.vendorName ?? "",
                              "projectName": selectedProject.projectName ?? "",
                              "deviceID": deviceID,
                              "serialNumber": item.serialNumber,
                              "productDescription": _descriptionControllers[allData.indexOf(item)].text.trim(),
                              "scanned_type": item.format,
                              "timestamp": item.scannedAt,
                            };
                          }).toList();

                          print("📤 Data to send to Google Sheets:");

                          var response = await GoogleSheetsService().callApi('store', {
                            'data': dataToSend
                          });

                          print("📥 Google Sheets Response: $response");

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("✓ ${response['message'] ?? 'Data stored successfully'}"),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );

                          await _databaseHelper.clearTable('SerialNumberStoreTable');
                          _loadScannedData();
                          setState(() {
                            _serialControllers.clear();
                            _descriptionControllers.clear();
                          });

                          // ✅ Optional: Clear selections after success
                          ref.read(selectedVendorProvider.notifier).state = null;
                          ref.read(selectedProjectProvider.notifier).state = null;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fix the errors in the form"),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (e, stackTrace) {
                        print("❌ Error storing data: $e");
                        print("Stack trace: $stackTrace");

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("✗ Error: ${e.toString()}"),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                  ),

                  */
/*ScanButtonWidget(
                    text: "Store Data",
                    onPressed: () async {
                      try {
                        if (_formKey.currentState?.validate() ?? false)
                        {
                          final List<Map<String, dynamic>> rawData =
                          await _databaseHelper.readData('SerialNumberStoreTable');

                          String deviceID = await getDeviceId();
                          print("Device ID: $deviceID");

                          if (rawData.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("No data to store!"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          if (selectedVendor == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("⚠️ Please select a Vendor before storing data!"),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return; // Stop execution
                          }

                          if (selectedProject == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("⚠️ Please select a Project before storing data!"),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return; // Stop execution
                          }

                          print("📦 Raw data from database (${rawData.length} items): $rawData");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Storing ${rawData.length} records..."),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          // Convert to ScannedItemModal
                          final List<ScannedItemModal> allData =
                          rawData.map((row) => ScannedItemModal.fromJson(row)).toList();

                          print("✅ Converted to models: ${allData.length} items");

                          // Prepare data for Google Sheets
                          List<Map<String, dynamic>> dataToSend = allData.map((item) {
                            return {
                              "id": item.id ?? "",
                              "vendorName": selectedVendor?.vendorName ?? "",
                              "projectName": selectedProject?.projectName ?? "",
                              "deviceID": deviceID, // Static or dynamic device ID
                              "serialNumber": item.serialNumber,
                              "productDescription": _descriptionControllers[allData.indexOf(item)].text.trim(),
                              "scanned_type": item.format,
                              "timestamp": item.scannedAt,
                            };
                          }).toList();

                          print("📤 Data to send to Google Sheets:");
                          // print(jsonEncode(dataToSend)); // Print as formatted JSON

                          // Call API
                          var response = await GoogleSheetsService().callApi('store', {
                            'data': dataToSend
                          });

                          print("📥 Google Sheets Response: $response");

                          if (!context.mounted) return;
                          else
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("✓ ${response['message'] ?? 'Data stored successfully'}"),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );

                            // Clear local database after successful upload
                            await _databaseHelper.clearTable('SerialNumberStoreTable');
                            _loadScannedData();
                            setState(() {
                              _serialControllers.clear();
                              _descriptionControllers.clear();
                            });
                          }
                        }
                        else
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fix the errors in the form"),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }

                      } catch (e, stackTrace) {
                        print("❌ Error storing data: $e");
                        print("Stack trace: $stackTrace");

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("✗ Error: ${e.toString()}"),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                  ),*//*

                ),
              )
            ],
          ),
        ),
      )*/
/*,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:*//*
 */
/*Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: SizedBox(
          width: double.infinity,
          child: ScanButtonWidget(
            text: "Store Data",
            onPressed: () async {
              try {
                final List<Map<String, dynamic>> rawData =
                await _databaseHelper.readData('SerialNumberStoreTable');

                String deviceID = await getDeviceId();
                print("Device ID: $deviceID");

                if (rawData.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("No data to store!"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                print("📦 Raw data from database (${rawData.length} items): $rawData");

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Storing ${rawData.length} records..."),
                    duration: const Duration(seconds: 2),
                  ),
                );

                // Convert to ScannedItemModal
                final List<ScannedItemModal> allData =
                rawData.map((row) => ScannedItemModal.fromJson(row)).toList();

                print("✅ Converted to models: ${allData.length} items");

                // Prepare data for Google Sheets
                List<Map<String, dynamic>> dataToSend = allData.map((item) {
                  return {
                    "id": item.id ?? "",
                    "deviceID": deviceID, // Static or dynamic device ID
                    "serialNumber": item.serialNumber,
                    "scanned_type": item.format,
                    "timestamp": item.scannedAt,
                  };
                }).toList();

                print("📤 Data to send to Google Sheets:");
                // print(jsonEncode(dataToSend)); // Print as formatted JSON

                // Call API
                var response = await GoogleSheetsService().callApi('store', {
                  'data': dataToSend
                });

                print("📥 Google Sheets Response: $response");

                if (!context.mounted) return;
                else
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("✓ ${response['message'] ?? 'Data stored successfully'}"),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );

                  // Clear local database after successful upload
                  await _databaseHelper.clearTable('SerialNumberStoreTable');
                  _loadScannedData();
                }

              } catch (e, stackTrace) {
                print("❌ Error storing data: $e");
                print("Stack trace: $stackTrace");

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("✗ Error: ${e.toString()}"),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
          ),
        ),
      )*//*

    );
  }
}
Widget GenerateComponentSerialDescriptionPhoto(
    TextEditingController _controllerSerialNumber,
    TextEditingController _controllerDescription,
    int index,
    void Function()? onDelete)
{
  return ComponentSerialnumberDiscriptionPhoto(
      showDelete: index != -1,
      onDelete: onDelete,
      serialController: _controllerSerialNumber,
      descriptionController: _controllerDescription,
      serialValidator: (index) => _controllerSerialNumber.text.trim().isEmpty ? 'Serial number cannot be empty' : null,
      descriptionValidator: (index) => _controllerDescription.text.trim().isEmpty ? 'Description cannot be empty' : null
  );
}
*/
