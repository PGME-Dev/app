class Address {
  final String street;
  final String street2;
  final String city;
  final String state;
  final String stateCode;
  final String pincode;
  final String country;

  Address({
    this.street = '',
    this.street2 = '',
    required this.city,
    required this.state,
    required this.stateCode,
    required this.pincode,
    this.country = 'India',
  });

  bool get isValid =>
      city.isNotEmpty &&
      state.isNotEmpty &&
      stateCode.isNotEmpty &&
      pincode.isNotEmpty &&
      RegExp(r'^[1-9][0-9]{5}$').hasMatch(pincode);

  String get displayString {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (street2.isNotEmpty) parts.add(street2);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (pincode.isNotEmpty) parts.add(pincode);
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() => {
        'street': street,
        'street2': street2,
        'city': city,
        'state': state,
        'state_code': stateCode,
        'pincode': pincode,
        'country': country,
      };

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String? ?? '',
      street2: json['street2'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      stateCode: json['state_code'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      country: json['country'] as String? ?? 'India',
    );
  }

  Address copyWith({
    String? street,
    String? street2,
    String? city,
    String? state,
    String? stateCode,
    String? pincode,
    String? country,
  }) {
    return Address(
      street: street ?? this.street,
      street2: street2 ?? this.street2,
      city: city ?? this.city,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
    );
  }
}
