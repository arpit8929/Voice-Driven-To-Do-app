import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import '../services/voice_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final voiceServiceProvider = Provider<VoiceService>((ref) {
  return VoiceService();
});

final todosProvider = StateNotifierProvider<TodosNotifier, List<Todo>>((ref) {
  return TodosNotifier(ref.watch(databaseServiceProvider));
});

class TodosNotifier extends StateNotifier<List<Todo>> {
  final DatabaseService _databaseService;

  TodosNotifier(this._databaseService) : super([]) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    state = _databaseService.getLocalTodos();
  }

  Future<void> addTodo(String title) async {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    
    await _databaseService.addTodoLocally(todo);
    state = [...state, todo];
    await _databaseService.syncWithCloud();
  }

  Future<void> toggleTodo(String id) async {
    final index = state.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final todo = state[index];
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        completedAt: !todo.isCompleted ? DateTime.now() : null,
      );
      
      await _databaseService.updateTodoLocally(updatedTodo);
      state = [
        ...state.sublist(0, index),
        updatedTodo,
        ...state.sublist(index + 1),
      ];
      await _databaseService.syncWithCloud();
    }
  }

  Future<void> deleteTodo(String id) async {
    await _databaseService.deleteTodoLocally(id);
    state = state.where((todo) => todo.id != id).toList();
    await _databaseService.syncWithCloud();
  }

  Future<void> syncTodos() async {
    await _databaseService.fetchFromCloud();
    state = _databaseService.getLocalTodos();
  }
} 