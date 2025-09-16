// lib/widgets/home/action_buttons_row.dart

import 'package:flutter/material.dart';
import '../../models/finance_models.dart';

class ActionButtonsRow extends StatelessWidget {
  final Account selectedAccount;
  // AÑADIDO: Callback para notificar cuando una transacción se guarda
  final VoidCallback onTransactionSaved;

  const ActionButtonsRow({
    super.key,
    required this.selectedAccount,
    required this.onTransactionSaved,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.arrow_upward_rounded,
            label: 'Ingreso',
            color: Colors.green.shade700,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/add_transaction',
                arguments: {
                  'type': TransactionType.ingreso,
                  'account': selectedAccount,
                },
              ).then((result) {
                // Si la pantalla de transacción devuelve 'true', refrescamos los datos
                if (result == true) {
                  onTransactionSaved();
                }
              });
            },
          ),
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.arrow_downward_rounded,
            label: 'Gasto',
            color: Colors.red.shade600,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/add_transaction',
                arguments: {
                  'type': TransactionType.gasto,
                  'account': selectedAccount,
                },
              ).then((result) {
                // Si la pantalla de transacción devuelve 'true', refrescamos los datos
                if (result == true) {
                  onTransactionSaved();
                }
              });
            },
          ),
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.swap_horiz,
            label: 'Transferir',
            onTap: () {
              Navigator.pushNamed(context, '/transfer');
            },
          ),
        ],
      ),
    );
  }
}

// ... El widget _ActionButton se mantiene igual ...
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: buttonColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: buttonColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
