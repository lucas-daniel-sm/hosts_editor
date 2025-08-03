import 'package:flutter/cupertino.dart';
import 'package:hosts_editor/utils/host_files_manager.dart';
import 'package:hosts_editor/utils/host_files_manager_impl.dart';
import 'package:mobx/mobx.dart';
import 'package:toastification/toastification.dart';

import '../models/host_entry.dart';

part 'hosts_editor_controller.g.dart';

class HostsEditorController = HostsEditorControllerBase
    with _$HostsEditorController;

abstract class HostsEditorControllerBase with Store {
  final HostsFilesManager hostsFilesManager = HostsFilesManagerImpl();
  @observable
  List<HostEntry> _hosts = <HostEntry>[].asObservable();
  @observable
  Set<int> _selectedIndices = <int>{}.asObservable();
  @observable
  bool _autoSave = false;
  @observable
  String _headerContent = '';

  HostsEditorControllerBase() {
    hostsFilesManager.registerOnLoadCallback(_onLoadFile);
    hostsFilesManager.registerOnSaveCallback(_onSaveFile);
    hostsFilesManager.registerPreSaveCallback(_preSaveFile);
  }

  void init() {
    hostsFilesManager.load();
  }

  void _onLoadFile(List<String> hosts) {
    try {
      _hosts
        ..clear()
        ..addAll(hosts.map(_parseHostLine));

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

  Iterable<String> _preSaveFile() => _hosts.map(_hostToLine);

  String _hostToLine(HostEntry host) {
    final comment = host.comment.isNotEmpty ? ' # ${host.comment}' : '';
    return '${host.disabled ? '# ' : ''}${host.ip} ${host.hostname}$comment';
  }

  void _onSaveFile([_]) {
    _showToast('Arquivo salvo com sucesso.', type: ToastificationType.success);
  }

  HostEntry _parseHostLine(final String line) {
    final isCommented = line.startsWith('#');
    final uncommented = isCommented ? line.substring(1).trim() : line;
    final parts = uncommented.split(RegExp(r'(\s|#)+'));
    return HostEntry(
      ip: parts[0],
      hostname: parts[1],
      comment: parts.length > 2 ? parts.sublist(2).join(' ') : '',
      enabled: !isCommented,
    );
  }

  void saveHostsFile() => hostsFilesManager.save();

  @action
  void removeHost(int index) {
    _hosts.removeAt(index);
  }

  @action
  void removeSelectedHosts() {
    final indicesToRemove = _selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a));
    for (int index in indicesToRemove) {
      _hosts.removeAt(index);
    }
    _selectedIndices.clear();
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
  void toggleAutoSave() {
    _autoSave = !_autoSave;
    if (_autoSave) {
      hostsFilesManager.enableAutoSave();
    } else {
      hostsFilesManager.disableAutoSave();
    }
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
  List<HostEntry> get hosts => _hosts;

  @computed
  int get hostsLength => _hosts.length;

  @computed
  Set<int> get selectedIndices => _selectedIndices;
}
