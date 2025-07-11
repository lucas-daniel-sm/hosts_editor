class HostEntry {
  String ip;
  String hostname;
  String comment;
  bool enabled;

  HostEntry({
    required this.ip,
    required this.hostname,
    this.comment = '',
    this.enabled = true,
  });

  String toHostsLine() {
    final prefix = enabled ? '' : '#';
    final commentSuffix = comment.isNotEmpty ? ' #$comment' : '';
    return '$prefix$ip $hostname$commentSuffix';
  }

  HostEntry copy() {
    return HostEntry(
      ip: ip,
      hostname: hostname,
      comment: comment,
      enabled: enabled,
    );
  }
}
