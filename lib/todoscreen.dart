import 'package:flutter/material.dart';

// Model data sederhana untuk satu item todo
class TodoItem {
  String title;
  Color color;
  bool isDone;

  TodoItem({
    required this.title,
    required this.color,
    this.isDone = false,
  });
}

class todoScreen extends StatefulWidget {
  const todoScreen({super.key});

  @override
  State<todoScreen> createState() => _todoScreenState();
}

class _todoScreenState extends State<todoScreen> {
  // Item baru ditambahkan di akhir (add),
  // jadi yang diketik pertama tetap berada paling atas.
  final List<TodoItem> _todos = [];

  // Warna pastel yang dipakai bergantian untuk tiap kartu
  final List<Color> _colors = const [
    Color(0xFFD4B8F5), // ungu
    Color(0xFFB8F5B8), // hijau
    Color(0xFFB8DCF5), // biru
    Color(0xFFFFD9A8), // oranye
  ];

  // Event listener tombol "+" -> menampilkan AlertDialog input
  void _showAddDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Todo'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Tulis kegiatanmu...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return; // abaikan input kosong
                _addTodo(text);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _addTodo(String title) {
    setState(() {
      _todos.add(TodoItem(
        title: title,
        color: _colors[_todos.length % _colors.length],
      ));
    });
  }

  void _toggleDone(TodoItem item) {
    setState(() => item.isDone = !item.isDone);
  }

  // Hapus item + SnackBar dengan aksi Undo
  void _deleteTodo(TodoItem item) {
    final index = _todos.indexOf(item);
    setState(() => _todos.removeAt(index));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${item.title}" dihapus'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // kembalikan ke posisi semula
            setState(() => _todos.insert(index, item));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header: judul + tombol tambah
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Todo',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300),
                  ),
                  
                ],
              ),
              const SizedBox(height: 16),

              // Daftar todo (urutan: yang pertama diinput di atas)
              Expanded(
                child: _todos.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada todo.\nTekan tombol  untuk menambah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _todos.length,
                        itemBuilder: (context, index) {
                          return _buildTodoCard(_todos[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // FloatingActionButton sebagai tombol tambah kedua
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildTodoCard(TodoItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black),
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.isDone,
          activeColor: Colors.black,
          onChanged: (_) => _toggleDone(item),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 16,
            decoration: item.isDone ? TextDecoration.lineThrough : null,
            color: item.isDone ? Colors.black54 : Colors.black,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _deleteTodo(item),
        ),
      ),
    );
  }
}