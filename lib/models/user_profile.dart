import 'session_models.dart';

class UserProfile {
  const UserProfile({
    this.uid = '',
    required this.name,
    required this.email,
    this.role = AppRole.client,
    required this.vehicleLabel,
    required this.favoriteAddress,
    required this.paymentMethod,
    this.photoUrl,
  });

  final String uid;
  final String name;
  final String email;
  final AppRole role;
  final String vehicleLabel;
  final String favoriteAddress;
  final String paymentMethod;
  final String? photoUrl;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final rawRole = (map['role'] as String? ?? AppRole.client.name)
        .trim()
        .toLowerCase();

    return UserProfile(
      uid: map['uid'] as String? ?? '',
      name:
          map['displayName'] as String? ??
          map['name'] as String? ??
          'Usuario Lavify',
      email: map['email'] as String? ?? '',
      role: rawRole == AppRole.worker.name ? AppRole.worker : AppRole.client,
      vehicleLabel: map['vehicleLabel'] as String? ?? '',
      favoriteAddress:
          map['favoriteAddress'] as String? ?? map['address'] as String? ?? '',
      paymentMethod: map['paymentMethod'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
    );
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    AppRole? role,
    String? vehicleLabel,
    String? favoriteAddress,
    String? paymentMethod,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      vehicleLabel: vehicleLabel ?? this.vehicleLabel,
      favoriteAddress: favoriteAddress ?? this.favoriteAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'displayName': name,
      'email': email,
      'role': role.name,
      'vehicleLabel': vehicleLabel,
      'favoriteAddress': favoriteAddress,
      'address': favoriteAddress,
      'paymentMethod': paymentMethod,
      'photoUrl': photoUrl,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
