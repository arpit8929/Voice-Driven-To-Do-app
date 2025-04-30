import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _todoBox = Hive.box('todos');

  Future<void> addTodoLocally(Todo todo) async {
    await _todoBox.put(todo.id, todo.toMap());
  }

  Future<void> addTodoToCloud(Todo todo) async {
    try {
      await _firestore.collection('todos').doc(todo.id).set(todo.toMap());
    } catch (e) {
      print('Error adding to cloud: $e');
    }
  }

  List<Todo> getLocalTodos() {
    final todos = _todoBox.values.map((e) => Todo.fromMap(Map<String, dynamic>.from(e))).toList();
    return todos;
  }

  Future<List<Todo>> getCloudTodos() async {
    try {
      final snapshot = await _firestore.collection('todos').get();
      return snapshot.docs.map((doc) => Todo.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching from cloud: $e');
      return [];
    }
  }

  Future<void> deleteTodoLocally(String id) async {
    await _todoBox.delete(id);
  }

  Future<void> deleteTodoFromCloud(String id) async {
    try {
      await _firestore.collection('todos').doc(id).delete();
    } catch (e) {
      print('Error deleting from cloud: $e');
    }
  }

  Future<void> toggleTodoLocally(String id) async {
    final todo = Todo.fromMap(Map<String, dynamic>.from(_todoBox.get(id)));
    await _todoBox.put(id, todo.copyWith(isCompleted: !todo.isCompleted).toMap());
  }

  Future<void> toggleTodoInCloud(String id) async {
    try {
      final doc = await _firestore.collection('todos').doc(id).get();
      if (doc.exists) {
        final todo = Todo.fromMap(doc.data()!);
        await _firestore.collection('todos').doc(id).update({
          'isCompleted': !todo.isCompleted,
        });
      }
    } catch (e) {
      print('Error toggling in cloud: $e');
    }
  }
} 