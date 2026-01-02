import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/categories.dart';

class CategoryChart extends StatelessWidget {
  final Map<String, double> data;
  final bool isIncome;

  const CategoryChart({super.key, required this.data, required this.isIncome});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: data.entries.map((entry) {
                final category = appCategories.firstWhere(
                  (c) => c.name == entry.key,
                  orElse: () => appCategories.last,
                );
                
                return PieChartSectionData(
                  color: category.color,
                  value: entry.value,
                  title: '', // Deixamos vazio para não poluir
                  radius: 50,
                  badgeWidget: _buildBadge(category.icon, category.color),
                  badgePositionPercentageOffset: .98,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legenda simples abaixo do gráfico
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: data.entries.map((entry) {
            final category = appCategories.firstWhere((c) => c.name == entry.key, orElse: () => appCategories.last);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 12, color: category.color),
                const SizedBox(width: 4),
                Text('${category.name}: R\$ ${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}