import 'package:flutter/material.dart';

class Task {
  final String name;
  final String description;
  final DateTime startDate;
  final TimeOfDay startTime;
  final DateTime endDate;
  final TimeOfDay endTime;
  String status;
  String priority;
  String icon;
  String group;
  bool deleted;

  Task({
    required this.name,
    this.description = "",
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    this.status = "Open",
    this.priority = "Low",
    this.group = "Personal",
    this.icon = "Personal",
    this.deleted = false,
  });

  // Convert TimeOfDay to String for storage
  String _timeOfDayToString(TimeOfDay timeOfDay) {
    final String hour = timeOfDay.hour.toString().padLeft(2, '0');
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  // Convert task to map for storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'startTime': _timeOfDayToString(startTime),
      'endDate': endDate.toIso8601String(),
      'endTime': _timeOfDayToString(endTime),
      'priority': priority,
      'group': group,
      'icon': icon,
      'status': status,
      'deleted': deleted,
    };
  }

  // Create task from map for retrieval
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'],
      description: map['description'] ?? "",
      startDate: DateTime.parse(map['startDate']),
      startTime: Task._stringToTimeOfDay(map['startTime']),
      endDate: DateTime.parse(map['endDate']),
      endTime: Task._stringToTimeOfDay(map['endTime']),
      status: map['status'] ?? "Open",
      priority: map['priority'] ?? "Low",
      group: map['group'] ?? "Personal",
      icon: map['icon'] ?? "Personal",
      deleted: map['deleted'] ?? false,
    );
  }

  // Convert string to TimeOfDay for retrieval
  static TimeOfDay _stringToTimeOfDay(String? timeString) {
    if (timeString == null || !timeString.contains(':')) {
      return const TimeOfDay(hour: 0, minute: 0); // Default value
    }
    List<String> parts = timeString.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }
}
