import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift; // Import necessário para o Value
import '../../../data/repositories/profile_repository.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  final bool initialIsIncome; // 1. Campo para receber a escolha do botão

  const AddTransactionModal({
    super.key, 
    this.initialIsIncome = false, // Padrão é saída se nada for passado
  });

  @override
  ConsumerState<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  late bool _isIncome; // 2. Variável que controlará o estado interno

  @override
  void initState() {
    super.initState();
    // 3. Importante: Inicia o estado com o valor que veio do botão da Home
    _isIncome = widget.initialIsIncome;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isIncome ? 'Nova Entrada' : 'Nova Saída',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: _isIncome ? Colors.green : Colors.redAccent,
            ),
          ),
          const SizedBox(height: 20),
          
          // Toggle (Botão Seletor)
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false, 
                label: Text('Saída'), 
                icon: Icon(Icons.remove_circle_outline)
              ),
              ButtonSegment(
                value: true, 
                label: Text('Entrada'), 
                icon: Icon(Icons.add_circle_outline)
              ),
            ],
            selected: {_isIncome},
            onSelectionChanged: (newVal) {
              setState(() {
                _isIncome = newVal.first;
              });
            },
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Descrição', 
              hintText: 'Ex: Salário, Aluguel, Mercado...',
              border: OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Valor', 
              prefixText: 'R\$ ', 
              border: OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: () async {
              final amountText = _amountController.text.replaceAll(',', '.');
              final amount = double.tryParse(amountText) ?? 0.0;
              
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Salvar Transação', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}