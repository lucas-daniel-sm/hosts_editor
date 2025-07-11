import 'package:flutter/material.dart';
import '../models/host_entry.dart';

class EditHostModal extends StatefulWidget {
  final HostEntry hostEntry;
  final Function(HostEntry) onSave;

  const EditHostModal({
    super.key,
    required this.hostEntry,
    required this.onSave,
  });

  @override
  State<EditHostModal> createState() => _EditHostModalState();
}

class _EditHostModalState extends State<EditHostModal> {
  late TextEditingController _ipController;
  late TextEditingController _hostnameController;
  late TextEditingController _commentController;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.hostEntry.ip);
    _hostnameController = TextEditingController(text: widget.hostEntry.hostname);
    _commentController = TextEditingController(text: widget.hostEntry.comment);
    _isEnabled = widget.hostEntry.enabled;
  }

  @override
  void dispose() {
    _ipController.dispose();
    _hostnameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveAndClose() {
    final updatedHost = HostEntry(
      ip: _ipController.text.trim(),
      hostname: _hostnameController.text.trim(),
      comment: _commentController.text.trim(),
      enabled: _isEnabled,
    );

    widget.onSave(updatedHost);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com título e botão fechar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Editar Host',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Fechar',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Campo Ativo
            SwitchListTile(
              title: const Text('Ativo'),
              subtitle: Text(_isEnabled ? 'Habilitado' : 'Desabilitado'),
              value: _isEnabled,
              onChanged: (value) {
                setState(() {
                  _isEnabled = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Campo IP
            TextFormField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Hostname
            TextFormField(
              controller: _hostnameController,
              decoration: const InputDecoration(
                labelText: 'Hostname',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
            ),
            const SizedBox(height: 16),

            // Campo Comentário
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comentário (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.comment),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Botão salvar no canto inferior direito
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _saveAndClose,
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
