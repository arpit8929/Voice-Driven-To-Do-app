import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import '../services/voice_service.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());
final voiceServiceProvider = Provider((ref) => VoiceService());

final todosProvider = StateNotifierProvider<TodosNotifier, List<Todo>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return TodosNotifier(databaseService);
});

class TodosNotifier extends StateNotifier<List<Todo>> {
  final DatabaseService _databaseService;
  final _uuid = const Uuid();

  TodosNotifier(this._databaseService) : super([]) {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    state = _databaseService.getLocalTodos();
  }

  Future<void> addTodo(String title) async {
    final todo = Todo(
      id: _uuid.v4(),
      title: title,
    );

    state = [...state, todo];
    await _databaseService.addTodoLocally(todo);
    await _databaseService.addTodoToCloud(todo);
  }

  Future<void> toggleTodo(String id) async {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(
            isCompleted: !todo.isCompleted,
            completedAt: !todo.isCompleted ? DateTime.now() : null,
          )
        else
          todo,
    ];

    await _databaseService.toggleTodoLocally(id);
    await _databaseService.toggleTodoInCloud(id);
  }

  Future<void> deleteTodo(String id) async {
    state = state.where((todo) => todo.id != id).toList();
    await _databaseService.deleteTodoLocally(id);
    await _databaseService.deleteTodoFromCloud(id);
  }

  Future<void> syncTodos() async {
    final cloudTodos = await _databaseService.getCloudTodos();
    state = cloudTodos;
    for (final todo in cloudTodos) {
      await _databaseService.addTodoLocally(todo);
    }
  }
} 