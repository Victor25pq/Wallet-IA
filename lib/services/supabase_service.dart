// lib/services/supabase_service.dart

import 'package:login_app/main.dart';
import 'package:login_app/models/finance_models.dart';
import 'package:login_app/utils/icon_helper.dart';

class SupabaseService {
  // ... las demás funciones se mantienen igual ...
  Future<List<Account>> getWallets() async {
    final response = await supabase
        .from('wallets')
        .select()
        .order('name', ascending: true);
    return response.map((map) {
      return Account(
        id: map['id'].toString(),
        name: map['name'],
        balance: (map['initial_balance'] as num).toDouble(),
        icon: getIconFromString(map['icon_name']),
        currency: map['currency'] ?? 'PEN',
      );
    }).toList();
  }

  Future<List<Category>> getCategories() async {
    final response = await supabase
        .from('categories')
        .select()
        .order('name', ascending: true);
    return response.map((map) {
      return Category(
        id: map['id'].toString(),
        title: map['name'],
        icon: getIconFromString(map['icon_name']),
        type: map['type'],
      );
    }).toList();
  }

  // --- GET TRANSACTIONS (ACTUALIZADO) ---
  Future<List<Transaction>> getTransactions() async {
    final response = await supabase
        .from('transactions')
        .select()
        // CAMBIADO: Ordenamos por la columna correcta
        .order('transaction_date', ascending: false);

    return response.map((map) {
      return Transaction(
        id: map['id'].toString(),
        walletId: map['wallet_id'].toString(),
        categoryId: map['category_id'].toString(),
        title: map['description'],
        // CAMBIADO: Leemos desde la columna correcta
        date: DateTime.parse(map['transaction_date']),
        amount: (map['amount'] as num).toDouble(),
        status: map['type'] == 'ingreso'
            ? TransactionStatus.Ingreso
            : TransactionStatus.Gasto,
      );
    }).toList();
  }

  // ...
  Future<Account> addWallet({
    required String name,
    required String currency,
    required double initialBalance,
    required String iconName,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');
    final response = await supabase
        .from('wallets')
        .insert({
          'user_id': userId,
          'name': name,
          'currency': currency,
          'initial_balance': initialBalance,
          'icon_name': iconName,
        })
        .select()
        .single();
    return Account(
      id: response['id'].toString(),
      name: response['name'],
      balance: (response['initial_balance'] as num).toDouble(),
      icon: getIconFromString(response['icon_name']),
      currency: response['currency'],
    );
  }

  Future<Account> updateWallet({
    required String id,
    required String name,
    required String currency,
    required double initialBalance,
    required String iconName,
  }) async {
    final response = await supabase
        .from('wallets')
        .update({
          'name': name,
          'currency': currency,
          'initial_balance': initialBalance,
          'icon_name': iconName,
        })
        .eq('id', int.parse(id))
        .select()
        .single();
    return Account(
      id: response['id'].toString(),
      name: response['name'],
      balance: (response['initial_balance'] as num).toDouble(),
      icon: getIconFromString(response['icon_name']),
      currency: response['currency'],
    );
  }

  Future<Category> addCategory({
    required String name,
    required String type,
    required String iconName,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');
    final response = await supabase
        .from('categories')
        .insert({
          'user_id': userId,
          'name': name,
          'type': type,
          'icon_name': iconName,
        })
        .select()
        .single();
    return Category(
      id: response['id'].toString(),
      title: response['name'],
      icon: getIconFromString(response['icon_name']),
      type: response['type'],
    );
  }

  Future<Category> updateCategory({
    required String id,
    required String name,
    required String type,
    required String iconName,
  }) async {
    final response = await supabase
        .from('categories')
        .update({'name': name, 'type': type, 'icon_name': iconName})
        .eq('id', int.parse(id))
        .select()
        .single();
    return Category(
      id: response['id'].toString(),
      title: response['name'],
      icon: getIconFromString(response['icon_name']),
      type: response['type'],
    );
  }

  // --- ADD TRANSACTION (ACTUALIZADO) ---
  Future<void> addTransaction({
    required double amount,
    required String type,
    required String categoryId,
    required String accountId,
    required String description,
    required DateTime date,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    await supabase.from('transactions').insert({
      'user_id': userId,
      'amount': amount,
      'type': type,
      'category_id': int.parse(categoryId),
      'wallet_id': int.parse(accountId),
      'description': description,
      // CAMBIADO: Usamos el nombre de columna correcto
      'transaction_date': date.toIso8601String(),
    });
  }

  // --- UPDATE TRANSACTION (ACTUALIZADO) ---
  Future<void> updateTransaction({
    required String id,
    required double amount,
    required String type,
    required String categoryId,
    required String accountId,
    required String description,
    required DateTime date,
  }) async {
    await supabase
        .from('transactions')
        .update({
          'amount': amount,
          'type': type,
          'category_id': int.parse(categoryId),
          'wallet_id': int.parse(accountId),
          'description': description,
          // CAMBIADO: Usamos el nombre de columna correcto
          'transaction_date': date.toIso8601String(),
        })
        .eq('id', int.parse(id));
  }

  // ...
  Future<void> deleteWallet(String id) async {
    await supabase.from('wallets').delete().eq('id', int.parse(id));
  }

  Future<void> deleteCategory(String id) async {
    await supabase.from('categories').delete().eq('id', int.parse(id));
  }
}
