import 'package:flutter/foundation.dart';

class TaskNotifier {
  static final TaskNotifier _instance = TaskNotifier._internal();
  factory TaskNotifier() => _instance;
  TaskNotifier._internal();

  final ValueNotifier<bool> tasksUpdated = ValueNotifier<bool>(false);

  void notifyTasksUpdated() {
    tasksUpdated.value = !tasksUpdated.value;
  }
}
