import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../services/draft_service.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final DraftService _draftService = DraftService();

  DateTime? _selectedDate;
  String _selectedStatus = 'To-Do';
  String? _blockedBy;
  bool _isEdit = false;
  bool _draftLoaded = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.task != null;

    if (_isEdit) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedDate = task.dueDate;
      _selectedStatus = task.status;
      _blockedBy = task.blockedBy;
      _draftLoaded = true;
    } else {
      _loadDraft();
    }

    _titleController.addListener(_saveDraftIfNeeded);
    _descriptionController.addListener(_saveDraftIfNeeded);
  }

  Future<void> _loadDraft() async {
    final draft = await _draftService.getDraft();
    if (!mounted) return;

    setState(() {
      _titleController.text = draft['title'] ?? '';
      _descriptionController.text = draft['description'] ?? '';
      _selectedStatus = draft['status'] ?? 'To-Do';
      _blockedBy =
          (draft['blockedBy'] ?? '').isEmpty ? null : draft['blockedBy'];

      if ((draft['dueDate'] ?? '').isNotEmpty) {
        _selectedDate = DateTime.tryParse(draft['dueDate']!);
      }

      _draftLoaded = true;
    });
  }

  Future<void> _saveDraftIfNeeded() async {
    if (_isEdit || !_draftLoaded) return;

    await _draftService.saveDraft(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDate?.toIso8601String() ?? '',
      status: _selectedStatus,
      blockedBy: _blockedBy ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _saveDraftIfNeeded();
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    final provider = context.read<TaskProvider>();

    final task = TaskModel(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDate!,
      status: _selectedStatus,
      blockedBy: (_blockedBy == null || _blockedBy!.isEmpty) ? null : _blockedBy,
    );

    if (_isEdit) {
      await provider.updateTask(task);
    } else {
      await provider.addTask(task);
      await _draftService.clearDraft();
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final availableTasks = provider.tasks
        .where((task) => task.id != widget.task?.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Task' : 'Create Task'),
        centerTitle: true,
      ),
      body: !_draftLoaded && !_isEdit
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Select due date'
                              : 'Due Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(
                            color: _selectedDate == null
                                ? Colors.grey.shade600
                                : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'To-Do', child: Text('To-Do')),
                        DropdownMenuItem(
                          value: 'In Progress',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(value: 'Done', child: Text('Done')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedStatus = value;
                          });
                          _saveDraftIfNeeded();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Status',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _blockedBy,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...availableTasks.map(
                          (task) => DropdownMenuItem<String>(
                            value: task.id,
                            child: Text(task.title),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _blockedBy = value;
                        });
                        _saveDraftIfNeeded();
                      },
                      decoration: InputDecoration(
                        labelText: 'Blocked By (Optional)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isSaving ? null : _saveTask,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: provider.isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isEdit ? 'Update Task' : 'Save Task'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}