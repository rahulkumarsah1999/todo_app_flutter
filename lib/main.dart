import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(){
    setState(() {
      if(_themeMode == ThemeMode.light){
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,


      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF5F3FF),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      home:  TodoScreen(onToggleTheme: _toggleTheme),
    );
  }
}
class TodoScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const TodoScreen({super.key, required this.onToggleTheme});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _tasks=[];

  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
    );
    if (picked != null){
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTask(){
    if (_controller.text.isNotEmpty){
      setState(() {
        _tasks.add({
          "title": _controller.text,
          "isDone": false,
        });
        _controller.clear();
      });
    }
  }
  void _toggleTask(int index){
    setState(() {
      _tasks[index]["isDone"]= !_tasks[index]["isDone"];
    });
  }
  void _deleteTask(int index){
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 3,
        iconTheme: const IconThemeData(
          color: Colors.black
        ),
        centerTitle: true,
        title:  Text(
          "Simple todo App",
          style: TextStyle(fontWeight: FontWeight.w600),

        ),

        actions: [
          IconButton(onPressed: _pickDate, icon: Icon(Icons.calendar_today),),
          IconButton(onPressed: widget.onToggleTheme, icon: Icon(
              Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
          ),
          ),

        ],
      ) ,
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Add a new task...",
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding:  const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius:  BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(14),
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Icon(Icons.add),
                )
              ],
            ) ,
          ),
          if (_selectedDate !=null)
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
              child: Text("Reminder: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
              style: const TextStyle( color: Colors.deepPurple),
              ),
            ),
          Expanded(
              child: ListView.builder(
            itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(_tasks[index]["title"] + index.toString()),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (_) {
                        final deletedTask = _tasks[index];
                        final deletedIndex = index;

                        setState(() {
                          _tasks.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: const Text("Task Deleted"),
                          action: SnackBarAction(
                              label: "UNDO",
                              onPressed: (){
                                setState(() {
                                  _tasks.insert(deletedIndex, deletedTask);
                                });
                              },
                          ),
                            duration: const Duration(seconds: 3),
                        ),
                        );
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                              )
                            ],
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: (_tasks[index]["isDone"] ?? false) as bool,
                              onChanged: (_) => _toggleTask(index),
                              activeColor: Colors.deepPurple,
                            ),
                            title: Text(
                              _tasks[index]["title"] as String,
                              style: TextStyle(
                                decoration: (_tasks[index]["isDone"] ?? false)
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            trailing:  IconButton(
                              icon: Icon(Icons.delete,color: Colors.red,),
                            onPressed: ()=> _deleteTask(index),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
          ),
          ),
        ],
      ),
    );
  }
}
