import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:shopping/src/data/auth_repository.dart';
import 'package:shopping/src/data/database_repository.dart';
import 'package:shopping/src/features/group/domain/group.dart';
import 'package:shopping/src/features/auth/domain/app_user.dart';
import 'package:shopping/src/features/group/presentation/group_detail_screen.dart';
import 'package:shopping/src/features/group/presentation/widgets/group_choice_card.dart';
import 'package:shopping/src/features/group/presentation/widgets/group_display_card.dart';

class GroupSelectionScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final DatabaseRepository databaseRepository;

  const GroupSelectionScreen(
    this.authRepository,
    this.databaseRepository, {
    super.key,
  });

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = widget.authRepository.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gruppenauswahl'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.authRepository.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Group>>(
        stream: widget.databaseRepository.getUserGroups(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          final groups = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (groups.isNotEmpty) ...[
                  Text(
                    'Deine Gruppen:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return GroupDisplayCard(
                        title: group.name,
                        description:
                            'Mitglieder: ${group.members.map((m) => m.name).join(', ')}',
                        buttonText: 'Öffnen',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return GroupDetailScreen(
                                  databaseRepository: widget.databaseRepository,
                                  authRepository: widget.authRepository,
                                  groupId: group.id,
                                  groupName: group.name,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                GroupChoiceCard(
                  title: 'Neue Gruppe erstellen',
                  hintText: 'Gruppenname',
                  tipText: 'Gib einen Namen für deine neue Gruppe ein.',
                  buttonText: 'Erstellen',
                  onPressed: (groupName) async {
                    if (groupName.isEmpty) return;
                    final groupId = const Uuid().v4();
                    final firebaseUser = widget.authRepository.getCurrentUser();

                    if (firebaseUser == null) {
                      throw Exception('Benutzer nicht angemeldet.');
                    }

                    final appUser = AppUser(
                      id: firebaseUser.uid,
                      name: firebaseUser.displayName ?? 'Unbekannt',
                      email: firebaseUser.email ?? '',
                      photoUrl: firebaseUser.photoURL ?? '',
                    );
                    final newGroup = Group(
                      id: groupId,
                      name: groupName,
                      members: [appUser],
                      creatorId: appUser.id,
                    );
                    await widget.databaseRepository.createGroup(newGroup);
                  },
                ),
                const SizedBox(height: 16),

                GroupChoiceCard(
                  title: 'Einer Gruppe beitreten',
                  hintText: 'Gruppen ID',
                  tipText:
                      'Gib die ID einer bestehenden Gruppe ein, um beizutreten.',
                  buttonText: 'Beitreten',
                  onPressed: (groupId) async {
                    if (groupId.isEmpty) return;
                    final group = await widget.databaseRepository.getGroup(
                      groupId,
                    );
                    if (group == null) {
                      throw Exception('Gruppe nicht gefunden');
                    }
                    final firebaseUser = widget.authRepository.getCurrentUser();

                    if (firebaseUser == null) {
                      throw Exception('Benutzer nicht angemeldet.');
                    }

                    final appUser = AppUser(
                      id: firebaseUser.uid,
                      name: firebaseUser.displayName ?? 'Unbekannt',
                      email: firebaseUser.email ?? '',
                      photoUrl: firebaseUser.photoURL ?? '',
                    );
                    await widget.databaseRepository.addMemberToGroup(
                      groupId,
                      appUser,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
