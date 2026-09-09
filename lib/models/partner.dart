/// A signed-in partner (salon owner), as returned by the API.
class Partner {
  const Partner({
    required this.id,
    required this.fullName,
    required this.businessName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.isActive,
  });

  final String id;
  final String fullName;
  final String businessName;
  final String email;
  final String phoneNumber;
  final String address;
  final bool isActive;

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      businessName: json['business_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      address: json['address'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
