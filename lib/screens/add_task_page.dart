import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/task_controller.dart';
import '../models/task.dart';

class CompactAddTaskPage extends StatefulWidget {
  final Task? task;
  final DateTime? startTime;
  const CompactAddTaskPage({this.task, this.startTime, super.key});

  @override
  _CompactAddTaskPageState createState() => _CompactAddTaskPageState();
}

class _CompactAddTaskPageState extends State<CompactAddTaskPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TaskController taskController = Get.find<TaskController>();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;

  String title = '';
  String? category;
  String? notes;
  DateTime startTime = DateTime.now();
  int? duration;
  TaskPriority priority = TaskPriority.medium;
  RecurrenceType recurrence = RecurrenceType.none;
  IconData icon = Icons.alarm;
  Color color = Colors.teal;
  List<String> tags = [];
  bool isTitleValid = false;

  static const List<String> _categories = ['Personal', 'Work', 'Rest'];
  static const List<Color> _colors = [
    Colors.teal,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.red,
  ];
  static const List<String> _suggestedTitles = [
    'Meeting',
    'Workout',
    'Study',
    'Shopping',
    'Call'
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _shimmerController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this)
      ..repeat(reverse: true);

    _initializeForm();
    _titleController.text = title;
    _titleController.addListener(_validateTitle);
    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeForm() {
    if (widget.task != null) {
      title = widget.task!.title;
      isTitleValid = title.isNotEmpty;
      category = _categories.contains(widget.task!.category)
          ? widget.task!.category
          : _categories.first;
      notes = widget.task!.notes;
      startTime = widget.task!.startTime;
      duration = widget.task!.duration;
      priority = widget.task!.priority;
      recurrence = widget.task!.recurrence;
      icon = widget.task!.icon;
      color = widget.task!.color;
      tags = List.from(widget.task!.tags);
    } else {
      final selectedDate = taskController.selectedDate.value;
      startTime = widget.startTime ??
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
              DateTime.now().hour, DateTime.now().minute);
      category = _categories.first;
    }
  }

  void _validateTitle() {
    setState(() {
      isTitleValid = _titleController.text.trim().isNotEmpty;
      title = _titleController.text.trim();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    _tagController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.15),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      title: Text(
        widget.task == null ? 'New Task' : 'Edit Task',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2, end: 0.0),
      actions: [
        IconButton(
          icon: Icon(Icons.check_rounded,
              size: 24, color: Theme.of(context).primaryColor),
          onPressed: _saveTask,
          tooltip: 'Save Task',
        )
            .animate()
            .scale(delay: 300.ms, duration: 200.ms, curve: Curves.easeOutBack),
      ],
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleSection(),
            const SizedBox(height: 16),
            _buildSuggestionsSection(),
            const SizedBox(height: 16),
            _buildQuickSettings(),
            const SizedBox(height: 16),
            _buildDetailsSection(),
            const SizedBox(height: 16),
            _buildTagsSection(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ).animate().slideX(
            begin: 0.2, end: 0.0, duration: 300.ms, curve: Curves.easeOutCubic),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Task Title',
            labelStyle: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            prefixIcon:
                Icon(Icons.edit_rounded, color: Theme.of(context).primaryColor),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isTitleValid
                  ? Icon(Icons.check_circle_rounded,
                      key: ValueKey('valid'),
                      color: Theme.of(context).primaryColor,
                      size: 20)
                  : Icon(Icons.error_outline_rounded,
                      key: ValueKey('invalid'),
                      color: Theme.of(context).colorScheme.error,
                      size: 20),
            ),
            filled: true,
            fillColor: Colors.transparent,
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          validator: (value) =>
              value?.trim().isEmpty ?? true ? 'Please enter a title' : null,
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).scale(duration: 200.ms);
  }

  Widget _buildSuggestionsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _suggestedTitles
          .map((suggestion) => InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _titleController.text = suggestion;
                  _validateTitle();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3)),
                  ),
                  child: Text(
                    suggestion,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 150.ms * _suggestedTitles.indexOf(suggestion))
                  .scale(duration: 200.ms))
          .toList(),
    );
  }

  Widget _buildQuickSettings() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildCategorySelector()),
                const SizedBox(width: 12),
                Expanded(child: _buildPrioritySelector()),
              ],
            ),
            const SizedBox(height: 12),
            _buildDateTimeSelector(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDurationField()),
                const SizedBox(width: 12),
                Expanded(child: _buildRecurrenceSelector()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildIconSelector()),
                const SizedBox(width: 12),
                Expanded(child: _buildColorSelector()),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms)
        .slideY(begin: 0.1, end: 0.0, duration: 200.ms);
  }

  Widget _buildCategorySelector() {
    if (category != null && !_categories.contains(category)) {
      category = _categories.first;
    }
    return DropdownButtonFormField<String>(
      value: category,
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
        ),
        prefixIcon:
            Icon(Icons.category_rounded, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: Theme.of(context).cardColor.withOpacity(0.7),
      ),
      items: _categories
          .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface)),
              ))
          .toList(),
      onChanged: (value) => setState(() => category = value!),
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildPrioritySelector() {
    return DropdownButtonFormField<TaskPriority>(
      value: priority,
      decoration: InputDecoration(
        labelText: 'Priority',
        labelStyle: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
        ),
        prefixIcon:
            Icon(Icons.flag_rounded, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: Theme.of(context).cardColor.withOpacity(0.7),
      ),
      items: TaskPriority.values
          .map((p) => DropdownMenuItem(
                value: p,
                child: Text(
                  StringExtension(p.toString().split('.').last).capitalize,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ))
          .toList(),
      onChanged: (value) => setState(() => priority = value!),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildDateTimeSelector() {
    return InkWell(
      onTap: () => _selectDateTime(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).cardColor.withOpacity(0.7),
              Theme.of(context).cardColor.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded,
                color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                DateFormat('EEE, MMM d – HH:mm').format(startTime),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms).scale(duration: 200.ms);
  }

  Widget _buildDurationField() {
    return TextFormField(
      initialValue: duration?.toString(),
      decoration: InputDecoration(
        labelText: 'Duration (min)',
        labelStyle: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
        ),
        prefixIcon:
            Icon(Icons.timer_rounded, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: Theme.of(context).cardColor.withOpacity(0.7),
      ),
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface),
      onChanged: (value) => duration = int.tryParse(value),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRecurrenceSelector() {
    return DropdownButtonFormField<RecurrenceType>(
      value: recurrence,
      decoration: InputDecoration(
        labelText: 'Repeat',
        labelStyle: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
        ),
        prefixIcon:
            Icon(Icons.repeat_rounded, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: Theme.of(context).cardColor.withOpacity(0.7),
      ),
      items: RecurrenceType.values
          .map((r) => DropdownMenuItem(
                value: r,
                child: Text(
                  StringExtension(r.toString().split('.').last).capitalize,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ))
          .toList(),
      onChanged: (value) => setState(() => recurrence = value!),
    ).animate().fadeIn(delay: 450.ms);
  }

  Widget _buildIconSelector() {
    final icons = [
      Icons.alarm,
      Icons.work,
      Icons.fitness_center,
      Icons.book,
      Icons.event,
      Icons.nightlight_round,
    ];
    return DropdownButtonFormField<IconData>(
      value: icon,
      decoration: InputDecoration(
        labelText: 'Icon',
        labelStyle: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
        ),
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: Theme.of(context).cardColor.withOpacity(0.7),
      ),
      items: icons
          .map((i) => DropdownMenuItem(
                value: i,
                child: Icon(i, color: Theme.of(context).primaryColor),
              ))
          .toList(),
      onChanged: (value) => setState(() => icon = value!),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildColorSelector() {
    return InkWell(
      onTap: () => _selectColor(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).cardColor.withOpacity(0.7),
              Theme.of(context).cardColor.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.2)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Color',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 550.ms).scale(duration: 200.ms);
  }

  Widget _buildDetailsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: TextFormField(
          initialValue: notes,
          decoration: InputDecoration(
            labelText: 'Notes (optional)',
            labelStyle: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.notes_rounded,
                color: Theme.of(context).primaryColor),
            filled: true,
            fillColor: Colors.transparent,
          ),
          maxLines: 3,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onChanged: (value) => notes = value?.trim(),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms)
        .slideY(begin: 0.1, end: 0.0, duration: 200.ms);
  }

  Widget _buildTagsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags
                    .map((tag) => Chip(
                          label: Text(
                            tag,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.2)),
                          ),
                          deleteIcon: Icon(Icons.close_rounded,
                              size: 18, color: Theme.of(context).primaryColor),
                          onDeleted: () => setState(() => tags.remove(tag)),
                        ).animate().scale(delay: 50.ms, duration: 200.ms))
                    .toList(),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'Add tag',
                      hintStyle: GoogleFonts.poppins(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.2)),
                      ),
                      prefixIcon: Icon(Icons.tag_rounded,
                          color: Theme.of(context).primaryColor),
                      filled: true,
                      fillColor: Theme.of(context).cardColor.withOpacity(0.7),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.add_circle_rounded,
                      size: 28, color: Theme.of(context).primaryColor),
                  onPressed: _addTag,
                ).animate().scale(
                    delay: 650.ms, duration: 200.ms, curve: Curves.easeOutBack),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 650.ms)
        .slideY(begin: 0.1, end: 0.0, duration: 200.ms);
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isTitleValid ? _saveTask : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
        ),
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment(-1.0 + (_shimmerController.value * 2), 0.0),
                  end: Alignment(1.0 + (_shimmerController.value * 2), 0.0),
                ).createShader(bounds);
              },
              child: Text(
                widget.task == null ? 'Create Task' : 'Update Task',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            );
          },
        ),
      ),
    ).animate().scale(delay: 700.ms, duration: 200.ms).shimmer(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
          duration: 1200.ms,
        );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: startTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                  surface: Theme.of(context).cardColor,
                  onSurface: Theme.of(context).colorScheme.onSurface,
                ),
            dialogBackgroundColor: Theme.of(context).cardColor.withOpacity(0.9),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(startTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Theme.of(context).colorScheme.onPrimary,
                    surface: Theme.of(context).cardColor,
                    onSurface: Theme.of(context).colorScheme.onSurface,
                  ),
              dialogBackgroundColor:
                  Theme.of(context).cardColor.withOpacity(0.9),
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        setState(() {
          startTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
          taskController.selectDate(date);
        });
      }
    }
  }

  Future<void> _selectColor(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Select Color',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colors
                .map((c) => GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => color = c);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color == c
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.2),
                            width: color == c ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .scale(duration: 200.ms, curve: Curves.easeOutBack),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        category: category ?? _categories.first,
        notes: notes,
        startTime: startTime,
        duration: duration,
        icon: icon,
        color: color,
        priority: priority,
        recurrence: recurrence,
        tags: tags,
      );

      if (widget.task == null) {
        taskController.addTask(task);
      } else {
        taskController.updateTask(task);
      }
      Get.back();
    }
  }
}

extension StringExtension on String {
  String get capitalize =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
