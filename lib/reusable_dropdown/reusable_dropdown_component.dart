import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

/// A reusable, generic dropdown widget that works with any model type [T].
class GenericDropdownWidget<T> extends StatelessWidget {
  final String title; // Dropdown label (e.g., "Select Vendor")
  final List<T> items; // The list of model objects
  final T? selectedItem; // Currently selected item
  final String Function(T) displayText; // How to show text from the model
  final ValueChanged<T?> onChanged; // Callback when an item is selected
  final double width;
  final double height;

  const GenericDropdownWidget({
    super.key,
    required this.title,
    required this.items,
    required this.displayText,
    required this.onChanged,
    this.selectedItem,
    this.width = 250,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,
            hint: Text('Select $title'),
            value: selectedItem,
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(displayText(item)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(
              height: height,
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
