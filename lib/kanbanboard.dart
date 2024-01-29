import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import 'package:intl/intl.dart';
import 'screens/profilepage.dart';
import 'task_model.dart';
import 'task_provider.dart';
import 'task_card.dart';


class KanbanBoard extends StatelessWidget {
  const KanbanBoard({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBackBlue,
        title: const Text('Project'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
                PopupMenuItem(
                  child: Text('Logout'),
                  // Go to the previous screen when Logout is selected for now
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
                _showAddTaskDialog(context, taskProvider, status);
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
        
            // Click and Hold to Move Task
            Expanded(
              child: ListView.builder(
                itemCount: taskProvider.tasks.length,
                itemBuilder: (context, index) {
                  var task = taskProvider.tasks[index];
                  if (task.status == status) {
                    return GestureDetector(
                      onLongPress: () {
                        _showMoveTaskDialog(context, taskProvider, task);
                      },
                      child: TaskCard(
                        task: task,
                        onDelete: () {
                          taskProvider.deleteTask(task.id);
                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskProvider taskProvider, String status) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController dueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: SingleChildScrollView(
          child: Column(
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
        ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && dueDateController.text.isNotEmpty) {
                // Convert due date string to DateTime
                DateTime dueDate = DateFormat('MM/dd/yy').parse(dueDateController.text);

                // Create a Task object
                Task newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  dueDate: dueDate,
                  status: status,
                );

                // Store the task in Firebase Firestore
                DocumentReference docRef = await FirebaseFirestore.instance.collection('tasks').add({
                    'title': newTask.title,
                    'description': newTask.description,
                    'dueDate': newTask.dueDate,
                    'status': newTask.status,
                  },
                );
                 // Updates the task's ID
                newTask.id = docRef.id;
                taskProvider.addTask(newTask);
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

  void _showMoveTaskDialog(BuildContext context, TaskProvider taskProvider, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Move Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select the catagory to move the task to:'),
              ElevatedButton(
                onPressed: () {
                  _moveTaskToColumn(taskProvider, task, 'ToDo');
                  Navigator.pop(context);
                },
                child: const Text('ToDo'),
              ),
              ElevatedButton(
                onPressed: () {
                  _moveTaskToColumn(taskProvider, task, 'Doing');
                  Navigator.pop(context);
                },
                child: const Text('Doing'),
              ),
              ElevatedButton(
                onPressed: () {
                  _moveTaskToColumn(taskProvider, task, 'Done');
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _moveTaskToColumn(TaskProvider taskProvider, Task task, String newStatus) {
    taskProvider.updateTaskStatus(task.id, newStatus);
  }
}