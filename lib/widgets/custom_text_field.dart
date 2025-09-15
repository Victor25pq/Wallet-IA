// En custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  // Propiedades que podremos configurar desde fuera
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool obscureText;

  // Constructor para recibir las propiedades
  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.obscureText = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  Color _focusColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    // PASO 1: Escuchamos a AMBOS, el foco y el controlador.
    // Ambos llamarán a la misma función para decidir el color.
    _focusNode.addListener(_updateColor);
    widget.controller.addListener(_updateColor);
  }

  @override
  void dispose() {
    // PASO 3: Es crucial remover los listeners y limpiar todo.
    _focusNode.removeListener(_updateColor);
    widget.controller.removeListener(_updateColor);
    _focusNode.dispose();
    super.dispose();
  }

  // PASO 2: Creamos un método central para la lógica del color.
  void _updateColor() {
    // setState se asegura de que la UI se redibuje con el nuevo color.
    setState(() {
      // LA NUEVA LÓGICA: El color será el primario si el campo tiene
      // el foco O si no está vacío. Solo será gris si no tiene el
      // foco Y está vacío.
      final hasFocus = _focusNode.hasFocus;
      final isNotEmpty = widget.controller.text.isNotEmpty;

      _focusColor = (hasFocus || isNotEmpty)
          ? Theme.of(context).primaryColor
          : Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    // El build method no cambia en absoluto.
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: _focusColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(widget.icon, color: _focusColor),
      ),
    );
  }
}
