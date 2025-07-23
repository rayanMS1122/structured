import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:structured/screens/add_task_page.dart';
import '../services/task_controller.dart';
import '../models/task.dart';
import '../models/inbox_item.dart';
import '../screens/inbox_page.dart';

class FloatingActionMenu extends StatefulWidget {
  const FloatingActionMenu({super.key});

  @override
  _FloatingActionMenuState createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();

    return Obx(() {
      final selectedDate = taskController.selectedDate.value;
      final taskCount = taskController.todayTasks.length;

      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (_isMenuOpen)
            _buildBottomSheet(context, selectedDate, taskController),
          Stack(
            alignment: Alignment.topRight,
            children: [
              FloatingActionButton(
                onPressed: _toggleMenu,
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  _isMenuOpen ? Icons.close : Icons.add,
                  size: 24,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              if (taskCount > 0 && !_isMenuOpen)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$taskCount',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildBottomSheet(BuildContext context, DateTime selectedDate,
      TaskController taskController) {
    return Container(
      margin: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.add_task,
            label: 'Add Task',
            onTap: () {
              HapticFeedback.selectionClick();
              _toggleMenu();
              Get.to(() => CompactAddTaskPage(startTime: selectedDate));
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.note_add,
            label: 'Add Note',
            onTap: () {
              HapticFeedback.selectionClick();
              _toggleMenu();
              taskController.addInboxItem(InboxItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Quick Note',
                type: InboxItemType.note,
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Note added to inbox'),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.inbox,
            label: 'Open Inbox',
            onTap: () {
              HapticFeedback.selectionClick();
              _toggleMenu();
              Get.to(() => const ModernInboxPage());
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.flash_on,
            label: 'Quick Task',
            onTap: () {
              HapticFeedback.selectionClick();
              _toggleMenu();
              taskController.addTask(Task(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Quick Task',
                category: 'Personal',
                startTime: selectedDate,
                duration: 30,
                icon: Icons.bolt,
                color: Theme.of(context).primaryColor,
                priority: TaskPriority.medium,
                recurrence: RecurrenceType.none,
                tags: [],
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Quick Task added'),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }
}
