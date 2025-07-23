import 'package:flutter/material.dart';

enum InboxItemType { task, note, idea, reminder }

class InboxItem {
  final String id;
  String title;
  String? description;
  InboxItemType type;
  DateTime createdAt;
  bool isProcessed;
  List<String> tags;
  Color? color;

  InboxItem({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    DateTime? createdAt,
    this.isProcessed = false,
    List<String>? tags,
    this.color,
  })  : createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [];

  IconData get typeIcon {
    switch (type) {
      case InboxItemType.task:
        return Icons.task_alt;
      case InboxItemType.note:
        return Icons.note;
      case InboxItemType.idea:
        return Icons.lightbulb;
      case InboxItemType.reminder:
        return Icons.notifications;
    }
  }

  Color get typeColor {
    if (color != null) return color!;
    switch (type) {
      case InboxItemType.task:
        return Colors.blue;
      case InboxItemType.note:
        return Colors.green;
      case InboxItemType.idea:
        return Colors.orange;
      case InboxItemType.reminder:
        return Colors.purple;
    }
  }

  String get typeLabel {
    switch (type) {
      case InboxItemType.task:
        return 'Aufgabe';
      case InboxItemType.note:
        return 'Notiz';
      case InboxItemType.idea:
        return 'Idee';
      case InboxItemType.reminder:
        return 'Erinnerung';
    }
  }

  void markAsProcessed() {
    isProcessed = true;
  }

  InboxItem copyWith({
    String? title,
    String? description,
    InboxItemType? type,
    bool? isProcessed,
    List<String>? tags,
    Color? color,
  }) {
    return InboxItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt,
      isProcessed: isProcessed ?? this.isProcessed,
      tags: tags ?? this.tags,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isProcessed': isProcessed,
      'tags': tags,
      'color': color?.value,
    };
  }

  factory InboxItem.fromJson(Map<String, dynamic> json) {
    return InboxItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: InboxItemType.values
          .firstWhere((e) => e.toString().split('.').last == json['type']),
      createdAt: DateTime.parse(json['createdAt']),
      isProcessed: json['isProcessed'] ?? false,
      tags: List<String>.from(json['tags']),
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }
}
