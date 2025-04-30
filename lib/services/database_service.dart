import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Box<Todo> _todoBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoAdapter());
    _todoBox = await Hive.openBox<Todo>('todos');
  }

  // Local Storage Operations
  Future<void> addTodoLocally(Todo todo) async {
    await _todoBox.put(todo.id, todo);
  }

  Future<void> updateTodoLocally(Todo todo) async {
    await _todoBox.put(todo.id, todo);
  }

  Future<void> deleteTodoLocally(String id) async {
    await _todoBox.delete(id);
  }

  List<Todo> getLocalTodos() {
    return _todoBox.values.toList();
  }

  // Cloud Storage Operations
  Future<void> syncWithCloud() async {
    final unsyncedTodos = _todoBox.values.where((todo) => !todo.isSynced).toList();
    
    for (final todo in unsyncedTodos) {
      try {
        await _firestore.collection('todos').doc(todo.id).set({
          'title': todo.title,
          'isCompleted': todo.isCompleted,
          'createdAt': todo.createdAt,
          'completedAt': todo.completedAt,
        });
        
        await _todoBox.put(todo.id, todo.copyWith(isSynced: true));
      } catch (e) {
        print('Error syncing todo ${todo.id}: $e');
      }
    }
  }

  Future<void> fetchFromCloud() async {
    try {
      final snapshot = await _firestore.collection('todos').get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final todo = Todo(
          id: doc.id,
          title: data['title'],
          isCompleted: data['isCompleted'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          completedAt: data['completedAt'] != null 
              ? (data['completedAt'] as Timestamp).toDate() 
              : null,
          isSynced: true,
        );
        
        await _todoBox.put(todo.id, todo);
      }
    } catch (e) {
      print('Error fetching from cloud: $e');
    }
  }
} 