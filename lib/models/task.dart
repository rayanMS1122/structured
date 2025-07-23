import 'package:flutter/material.dart';

enum TaskStatus { pending, completed }

enum TaskPriority { low, medium, high, urgent }

enum RecurrenceType { none, daily, weekly, monthly }

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String category;
  final String? notes;
  final DateTime startTime;
  final int? duration;
  final IconData icon;
  final Color color;
  final TaskPriority priority;
  final List<SubTask> subTasks;
  final TaskStatus status;
  final DateTime? completedAt; // Added completedAt field
  final RecurrenceType recurrence;
  final List<String> tags;
  final bool isTimeBlocked;
  final bool hasReminder;
  final DateTime? reminderTime;

  Task({
    required this.id,
    required this.title,
    required this.category,
    this.notes,
    required this.startTime,
    this.duration,
    required this.icon,
    required this.color,
    this.priority = TaskPriority.low,
    this.subTasks = const [],
    this.status = TaskStatus.pending,
    this.completedAt,
    this.recurrence = RecurrenceType.none,
    this.tags = const [],
    this.isTimeBlocked = false,
    this.hasReminder = false,
    this.reminderTime,
  });

  Task copyWith({
    String? id,
    String? title,
    String? category,
    String? notes,
    DateTime? startTime,
    int? duration,
    IconData? icon,
    Color? color,
    TaskPriority? priority,
    List<SubTask>? subTasks,
    TaskStatus? status,
    DateTime? completedAt,
    RecurrenceType? recurrence,
    List<String>? tags,
    bool? isTimeBlocked,
    bool? hasReminder,
    DateTime? reminderTime,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      subTasks: subTasks ?? this.subTasks,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      recurrence: recurrence ?? this.recurrence,
      tags: tags ?? this.tags,
      isTimeBlocked: isTimeBlocked ?? this.isTimeBlocked,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'notes': notes,
      'startTime': startTime.toIso8601String(),
      'duration': duration,
      'icon': icon.codePoint,
      'color': color.value,
      'priority': priority.index,
      'subTasks': subTasks.map((subTask) => subTask.toJson()).toList(),
      'status': status.index,
      'completedAt': completedAt?.toIso8601String(),
      'recurrence': recurrence.index,
      'tags': tags,
      'isTimeBlocked': isTimeBlocked,
      'hasReminder': hasReminder,
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      notes: json['notes'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      duration: json['duration'] as int?,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      priority: TaskPriority.values[json['priority'] as int],
      subTasks: (json['subTasks'] as List<dynamic>?)
              ?.map((subTaskJson) => SubTask.fromJson(subTaskJson))
              .toList() ??
          [],
      status: TaskStatus.values[json['status'] as int],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      recurrence: RecurrenceType.values[json['recurrence'] as int],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isTimeBlocked: json['isTimeBlocked'] as bool? ?? false,
      hasReminder: json['hasReminder'] as bool? ?? false,
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'] as String)
          : null,
    );
  }
}
