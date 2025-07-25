import 'package:shopping/src/features/auth/domain/app_user.dart';

class Group {
  final String id;
  final String name;
  final List<AppUser> members;
  final String creatorId;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.creatorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'members': members.map((e) => e.toMap()).toList(),
      'memberIds': members.map((e) => e.id).toList(),
      'creatorId': creatorId,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      members: (map['members'] as List).map((e) => AppUser.fromMap(e)).toList(),
      creatorId: map['creatorId'],
    );
  }

  AppUser? getCreator() {
    for (AppUser user in members) {
      if (user.id == creatorId) {
        return user;
      }
    }
    return null;
  }
}
