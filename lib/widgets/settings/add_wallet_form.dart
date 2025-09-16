// lib/widgets/settings/add_wallet_form.dart

import 'package:flutter/material.dart';
import 'package:login_app/models/finance_models.dart';
import 'package:login_app/services/supabase_service.dart';
import 'package:login_app/utils/icon_helper.dart';

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
  final Account? walletToEdit;

  const AddWalletForm({super.key, this.walletToEdit});

  @override
  State<AddWalletForm> createState() => _AddWalletFormState();
}

class _AddWalletFormState extends State<AddWalletForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();

  int _selectedCurrencyIndex = 0;
  IconData _selectedIcon = walletIcons.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.walletToEdit != null) {
      _nameController.text = widget.walletToEdit!.name;
      _balanceController.text = widget.walletToEdit!.balance.toString();
      _selectedIcon = widget.walletToEdit!.icon;
      // --- LÓGICA DE MONEDA AÑADIDA ---
      if (widget.walletToEdit!.currency == 'USD') {
        _selectedCurrencyIndex = 1;
      } else {
        _selectedCurrencyIndex = 0;
      }
    }
  }

  Future<void> _saveWallet() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final double balance = double.tryParse(_balanceController.text) ?? 0.0;
        final String iconName = _selectedIcon.codePoint.toString();
        final String currency = _selectedCurrencyIndex == 0 ? 'PEN' : 'USD';

        if (widget.walletToEdit == null) {
          final newWallet = await _supabaseService.addWallet(
            name: _nameController.text,
            currency: currency,
            initialBalance: balance,
            iconName: iconName,
          );
          if (mounted) Navigator.of(context).pop(newWallet);
        } else {
          final updatedWallet = await _supabaseService.updateWallet(
            id: widget.walletToEdit!.id,
            name: _nameController.text,
            currency: currency,
            initialBalance: balance,
            iconName: iconName,
          );
          if (mounted) Navigator.of(context).pop(updatedWallet);
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Nombre de la billetera',
                border: InputBorder.none,
                labelText: widget.walletToEdit != null
                    ? 'Editando Billetera'
                    : null,
              ),
              validator: (value) => value!.isEmpty ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),

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

            const Text('Elige un ícono:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: walletIcons.map((icon) {
                final isSelected = _selectedIcon.codePoint == icon.codePoint;
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
