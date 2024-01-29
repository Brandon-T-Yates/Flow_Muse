import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> tasks = [];

  void addTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  void deleteTask(String taskId) {
    tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  void updateTaskStatus(String taskId, String newStatus) {
    Task task = tasks.firstWhere((t) => t.id == taskId);
    task.status = newStatus;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    try {
      // Clear existing tasks
      tasks.clear();

      // Fetch tasks from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('tasks').get();

      // Process the retrieved tasks
      querySnapshot.docs.forEach((doc) {
        Task task = Task(
          id: doc.id,
          title: doc['title'],
          description: doc['description'],
          dueDate: doc['dueDate'].toDate(), // Convert Firestore Timestamp to DateTime
          status: doc['status'],
        );

        tasks.add(task);
      });

      // Notify listeners about the changes
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }
}