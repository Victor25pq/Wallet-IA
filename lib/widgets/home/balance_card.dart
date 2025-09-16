import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/finance_models.dart'; // Ajusta la ruta si es necesario

class BalanceCard extends StatefulWidget {
  final double balance;
  final List<Account> accounts;
  final Account allAccountsOption;
  final Function(Account) onAccountSelected;
  final Account selectedAccount;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.accounts,
    required this.allAccountsOption,
    required this.onAccountSelected,
    required this.selectedAccount,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
    );

    return Container(
      padding: const EdgeInsets.all(25.0),
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
          PopupMenuButton<Account>(
            onSelected: widget.onAccountSelected,
            itemBuilder: (context) {
              // ... (el código interno del PopupMenuButton se mantiene igual)
              final allAccountsOption = [
                PopupMenuItem<Account>(
                  value: widget.allAccountsOption,
                  child: Text(widget.allAccountsOption.name),
                ),
              ];
              final accountOptions = widget.accounts.map((account) {
                final isSelected = widget.selectedAccount.id == account.id;
                return PopupMenuItem<Account>(
                  value: account,
                  child: Text(
                    account.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList();
              return allAccountsOption + accountOptions;
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.selectedAccount.name,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _isBalanceVisible
                    ? currencyFormatter.format(widget.balance)
                    : '••••••••••',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
                child: Icon(
                  _isBalanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
