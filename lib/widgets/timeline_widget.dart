import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/task_controller.dart';
import '../models/task.dart';
import 'task_detail_sheet.dart';

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({Key? key}) : super(key: key);

  @override
  _TimelineWidgetState createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String? _draggedTaskId;
  int? _dragTargetHour;
  bool _isDragging = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(
      builder: (controller) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: 24,
            itemBuilder: (context, index) {
              final hour = index;
              final hourTasks = controller.todayTasks
                  .where((task) => task.startTime.hour == hour)
                  .toList();
              final isCurrentHour = DateTime.now().hour == hour;
              final isDropTarget = _isDragging && _dragTargetHour == hour;

              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.25,
                isFirst: hour == 0,
                isLast: hour == 23,
                indicatorStyle: IndicatorStyle(
                  width: isCurrentHour ? 16 : 12,
                  height: isCurrentHour ? 16 : 12,
                  color: isCurrentHour
                      ? Theme.of(context).primaryColor
                      : isDropTarget
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).dividerColor,
                  indicatorXY: 0.5,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  drawGap: true,
                  indicator: isCurrentHour
                      ? AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).primaryColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : isDropTarget
                          ? Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.secondary,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ).animate().scale(duration: 150.ms).fadeIn()
                          : null,
                ),
                beforeLineStyle: LineStyle(
                  color: isCurrentHour
                      ? Theme.of(context).primaryColor.withOpacity(0.4)
                      : Theme.of(context).dividerColor,
                  thickness: isCurrentHour ? 3 : 2,
                ),
                afterLineStyle: LineStyle(
                  color: isCurrentHour
                      ? Theme.of(context).primaryColor.withOpacity(0.4)
                      : Theme.of(context).dividerColor,
                  thickness: isCurrentHour ? 3 : 2,
                ),
                startChild: Container(
                  margin: const EdgeInsets.only(left: 12, right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrentHour
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : isDropTarget
                            ? Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.1)
                            : Theme.of(context).cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentHour
                          ? Theme.of(context).primaryColor.withOpacity(0.4)
                          : isDropTarget
                              ? Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.5)
                              : Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: TextStyle(
                      fontSize: 14,
                      color: isCurrentHour
                          ? Theme.of(context).primaryColor
                          : isDropTarget
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.onSurface,
                      fontWeight:
                          isCurrentHour ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms),
                endChild: _buildHourSlot(context, controller, hour, hourTasks),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHourSlot(BuildContext context, TaskController controller,
      int hour, List<Task> hourTasks) {
    return DragTarget<Task>(
      onAccept: (Task task) {
        if (task.startTime.hour != hour) {
          _rescheduleTask(controller, task, hour);
        } else {
          setState(() {
            _isDragging = false;
            _dragTargetHour = null;
            _draggedTaskId = null;
          });
        }
      },
      onWillAccept: (Task? task) {
        setState(() {
          _dragTargetHour = hour;
        });
        return task != null;
      },
      onLeave: (Task? task) {
        setState(() {
          _dragTargetHour = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 12, left: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: _dragTargetHour == hour && _isDragging
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: _dragTargetHour == hour && _isDragging
                ? Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.4),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_dragTargetHour == hour && _isDragging && hourTasks.isEmpty)
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Drop Here',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 150.ms),
              ...hourTasks
                  .map((task) => _buildDraggableTaskCard(context, task))
                  .toList(),
              if (_dragTargetHour == hour &&
                  _isDragging &&
                  hourTasks.isNotEmpty)
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ).animate().fadeIn(duration: 150.ms),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableTaskCard(BuildContext context, Task task) {
    final isDraggedTask = _draggedTaskId == task.id;

    return LongPressDraggable<Task>(
      data: task,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () {
        setState(() {
          _isDragging = true;
          _draggedTaskId = task.id;
        });
        HapticFeedback.mediumImpact();
      },
      onDragEnd: (details) {
        setState(() {
          _isDragging = false;
          _draggedTaskId = null;
          _dragTargetHour = null;
        });
      },
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: task.color.withOpacity(0.8),
              width: 1.5,
            ),
          ),
          child: _buildTaskContent(context, task),
        ),
      ).animate().scale(duration: 150.ms),
      childWhenDragging: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Opacity(
          opacity: 0.5,
          child: _buildTaskContent(context, task),
        ),
      ),
      child: Slidable(
        key: Key(task.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (context) {
                final controller = Get.find<TaskController>();
                controller.toggleTaskComplete(task.id);
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              icon: Icons.check_circle,
              label: 'Done',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => showTaskDetailSheet(context, task),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDraggedTask
                  ? Theme.of(context).cardColor.withOpacity(0.7)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDraggedTask
                    ? Theme.of(context).dividerColor
                    : task.color.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: isDraggedTask
                  ? []
                  : [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: _buildTaskContent(context, task),
          ),
        ),
      ).animate().fadeIn(duration: 200.ms),
    );
  }

  Widget _buildTaskContent(BuildContext context, Task task) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: task.color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            task.icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: task.status == TaskStatus.completed
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                      : Theme.of(context).colorScheme.onSurface,
                  decoration: task.status == TaskStatus.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              if (task.duration != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: task.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: task.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${task.duration} min',
                    style: TextStyle(
                      fontSize: 11,
                      color: task.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: task.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.drag_handle,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            size: 18,
          ),
        ),
      ],
    );
  }

  void _rescheduleTask(TaskController controller, Task task, int newHour) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Apply Time Change',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'How should the time change for "${task.title}" be applied?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).cardColor,
          actions: [
            TextButton(
              onPressed: () {
                final newStartTime = DateTime(
                  task.startTime.year,
                  task.startTime.month,
                  task.startTime.day,
                  newHour,
                  task.startTime.minute,
                );
                final updatedTask = task.copyWith(startTime: newStartTime);
                controller.updateTask(updatedTask);
                _showConfirmationSnackbar(task, newHour);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'This Task Only',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                controller.updateFutureTasks(task, newHour);
                _showConfirmationSnackbar(task, newHour);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Future Tasks',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                controller.updateAllTasks(task, newHour);
                _showConfirmationSnackbar(task, newHour);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'All Tasks',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {
        _isDragging = false;
        _dragTargetHour = null;
        _draggedTaskId = null;
      });
    });
  }

  void _showConfirmationSnackbar(Task task, int newHour) {
    Get.snackbar(
      'Task Moved',
      '"${task.title}" moved to ${newHour.toString().padLeft(2, '0')}:${task.startTime.minute.toString().padLeft(2, '0')}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      colorText: Theme.of(context).colorScheme.onPrimary,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(
        Icons.check_circle,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 24,
      ),
      snackStyle: SnackStyle.FLOATING,
    );
  }

  void showTaskDetailSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      TaskDetailSheet(task: task),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    );
  }
}
