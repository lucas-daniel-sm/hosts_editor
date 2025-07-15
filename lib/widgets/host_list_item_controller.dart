import 'package:flutter/widgets.dart';
import 'package:hosts_editor/models/host_entry.dart';
import 'package:mobx/mobx.dart';

part 'host_list_item_controller.g.dart';

class HostListItemControler = HostListItemControlerBase
    with _$HostListItemControler;

abstract class HostListItemControlerBase with Store {
  final HostEntry _hostEntry;
  final TextEditingController ipTextController;
  final TextEditingController hostnameTextController;
  final VoidCallback callAutosave;

  @observable
  late bool _enabled = _hostEntry.enabled;

  HostListItemControlerBase(this._hostEntry, this.callAutosave)
    : ipTextController = TextEditingController(text: _hostEntry.ip),
      hostnameTextController = TextEditingController(text: _hostEntry.hostname);

  @action
  void toggleEnabled() {
    print('call toggleEnabled $_enabled');
    _enabled = !_enabled;
    _hostEntry.enabled = _enabled;
    print('toggleEnabled: $_enabled');
    callAutosave();
  }

  @action
  void updateIp() {
    _hostEntry.ip = ipTextController.text;
    callAutosave();
  }

  @action
  void updateHostname() {
    _hostEntry.hostname = hostnameTextController.text;
    callAutosave();
  }

  @computed
  bool get enabled {
    return _enabled;
  }

  String get ip => _hostEntry.ip;

  String get hostname => _hostEntry.hostname;
}
