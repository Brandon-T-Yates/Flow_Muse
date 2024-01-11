import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import 'package:intl/intl.dart';


class Task {
  String title;
  String description;
  DateTime dueDate;
  String status;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
  });
}

class TaskProvider extends ChangeNotifier {
  List<Task> tasks = [];

  void addTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  void removeTask(Task task) {
    tasks.remove(task);
    notifyListeners();
  }

  void reorderTasks(int oldIndex, int newIndex, String status) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF92A4CF)),
          useMaterial3: true,
          scaffoldBackgroundColor: Color.fromARGB(255, 253, 253, 253),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 218, 212, 212)),
            ),
          ),
        ),
        home: MyHomePage(title: 'Flow Muse Sign In'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _nameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  void _submitForm() async {
    final String name = _nameController.text;
    final String password = _passwordController.text;

    if (name.isNotEmpty && password.isNotEmpty) {
      // Store name and password in Firebase Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'name': name,
        'password': password,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear text fields after submission
      _nameController.clear();
      _passwordController.clear();

      // Navigate to the Kanban board
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => KanbanBoard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 30),
            const Text(
              'Flow Muse',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold,),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                onSubmitted: (_) => _submitForm(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                onSubmitted: (_) => _submitForm(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({super.key});

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBackBlue,
        title: const Text('Project'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Disables the back button
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Profile'),
                  // Add functionality or route navigation for the Settings option
                  onTap: () {
                    // Add your code to handle the Settings option
                  },
                ),
                PopupMenuItem(
                  child: Text('Logout'),
                  // Go to the previous screen when Logout is selected
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        color: appBackBlue,
        child: KanbanColumns(),
      ),
    );
  }
}
class KanbanColumns extends StatelessWidget {
  const KanbanColumns({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        KanbanColumn(status: 'ToDo'),
        KanbanColumn(status: 'Doing'),
        KanbanColumn(status: 'Done'),
      ],
    );
  }
}

class KanbanColumn extends StatelessWidget {
  final String status;

  KanbanColumn({required this.status});

  @override
  Widget build(BuildContext context) {
    var taskProvider = Provider.of<TaskProvider>(context);

    return Card(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: appBackBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _showAddTaskDialog(context, taskProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(345, 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('+'),
            ),

            // Draggable Column
            Expanded(
              child: DragTarget<Task>(
                onWillAccept: (task) => task != null && task.status != status,
                onAccept: (task) {
                  taskProvider.tasks.remove(task);
                  task.status = status;
                  taskProvider.addTask(task);
                  taskProvider.notifyListeners();
                },
                builder: (context, candidateData, rejectedData) {
                  return ListView.builder(
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      var task = taskProvider.tasks[index];
                      if (task.status == status) {
                        return LongPressDraggable<Task>(
                          data: task,
                          child: TaskCard(
                            task: task,
                            onDelete: () {
                              taskProvider.tasks.removeAt(index);
                              taskProvider.notifyListeners();
                            },
                          ),
                          feedback: TaskCard(task: task, onDelete: () {}),
                          onDragEnd: (details) {
                            // Handle drag end if needed
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskProvider taskProvider) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController dueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(labelText: 'Due Date (mm/dd/yy)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    dueDateController.text.isNotEmpty) {
                  taskProvider.addTask(
                    Task(
                      title: titleController.text,
                      description: descriptionController.text,
                      dueDate: DateFormat('MM/dd/yy').parse(dueDateController.text),
                      status: status,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  TaskCard({required this.task, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      color: Colors.white,
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            Text(
              'Due Date: ${DateFormat('MM/dd/yy').format(task.dueDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}