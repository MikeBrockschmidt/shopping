class AppUser {
  final String id;
  final String name;
  final String email;
  final String photoUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'photoUrl': photoUrl};
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
    );
  }
}
