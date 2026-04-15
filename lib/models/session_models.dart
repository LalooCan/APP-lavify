enum AppRole { client, worker }

class MockSession {
  const MockSession({
    required this.role,
    required this.email,
    required this.visibleName,
    required this.favoriteAddress,
  });

  final AppRole role;
  final String email;
  final String visibleName;
  final String favoriteAddress;

  MockSession copyWith({
    AppRole? role,
    String? email,
    String? visibleName,
    String? favoriteAddress,
  }) {
    return MockSession(
      role: role ?? this.role,
      email: email ?? this.email,
      visibleName: visibleName ?? this.visibleName,
      favoriteAddress: favoriteAddress ?? this.favoriteAddress,
    );
  }
}
