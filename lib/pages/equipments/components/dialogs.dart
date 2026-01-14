import 'package:flutter/material.dart';

class AddRoomDialog extends StatefulWidget {
  @override
  _AddRoomDialogState createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle pièce'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _roomNameController,
          decoration: const InputDecoration(
            labelText: 'Nom de la pièce',
            hintText: 'Ex: Bureau, Garage, Buanderie...',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un nom';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _roomNameController.text);
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

class EditRoomDialog extends StatefulWidget {
  final String initialName;

  const EditRoomDialog({super.key, required this.initialName});

  @override
  _EditRoomDialogState createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<EditRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roomNameController;

  @override
  void initState() {
    super.initState();
    _roomNameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la pièce'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _roomNameController,
          decoration: const InputDecoration(
            labelText: 'Nom de la pièce',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un nom';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _roomNameController.text);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final String warning;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning,
            size: 50,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            warning,
            style: const TextStyle(fontSize: 14, color: Colors.red),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text(
            'Supprimer',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}