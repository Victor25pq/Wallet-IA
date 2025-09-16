// lib/services/supabase_service.dart

import 'package:flutter/material.dart';
import 'package:login_app/main.dart';
import 'package:login_app/models/finance_models.dart';
import 'package:login_app/utils/icon_helper.dart';

class SupabaseService {
  // --- OBTENER BILLETERAS ---
  Future<List<Account>> getWallets() async {
    final response = await supabase
        .from('wallets')
        .select()
        .order('name', ascending: true);

    final wallets = response.map((map) {
      return Account(
        id: map['id'].toString(),
        name: map['name'],
        balance: (map['initial_balance'] as num).toDouble(),
        icon: getIconFromString(map['icon_name']),
      );
    }).toList();
    return wallets;
  }

  // --- OBTENER CATEGORÍAS ---
  Future<List<Category>> getCategories() async {
    final response = await supabase
        .from('categories')
        .select()
        .order('name', ascending: true);

    final categories = response.map((map) {
      return Category(
        id: map['id'].toString(),
        title: map['name'],
        icon: getIconFromString(map['icon_name']),
        type: map['type'],
      );
    }).toList();
    return categories;
  }

  // --- AÑADIR BILLETERA ---
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
    );
  }

  // --- AÑADIR CATEGORÍA ---
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

  // --- ELIMINAR BILLETERA (LA FUNCIÓN QUE FALTABA) ---
  Future<void> deleteWallet(String id) async {
    await supabase.from('wallets').delete().eq('id', int.parse(id));
  }

  // --- ELIMINAR CATEGORÍA (LA FUNCIÓN QUE FALTABA) ---
  Future<void> deleteCategory(String id) async {
    await supabase.from('categories').delete().eq('id', int.parse(id));
  }
}
