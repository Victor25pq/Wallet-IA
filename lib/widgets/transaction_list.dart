// En lib/widgets/transaction_list.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/finance_models.dart';

// 1. EL WIDGET REUTILIZABLE PRINCIPAL
class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Usamos ListView.separated para añadir un divisor entre ítems
    return ListView.separated(
      itemCount: transactions.length,
      // shrinkWrap y physics son necesarios cuando un ListView está dentro de otro
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionListItem(transaction: transaction);
      },
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }
}

// 2. EL WIDGET PARA UN SOLO ÍTEM (AHORA PÚBLICO)
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final category = mockCategories.firstWhere(
      (cat) => cat.id == transaction.categoryId,
      // 'orElse' es una medida de seguridad por si no se encuentra la categoría.
      orElse: () => const Category(
        id: 'error',
        title: 'Error',
        icon: Icons.error_outline,
      ),
    );
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
    );
    final bool isIncome = transaction.status == TransactionStatus.Ingreso;
    final String sign = isIncome ? '+' : '-';
    final Color amountColor = isIncome
        ? Colors.green.shade700
        : Colors.red.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[100],
            child: Icon(category.icon, color: Colors.grey[600], size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  // Usamos DateFormat para convertir el DateTime a un String con el formato "día Mes Hora:minuto"
                  DateFormat('d MMM H:mm').format(transaction.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            '$sign${currencyFormatter.format(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
