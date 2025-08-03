class HostsEditorConfig {
  bool isAutoSaveEnabled = false;
  int autoSaveIntervalInSeconds = 10;

  bool get isAutoSaveDisabled => !isAutoSaveEnabled;

  Duration get autoSaveIntervalDuration =>
      Duration(seconds: autoSaveIntervalInSeconds);
}
