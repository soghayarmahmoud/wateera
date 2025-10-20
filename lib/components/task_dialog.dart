import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;

  const TaskDialog({super.key, this.task});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _date = widget.task?.date ?? DateTime.now();
    _startTime = widget.task != null
        ? TimeOfDay(
            hour: int.parse(widget.task!.startTime.split(':')[0]),
            minute: int.parse(widget.task!.startTime.split(':')[1]))
        : TimeOfDay.now();
    _endTime = widget.task != null
        ? TimeOfDay(
            hour: int.parse(widget.task!.endTime.split(':')[0]),
            minute: int.parse(widget.task!.endTime.split(':')[1]))
        : TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Date: ${_date.day}/${_date.month}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text('Start Time: ${_startTime.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(isStartTime: true),
              ),
              ListTile(
                title: Text('End Time: ${_endTime.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(isStartTime: false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _date) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (widget.task == null) {
        final newTask = Task(
          id: Uuid().v4(),
          title: _title,
          date: _date,
          startTime: '${_startTime.hour}:${_startTime.minute}',
          endTime: '${_endTime.hour}:${_endTime.minute}',
        );
        taskProvider.addTask(newTask);
      } else {
        final updatedTask = widget.task!.copyWith(
          title: _title,
          date: _date,
          startTime: '${_startTime.hour}:${_startTime.minute}',
          endTime: '${_endTime.hour}:${_endTime.minute}',
        );
        taskProvider.updateTask(updatedTask);
      }

      Navigator.pop(context);
    }
  }
}
