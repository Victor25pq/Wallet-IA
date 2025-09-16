// lib/widgets/settings/add_wallet_form.dart

import 'package:flutter/material.dart';
import 'package:login_app/models/finance_models.dart';
import 'package:login_app/services/supabase_service.dart';

// Lista de íconos disponibles para que el usuario elija.
const List<IconData> walletIcons = [
  Icons.account_balance_wallet,
  Icons.savings,
  Icons.credit_card,
  Icons.monetization_on,
  Icons.account_balance,
  Icons.paypal,
  Icons.currency_bitcoin,
];

class AddWalletForm extends StatefulWidget {
  const AddWalletForm({super.key});

  @override
  State<AddWalletForm> createState() => _AddWalletFormState();
}

class _AddWalletFormState extends State<AddWalletForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();

  // Estado para la selección
  int _selectedCurrencyIndex = 0; // 0 para Soles, 1 para Dólares
  IconData _selectedIcon = walletIcons.first;

  bool _isLoading = false;

  Future<void> _saveWallet() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // AÑADE EL TIPO 'Account' EXPLÍCITAMENTE AQUÍ
        final Account newWallet = await _supabaseService.addWallet(
          name: _nameController.text,
          currency: _selectedCurrencyIndex == 0 ? 'PEN' : 'USD',
          initialBalance: double.tryParse(_balanceController.text) ?? 0.0,
          iconName: _selectedIcon.codePoint.toString(),
        );

        if (mounted) {
          Navigator.of(context).pop(newWallet);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding para que el teclado no tape el formulario
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Para que ocupe el mínimo espacio
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CAMPO: NOMBRE DE LA BILLETERA ---
            TextFormField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Nombre de la billetera',
                border: InputBorder.none,
              ),
              validator: (value) => value!.isEmpty ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),

            // --- SELECTOR DE MONEDA ---
            ToggleButtons(
              isSelected: [
                _selectedCurrencyIndex == 0,
                _selectedCurrencyIndex == 1,
              ],
              onPressed: (index) =>
                  setState(() => _selectedCurrencyIndex = index),
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Soles (S/.)'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Dólares (\$)'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- CAMPO: MONTO INICIAL ---
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Monto Inicial',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) => value!.isEmpty ? 'Ingresa un monto' : null,
            ),
            const SizedBox(height: 24),

            // --- SELECTOR DE ÍCONOS ---
            const Text('Elige un ícono:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: walletIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.2)
                        : Colors.grey[200],
                    child: Icon(
                      icon,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // --- BOTONES DE ACCIÓN ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveWallet,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
