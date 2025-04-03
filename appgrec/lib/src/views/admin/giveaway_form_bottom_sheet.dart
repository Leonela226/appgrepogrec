import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GiveawayModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const GiveawayModal({super.key, required this.onSave});

  @override
  GiveawayModalState createState() => GiveawayModalState();
}

class GiveawayModalState extends State<GiveawayModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prizeCountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _drawDateController = TextEditingController();

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Crear/Editar Sorteo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre del sorteo'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              TextFormField(
                controller: _prizeCountController,
                decoration: InputDecoration(labelText: 'Cantidad de premios'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Fecha de inicio',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _startDateController),
                  ),
                ),
                readOnly: true,
              ),
              TextFormField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'Fecha de fin',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _endDateController),
                  ),
                ),
                readOnly: true,
              ),
              TextFormField(
                controller: _drawDateController,
                decoration: InputDecoration(
                  labelText: 'Fecha del sorteo',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _drawDateController),
                  ),
                ),
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'name': _nameController.text,
                'description': _descriptionController.text,
                'prize_count': int.tryParse(_prizeCountController.text) ?? 0,
                'start_date': _startDateController.text,
                'end_date': _endDateController.text,
                'draw_date': _drawDateController.text,
              });
              Navigator.of(context).pop();
            }
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
