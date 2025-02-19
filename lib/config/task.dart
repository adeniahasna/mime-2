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
    this.icon = "personal",
    this.deleted = false,
  });

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
      'status': status,
      'priority': priority,
      'icon': icon,
      'group': group,
      'deleted': deleted,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'],
      description: map['description'] ?? "",
      startDate: DateTime.parse(map['startDate']),
      startTime: _stringToTimeOfDay(map['startTime']),
      endDate: DateTime.parse(map['endDate']),
      endTime: _stringToTimeOfDay(map['endTime']),
      status: map['status'] ?? "Open",
      priority: map['priority'] ?? "Low",
      icon: map['icon'] ?? "personal",
      group: map['group'] ?? "Personal",
      deleted: map['deleted'] ?? false,
    );
  }

  static TimeOfDay _stringToTimeOfDay(String? timeString) {
    if (timeString == null || !timeString.contains(':')) {
      return TimeOfDay(hour: 0, minute: 0);
    }
    List<String> parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
