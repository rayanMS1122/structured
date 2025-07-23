// File: advanced_timeline_page.dart
// Changes:
// - Added smoother gradients and neumorphic shadows for a modern look
// - Increased font sizes and animation durations for better readability and fluidity
// - Enhanced FAB with vibrant colors and shimmer effects
// - Uncommented and refined ProgressIndicatorWidget for a polished appearance
// - Adjusted padding and margins for better spacing

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:structured/models/task.dart';
import 'package:structured/widgets/floating_action_menu.dart';
import '../services/task_controller.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/date_selector.dart';
import '../widgets/progress_indicator_widget.dart';
import 'inbox_page.dart';
import 'add_task_page.dart';

class AdvancedTimelinePage extends StatefulWidget {
  @override
  _AdvancedTimelinePageState createState() => _AdvancedTimelinePageState();
}

class _AdvancedTimelinePageState extends State<AdvancedTimelinePage>
    with TickerProviderStateMixin {
  late TaskController taskController;
  late AnimationController _fabController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    taskController = Get.find<TaskController>();
    taskController.checkAndInitializeSampleData();
    _fabController = AnimationController(
      duration: Duration(milliseconds: 400), // Smoother animation
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240, // Slightly taller for better spacing
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context)
                            .primaryColor
                            .withOpacity(0.15), // Softer gradient
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: GetBuilder<TaskController>(
                            builder: (controller) => AnimationLimiter(
                              child: Column(
                                children:
                                    AnimationConfiguration.toStaggeredList(
                                  duration: Duration(
                                      milliseconds: 700), // Smoother stagger
                                  childAnimationBuilder: (widget) =>
                                      SlideAnimation(
                                    verticalOffset: 60.0,
                                    child: FadeInAnimation(child: widget),
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: DateSelector(),
                                    ),
                                    SizedBox(height: 16),
                                    _buildProgressCard(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Today\'s Timeline',
                      style: TextStyle(
                        fontSize: 26, // Larger for emphasis
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () =>
                          setState(() => _isExpanded = !_isExpanded),
                      icon: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: Duration(milliseconds: 400),
                        child: Icon(Icons.expand_more,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.3),
            ),
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 400),
                height:
                    _isExpanded ? 750 : 550, // Adjusted for better content fit
                child: TimelineWidget(),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionMenu());
  }

  Widget _buildProgressCard() {
    return Container(
      width: Get.width - 32,
      height: 60, // Larger for visibility
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24), // Softer corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(-2, -2),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Theme.of(context).cardColor,
            Theme.of(context).cardColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ProgressIndicatorWidget(),
    ).animate().fadeIn(delay: 600.ms).scale();
  }

  Widget _buildAdvancedFAB() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            if (_fabController.value > 0)
              Transform.translate(
                offset:
                    Offset(0, -160 * _fabController.value), // Adjusted spacing
                child: Transform.scale(
                  scale: _fabController.value,
                  child: FloatingActionButton(
                    heroTag: "inbox",
                    onPressed: _navigateToInbox,
                    backgroundColor: Colors.orange.shade400, // Vibrant color
                    elevation: 8,
                    child: Icon(Icons.inbox, color: Colors.white),
                  ).animate().scale(duration: 300.ms),
                ),
              ),
            if (_fabController.value > 0)
              Transform.translate(
                offset: Offset(
                    -80 * _fabController.value, -80 * _fabController.value),
                child: Transform.scale(
                  scale: _fabController.value,
                  child: FloatingActionButton(
                    heroTag: "add",
                    onPressed: _navigateToAddTask,
                    backgroundColor: Colors.teal.shade400, // Vibrant color
                    elevation: 8,
                    child: Icon(Icons.add_task, color: Colors.white),
                  ).animate().scale(duration: 300.ms),
                ),
              ),
            FloatingActionButton(
              heroTag: "main",
              onPressed: () {
                if (_fabController.isCompleted) {
                  _fabController.reverse();
                } else {
                  _fabController.forward();
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 10,
              child: AnimatedRotation(
                turns: _fabController.value * 0.125,
                duration: Duration(milliseconds: 400),
                child: Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ).animate().scale(duration: 300.ms).shimmer(),
          ],
        );
      },
    );
  }

  void _navigateToAddTask() {
    _fabController.reverse();
    Get.to(() => CompactAddTaskPage(),
        transition: Transition.rightToLeft,
        duration: Duration(milliseconds: 400));
  }

  void _navigateToInbox() {
    _fabController.reverse();
    Get.to(() => ModernInboxPage(),
        transition: Transition.upToDown, duration: Duration(milliseconds: 400));
  }
}
