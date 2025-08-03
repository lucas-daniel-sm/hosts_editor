typedef OnLoadCallback = void Function(List<String> hosts);
typedef OnSaveCallback = void Function();
typedef PreSaveCallback = Iterable<String> Function();

abstract class HostsFilesManager {
  List<String> get hosts;

  Future<List<String>> load();

  Future<List<String>> save();

  void registerOnLoadCallback(final OnLoadCallback callback);

  void unregisterOnLoadCallback(final OnLoadCallback callback);

  void registerPreSaveCallback(final PreSaveCallback callback);

  void unregisterPreSaveCallback();

  void registerOnSaveCallback(final OnSaveCallback callback);

  void unregisterOnSaveCallback(final OnSaveCallback callback);

  void enableAutoSave();

  void disableAutoSave();

  void toggleAutosave();

  bool get isAutoSaveEnabled;
}
