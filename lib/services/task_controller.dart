import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import '../models/inbox_item.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  var inboxItems = <InboxItem>[].obs;
  var selectedDate = DateTime.now().obs;

  // Cache for generated recurring tasks to avoid regeneration
  final Map<String, Set<String>> _generatedRecurringTasks = {};

  // Base recurring tasks (templates)
  final List<Task> _baseRecurringTasks = [];

  // SharedPreferences keys
  static const String _tasksKey = 'tasks';
  static const String _inboxItemsKey = 'inbox_items';
  static const String _baseRecurringTasksKey = 'base_recurring_tasks';
  static const String _generatedRecurringTasksKey = 'generated_recurring_tasks';

  List<Task> get todayTasks => tasks
      .where((task) =>
          task.startTime.year == selectedDate.value.year &&
          task.startTime.month == selectedDate.value.month &&
          task.startTime.day == selectedDate.value.day)
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  List<Task> get completedTasks =>
      tasks.where((task) => task.status == TaskStatus.completed).toList();
  List<Task> get pendingTasks =>
      tasks.where((task) => task.status == TaskStatus.pending).toList();

  double get todayProgress {
    final today = todayTasks;
    if (today.isEmpty) return 0.0;
    final completed =
        today.where((task) => task.status == TaskStatus.completed).length;
    return completed / today.length;
  }

  int get todayRemainingMinutes {
    final now = DateTime.now();
    final todayRemaining = todayTasks.where((task) =>
        task.status != TaskStatus.completed && task.startTime.isAfter(now));
    return todayRemaining.fold(0, (sum, task) => sum + (task.duration ?? 30));
  }

  @override
  void onInit() {
    super.onInit();
    _loadDataFromStorage();
    ever(selectedDate, (DateTime date) {
      _generateRecurringTasksForDate(date);
    });
  }

  Future<void> checkAndInitializeSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    final inboxItemsJson = prefs.getString(_inboxItemsKey);
    if (tasksJson == null && inboxItemsJson == null) {
      print(
          'DEBUG: No data found in SharedPreferences, initializing sample data');
      initializeSampleData();
    } else {
      print(
          'DEBUG: Data found in SharedPreferences, skipping sample data initialization');
    }
  }

  Future<void> _loadDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load tasks
      final tasksJson = prefs.getString(_tasksKey);
      if (tasksJson != null) {
        final List<dynamic> decodedTasks = jsonDecode(tasksJson);
        tasks.assignAll(
            decodedTasks.map((json) => Task.fromJson(json)).toList());
        print(
            'DEBUG: Loaded ${decodedTasks.length} tasks from SharedPreferences');
      } else {
        print('DEBUG: No tasks found in SharedPreferences');
      }

      // Load inbox items
      final inboxItemsJson = prefs.getString(_inboxItemsKey);
      if (inboxItemsJson != null) {
        final List<dynamic> decodedInboxItems = jsonDecode(inboxItemsJson);
        inboxItems.assignAll(
            decodedInboxItems.map((json) => InboxItem.fromJson(json)).toList());
        print(
            'DEBUG: Loaded ${decodedInboxItems.length} inbox items from SharedPreferences');
      } else {
        print('DEBUG: No inbox items found in SharedPreferences');
      }

      // Load base recurring tasks
      final baseRecurringTasksJson = prefs.getString(_baseRecurringTasksKey);
      if (baseRecurringTasksJson != null) {
        final List<dynamic> decodedBaseTasks =
            jsonDecode(baseRecurringTasksJson);
        _baseRecurringTasks.addAll(
            decodedBaseTasks.map((json) => Task.fromJson(json)).toList());
        print(
            'DEBUG: Loaded ${decodedBaseTasks.length} base recurring tasks from SharedPreferences');
      } else {
        print('DEBUG: No base recurring tasks found in SharedPreferences');
      }

      // Load generated recurring tasks cache
      final generatedRecurringTasksJson =
          prefs.getString(_generatedRecurringTasksKey);
      if (generatedRecurringTasksJson != null) {
        final Map<String, dynamic> decodedCache =
            jsonDecode(generatedRecurringTasksJson);
        _generatedRecurringTasks.clear();
        decodedCache.forEach((key, value) {
          _generatedRecurringTasks[key] =
              (value as List<dynamic>).cast<String>().toSet();
        });
        print(
            'DEBUG: Loaded generated recurring tasks cache with ${_generatedRecurringTasks.length} entries');
      } else {
        print(
            'DEBUG: No generated recurring tasks cache found in SharedPreferences');
      }

      tasks.refresh();
      inboxItems.refresh();
      update();
      print('DEBUG: Data loaded from SharedPreferences successfully');
    } catch (e, stackTrace) {
      print('ERROR: Failed to load data from SharedPreferences: $e');
      print('StackTrace: $stackTrace');
      Get.snackbar(
        'Fehler',
        'Daten konnten nicht geladen werden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveDataToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save tasks
      final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
      await prefs.setString(_tasksKey, tasksJson);
      print(
          'DEBUG: Saved ${tasks.length} tasks to SharedPreferences: $tasksJson');

      // Save inbox items
      final inboxItemsJson =
          jsonEncode(inboxItems.map((item) => item.toJson()).toList());
      await prefs.setString(_inboxItemsKey, inboxItemsJson);
      print(
          'DEBUG: Saved ${inboxItems.length} inbox items to SharedPreferences: $inboxItemsJson');

      // Save base recurring tasks
      final baseRecurringTasksJson =
          jsonEncode(_baseRecurringTasks.map((task) => task.toJson()).toList());
      await prefs.setString(_baseRecurringTasksKey, baseRecurringTasksJson);
      print(
          'DEBUG: Saved ${_baseRecurringTasks.length} base recurring tasks to SharedPreferences: $baseRecurringTasksJson');

      // Save generated recurring tasks cache
      final generatedRecurringTasksJson = jsonEncode(_generatedRecurringTasks
          .map((key, value) => MapEntry(key, value.toList())));
      await prefs.setString(
          _generatedRecurringTasksKey, generatedRecurringTasksJson);
      print(
          'DEBUG: Saved ${_generatedRecurringTasks.length} generated recurring tasks cache entries to SharedPreferences: $generatedRecurringTasksJson');

      // Verify save
      final savedTasksJson = prefs.getString(_tasksKey);
      if (savedTasksJson != tasksJson) {
        print('ERROR: Task data verification failed after save');
        Get.snackbar(
          'Fehler',
          'Aufgaben konnten nicht korrekt gespeichert werden',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      print('ERROR: Failed to save data to SharedPreferences: $e');
      print('StackTrace: $stackTrace');
      Get.snackbar(
        'Fehler',
        'Daten konnten nicht gespeichert werden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
    _generateRecurringTasksForDate(selectedDate.value);
    update();
    _saveDataToStorage();
  }

  void addTask(Task task) {
    tasks.add(task);

    // If it's a recurring task, add to base templates
    if (task.recurrence != RecurrenceType.none) {
      _baseRecurringTasks.add(task);
      _generateRecurringTasksForDateRange(
          task, DateTime.now(), DateTime.now().add(Duration(days: 60)));
    }

    tasks.refresh();
    update();
    _saveDataToStorage();
    print('DEBUG: Task added: ${task.id} - ${task.title}');
  }

  void updateTask(Task updatedTask) {
    print(
        'DEBUG: Updating task: ${updatedTask.id} at ${updatedTask.startTime}');
    try {
      final index = tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
        tasks.refresh();
        update();
        _saveDataToStorage();
        print('DEBUG: Task updated successfully: ${updatedTask.id}');
      } else {
        print('ERROR: Task not found with ID: ${updatedTask.id}');
        Get.snackbar(
          'Fehler',
          'Aufgabe nicht gefunden',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      print('ERROR: Failed to update task: $e');
      print('StackTrace: $stackTrace');
      Get.snackbar(
        'Fehler',
        'Fehler beim Aktualisieren der Aufgabe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void addSubTask(String taskId, String subTaskTitle, {DateTime? dueDate}) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = tasks[index];
      final updatedSubTasks = List<SubTask>.from(task.subTasks)
        ..add(SubTask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: subTaskTitle,
          dueDate: dueDate,
        ));
      final updatedTask = task.copyWith(subTasks: updatedSubTasks);
      updateTask(updatedTask);
      print('DEBUG: SubTask added to task: $taskId');
    } else {
      print('ERROR: Task not found with ID: $taskId');
      Get.snackbar(
        'Fehler',
        'Aufgabe nicht gefunden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeSubTask(String taskId, String subTaskId) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = tasks[index];
      final updatedSubTasks = List<SubTask>.from(task.subTasks)
        ..removeWhere((subTask) => subTask.id == subTaskId);
      final updatedTask = task.copyWith(subTasks: updatedSubTasks);
      updateTask(updatedTask);
      print('DEBUG: SubTask removed from task: $taskId');
    } else {
      print('ERROR: Task not found with ID: $taskId');
      Get.snackbar(
        'Fehler',
        'Aufgabe nicht gefunden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void toggleSubTaskComplete(String taskId, String subTaskId) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = tasks[index];
      final updatedSubTasks = List<SubTask>.from(task.subTasks);
      final subTaskIndex =
          updatedSubTasks.indexWhere((subTask) => subTask.id == subTaskId);
      if (subTaskIndex != -1) {
        final subTask = updatedSubTasks[subTaskIndex];
        updatedSubTasks[subTaskIndex] = SubTask(
          id: subTask.id,
          title: subTask.title,
          isCompleted: !subTask.isCompleted,
          dueDate: subTask.dueDate,
        );
        final updatedTask = task.copyWith(subTasks: updatedSubTasks);
        updateTask(updatedTask);
        print('DEBUG: SubTask $subTaskId toggled in task: $taskId');
      } else {
        print('ERROR: SubTask not found with ID: $subTaskId');
        Get.snackbar(
          'Fehler',
          'Teilaufgabe nicht gefunden',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      print('ERROR: Task not found with ID: $taskId');
      Get.snackbar(
        'Fehler',
        'Aufgabe nicht gefunden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void updateFutureTasks(Task task, int newHour) {
    print(
        'DEBUG: Starting updateFutureTasks for task ID: ${task.id} to hour: $newHour');
    try {
      // Update the specific task instance
      final newStartTime = DateTime(
        task.startTime.year,
        task.startTime.month,
        task.startTime.day,
        newHour,
        task.startTime.minute,
      );
      final updatedTask = task.copyWith(startTime: newStartTime);
      updateTask(updatedTask);

      // Handle recurring tasks
      if (task.recurrence != RecurrenceType.none || task.id.contains('_')) {
        final baseTaskId =
            task.id.contains('_') ? task.id.split('_')[0] : task.id;
        print('DEBUG: Identified base task ID: $baseTaskId');

        final baseIndex =
            _baseRecurringTasks.indexWhere((t) => t.id == baseTaskId);
        if (baseIndex == -1) {
          print('ERROR: Base task not found for ID: $baseTaskId');
          Get.snackbar(
            'Fehler',
            'Basisaufgabe nicht gefunden',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Update the base task's start time
        final baseTask = _baseRecurringTasks[baseIndex];
        final updatedBaseTask = baseTask.copyWith(
          startTime: DateTime(
            baseTask.startTime.year,
            baseTask.startTime.month,
            baseTask.startTime.day,
            newHour,
            baseTask.startTime.minute,
          ),
        );
        _baseRecurringTasks[baseIndex] = updatedBaseTask;
        print(
            'DEBUG: Updated base task ${baseTask.id} to new time: ${updatedBaseTask.startTime}');

        // Remove all future instances of this recurring task
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        tasks.removeWhere((t) =>
            t.id.startsWith(baseTaskId + '_') &&
            DateTime(t.startTime.year, t.startTime.month, t.startTime.day)
                .isAfter(today));

        // Clear cache for future dates
        _generatedRecurringTasks[baseTaskId]?.removeWhere((key) {
          final parts = key.split('-');
          final date = DateTime(
              int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          return date.isAfter(today) || date.isAtSameMomentAs(today);
        });

        // Regenerate future tasks
        _generateRecurringTasksForDateRange(
          updatedBaseTask,
          today,
          today.add(Duration(days: 60)),
        );
      }
      tasks.refresh();
      update();
      _saveDataToStorage();
      print('DEBUG: updateFutureTasks completed successfully');
    } catch (e, stackTrace) {
      print('ERROR: Failed to update future tasks: $e');
      print('StackTrace: $stackTrace');
      Get.snackbar(
        'Fehler',
        'Fehler beim Aktualisieren zukünftiger Aufgaben',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void updateAllTasks(Task task, int newHour) {
    print(
        'DEBUG: Updating all tasks for task ID: ${task.id} to hour: $newHour');
    try {
      final newStartTime = DateTime(
        task.startTime.year,
        task.startTime.month,
        task.startTime.day,
        newHour,
        task.startTime.minute,
      );

      // Update the specific task instance
      final updatedTask = task.copyWith(startTime: newStartTime);
      updateTask(updatedTask);

      // Handle recurring tasks
      if (task.recurrence != RecurrenceType.none || task.id.contains('_')) {
        final baseTaskId =
            task.id.contains('_') ? task.id.split('_')[0] : task.id;
        final baseIndex =
            _baseRecurringTasks.indexWhere((t) => t.id == baseTaskId);
        if (baseIndex == -1) {
          print('ERROR: Base task not found for ID: $baseTaskId');
          Get.snackbar(
            'Fehler',
            'Basisaufgabe nicht gefunden',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        final baseTask = _baseRecurringTasks[baseIndex];
        final updatedBaseTask = baseTask.copyWith(
          startTime: DateTime(
            baseTask.startTime.year,
            baseTask.startTime.month,
            baseTask.startTime.day,
            newHour,
            baseTask.startTime.minute,
          ),
        );
        _baseRecurringTasks[baseIndex] = updatedBaseTask;

        // Update all existing instances
        final updatedTasks = tasks.map((t) {
          if (t.id == task.id || t.id.startsWith(baseTaskId + '_')) {
            return t.copyWith(
              startTime: DateTime(
                t.startTime.year,
                t.startTime.month,
                t.startTime.day,
                newHour,
                t.startTime.minute,
              ),
            );
          }
          return t;
        }).toList();
        tasks.assignAll(updatedTasks);

        // Clear cache and regenerate
        _generatedRecurringTasks.remove(baseTaskId);
        _generateRecurringTasksForDateRange(
          updatedBaseTask,
          DateTime.now().subtract(Duration(days: 30)),
          DateTime.now().add(Duration(days: 60)),
        );
      }
      tasks.refresh();
      update();
      _saveDataToStorage();
      print('DEBUG: updateAllTasks completed successfully');
    } catch (e, stackTrace) {
      print('ERROR: Failed to update all tasks: $e');
      print('StackTrace: $stackTrace');
      Get.snackbar(
        'Fehler',
        'Fehler beim Aktualisieren aller Aufgaben',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void addTagToTask(String taskId, String tag) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = tasks[index];
      if (!task.tags.contains(tag)) {
        final updatedTags = List<String>.from(task.tags)..add(tag);
        final updatedTask = task.copyWith(tags: updatedTags);
        updateTask(updatedTask);
        print('DEBUG: Tag "$tag" added to task: $taskId');
      }
    } else {
      print('ERROR: Task not found with ID: $taskId');
      Get.snackbar(
        'Fehler',
        'Aufgabe nicht gefunden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void deleteTask(String taskId) {
    _baseRecurringTasks.removeWhere((task) => task.id == taskId);
    tasks.removeWhere(
        (task) => task.id == taskId || task.id.startsWith(taskId + '_'));
    _generatedRecurringTasks.remove(taskId);
    tasks.refresh();
    update();
    _saveDataToStorage();
    print('DEBUG: Task deleted: $taskId');
  }

  void toggleTaskComplete(String taskId) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = tasks[index];
      final isCompleted = task.status == TaskStatus.completed;
      final updatedTask = task.copyWith(
        status: isCompleted ? TaskStatus.pending : TaskStatus.completed,
        completedAt: isCompleted ? null : DateTime.now(),
        subTasks: isCompleted
            ? task.subTasks
            : task.subTasks
                .map((st) => SubTask(
                      id: st.id,
                      title: st.title,
                      isCompleted: true,
                      dueDate: st.dueDate,
                    ))
                .toList(),
      );
      updateTask(updatedTask);
      print('DEBUG: Task completion toggled: $taskId');
    } else {
      print('ERROR: Task not found with ID: $taskId');
      Get.snackbar(
        'Fehler',
        'Aufgabe nicht gefunden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void moveTaskToDate(String taskId, DateTime newDate) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = tasks[index];
      final newStartTime = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        task.startTime.hour,
        task.startTime.minute,
      );
      final updatedTask = task.copyWith(
          startTime: newStartTime, recurrence: RecurrenceType.none);
      updateTask(updatedTask);
      print('DEBUG: Task $taskId moved to $newStartTime');
    } else {
      print('ERROR: Task not found with ID: $taskId');
      Get.snackbar(
        'Fehler',
        'Aufgabe nicht gefunden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void addInboxItem(InboxItem item) {
    inboxItems.add(item);
    inboxItems.refresh();
    _saveDataToStorage();
    print('DEBUG: Inbox item added: ${item.id} - ${item.title}');
  }

  void removeInboxItem(String itemId) {
    inboxItems.removeWhere((item) => item.id == itemId);
    inboxItems.refresh();
    _saveDataToStorage();
    print('DEBUG: Inbox item removed: $itemId');
  }

  void processInboxItem(String itemId, {Task? convertedTask}) {
    final index = inboxItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = inboxItems[index];
      final updatedItem = item.copyWith(isProcessed: true);
      inboxItems[index] = updatedItem;
      if (convertedTask != null) {
        addTask(convertedTask.copyWith(recurrence: RecurrenceType.none));
      }
      inboxItems.refresh();
      _saveDataToStorage();
      print('DEBUG: Inbox item processed: $itemId');
    } else {
      print('ERROR: Inbox item not found with ID: $itemId');
      Get.snackbar(
        'Fehler',
        'Eingangselement nicht gefunden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void deleteInboxItem(String itemId) {
    inboxItems.removeWhere((item) => item.id == itemId);
    inboxItems.refresh();
    _saveDataToStorage();
    print('DEBUG: Inbox item deleted: $itemId');
  }

  Task convertInboxItemToTask(
    InboxItem item, {
    required DateTime startTime,
    required String category,
    required IconData icon,
    required Color color,
    int? duration,
  }) {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: item.title,
      category: category,
      notes: item.description,
      startTime: startTime,
      duration: duration,
      icon: icon,
      color: color,
      tags: item.tags,
      recurrence: RecurrenceType.none,
    );
    addTask(task);
    print('DEBUG: Inbox item ${item.id} converted to task: ${task.id}');
    return task;
  }

  void _generateRecurringTasksForDate(DateTime targetDate) {
    final dateKey = _getDateKey(targetDate);

    for (final baseTask in _baseRecurringTasks) {
      final taskCacheKey = '${baseTask.id}_$dateKey';

      if (_generatedRecurringTasks[baseTask.id]?.contains(dateKey) == true) {
        continue;
      }

      if (_shouldGenerateTaskForDate(baseTask, targetDate)) {
        final newTask = _createRecurringTaskInstance(baseTask, targetDate);

        if (!tasks.any((t) => t.id == newTask.id)) {
          tasks.add(newTask);
        }

        _generatedRecurringTasks
            .putIfAbsent(baseTask.id, () => <String>{})
            .add(dateKey);
      }
    }
    _saveDataToStorage();
    print('DEBUG: Recurring tasks generated for $dateKey');
  }

  void _generateRecurringTasksForDateRange(
      Task baseTask, DateTime startDate, DateTime endDate) {
    final currentDate =
        DateTime(startDate.year, startDate.month, startDate.day);
    final targetEndDate = DateTime(endDate.year, endDate.month, endDate.day);

    DateTime checkDate = currentDate;
    while (checkDate.isBefore(targetEndDate) ||
        checkDate.isAtSameMomentAs(targetEndDate)) {
      if (_shouldGenerateTaskForDate(baseTask, checkDate)) {
        final dateKey = _getDateKey(checkDate);

        if (_generatedRecurringTasks[baseTask.id]?.contains(dateKey) != true) {
          final newTask = _createRecurringTaskInstance(baseTask, checkDate);

          if (!tasks.any((t) => t.id == newTask.id)) {
            tasks.add(newTask);
          }

          _generatedRecurringTasks
              .putIfAbsent(baseTask.id, () => <String>{})
              .add(dateKey);
        }
      }
      checkDate = checkDate.add(Duration(days: 1));
    }
    _saveDataToStorage();
    print('DEBUG: Recurring tasks generated for range $startDate to $endDate');
  }

  bool _shouldGenerateTaskForDate(Task baseTask, DateTime targetDate) {
    final baseDate = DateTime(baseTask.startTime.year, baseTask.startTime.month,
        baseTask.startTime.day);
    final checkDate =
        DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (checkDate.isBefore(baseDate)) {
      return false;
    }

    switch (baseTask.recurrence) {
      case RecurrenceType.daily:
        return true;
      case RecurrenceType.weekly:
        return checkDate.weekday == baseDate.weekday;
      case RecurrenceType.monthly:
        return checkDate.day == baseDate.day;
      case RecurrenceType.none:
        return false;
    }
  }

  Task _createRecurringTaskInstance(Task baseTask, DateTime targetDate) {
    final newStartTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      baseTask.startTime.hour,
      baseTask.startTime.minute,
    );

    return Task(
      id: '${baseTask.id}_${_getDateKey(targetDate)}',
      title: baseTask.title,
      category: baseTask.category,
      notes: baseTask.notes,
      startTime: newStartTime,
      duration: baseTask.duration,
      icon: baseTask.icon,
      color: baseTask.color,
      priority: baseTask.priority,
      recurrence: RecurrenceType.none,
      tags: List.from(baseTask.tags),
      isTimeBlocked: baseTask.isTimeBlocked,
      hasReminder: baseTask.hasReminder,
      reminderTime: baseTask.reminderTime,
    );
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void cleanupOldGeneratedTasks() {
    final cutoffDate = DateTime.now().subtract(Duration(days: 30));

    tasks.removeWhere((task) =>
        task.id.contains('_') &&
        task.startTime.isBefore(cutoffDate) &&
        task.recurrence == RecurrenceType.none);

    _generatedRecurringTasks.forEach((taskId, dateKeys) {
      dateKeys.removeWhere((dateKey) {
        final parts = dateKey.split('-');
        final date = DateTime(
            int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        return date.isBefore(cutoffDate);
      });
    });

    tasks.refresh();
    _saveDataToStorage();
    print('DEBUG: Old generated tasks cleaned up before $cutoffDate');
  }

  void initializeSampleData() {
    tasks.clear();
    inboxItems.clear();
    _baseRecurringTasks.clear();
    _generatedRecurringTasks.clear();

    final standUp = Task(
      id: '1',
      title: 'Stand up',
      category: 'Personal',
      startTime: DateTime.now().copyWith(hour: 6, minute: 0),
      duration: 30,
      icon: Icons.alarm,
      color: Colors.red,
      priority: TaskPriority.high,
      recurrence: RecurrenceType.daily,
      isTimeBlocked: true,
      hasReminder: true,
      reminderTime: DateTime.now().copyWith(hour: 5, minute: 45),
    );

    final sleep = Task(
      id: '2',
      title: 'Sleep',
      category: 'Personal',
      startTime: DateTime.now().copyWith(hour: 23, minute: 0),
      duration: 1,
      icon: Icons.nightlight_outlined,
      color: Colors.blue,
      priority: TaskPriority.urgent,
      notes: 'Weekly sync with the team',
      recurrence: RecurrenceType.daily,
      isTimeBlocked: true,
    );

    final payBills = Task(
      id: '3',
      title: 'Pay Bills',
      category: 'Personal',
      startTime: DateTime(DateTime.now().year, DateTime.now().month, 1, 9, 0),
      duration: 30,
      icon: Icons.payment,
      color: Colors.green,
      priority: TaskPriority.medium,
      recurrence: RecurrenceType.monthly,
      isTimeBlocked: true,
    );

    _baseRecurringTasks.addAll([standUp, sleep, payBills]);

    final today = DateTime.now();
    _generateRecurringTasksForDateRange(standUp,
        today.subtract(Duration(days: 7)), today.add(Duration(days: 14)));
    _generateRecurringTasksForDateRange(sleep,
        today.subtract(Duration(days: 7)), today.add(Duration(days: 14)));
    _generateRecurringTasksForDateRange(payBills,
        today.subtract(Duration(days: 7)), today.add(Duration(days: 14)));

    inboxItems.assignAll([
      InboxItem(
        id: '1',
        title: 'Zahnarzttermin vereinbaren',
        description: 'Kontrolle fällig, Terminwunsch: nächste Woche',
        type: InboxItemType.task,
        tags: ['Gesundheit', 'Termine'],
      ),
      InboxItem(
        id: '2',
        title: 'App-Idee: Habit Tracker',
        description: 'Integration mit Kalender, Social Features, Gamification',
        type: InboxItemType.idea,
        tags: ['App-Entwicklung', 'Business'],
      ),
      InboxItem(
        id: '3',
        title: 'Geburtstagsgeschenk für Maria',
        description: 'Geburtstag am 15. Juli - vielleicht ein Buch?',
        type: InboxItemType.reminder,
        tags: ['Geschenke', 'Familie'],
      ),
    ]);

    _saveDataToStorage();
    print('DEBUG: Sample data initialized and saved');
  }
}
