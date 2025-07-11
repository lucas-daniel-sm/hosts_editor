import 'package:flutter/material.dart';
import '../models/host_entry.dart';

class HostListItem extends StatelessWidget {
  final HostEntry hostEntry;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onToggleSelection;
  final Function(String field, String value) onUpdateInline;

  const HostListItem({
    super.key,
    required this.hostEntry,
    required this.isSelected,
    required this.onToggle,
    required this.onEdit,
    required this.onRemove,
    required this.onToggleSelection,
    required this.onUpdateInline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected ? Colors.blue.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Checkbox para seleção múltipla
            Checkbox(
              value: isSelected,
              onChanged: (_) => onToggleSelection(),
            ),
            const SizedBox(width: 8),

            // Radio button para habilitar/desabilitar
            Radio<bool>(
              value: true,
              groupValue: hostEntry.enabled,
              onChanged: (value) => onToggle(),
            ),
            const SizedBox(width: 8),

            // Campo IP editável
            Expanded(
              flex: 2,
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    // Auto save quando perder o foco
                  }
                },
                child: TextFormField(
                  key: ValueKey('ip_${hostEntry.ip}_${hostEntry.hostname}'),
                  initialValue: hostEntry.ip,
                  decoration: const InputDecoration(
                    labelText: 'IP',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => onUpdateInline('ip', value),
                  style: TextStyle(
                    color: hostEntry.enabled ? Colors.black : Colors.grey,
                  ),
                  enabled: hostEntry.enabled,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Campo Hostname editável
            Expanded(
              flex: 3,
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    // Auto save quando perder o foco
                  }
                },
                child: TextFormField(
                  key: ValueKey('hostname_${hostEntry.ip}_${hostEntry.hostname}'),
                  initialValue: hostEntry.hostname,
                  decoration: const InputDecoration(
                    labelText: 'Hostname',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => onUpdateInline('hostname', value),
                  style: TextStyle(
                    color: hostEntry.enabled ? Colors.black : Colors.grey,
                  ),
                  enabled: hostEntry.enabled,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Botão de editar
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Editar',
            ),

            // Botão de remover
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete),
              tooltip: 'Remover',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
