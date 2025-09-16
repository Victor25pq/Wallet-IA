// lib/widgets/home/transaction_section.dart

import 'package:flutter/material.dart';
import '../../models/finance_models.dart';
import '../transaction_list.dart';

class TransactionSection extends StatelessWidget {
  final List<Transaction> transactions;
  const TransactionSection({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Tomamos solo las 3 transacciones más recientes para la HomePage
    final recentTransactions = transactions.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transacciones',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/all_transactions');
                },
                child: const Text('Ver Todas'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (recentTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: Text('Aún no hay transacciones.')),
            )
          else
            TransactionList(transactions: recentTransactions),
        ],
      ),
    );
  }
}
