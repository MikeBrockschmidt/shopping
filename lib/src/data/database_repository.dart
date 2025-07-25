import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping/src/features/group/domain/group.dart';
import 'package:shopping/src/features/shopping_list/data/shopping_item.dart';
import 'package:shopping/src/features/todo/domain/todo.dart';
import 'package:shopping/src/features/auth/domain/app_user.dart';
import 'package:shopping/src/features/memory/domain/memory_item.dart';

class DatabaseRepository {
  final FirebaseFirestore _firestore;

  DatabaseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createTodo(String groupId, Todo todo) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('todos')
        .doc(todo.id)
        .set(todo.toMap());
  }

  Stream<List<Todo>> getTodosStream(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('todos')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Todo.fromMap(doc.data())).toList();
        });
  }

  Future<List<Todo>> getTodos(String groupId) async {
    final querySnapshot = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('todos')
        .get();
    return querySnapshot.docs.map((doc) => Todo.fromMap(doc.data())).toList();
  }

  Future<void> checkTodo(String groupId, String todoId) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('todos')
        .doc(todoId)
        .update({'isDone': true});
  }

  Future<void> uncheckTodo(String groupId, String todoId) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('todos')
        .doc(todoId)
        .update({'isDone': false});
  }

  Future<void> createGroup(Group group) async {
    await _firestore.collection('groups').doc(group.id).set(group.toMap());
  }

  Future<Group?> getGroup(String groupId) async {
    final doc = await _firestore.collection('groups').doc(groupId).get();
    if (doc.exists) {
      return Group.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> addMemberToGroup(String groupId, AppUser user) async {
    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([user.toMap()]),
      'memberIds': FieldValue.arrayUnion([user.id]),
    });
  }

  Stream<List<Group>> getUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList();
        });
  }

  Future<void> createShoppingItem(String groupId, ShoppingItem item) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('shopping_items')
        .doc(item.id)
        .set(item.toMap());
  }

  Stream<List<ShoppingItem>> getShoppingItemsStream(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('shopping_items')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ShoppingItem.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> updateShoppingItem(
    String groupId,
    String itemId,
    bool isBought,
  ) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('shopping_items')
        .doc(itemId)
        .update({'isBought': isBought});
  }

  Future<void> deleteShoppingItem(String groupId, String itemId) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('shopping_items')
        .doc(itemId)
        .delete();
  }

  Future<List<MemoryItem>> getMemories(String groupId) async {
    final querySnapshot = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('memories')
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => MemoryItem.fromFirestore(doc))
        .toList();
  }

  Future<void> addMemory(String groupId, String name) async {
    final newDocRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('memories')
        .doc();

    final memoryItem = MemoryItem(
      id: newDocRef.id,
      name: name,
      isArchived: false,
    );
    await newDocRef.set(memoryItem.toFirestore());
  }

  Future<void> archiveMemory(String groupId, String memoryId) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('memories')
        .doc(memoryId)
        .update({'isArchived': true});
  }

  Future<void> unarchiveMemory(String groupId, String memoryId) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('memories')
        .doc(memoryId)
        .update({'isArchived': false});
  }

  Future<void> removeMemory(String groupId, String memoryId) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('memories')
        .doc(memoryId)
        .delete();
  }
}
