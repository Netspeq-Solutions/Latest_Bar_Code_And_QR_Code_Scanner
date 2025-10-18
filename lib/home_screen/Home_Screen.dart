import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latestversionscanner/Device_Info_Module/device_info_app.dart';
import 'package:latestversionscanner/home_screen/custom_button.dart';

import '../component_serialnumber_discription_photo.dart';
import '../image_upload_module/image_upload_module.dart';
import '../modal/project_model.dart';
import '../modal/scanned_item_modal.dart';
import '../modal/vendor_model.dart';
import '../network_services/network_google_sheets_api_call.dart';
import '../reusable_dropdown/reusable_dropdown_component.dart';
import '../scanner_module/scanner_module.dart';
import '../sqlite_manager/database_helper.dart';
import 'package:flutter/services.dart';

import '../vendor_project_service/riverpod/data_provider.dart';

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
    final List<Map<String, dynamic>> rawData = await _databaseHelper.readData(
      'SerialNumberStoreTable',
    );

    final List<ScannedItemModal> allData = rawData
        .map((row) => ScannedItemModal.fromJson(row))
        .toList();

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
                      child: Column(
                        children: [
                          Icon(Icons.qr_code, size: 40),
                          SizedBox(height: 8),
                          Text(
                            "Scan QR or Bar",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
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
                                duration: const Duration(seconds: 5),
                              ),
                            );

                            // Convert ScannedItemModal → Map<String, dynamic>
                            final List<Map<String, dynamic>> codeMaps =
                                scanResponse.listOfScannedData!
                                    .map((code) => code.mapToJson())
                                    .toList();
                            // Database insert response
                            final dbResponse = await _databaseHelper
                                .insertDataList(
                                  "SerialNumberStoreTable",
                                  codeMaps,
                                );
                            _loadScannedData();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(dbResponse),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 5),
                              ),
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
                              content: Text("Error: ${e}"),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
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
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 540,
                width: double.infinity,
                child: FutureBuilder<List<ScannedItemModal>>(
                  future: Future.value(scannedList),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if ((snapshot.data == null ||
                            snapshot.data!.isEmpty) &&
                        _serialControllers.isEmpty) {
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
                      _serialControllers[i].text =
                          scannedListData[i].serialNumber;
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: _serialControllers.length,
                      itemBuilder: (context, index) {
                        final bool isScannedData =
                            index < scannedListData.length;
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
                              await _deleteScanned(
                                scannedListData[index].serialNumber,
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              vendorsAsync.when(
                data: (vendorList) {
                  return GenericDropdownWidget<VendorModel>(
                    title: 'Vendor',
                    items: vendorList,
                    selectedItem: selectedVendor,
                    displayText: (v) => v.vendorName ?? 'Unknown Vendor',
                    onChanged: (value) {
                      setState(() => selectedVendor = value);
                      debugPrint('Selected Vendor: ${value?.vendorName}');
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error loading vendors: $err'),
              ),

              const SizedBox(height: 20),

              // Project Dropdown
              projectsAsync.when(
                data: (projectList) {
                  return GenericDropdownWidget<ProjectModel>(
                    title: 'Project',
                    items: projectList,
                    selectedItem: selectedProject,
                    displayText: (p) => p.projectName ?? 'Unknown Project',
                    onChanged: (value) {
                      setState(() => selectedProject = value);
                      debugPrint('Selected Project: ${value?.projectName}');
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error loading projects: $err'),
              ),

              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ScanButtonWidget(
                    text: "Store Data",
                    onPressed: () async {
                      try {
                        if (_formKey.currentState?.validate() ?? false) {
                          final List<Map<String, dynamic>> rawData =
                              await _databaseHelper.readData(
                                'SerialNumberStoreTable',
                              );

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

                          print(
                            "📦 Raw data from database (${rawData.length} items): $rawData",
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Storing ${rawData.length} records...",
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          // Convert to ScannedItemModal
                          final List<ScannedItemModal> allData = rawData
                              .map((row) => ScannedItemModal.fromJson(row))
                              .toList();

                          print(
                            "✅ Converted to models: ${allData.length} items",
                          );

                          // Prepare data for Google Sheets
                          List<Map<String, dynamic>> dataToSend = allData.map((
                            item,
                          ) {
                            return {
                              "id": item.id ?? "",
                              "deviceID":
                                  deviceID, // Static or dynamic device ID
                              "serialNumber": item.serialNumber,
                              "productDescription":
                                  _descriptionControllers[allData.indexOf(item)]
                                      .text
                                      .trim(),
                              "scanned_type": item.format,
                              "timestamp": item.scannedAt,
                            };
                          }).toList();

                          print("📤 Data to send to Google Sheets:");
                          // print(jsonEncode(dataToSend)); // Print as formatted JSON

                          // Call API
                          var response = await GoogleSheetsService().callApi(
                            'store',
                            {'data': dataToSend},
                          );

                          print("📥 Google Sheets Response: $response");

                          if (!context.mounted)
                            return;
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "✓ ${response['message'] ?? 'Data stored successfully'}",
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );

                            // Clear local database after successful upload
                            await _databaseHelper.clearTable(
                              'SerialNumberStoreTable',
                            );
                            _loadScannedData();
                            setState(() {
                              _serialControllers.clear();
                              _descriptionControllers.clear();
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please fix the errors in the form",
                              ),
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
                ),
              ),
            ],
          ),
        ),
      ) /*,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:*/ /*Padding(
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
      )*/,
    );
  }
}

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
    descriptionValidator: (index) => _controllerDescription.text.trim().isEmpty
        ? 'Description cannot be empty'
        : null,
  );
}
