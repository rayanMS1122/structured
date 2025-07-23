import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/task_controller.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(
      builder: (controller) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: controller.todayProgress,
              strokeWidth: 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                controller.todayProgress > 0.7
                    ? Colors.green
                    : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(controller.todayProgress * 100).toStringAsFixed(0)}% Completed',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Today',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
