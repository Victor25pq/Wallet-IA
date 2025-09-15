// En lib/utils/account_selector.dart

import 'package:flutter/material.dart';
import '../models/finance_models.dart';

// Esta función es 'async' y devuelve en el futuro la cuenta que el usuario elija.
Future<Account?> showAccountSelector(
  BuildContext context,
  List<Account> accounts,
) async {
  // showModalBottomSheet devuelve el valor que le pasemos a Navigator.pop()
  final selectedAccount = await showModalBottomSheet<Account>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (ctx) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Text(
            'Seleccionar Cuenta',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return ListTile(
                  leading: Icon(account.icon),
                  title: Text(account.name),
                  onTap: () {
                    // Al presionar, cerramos el menú y devolvemos la cuenta seleccionada.
                    Navigator.pop(ctx, account);
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );

  return selectedAccount;
}
