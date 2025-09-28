class AppConfig {
  final int activationCharge;
  final int activationValidity;
  final String smsApiKey;
  final double smsCharge;
  final String smsSenderId;
  final double discount;

  AppConfig({
    required this.activationCharge,
    required this.activationValidity,
    required this.smsApiKey,
    required this.smsCharge,
    required this.smsSenderId,
    required this.discount,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      activationCharge: json['activationCharge'] ?? 0,
      activationValidity: json['activationValidity'] ?? 0,
      smsApiKey: json['smsApiKey'] ?? '',
      smsCharge: (json['smsCharge'] ?? 0).toDouble(),
      smsSenderId: json['smsSenderId'] ?? '',
      discount: (json['discount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activationCharge': activationCharge,
      'activationValidity': activationValidity,
      'smsApiKey': smsApiKey,
      'smsCharge': smsCharge,
      'smsSenderId': smsSenderId,
      'discount': discount,
    };
  }
}
