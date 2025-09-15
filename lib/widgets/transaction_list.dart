// En lib/widgets/transaction_list.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/finance_models.dart';
import '../screens/add_transaction_page.dart';

class TransactionList extends StatefulWidget {
  final List<Transaction> transactions;
  const TransactionList({super.key, required this.transactions});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  late List<Transaction> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = List.from(widget.transactions);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _transactions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        // 2. REEMPLAZAMOS DISMISSIBLE CON SLIDABLE
        return Dismissible(
          key: Key(transaction.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            final removedTransaction = _transactions[index];
            final removedIndex = index;

            setState(() {
              _transactions.removeAt(index);
            });

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${transaction.title} eliminado'),
                action: SnackBarAction(
                  label: 'Deshacer',
                  onPressed: () {
                    setState(() {
                      _transactions.insert(removedIndex, removedTransaction);
                    });
                  },
                ),
              ),
            );
          },
          // ESTA ES LA PARTE CLAVE: EL FONDO PERSONALIZADO
          background: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 4,
            ), // Margen para que se vea redondeado
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(12), // Bordes redondeados
            ),
            child: const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTransactionPage(
                    type: transaction.status == TransactionStatus.Ingreso
                        ? TransactionType.ingreso
                        : TransactionType.gasto,
                    transaction: transaction,
                  ),
                ),
              );
            },
            child: TransactionListItem(transaction: transaction),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }
}

// TransactionListItem se mantiene igual
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final category = mockCategories.firstWhere(
      (cat) => cat.id == transaction.categoryId,
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
