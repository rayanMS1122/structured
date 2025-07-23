import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:structured/screens/add_task_page.dart';
import '../models/task.dart';
import '../services/task_controller.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart' as getx;

class TaskDetailSheet extends StatefulWidget {
  final Task task;

  const TaskDetailSheet({required this.task});

  @override
  _TaskDetailSheetState createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final TextEditingController _tagController = TextEditingController();
  final TaskController _taskController = Get.find<TaskController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(
      builder: (_) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.task.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(widget.task.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.edit,
                      color: Theme.of(context).primaryColor, size: 20),
                  onPressed: () {
                    Get.back();
                    Get.to(() => CompactAddTaskPage(task: widget.task));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Category: ${widget.task.category}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14),
            ),
            Text(
              'Time: ${TimeOfDay.fromDateTime(widget.task.startTime).format(context)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14),
            ),
            Text(
              'Priority: ${getx.GetStringUtils(widget.task.priority.toString().split('.').last).capitalize}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14),
            ),
            Text(
              'Recurrence: ${getx.GetStringUtils(widget.task.recurrence.toString().split('.').last).capitalize}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14),
            ),
            if (widget.task.notes != null)
              Text(
                'Notes: ${widget.task.notes}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 14),
              ),
            const SizedBox(height: 12),
            Text(
              'Tags: ${widget.task.tags.isEmpty ? 'None' : widget.task.tags.join(', ')}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      labelText: 'Add Tag',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_tagController.text.isNotEmpty) {
                      _taskController.addTagToTask(
                          widget.task.id, _tagController.text.trim());
                      _tagController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }
}
