import 'package:flutter/material.dart';

class ComponentSerialnumberDiscriptionPhoto extends StatelessWidget {
  final TextEditingController serialController;
  final TextEditingController descriptionController;
  final VoidCallback? onDelete;
  final bool showDelete;
  final VoidCallback? onManualEntryComplete;
  final String? Function(String?)? serialValidator;
  final String? Function(String?)? descriptionValidator;

  const ComponentSerialnumberDiscriptionPhoto({
    super.key,
    required this.serialController,
    required this.descriptionController,
    this.onDelete,
    this.showDelete = true,
    this.onManualEntryComplete,
    this.serialValidator,
    this.descriptionValidator,
  });

  @override
  Widget build(BuildContext context) {
    final serialFocus = FocusNode();

    serialFocus.addListener(() {
      if (!serialFocus.hasFocus &&
          serialController.text.trim().isNotEmpty &&
          onManualEntryComplete != null) {
        onManualEntryComplete!();
      }
    });

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Serial Number',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (showDelete && onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
              ],
            ),
            TextFormField(
              controller: serialController,
              focusNode: serialFocus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true, // Reduces vertical padding
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              validator: serialValidator
            ),

            const SizedBox(height: 10),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true, // Reduces vertical padding
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              validator: descriptionValidator
            ),

          ],
        ),
      ),
    );
  }
}
