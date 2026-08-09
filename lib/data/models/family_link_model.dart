class DeviceRole {
  static const none = 'none';
  static const parent = 'parent';
  static const child = 'child';
}

class ChildSummary {
  final String deviceId;
  final String? name;
  ChildSummary({required this.deviceId, this.name});
}
