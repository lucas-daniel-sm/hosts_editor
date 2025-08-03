final _ipv4RegExp = RegExp(
  r'^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}'
  r'(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$',
);

final _ipv6RegExp = RegExp(
  r'^('
  r'(([0-9a-fA-F]{1,4}:){7}([0-9a-fA-F]{1,4}|:))|'
  r'(([0-9a-fA-F]{1,4}:){1,7}:)|'
  r'(([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})|'
  r'(([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2})|'
  r'(([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3})|'
  r'(([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4})|'
  r'(([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5})|'
  r'([0-9a-fA-F]{1,4}:)((:[0-9a-fA-F]{1,4}){1,6})|'
  r':((:[0-9a-fA-F]{1,4}){1,7}|:)|'
  r'fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|'
  r'::(ffff(:0{1,4}){0,1}:){0,1}'
  r'((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}'
  r'(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)|'
  r'([0-9a-fA-F]{1,4}:){1,4}:'
  r'((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}'
  r'(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)'
  r')$',
);

class AddressUtils {
  bool isValidIPv4(final String ip) => _ipv4RegExp.hasMatch(ip);

  bool isValidIPv6(final String ip) => _ipv6RegExp.hasMatch(ip);

  bool isValidIP(final String ip) => isValidIPv4(ip) || isValidIPv6(ip);

  bool isValidHost(final String host) {
    try {
      return Uri.http(host).host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
