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
  final bool isLoading; // ✅ Add loading state
  final String? errorMessage; // ✅ Add error state

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
    this.isLoading = false, // ✅ Default to false
    this.errorMessage, // ✅ Optional error message
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

        // Dropdown Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: errorMessage != null ? Colors.red : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: _buildContent(context),
        ),

        // Error message below dropdown
        if (errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    // ✅ Show error state
    if (errorMessage != null) {
      return Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, size: 20, color: Colors.red),
            const SizedBox(width: 8),
          ],
          const Expanded(
            child: Text('Failed to load', style: TextStyle(color: Colors.red)),
          ),
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
        ],
      );
    }

    // ✅ Show loading state
    if (isLoading) {
      return Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              'Loading $title...',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }

    // ✅ Show normal dropdown
    return DropdownButtonHideUnderline(
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
          if (showClearButton && selectedItem != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              color: Colors.grey.shade600,
              onPressed: () => onChanged(null),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

/*
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
}*/
