import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hosts_editor/widgets/host_list_item_controller.dart';

import '../models/host_entry.dart';

class HostListItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onToggleSelection;

  final HostListItemControler _controller;

  HostListItem({
    super.key,
    required HostEntry hostEntry,
    required VoidCallback callAutosave,
    required this.isSelected,
    required this.onEdit,
    required this.onRemove,
    required this.onToggleSelection,
  }) : _controller = HostListItemControler(hostEntry, callAutosave);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.brightness == Brightness.dark
        ? Colors.blue.shade900
        : Colors.blue.shade50;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected ? color : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Observer(
          builder: (context) {
            final textStyle = TextStyle(
              color: _controller.enabled
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withAlpha(128),
            );
            return _geRow(textStyle);
          },
        ),
      ),
    );
  }

  Widget _geRow(final TextStyle textStyle) => Row(
    children: [
      // Checkbox para seleção múltipla
      Checkbox(value: isSelected, onChanged: (_) => onToggleSelection()),
      const SizedBox(width: 8),

      // Radio button para habilitar/desabilitar (corrigido)
      btnEnabled,
      const SizedBox(width: 8),

      // Campo IP editável
      _getTfIp(textStyle),
      const SizedBox(width: 8),

      // Campo Hostname editável
      _getTfHostname(textStyle),
      const SizedBox(width: 8),

      // Botão de editar
      editButton,

      // Botão de remover
      removeButton,
    ],
  );

  Widget get btnEnabled => Observer(
    builder: (_) {
      return Radio<bool>(
        value: _controller.enabled,
        groupValue: true,
        toggleable: true,
        onChanged: (_) => _controller.toggleEnabled(),
      );
    },
  );

  Widget _getTfIp(final TextStyle textStyle) => Expanded(
    flex: 2,
    child: TextFormField(
      controller: _controller.ipTextController,
      decoration: const InputDecoration(
        labelText: 'IP',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      onEditingComplete: _controller.updateIp,
      onTapOutside: (_) => _controller.updateIp(),
      style: textStyle,
      enabled: _controller.enabled,
    ),
  );

  Widget _getTfHostname(final TextStyle textStyle) => Expanded(
    flex: 3,
    child: TextFormField(
      controller: _controller.hostnameTextController,
      decoration: const InputDecoration(
        labelText: 'Hostname',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      onEditingComplete: _controller.updateHostname,
      onTapOutside: (_) => _controller.updateHostname(),
      style: textStyle,
      enabled: _controller.enabled,
    ),
  );

  Widget get editButton => IconButton(
    onPressed: onEdit,
    icon: const Icon(Icons.edit),
    tooltip: 'Editar',
  );

  Widget get removeButton => IconButton(
    onPressed: onRemove,
    icon: const Icon(Icons.delete),
    tooltip: 'Remover',
    color: Colors.red,
  );
}
