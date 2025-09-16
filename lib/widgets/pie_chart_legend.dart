// En lib/widgets/pie_chart_legend.dart
import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../data/mock_data.dart';

class PieChartLegend extends StatelessWidget {
  final Map<String, double> categoryTotals; // Recibe [categoryId, totalAmount]
  final double totalExpenses;
  final Function(String?) onCategorySelected;
  final String? selectedCategoryTitle;

  const PieChartLegend({
    super.key,
    required this.categoryTotals,
    required this.totalExpenses,
    required this.onCategorySelected,
    this.selectedCategoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) return const SizedBox.shrink();

    // Ordenamos las categorías de mayor a menor gasto
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedCategories.map((entry) {
        final categoryId = entry.key;
        final category = mockCategories.firstWhere(
          (cat) => cat.id == categoryId,
          orElse: () => const Category(
            id: 'error',
            title: 'Error',
            icon: Icons.error,
            type: 'Gasto',
          ),
        );
        final percentage = (entry.value / totalExpenses * 100);
        final isSelected = category.title == selectedCategoryTitle;

        return InkWell(
          onTap: () => onCategorySelected(category.title),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Icon(
                  category.icon,
                  color: _getColorForCategory(category.title),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.title,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Text('${percentage.toStringAsFixed(0)}%'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForCategory(String title) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[title.hashCode % colors.length];
  }
}
