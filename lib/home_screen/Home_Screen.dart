import 'package:flutter/material.dart';

import '../modal/scanned_item_modal.dart';
import '../scanner_module/scanner_module.dart';
import '../sqlite_manager/database_helper.dart';
import 'package:flutter/services.dart';


class HomeScreen extends StatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ScannedItemModal> scannedList = [];
  final List<ScannedItemModal> addNewScannedData = [];
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();

    // 2️⃣ Load all scanned data from DB
    _loadScannedData();
    // Force portrait before going bac
  }

  Future<void> _loadScannedData() async {
    final List<Map<String, dynamic>> rawData = await dbHelper.readData('SerialNumberStoreTable');

    final List<ScannedItemModal> allData =
    rawData.map((row) => ScannedItemModal.fromMap(row)).toList();

    setState(() {
      scannedList.clear();
      scannedList.addAll(allData);
    });
  }


  Future<void> _deleteScanned(int id) async {
    await dbHelper.deleteData('SerialNumberStoreTable', id);
    _loadScannedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanned List")),
      body: Column(
        children: [
         Padding(
              padding: EdgeInsets.all(16.0),
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
                      Icon(Icons.qr_code, size: 50),
                      SizedBox(height: 8),
                      Text("Scan QR or Bar", style: TextStyle(fontSize: 18)),
                    ],),
                  ),
                  SizedBox(width: 20,),
                  GestureDetector(
                    onTap: () {
                    },
                    child: Column(children: [
                      Icon(Icons.image_outlined, size: 50),
                      SizedBox(height: 8),
                      Text("Upload Image", style: TextStyle(fontSize: 18)),
                    ],),
                  )
                ],
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<ScannedItemModal>>(
              future: Future.value(scannedList),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No scanned data",
                      style: TextStyle(color: Colors.black), // 👈 white on white was invisible
                    ),
                  );
                } else {
                  final scannedList = snapshot.data!;
                  return ListView.builder(
                    itemCount: scannedList.length,
                    itemBuilder: (context, index) {
                      final item = scannedList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.qr_code),
                          title: Text(item.serialNumber),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Type: ${item.format}"),
                              Text(
                                "Date: ${item.scannedAt.toString().split('.')[0]}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteScanned(int.parse(item.id!)),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),

        ],
      ),
    );
  }
}

