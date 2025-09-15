// En screens/add_transaction_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/finance_models.dart';
import '../utils/account_selector.dart';

enum TransactionType { ingreso, gasto }

class AddTransactionPage extends StatefulWidget {
  final TransactionType type;
  final Transaction? transaction;
  const AddTransactionPage({super.key, required this.type, this.transaction});
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  Future<void> _selectAccount() async {
    // Llamamos a nuestra función reutilizable y esperamos el resultado
    final account = await showAccountSelector(context, mockAccounts);

    // Si el usuario seleccionó una cuenta, actualizamos el estado
    if (account != null) {
      setState(() {
        _selectedAccount = account;
      });
    }
  }

  // --- 1. VARIABLES DE ESTADO PARA LAS SELECCIONES ---
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  int? _selectedCategoryIndex;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      // Si estamos editando, rellenamos los campos
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.title;
      _selectedAccount = mockAccounts.firstWhere(
        (acc) => acc.id == widget.transaction!.accountId,
      );
      _selectedDate = widget.transaction!.date;
      _selectedCategoryIndex = mockCategories.indexWhere(
        (cat) => cat.id == widget.transaction!.categoryId,
      );
      if (_selectedCategoryIndex == -1) _selectedCategoryIndex = null;
    }
  }

  // --- 2. LÓGICA PARA EL SELECTOR DE FECHA ---
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- 4. LÓGICA PARA GUARDAR (POR AHORA, SOLO IMPRIME) ---
  void _saveTransaction() {
    print('--- Guardando Transacción ---');
    print('Monto: ${_amountController.text}');
    print('Descripción: ${_descriptionController.text}');
    print(
      'Categoría: ${_selectedCategoryIndex != null ? categories[_selectedCategoryIndex!]['label'] : 'No seleccionada'}',
    );
    print('Cuenta: ${_selectedAccount?.name ?? 'No seleccionada'}');
    print('Fecha: ${DateFormat.yMd().format(_selectedDate)}');
    // En el futuro, aquí guardarías los datos en la base de datos
    // y luego cerrarías la pantalla:
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.type == TransactionType.ingreso
        ? 'Añadir Ingreso'
        : 'Añadir Gasto';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      // --- 5. BOTÓN FLOTANTE PARA GUARDAR ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTransaction,
        label: const Text(
          'Guardar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          20.0,
          0,
          20.0,
          80.0,
        ), // Padding extra abajo para el botón
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.grey.shade300),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Categoría',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  _CategorySelector(
                    initialIndex: _selectedCategoryIndex,
                    onCategorySelected: (index) =>
                        setState(() => _selectedCategoryIndex = index),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.description_outlined),
                      labelText: 'Descripción',
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),

                  // --- 6. LISTTILE DE CUENTA AHORA ES INTERACTIVO ---
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: const Text('Cuenta'),
                    subtitle: Text(
                      _selectedAccount?.name ?? 'Seleccionar cuenta',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectAccount,
                  ),

                  // --- 7. LISTTILE DE FECHA AHORA ES INTERACTIVO ---
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Fecha'),
                    subtitle: Text(
                      DateFormat.yMMMMd('es_ES').format(_selectedDate),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectDate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 8. WIDGET DE CATEGORÍA MODIFICADO ---
final List<Map<String, dynamic>> categories = [
  {'icon': Icons.fastfood_outlined, 'label': 'Comida'},
  {'icon': Icons.receipt_long_outlined, 'label': 'Servicios'},
  {'icon': Icons.directions_bus_outlined, 'label': 'Transporte'},
  {'icon': Icons.home_outlined, 'label': 'Alquiler'},
  {'icon': Icons.healing_outlined, 'label': 'Salud'},
  {'icon': Icons.shopping_bag_outlined, 'label': 'Ropa'},
  {'icon': Icons.more_horiz, 'label': 'Otros'},
];

class _CategorySelector extends StatefulWidget {
  final Function(int) onCategorySelected;
  final int? initialIndex;
  const _CategorySelector({
    required this.onCategorySelected,
    this.initialIndex,
  });

  @override
  State<_CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<_CategorySelector> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Asignamos el índice inicial al estado del widget
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = _selectedIndex == index;
          final color = Theme.of(context).primaryColor;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onCategorySelected(index);
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: isSelected
                  ? color.withOpacity(0.2)
                  : Colors.grey[200],
              child: Icon(
                category['icon'] as IconData,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
      ),
    );
  }
}
