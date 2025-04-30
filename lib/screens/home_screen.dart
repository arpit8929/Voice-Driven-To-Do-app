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
  final TextEditingController _controller = TextEditingController();
  late final VoiceService _voiceService;

  @override
  void initState() {
    super.initState();
    _voiceService = ref.read(voiceServiceProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTodo() {
    if (_controller.text.isNotEmpty) {
      ref.read(todosProvider.notifier).addTodo(_controller.text);
      _controller.clear();
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add a new todo...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _voiceService.isListening ? Icons.mic_off : Icons.mic,
                    color: _voiceService.isListening ? Colors.red : null,
                  ),
                  onPressed: () {
                    if (_voiceService.isListening) {
                      _voiceService.stopListening();
                    } else {
                      _voiceService.startListening((text) {
                        _controller.text = text;
                        _addTodo();
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTodo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 