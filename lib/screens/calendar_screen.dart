import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wateera/components/wateera_app_bar.dart';
import 'package:wateera/models/goal_model.dart';
import 'package:wateera/models/note_model.dart';
import 'package:wateera/models/task_model.dart';
import 'package:wateera/providers/goal_provider.dart';
import 'package:wateera/providers/note_provider.dart';
import 'package:wateera/providers/task_provider.dart';
import 'day_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final goalProvider = Provider.of<GoalProvider>(context);
    final noteProvider = Provider.of<NoteProvider>(context);

    final tasksForSelectedDay = taskProvider.getTasksForDate(_selectedDay);
    final goalsForSelectedDay = goalProvider.goals.where((goal) => isSameDay(goal.endTime, _selectedDay)).toList();
    final notesForSelectedDay = noteProvider.getNotesForDate(_selectedDay);

    return Scaffold(
      appBar: const WateeraAppBar(title: Text('Calendar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFA7F3D0)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.purple.shade200,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFFA7F3D0),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                eventLoader: (day) {
                  return [
                    ...taskProvider.getTasksForDate(day),
                    ...goalProvider.goals.where((goal) => isSameDay(goal.endTime, day)),
                    ...noteProvider.getNotesForDate(day),
                  ];
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tasks for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            if (tasksForSelectedDay.isEmpty)
              const Center(
                child: Text('No tasks for this day'),
              )
            else
              ...tasksForSelectedDay.map((task) => _buildTaskCard(task, taskProvider)),
            const SizedBox(height: 24),
            Text(
              'Goals for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            if (goalsForSelectedDay.isEmpty)
              const Center(
                child: Text('No goals for this day'),
              )
            else
              ...goalsForSelectedDay.map((goal) => _buildGoalCard(goal, goalProvider)),
            const SizedBox(height: 24),
            Text(
              'Notes for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            if (notesForSelectedDay.isEmpty)
              const Center(
                child: Text('No notes for this day'),
              )
            else
              ...notesForSelectedDay.map((note) => _buildNoteCard(note, noteProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, TaskProvider taskProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => taskProvider.toggleTaskCompletion(task.id),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text('${task.startTime} - ${task.endTime}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => taskProvider.deleteTask(task.id),
        ),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal, GoalProvider goalProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: goal.isCompleted,
          onChanged: (_) => goalProvider.toggleGoalCompletion(goal.id),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          goal.title,
          style: TextStyle(
            decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => goalProvider.deleteGoal(goal.id),
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note, NoteProvider noteProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(note.title),
        subtitle: Text(note.content),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => noteProvider.deleteNote(note.id),
        ),
      ),
    );
  }
}