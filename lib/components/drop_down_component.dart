import 'package:flutter/material.dart';

class GenericDropdownWidget<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) displayText;
  final void Function(T?) onChanged;
  final String? hint;
  final IconData? prefixIcon;
  final bool showClearButton;

  const GenericDropdownWidget({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.displayText,
    required this.onChanged,
    this.hint,
    this.prefixIcon,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<T>(
                    isExpanded: true,
                    value: selectedItem,
                    hint: Text(
                      hint ?? 'Select $title',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: items.map((T item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Row(
                          children: [
                            if (prefixIcon != null) ...[
                              Icon(prefixIcon, size: 20, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                displayText(item),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,

                  ),
                ),
                if (selectedItem != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    color: Colors.grey.shade600,
                    onPressed: () => onChanged(null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}