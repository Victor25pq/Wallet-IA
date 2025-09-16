// lib/widgets/settings/add_category_form.dart

import 'package:flutter/material.dart';
import 'package:login_app/models/finance_models.dart';
import 'package:login_app/services/supabase_service.dart';

const List<IconData> categoryIcons = [
  Icons.fastfood,
  Icons.local_bar,
  Icons.local_gas_station,
  Icons.local_mall,
  Icons.movie,
  Icons.restaurant,
  Icons.shopping_cart,
  Icons.train,
  Icons.work,
  Icons.attach_money,
  Icons.card_giftcard,
  Icons.home,
  Icons.flight,
  Icons.directions_car,
  Icons.local_hospital,
  Icons.school,
  Icons.pets,
  Icons.phone_android,
  Icons.devices,
  Icons.sports_esports,
  Icons.fitness_center,
  Icons.music_note,
  Icons.brush,
  Icons.redeem,
];

class AddCategoryForm extends StatefulWidget {
  final Category? categoryToEdit;
  // NUEVO PARÁMETRO
  final TransactionType? preselectedType;

  const AddCategoryForm({super.key, this.categoryToEdit, this.preselectedType});

  @override
  State<AddCategoryForm> createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<AddCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();

  int _selectedTypeIndex = 0;
  IconData _selectedIcon = categoryIcons.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.title;
      _selectedIcon = widget.categoryToEdit!.icon;
      _selectedTypeIndex = widget.categoryToEdit!.type == 'gasto' ? 0 : 1;
    } else if (widget.preselectedType != null) {
      // Si hay un tipo preseleccionado (y no estamos editando), lo usamos
      _selectedTypeIndex = widget.preselectedType == TransactionType.gasto
          ? 0
          : 1;
    }
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final String type = _selectedTypeIndex == 0 ? 'gasto' : 'ingreso';
        final String iconName = _selectedIcon.codePoint.toString();

        if (widget.categoryToEdit == null) {
          final newCategory = await _supabaseService.addCategory(
            name: _nameController.text,
            type: type,
            iconName: iconName,
          );
          if (mounted) Navigator.of(context).pop(newCategory);
        } else {
          final updatedCategory = await _supabaseService.updateCategory(
            id: widget.categoryToEdit!.id,
            name: _nameController.text,
            type: type,
            iconName: iconName,
          );
          if (mounted) Navigator.of(context).pop(updatedCategory);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color expenseColor = Colors.red.shade400;
    final Color incomeColor = Colors.green.shade600;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Nombre de la categoría',
                border: InputBorder.none,
                labelText: widget.categoryToEdit != null
                    ? 'Editando Categoría'
                    : null,
              ),
              validator: (value) => value!.isEmpty ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),

            // --- LÓGICA DE VISIBILIDAD AÑADIDA ---
            // El selector solo aparece si no hay un tipo preseleccionado
            if (widget.preselectedType == null)
              ToggleButtons(
                isSelected: [_selectedTypeIndex == 0, _selectedTypeIndex == 1],
                onPressed: (index) =>
                    setState(() => _selectedTypeIndex = index),
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                color: Colors.grey[600],
                fillColor: _selectedTypeIndex == 0 ? expenseColor : incomeColor,
                selectedBorderColor: _selectedTypeIndex == 0
                    ? expenseColor
                    : incomeColor,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Gasto'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Ingreso'),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            const Text('Elige un ícono:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryIcons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final icon = categoryIcons[index];
                  final isSelected = _selectedIcon.codePoint == icon.codePoint;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Colors.grey[200],
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveCategory,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
