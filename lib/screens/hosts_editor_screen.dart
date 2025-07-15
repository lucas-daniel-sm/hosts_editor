import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hosts_editor/screens/hosts_editor_controller.dart';
import 'package:toastification/toastification.dart';

import '../models/host_entry.dart';
import '../widgets/edit_host_modal.dart';
import '../widgets/host_list_item.dart';

class HostsEditorScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HostsEditorScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<HostsEditorScreen> createState() => _HostsEditorScreenState();
}

class _HostsEditorScreenState extends State<HostsEditorScreen> {
  final HostsEditorController controller = HostsEditorController();

  @override
  void initState() {
    super.initState();
    controller.loadHostsFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Expanded(child: list),
          Container(padding: const EdgeInsets.all(16.0), child: footer),
        ],
      ),
    );
  }

  PreferredSizeWidget get appBar => AppBar(
    title: Row(
      children: [
        // Logo no cabeçalho
        Container(
          height: 32,
          width: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Image.asset(
            'assets/images/logo.png',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        const Text('Editor de Hosts'),
      ],
    ),
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    toolbarHeight: 48,
    actions: [
      // Botão de modo escuro
      IconButton(
        onPressed: widget.onThemeToggle,
        icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
        tooltip: widget.isDarkMode
            ? 'Mudar para modo claro'
            : 'Mudar para modo escuro',
      ),
      IconButton(
        onPressed: addNewHost,
        icon: const Icon(Icons.add),
        tooltip: 'Adicionar Host',
      ),

      if (controller.selectedIndices.isNotEmpty)
        IconButton(
          onPressed: () => removeHost(() => controller.removeSelectedHosts()),
          icon: const Icon(Icons.delete),
          tooltip: 'Remover Selecionados',
        ),
    ],
  );

  Widget get list => Observer(
    builder: (_) {
      final hostsLength = controller.hostsLength;
      return ListView.builder(
        itemCount: hostsLength,
        itemBuilder: (_, index) {
          return HostListItem(
            hostEntry: controller.hosts[index],
            callAutosave: controller.autoSaveIfEnabled,
            isSelected: controller.selectedIndices.contains(index),
            onEdit: () => editHost(index),
            onRemove: () => removeHost(() => controller.removeHost(index)),
            onToggleSelection: () {
              setState(() => controller.toggleSelection(index));
            },
          );
        },
      );
    },
  );

  Widget get footer => Observer(
    builder: (context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Tooltip(
                message: controller.autoSave
                    ? 'Auto save ativado'
                    : 'Auto save desativado',
                child: IconButton(
                  onPressed: controller.toggleAutoSave,
                  icon: Icon(
                    controller.autoSave ? Icons.save : Icons.save_outlined,
                    color: controller.autoSave ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              Tooltip(
                message: controller.autoReload
                    ? 'Auto reload ativado'
                    : 'Auto reload desativado',
                child: IconButton(
                  onPressed: controller.toggleAutoReload,
                  icon: Icon(
                    controller.autoReload
                        ? Icons.refresh
                        : Icons.refresh_outlined,
                    color: controller.autoReload ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: controller.saveHostsFile,
            child: const Text('Salvar'),
          ),
        ],
      );
    },
  );

  void addNewHost() {
    showDialog(
      context: context,
      builder: (context) {
        return EditHostModal(
          hostEntry: HostEntry(
            ip: '',
            hostname: '',
            comment: '',
            enabled: true,
          ),
          onSave: (newHost) {
            controller.hosts.add(newHost);
            controller.autoSaveIfEnabled();
            toastification.show(
              title: Text('Host adicionado: ${newHost.hostname}'),
              autoCloseDuration: const Duration(seconds: 3),
              type: ToastificationType.success,
            );
          },
        );
      },
    );
  }

  void editHost(int index) {
    showDialog(
      context: context,
      builder: (context) => EditHostModal(
        hostEntry: controller.hosts[index],
        onSave: (updatedHost) {
          setState(() {
            controller.hosts[index] = updatedHost;
            controller.autoSaveIfEnabled();
            toastification.show(
              title: Text('Host atualizado: ${updatedHost.hostname}'),
              autoCloseDuration: const Duration(seconds: 3),
              type: ToastificationType.success,
            );
          });
        },
      ),
    );
  }

  void removeHost(VoidCallback action) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover Host'),
          content: const Text(
            'Você tem certeza que deseja remover este(s) host(s)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                action();
                Navigator.of(context).pop();
                toastification.show(
                  title: const Text('Host(s) removido(s) com sucesso!'),
                  autoCloseDuration: const Duration(seconds: 3),
                  type: ToastificationType.success,
                );
              },
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }
}

class StringBuilder {
  final List<String> _buffer = [];

  void writeln(String line) {
    _buffer.add(line);
  }

  @override
  String toString() {
    return _buffer.join('\n');
  }
}
