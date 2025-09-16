import 'package:flutter/material.dart';

// Función para convertir el string guardado en la DB a un IconData
IconData getIconFromString(String? iconName) {
  if (iconName == null) {
    // Ícono por defecto si no hay nada en la base de datos
    return Icons.label_outline;
  }
  try {
    // Parseamos el string a un entero
    final codePoint = int.parse(iconName);
    // Creamos el IconData
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  } catch (e) {
    // Si falla el parseo, devolvemos el ícono por defecto
    return Icons.label_outline;
  }
}
