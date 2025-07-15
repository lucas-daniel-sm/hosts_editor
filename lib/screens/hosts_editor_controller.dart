import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:toastification/toastification.dart';

import '../models/host_entry.dart';
import 'hosts_editor_screen.dart';

part 'hosts_editor_controller.g.dart';

const String hostsPath = r'C:\Windows\System32\drivers\etc\hosts';

class HostsEditorController = HostsEditorControllerBase
    with _$HostsEditorController;

abstract class HostsEditorControllerBase with Store {
  @observable
  List<HostEntry> _hosts = <HostEntry>[].asObservable();
  @observable
  Set<int> _selectedIndices = <int>{}.asObservable();
  @observable
  bool _autoReload = false;
  @observable
  bool _autoSave = false;
  @observable
  String _headerContent = '';

  void loadHostsFile() async {
    try {
      final file = File(hostsPath);
      final contents = await file.readAsString();

      final lines = contents.split('\n');
      final List<HostEntry> hosts = [];
      final List<String> headerLines = [];
      bool headerEnded = false;

      for (final line in lines) {
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

      _hosts.clear();
      _hosts.addAll(hosts);
      _headerContent = headerLines.join('\n');
      _showToast(
        'Arquivo carregado com sucesso.',
        type: ToastificationType.success,
      );
    } catch (e) {
      _showToast(
        'Erro ao carregar o arquivo: $e',
        type: ToastificationType.error,
      );
    }
  }

  bool _isHostLine(final String line) {
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

  @action
  Future<void> saveHostsFile() async {
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
      _showToast(
        'Arquivo salvo com sucesso.',
        type: ToastificationType.success,
      );
    } catch (e) {
      _showToast(
        'Erro ao salvar o arquivo: $e',
        type: ToastificationType.error,
      );
    }
  }

  @action
  void autoSaveIfEnabled() {
    if (_autoSave) {
      saveHostsFile();
    }
  }

  @action
  void removeHost(int index) {
    _hosts.removeAt(index);
    autoSaveIfEnabled();
  }

  @action
  void removeSelectedHosts() {
    final indicesToRemove = _selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a));
    for (int index in indicesToRemove) {
      _hosts.removeAt(index);
    }
    _selectedIndices.clear();
    autoSaveIfEnabled();
  }

  @action
  void toggleSelection(int index) {
    if (_selectedIndices.contains(index)) {
      _selectedIndices.remove(index);
    } else {
      _selectedIndices.add(index);
    }
  }

  @action
  void toggleAutoReload() {
    _autoReload = !_autoReload;
  }

  @action
  void toggleAutoSave() {
    _autoSave = !_autoSave;
  }

  void _showToast(
    String message, {
    ToastificationType type = ToastificationType.info,
  }) {
    toastification.show(
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      type: type,
    );
  }

  @computed
  bool get autoSave => _autoSave;

  @computed
  bool get autoReload => _autoReload;

  @computed
  List<HostEntry> get hosts => _hosts;

  @computed
  int get hostsLength => _hosts.length;

  @computed
  Set<int> get selectedIndices => _selectedIndices;
}
