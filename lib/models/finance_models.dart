// lib/models/finance_models.dart
import 'package:flutter/material.dart';

enum TransactionStatus { Ingreso, Gasto }

enum TransactionType { ingreso, gasto }

class Transaction {
  final String id;
  // CAMBIADO: de accountId a walletId
  final String walletId;
  final String categoryId;
  final String title;
  final DateTime date;
  final double amount;
  final TransactionStatus status;

  const Transaction({
    required this.id,
    // CAMBIADO: de accountId a walletId
    required this.walletId,
    required this.categoryId,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
  });
}

// ... El resto del archivo se mantiene igual ...
class Account {
  final String id;
  final String name;
  final double balance;
  final IconData icon;
  final String currency;

  const Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.icon,
    required this.currency,
  });
}

class Category {
  final String id;
  final String title;
  final IconData icon;
  final String type;

  const Category({
    required this.id,
    required this.title,
    required this.icon,
    required this.type,
  });
}
