import 'package:flutter/material.dart';

class GoalsCard extends StatelessWidget {
  final double currentBalance;
  final double goal;

  const GoalsCard({super.key, required this.currentBalance, required this.goal});

  @override
  Widget build(BuildContext context) {
    // Evita divisão por zero e limita o progresso entre 0.0 e 1.0
    double progress = goal > 0 ? (currentBalance / goal).clamp(0.0, 1.0) : 0.0;
    bool goalReached = currentBalance >= goal && goal > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Meta de Economia', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                goalReached ? 'Meta Batida! 🎉' : '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: goalReached ? Colors.green : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: goalReached ? Colors.green : Colors.blue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${currentBalance.toStringAsFixed(2)} de R\$ ${goal.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}