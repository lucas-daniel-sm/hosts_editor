import 'dart:io';
import 'package:flutter/material.dart';
import '../models/host_entry.dart';
import '../widgets/host_list_item.dart';
import '../widgets/edit_host_modal.dart';

class HostsEditorScreen extends StatefulWidget {
  const HostsEditorScreen({super.key});

  @override
  State<HostsEditorScreen> createState() => _HostsEditorScreenState();
}

class _HostsEditorScreenState extends State<HostsEditorScreen> {
  List<HostEntry> _hosts = [];
  Set<int> _selectedIndices = {};
  bool _autoReload = false;
  bool _autoSave = true;
  String _status = '';
  String _headerContent = '';
  final String hostsPath = r'C:\Windows\System32\drivers\etc\hosts';

  @override
  void initState() {
    super.initState();
    _loadHostsFile();
  }

  void _loadHostsFile() async {
    try {
      final file = File(hostsPath);
      final contents = await file.readAsString();

      final lines = contents.split('\n');
      final List<HostEntry> hosts = [];
      final List<String> headerLines = [];
      bool headerEnded = false;

      for (String line in lines) {
        final trimmed = line.trim();

        // Collect header lines until we find the first host entry
        if (!headerEnded && !_isHostLine(trimmed)) {
          headerLines.add(line);
          continue;
        }

        if (_isHostLine(trimmed)) {
          headerEnded = true;
          final hostEntry = _parseHostLine(trimmed);
          if (hostEntry != null) {
            hosts.add(hostEntry);
          }
        }
      }

      setState(() {
        _hosts = hosts;
        _headerContent = headerLines.join('\n');
        _status = 'Arquivo carregado com sucesso.';
      });
    } catch (e) {
      setState(() {
        _status = 'Erro ao carregar: $e';
      });
    }
  }

  bool _isHostLine(String line) {
    final uncommented = line.startsWith('#') ? line.substring(1).trim() : line;
    final parts = uncommented.split(RegExp(r'\s+'));
    return parts.length >= 2 && _isValidIP(parts[0]);
  }

  bool _isValidIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    try {
      for (String part in parts) {
        final num = int.parse(part);
        if (num < 0 || num > 255) return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  HostEntry? _parseHostLine(String line) {
    final isEnabled = !line.startsWith('#');
    final cleanLine = line.startsWith('#') ? line.substring(1).trim() : line;

    String comment = '';
    String workingLine = cleanLine;

    // Extract comment if exists
    final commentIndex = cleanLine.indexOf('#');
    if (commentIndex != -1) {
      comment = cleanLine.substring(commentIndex + 1).trim();
      workingLine = cleanLine.substring(0, commentIndex).trim();
    }

    final parts = workingLine.split(RegExp(r'\s+'));
    if (parts.length >= 2 && _isValidIP(parts[0])) {
      return HostEntry(
        ip: parts[0],
        hostname: parts[1],
        comment: comment,
        enabled: isEnabled,
      );
    }

    return null;
  }

  void _saveHostsFile() async {
    try {
      final StringBuilder content = StringBuilder();

      // Add header content
      if (_headerContent.isNotEmpty) {
        content.writeln(_headerContent);
        content.writeln('');
      }

      for (HostEntry host in _hosts) {
        final line = host.toHostsLine();
        content.writeln(line);
      }

      final file = File(hostsPath);
      await file.writeAsString(content.toString());

      setState(() {
        _status = 'Arquivo salvo com sucesso.';
      });
    } catch (e) {
      setState(() {
        _status = 'Erro ao salvar: $e';
      });
    }
  }

  void _autoSaveIfEnabled() {
    if (_autoSave) {
      _saveHostsFile();
    }
  }

  void _toggleHost(int index) {
    setState(() {
      _hosts[index].enabled = !_hosts[index].enabled;
    });
    _autoSaveIfEnabled();
  }

  void _editHost(int index) {
    showDialog(
      context: context,
      builder: (context) => EditHostModal(
        hostEntry: _hosts[index],
        onSave: (updatedHost) {
          setState(() {
            _hosts[index] = updatedHost;
          });
          _autoSaveIfEnabled();
        },
      ),
    );
  }

  void _updateHostInline(int index, String field, String value) {
    setState(() {
      switch (field) {
        case 'ip':
          _hosts[index].ip = value;
          break;
        case 'hostname':
          _hosts[index].hostname = value;
          break;
      }
    });
    _autoSaveIfEnabled();
  }

  void _addNewHost() {
    showDialog(
      context: context,
      builder: (context) => EditHostModal(
        hostEntry: HostEntry(ip: '', hostname: '', comment: '', enabled: true),
        onSave: (newHost) {
          setState(() {
            _hosts.add(newHost);
          });
          _autoSaveIfEnabled();
        },
      ),
    );
  }

  void _removeHost(int index) {
    setState(() {
      _hosts.removeAt(index);
    });
    _autoSaveIfEnabled();
  }

  void _removeSelectedHosts() {
    final indicesToRemove = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    setState(() {
      for (int index in indicesToRemove) {
        _hosts.removeAt(index);
      }
      _selectedIndices.clear();
    });
    _autoSaveIfEnabled();
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _toggleAutoReload() {
    setState(() {
      _autoReload = !_autoReload;
    });
  }

  void _toggleAutoSave() {
    setState(() {
      _autoSave = !_autoSave;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Hosts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        toolbarHeight: 48,
        actions: [
          IconButton(
            onPressed: _addNewHost,
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Host',
          ),
          if (_selectedIndices.isNotEmpty)
            IconButton(
              onPressed: _removeSelectedHosts,
              icon: const Icon(Icons.delete),
              tooltip: 'Remover Selecionados',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _hosts.length,
              itemBuilder: (context, index) {
                return HostListItem(
                  hostEntry: _hosts[index],
                  isSelected: _selectedIndices.contains(index),
                  onToggle: () => _toggleHost(index),
                  onEdit: () => _editHost(index),
                  onRemove: () => _removeHost(index),
                  onToggleSelection: () => _toggleSelection(index),
                  onUpdateInline: (field, value) => _updateHostInline(index, field, value),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_status.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _status,
                      style: TextStyle(
                        color: _status.contains('Erro') ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Tooltip(
                          message: _autoSave ? 'Auto save ativado' : 'Auto save desativado',
                          child: IconButton(
                            onPressed: _toggleAutoSave,
                            icon: Icon(
                              _autoSave ? Icons.save : Icons.save_outlined,
                              color: _autoSave ? Colors.green : Colors.grey,
                            ),
                          ),
                        ),
                        Tooltip(
                          message: _autoReload ? 'Auto reload ativado' : 'Auto reload desativado',
                          child: IconButton(
                            onPressed: _toggleAutoReload,
                            icon: Icon(
                              _autoReload ? Icons.refresh : Icons.refresh_outlined,
                              color: _autoReload ? Colors.green : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _saveHostsFile,
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
