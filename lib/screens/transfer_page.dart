import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/finance_models.dart';
import '../utils/account_selector.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  // Controladores para los campos de texto
  final _fromAmountController = TextEditingController();
  final _toAmountController = TextEditingController();

  Future<void> _selectAccount(bool isFromAccount) async {
    final availableAccounts = isFromAccount
        ? mockAccounts
        : mockAccounts.where((acc) => acc.id != _fromAccount?.id).toList();

    // Llamamos a nuestra función reutilizable y esperamos el resultado
    final account = await showAccountSelector(context, availableAccounts);

    // Si el usuario seleccionó una cuenta, actualizamos el estado
    if (account != null) {
      setState(() {
        if (isFromAccount) {
          _fromAccount = account;
          if (_toAccount?.id == _fromAccount?.id) _toAccount = null;
        } else {
          _toAccount = account;
        }
      });
    }
  }

  // Estado para las cuentas seleccionadas
  Account? _fromAccount;
  Account? _toAccount;

  @override
  void dispose() {
    _fromAmountController.dispose();
    _toAmountController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE LA PANTALLA ---

  // Intercambia las cuentas de origen y destino
  void _swapAccounts() {
    setState(() {
      final temp = _fromAccount;
      _fromAccount = _toAccount;
      _toAccount = temp;
    });
  }

  // Lógica para guardar (actualmente solo imprime los datos)
  void _saveTransfer() {
    print('--- Guardando Transferencia ---');
    print('Monto: ${_fromAmountController.text}');
    print('Desde: ${_fromAccount?.name ?? 'No seleccionada'}');
    print('Hasta: ${_toAccount?.name ?? 'No seleccionada'}');
  }

  // --- INTERFAZ DE USUARIO ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).canvasColor, // Fondo oscuro para toda la pantalla
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTransfer,
        label: const Text(
          'Realizar Transferencia',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Transferencia",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            // Tarjeta de "Origen"
            _TransferCard(
              label: 'Desde',
              selectedAccount: _fromAccount,
              amountController: _fromAmountController,
              onAccountSelectorTap: () => _selectAccount(true),
            ),

            // Botón para intercambiar las cuentas
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: IconButton(
                alignment: Alignment.bottomRight,
                icon: Icon(
                  Icons.swap_vert,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: _swapAccounts,
              ),
            ),

            // Tarjeta de "Destino"
            _TransferCard(
              label: 'Hasta',
              selectedAccount: _toAccount,
              amountController: _toAmountController,
              onAccountSelectorTap: () => _selectAccount(false),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Widget Reutilizable para la Tarjeta de Transferencia --
class _TransferCard extends StatelessWidget {
  final String label;
  final Account? selectedAccount;
  final TextEditingController amountController;
  final VoidCallback onAccountSelectorTap;

  const _TransferCard({
    required this.label,
    required this.selectedAccount,
    required this.amountController,
    required this.onAccountSelectorTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
    );

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[900])),
              GestureDetector(
                onTap: onAccountSelectorTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      if (selectedAccount != null) ...[
                        Icon(
                          selectedAccount!.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        selectedAccount?.name ?? 'Seleccionar',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0.00',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disponible: ${selectedAccount != null ? currencyFormatter.format(selectedAccount!.balance) : 'N/A'}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              // Aquí podría ir el botón de "MAX" en el futuro
            ],
          ),
        ],
      ),
    );
  }
}
