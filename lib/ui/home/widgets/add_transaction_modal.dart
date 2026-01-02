import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../core/constants/categories.dart'; // Importe suas constantes aqui

class AddTransactionModal extends ConsumerStatefulWidget {
  final bool initialIsIncome;

  const AddTransactionModal({
    super.key,
    this.initialIsIncome = false,
  });

  @override
  ConsumerState<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  late bool _isIncome;
  String _selectedCategory = 'Outros'; // Categoria padrão inicial

  @override
  void initState() {
    super.initState();
    _isIncome = widget.initialIsIncome;
    
    // Ajuste inicial de categoria comum: se for entrada, sugere 'Salário'
    if (_isIncome) _selectedCategory = 'Salário';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView( // Adicionado para evitar overflow com teclado/muitas categorias
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
            
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                    value: false,
                    label: Text('Saída'),
                    icon: Icon(Icons.remove_circle_outline)),
                ButtonSegment(
                    value: true,
                    label: Text('Entrada'),
                    icon: Icon(Icons.add_circle_outline)),
              ],
              selected: {_isIncome},
              onSelectionChanged: (newVal) {
                setState(() {
                  _isIncome = newVal.first;
                  // Sugestão inteligente ao trocar o tipo
                  _selectedCategory = _isIncome ? 'Salário' : 'Outros';
                });
              },
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex: Salário, Aluguel, Mercado...',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // --- SELETOR DE CATEGORIAS ---
            const Text(
              'Categoria',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: appCategories.length,
                itemBuilder: (context, index) {
                  final cat = appCategories[index];
                  final isSelected = _selectedCategory == cat.name;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(cat.icon, 
                        size: 18, 
                        color: isSelected ? cat.color : Colors.grey
                      ),
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = cat.name);
                      },
                      selectedColor: cat.color.withOpacity(0.2),
                      checkmarkColor: cat.color,
                    ),
                  );
                },
              ),
            ),
            // ------------------------------

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
                        _selectedCategory, // Agora envia a categoria selecionada
                      );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _isIncome ? Colors.green : Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Salvar Transação',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
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