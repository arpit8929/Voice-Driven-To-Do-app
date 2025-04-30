import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/todo_provider.dart';
import '../services/voice_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final VoiceService _voiceService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    _voiceService = ref.read(voiceServiceProvider);
    final isAvailable = await _voiceService.initialize();
    setState(() {
      _isInitialized = isAvailable;
    });
  }

  Future<void> _startListening() async {
    if (!_isInitialized) return;

    await _voiceService.startListening((result) {
      _processVoiceCommand(result);
    });
  }

  void _processVoiceCommand(String command) {
    final todosNotifier = ref.read(todosProvider.notifier);
    
    if (command.toLowerCase().contains('add')) {
      final title = command.replaceAll('add', '').trim();
      if (title.isNotEmpty) {
        todosNotifier.addTodo(title);
        _voiceService.speak('Added task: $title');
      }
    } else if (command.toLowerCase().contains('complete')) {
      final title = command.replaceAll('complete', '').trim();
      final todos = ref.read(todosProvider);
      final todo = todos.firstWhere(
        (t) => t.title.toLowerCase().contains(title.toLowerCase()),
        orElse: () => todos.first,
      );
      todosNotifier.toggleTodo(todo.id);
      _voiceService.speak('Marked task as completed');
    } else if (command.toLowerCase().contains('delete')) {
      final title = command.replaceAll('delete', '').trim();
      final todos = ref.read(todosProvider);
      final todo = todos.firstWhere(
        (t) => t.title.toLowerCase().contains(title.toLowerCase()),
        orElse: () => todos.first,
      );
      todosNotifier.deleteTodo(todo.id);
      _voiceService.speak('Deleted task');
    }
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice-Driven Todo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => ref.read(todosProvider.notifier).syncTodos(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => ref.read(todosProvider.notifier).deleteTodo(todo.id),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      'Created: ${todo.createdAt.toString().split('.').first}',
                    ),
                    trailing: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (_) => ref.read(todosProvider.notifier).toggleTodo(todo.id),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton.extended(
              onPressed: _isInitialized ? _startListening : null,
              icon: const Icon(Icons.mic),
              label: Text(_isInitialized ? 'Start Voice Command' : 'Initializing...'),
            ),
          ),
        ],
      ),
    );
  }
} 