import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/task_controller.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskController>();
    DateTime? lastTapTime;

    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      final startOfWeek =
          selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
                  onPressed: () {
                    final now = DateTime.now();
                    if (lastTapTime == null ||
                        now.difference(lastTapTime!).inMilliseconds > 500) {
                      lastTapTime = now;
                      HapticFeedback.mediumImpact();
                      final newStartOfWeek =
                          startOfWeek.subtract(const Duration(days: 7));
                      controller.selectDate(newStartOfWeek);
                    }
                  },
                  splashRadius: 20,
                  tooltip: 'Previous Week',
                )
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .scale(duration: 200.ms, curve: Curves.easeOutBack),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context)
                                  .colorScheme
                                  .copyWith(
                                    primary: Theme.of(context).primaryColor,
                                    onPrimary:
                                        Theme.of(context).colorScheme.onPrimary,
                                    surface: Theme.of(context).cardColor,
                                    onSurface:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                              dialogBackgroundColor:
                                  Theme.of(context).cardColor,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        HapticFeedback.selectionClick();
                        controller.selectDate(pickedDate);
                      }
                    },
                    child: Text(
                      DateFormat('MMMM yyyy').format(startOfWeek),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 150.ms)
                      .slideY(begin: 0.2, end: 0.0, duration: 200.ms),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
                  onPressed: () {
                    final now = DateTime.now();
                    if (lastTapTime == null ||
                        now.difference(lastTapTime!).inMilliseconds > 500) {
                      lastTapTime = now;
                      HapticFeedback.mediumImpact();
                      final newStartOfWeek =
                          startOfWeek.add(const Duration(days: 7));
                      controller.selectDate(newStartOfWeek);
                    }
                  },
                  splashRadius: 20,
                  tooltip: 'Next Week',
                )
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .scale(duration: 200.ms, curve: Curves.easeOutBack),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final day = startOfWeek.add(Duration(days: index));
                final isToday = day.year == DateTime.now().year &&
                    day.month == DateTime.now().month &&
                    day.day == DateTime.now().day;
                final isSelected = day.year == selectedDate.year &&
                    day.month == selectedDate.month &&
                    day.day == selectedDate.day;
                final taskCount = controller.todayTasks
                    .where((task) =>
                        task.startTime.year == day.year &&
                        task.startTime.month == day.month &&
                        task.startTime.day == day.day)
                    .length;

                return Expanded(
                    child: InkWell(
                  onTap: () {
                    final now = DateTime.now();
                    if (lastTapTime == null ||
                        now.difference(lastTapTime!).inMilliseconds > 500) {
                      lastTapTime = now;
                      HapticFeedback.selectionClick();
                      controller.selectDate(day);
                    }
                  },
                  onLongPress: () {
                    HapticFeedback.vibrate();
                    Get.snackbar(
                      DateFormat('EEEE, MMMM d').format(day),
                      isToday ? 'Today • $taskCount tasks' : '$taskCount tasks',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.9),
                      colorText: Theme.of(context).colorScheme.onPrimary,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(10),
                      borderRadius: 10,
                      snackStyle: SnackStyle.FLOATING,
                      boxShadows: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : isToday
                              ? LinearGradient(
                                  colors: [
                                    Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.4),
                                    Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Theme.of(context).cardColor,
                                    Theme.of(context)
                                        .cardColor
                                        .withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.2,
                            )
                          : null,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('EEE').format(day),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('d').format(day),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isToday)
                          Positioned(
                            bottom: 6,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                              ).animate().scale(
                                  duration: 300.ms, curve: Curves.easeOutBack),
                            ),
                          ),
                        if (taskCount > 0)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.2),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Text(
                                '$taskCount',
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ).animate().fadeIn(duration: 200.ms),
                          ),
                      ],
                    ),
                  ),
                )
                        .animate()
                        .scale(
                            delay: 50.ms * index,
                            duration: 150.ms,
                            curve: Curves.easeOutBack)
                        .then());
              }),
            ),
          ),
        ],
      );
    });
  }
}
