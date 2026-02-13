class ShoeSideData {
  final int frontPressure;
  final int heelPressure;
  final int battery;
  final String status;

  ShoeSideData({
    required this.frontPressure,
    required this.heelPressure,
    required this.battery,
    required this.status,
  });

  factory ShoeSideData.fromJson(Map<String, dynamic> json) => ShoeSideData(
        frontPressure: json['front_pressure'] ?? 0,
        heelPressure: json['heel_pressure'] ?? 0,
        battery: json['battery'] ?? 0,
        status: json['status'] ?? 'normal',
      );
}

class ShoeAlerts {
  final bool freezing;
  final bool imbalance;

  ShoeAlerts({
    required this.freezing,
    required this.imbalance,
  });

  factory ShoeAlerts.fromJson(Map<String, dynamic> json) => ShoeAlerts(
        freezing: json['freezing'] ?? false,
        imbalance: json['imbalance'] ?? false,
      );
}

class ShoeData {
  final ShoeSideData left;
  final ShoeSideData right;
  final ShoeAlerts alerts;

  ShoeData({
    required this.left,
    required this.right,
    required this.alerts,
  });

  factory ShoeData.fromJson(Map<String, dynamic> json) => ShoeData(
        left: ShoeSideData.fromJson(json['left'] as Map<String, dynamic>),
        right: ShoeSideData.fromJson(json['right'] as Map<String, dynamic>),
        alerts: ShoeAlerts.fromJson(json['alerts'] as Map<String, dynamic>),
      );
}

enum BLEConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
}


