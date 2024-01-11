import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';

class Task {
  String title;
  String status;

  Task({required this.title, required this.status});
}

class TaskProvider extends ChangeNotifier {
  List<Task> tasks = [];

  void addTask(Task task) {
    tasks.add(task);
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
        title: null, // Remove the title from the app bar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 30),
            Text(
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
        title: const Text('Flow Muse'),
        centerTitle: true,
      ),
      body: Container(
        color: appBackBlue, // Set your desired background color here
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

    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _showAddTaskDialog(context, taskProvider);
          },
          child: Text('Add Task'),
        ),
        Text(status, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Expanded(
          child: ListView.builder(
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              var task = taskProvider.tasks[index];
              if (task.status == status) {
                return ListTile(title: Text(task.title));
              } else {
                return Container();
              }
            },
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskProvider taskProvider) {
    TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: TextField(
            controller: taskController,
            decoration: InputDecoration(labelText: 'Task Title'),
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
                if (taskController.text.isNotEmpty) {
                  taskProvider.addTask(Task(title: taskController.text, status: status));
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
