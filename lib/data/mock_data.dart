// En lib/data/mock_data.dart
import 'package:flutter/material.dart';
import '../models/finance_models.dart';

// La lista de cuentas no cambia
final List<Account> mockAccounts = const [
  Account(
    id: 'bcp',
    name: 'BCP',
    balance: 5250.50,
    icon: Icons.account_balance,
  ),
  Account(id: 'paypal', name: 'PayPal', balance: 320.00, icon: Icons.paypal),
  Account(
    id: 'binance',
    name: 'Binance',
    balance: 7000.00,
    icon: Icons.currency_bitcoin,
  ),
  Account(id: 'efectivo', name: 'Efectivo', balance: 80.50, icon: Icons.wallet),
];

// NUEVA LISTA DE CATEGORÍAS
final List<Category> mockCategories = [
  const Category(
    id: 'food',
    title: 'Comida',
    icon: Icons.fastfood_outlined,
    type: 'Gasto',
  ),
  const Category(
    id: 'services',
    title: 'Servicios',
    icon: Icons.receipt_long_outlined,
    type: 'Gasto',
  ),
  const Category(
    id: 'transport',
    title: 'Transporte',
    icon: Icons.directions_bus_outlined,
    type: 'Gasto',
  ),
  const Category(
    id: 'shopping',
    title: 'Compras',
    icon: Icons.shopping_bag_outlined,
    type: 'Gasto',
  ),
  const Category(
    id: 'housing',
    title: 'Alquiler',
    icon: Icons.home_outlined,
    type: 'Gasto',
  ),
  const Category(
    id: 'health',
    title: 'Salud',
    icon: Icons.healing_outlined,
    type: 'Gasto',
  ),
  const Category(
    id: 'clothing',
    title: 'Ropa',
    icon: Icons.checkroom,
    type: 'Ingreso',
  ),
  const Category(
    id: 'others',
    title: 'Otros',
    icon: Icons.more_horiz,
    type: 'Gasto',
  ),
];

// LISTA DE TRANSACCIONES ACTUALIZADA
final List<Transaction> mockTransactions = [
  Transaction(
    id: 't1',
    accountId: 'bcp',
    categoryId: 'shopping',
    title: 'Zapatillas nuevas',
    date: DateTime.now().subtract(const Duration(days: 2)),
    amount: 120.00,
    status: TransactionStatus.Gasto,
  ),
  Transaction(
    id: 't2',
    accountId: 'efectivo',
    categoryId: 'food',
    title: 'Almuerzo',
    date: DateTime.now().subtract(const Duration(days: 5)),
    amount: 15.00,
    status: TransactionStatus.Gasto,
  ),
  Transaction(
    id: 't3',
    accountId: 'bcp',
    categoryId: 'services',
    title: 'Pago de Internet',
    date: DateTime.now().subtract(const Duration(days: 10)),
    amount: 50.00,
    status: TransactionStatus.Gasto,
  ),
  Transaction(
    id: 't4',
    accountId: 'paypal',
    categoryId: 'shopping',
    title: 'Compra online',
    date: DateTime.now().subtract(const Duration(days: 40)),
    amount: 250.00,
    status: TransactionStatus.Gasto,
  ),
  Transaction(
    id: 't5',
    accountId: 'binance',
    categoryId: 'others',
    title: 'Ganancia Crypto',
    date: DateTime.now().subtract(const Duration(days: 60)),
    amount: 1500.00,
    status: TransactionStatus.Ingreso,
  ),
];
