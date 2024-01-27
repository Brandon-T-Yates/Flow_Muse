import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'task_model.dart';

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
          onPressed: () async {
            // Delete task from Firebase Firestore
            await FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
            // Call the onDelete callback to remove the task locally
            onDelete();
          },
        ),
      ),
    );
  }
}