// lib/widgets/settings/collapsible_section.dart

import 'package:flutter/material.dart';

class CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool isInitiallyExpanded;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.child,
    this.isInitiallyExpanded = true,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggleExpanded,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          if (_isExpanded) const SizedBox(height: 16),
          // El contenido se muestra y oculta con una animación
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) {
              return SizeTransition(sizeFactor: animation, child: child);
            },
            child: _isExpanded ? widget.child : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
