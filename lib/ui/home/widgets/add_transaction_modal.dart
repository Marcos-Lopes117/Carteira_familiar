import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/profile_repository.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  const AddTransactionModal({super.key});

  @override
  ConsumerState<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncome = false; // Define se é entrada ou saída

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Ajusta para o teclado
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isIncome ? 'Nova Entrada' : 'Nova Saída',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Toggle para escolher Entrada ou Saída
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Saída'), icon: Icon(Icons.remove_circle_outline)),
              ButtonSegment(value: true, label: Text('Entrada'), icon: Icon(Icons.add_circle_outline)),
            ],
            selected: {_isIncome},
            onSelectionChanged: (newVal) => setState(() => _isIncome = newVal.first),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Descrição (ex: Mercado, Aluguel)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ ', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
              if (amount > 0 && _descController.text.isNotEmpty) {
                await ref.read(profileRepositoryProvider).addTransaction(
                  _descController.text,
                  amount,
                  _isIncome,
                  'Geral',
                );
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _isIncome ? Colors.green : Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar Transação'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}