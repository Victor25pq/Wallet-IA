import 'package:flutter/material.dart';

// Un 'enum' para definir los posibles estados de una transacción
enum TransactionStatus { Ingreso, Gasto }

// Una clase 'modelo' para estructurar los datos de una transacción
class Transaction {
  final String accountId;
  final String categoryId; // <-- CAMBIADO de 'title' a 'categoryId'
  final String title; // <-- El título ahora es para la descripción específica
  final DateTime date; // <-- CAMBIADO de String a DateTime
  final double amount;
  final TransactionStatus status;

  const Transaction({
    required this.accountId,
    required this.categoryId, // <-- AÑADIDO
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
  });
}

// Modelo para una Cuenta Bancaria o Billetera
class Account {
  final String id;
  final String name;
  final double balance;
  final IconData icon;

  const Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.icon,
  });
}

class Category {
  final String id;
  final String title;
  final IconData icon;

  const Category({required this.id, required this.title, required this.icon});
}
