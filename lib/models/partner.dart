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
    this.imageUrl,
  });

  final String id;
  final String fullName;
  final String businessName;
  final String email;
  final String phoneNumber;
  final String address;
  final bool isActive;

  /// Server-relative path to the parlor photo (e.g. `/media/parlors/x.jpg`),
  /// or null. Prefix with [apiBaseUrl] to load it.
  final String? imageUrl;

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      businessName: json['business_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      address: json['address'] as String,
      isActive: json['is_active'] as bool? ?? true,
      imageUrl: json['image_url'] as String?,
    );
  }
}
