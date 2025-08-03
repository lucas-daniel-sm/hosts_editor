import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hosts_editor/models/hosts_editor_config.dart';

import 'address_utils.dart';
import 'host_files_manager.dart';

const String _hostsPath = r'D:\Windows\System32\drivers\etc\hosts';
const String _msHostsHeader = """
# Copyright (c) 1993-2009 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host

# localhost name resolution is handled within DNS itself.
#	127.0.0.1       localhost
#	::1             localhost
""";

class HostsFilesManagerImpl extends HostsFilesManager {
  final _hostsFile = File(_hostsPath);
  final _addressUtils = AddressUtils();

  final hostsFilesManagerConfig = HostsEditorConfig();

  @override
  final hosts = <String>[];
  var _lastLoadedContent = '';

  Timer? _autoSaveTimer;
  final _oOnLoadCallbacks = <OnLoadCallback>[];
  final _onSaveCallbacks = <OnSaveCallback>[];
  PreSaveCallback? _preSaveCallback;

  var _isSaving = false;

  @override
  Future<List<String>> load() async {
    final contents = await _hostsFile.readAsString();
    if (contents == _lastLoadedContent) {
      return hosts;
    }
    _lastLoadedContent = contents;
    final lines = contents
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (contents.startsWith(_msHostsHeader)) {
      lines.removeRange(0, 20);
    }

    final hostLines = <String>[];
    var headerEnded = false;

    for (final line in lines) {
      final isValidHostLine = _isValidHostLine(line);
      if (!headerEnded && !isValidHostLine) {
        continue;
      }

      if (isValidHostLine) {
        hostLines.add(line);
      }
    }

    hosts
      ..clear()
      ..addAll(hostLines);

    for (final callback in _oOnLoadCallbacks) {
      callback(hosts);
    }

    return hosts;
  }

  bool _isValidHostLine(final String line) {
    final possibleHostLineRegex = RegExp(
      r'^\s*#?\s*((\d{1,3}\.){3}\d{1,3}|([a-fA-F0-9]{1,4}:){1,7}([a-fA-F0-9]{1,4}|:))\s+(\S)+\s*(#.*)?$',
    );
    if (!possibleHostLineRegex.hasMatch(line)) {
      return false;
    }
    final uncommented = line.startsWith('#') ? line.substring(1).trim() : line;
    final parts = uncommented.split(RegExp(r'(\s|#)+'));
    if (parts.length < 2) return false;
    final ip = parts[0];
    final host = parts[1];
    final validIp = _addressUtils.isValidIP(ip);
    final validHost = _addressUtils.isValidHost(host);
    final hostNotIp = !_addressUtils.isValidIP(host);
    return validIp && validHost && hostNotIp;
  }

  @override
  Future<List<String>> save() async {
    if (_preSaveCallback != null) {
      hosts
        ..clear()
        ..addAll(_preSaveCallback!());
    }

    _isSaving = true;
    final content = _msHostsHeader + hosts.join('\n');

    if (_lastLoadedContent == content) {
      debugPrint('No changes detected, skipping save.');
      _isSaving = false;
      return hosts;
    }

    await _hostsFile.writeAsString(content);
    _lastLoadedContent = content;
    for (final callback in _onSaveCallbacks) {
      callback();
    }
    return hosts;
  }

  @override
  void enableAutoSave() {
    if (hostsFilesManagerConfig.isAutoSaveEnabled) {
      return;
    }
    hostsFilesManagerConfig.isAutoSaveEnabled = true;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      hostsFilesManagerConfig.autoSaveIntervalDuration,
      (_) {
        if (_isSaving) {
          debugPrint(
            'Auto-save skipped because a save operation is already in progress.',
          );
          return;
        }
        save();
      },
    );
  }

  @override
  void disableAutoSave() {
    if (hostsFilesManagerConfig.isAutoSaveDisabled) {
      return;
    }
    hostsFilesManagerConfig.isAutoSaveEnabled = false;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  @override
  void toggleAutosave() {
    if (hostsFilesManagerConfig.isAutoSaveEnabled) {
      disableAutoSave();
    } else {
      enableAutoSave();
    }
  }

  @override
  bool get isAutoSaveEnabled => hostsFilesManagerConfig.isAutoSaveEnabled;

  @override
  void registerOnLoadCallback(final OnLoadCallback callback) {
    _oOnLoadCallbacks.add(callback);
  }

  @override
  void unregisterOnLoadCallback(final OnLoadCallback callback) {
    _oOnLoadCallbacks.remove(callback);
  }

  @override
  void registerPreSaveCallback(final PreSaveCallback callback) {
    _preSaveCallback = callback;
  }

  @override
  void unregisterPreSaveCallback() {
    _preSaveCallback = null;
  }

  @override
  void registerOnSaveCallback(final OnSaveCallback callback) {
    _onSaveCallbacks.add(callback);
  }

  @override
  void unregisterOnSaveCallback(final OnSaveCallback callback) {
    _onSaveCallbacks.remove(callback);
  }
}
