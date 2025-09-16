// lib/widgets/home/home_header.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En el futuro, este nombre vendrá del perfil del usuario
            const Text(
              'Bienvenido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat.yMMMMd('es_ES').format(DateTime.now()),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.person_outline,
            size: 35,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
