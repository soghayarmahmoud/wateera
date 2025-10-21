// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:wateera/models/task_model.dart';
// import 'package:wateera/components/wateera_app_bar.dart';
// import 'package:wateera/providers/task_provider.dart';
// import 'dart:math';

// import 'goals_screen.dart'; // Assuming you have these screens
// import 'notes_screen.dart';
// import 'pomodoro_screen.dart';
// import 'tasks_screen.dart';

// class DayScreen extends StatefulWidget {
//   final DateTime day;

//   const DayScreen({super.key, required this.day});

//   @override
//   State<DayScreen> createState() => _DayScreenState();
// }

// class _DayScreenState extends State<DayScreen> {
//   @override
//   Widget build(BuildContext context) {
//     // Get tasks from the provider for the selected day
//     final taskProvider = Provider.of<TaskProvider>(context);
//     final tasks = taskProvider.getTasksForDate(widget.day);

//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildMenuButton(
//               context,
//               title: 'Notes',
//               color: Colors.blue,
//               icon: Icons.note,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const NotesScreen()),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildMenuButton(
//               context,
//               title: 'To-do',
//               color: Colors.green,
//               icon: Icons.check_circle_outline,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const TasksScreen()),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildMenuButton(
//               context,
//               title: 'Pomodoro',
//               color: Colors.orange,
//               icon: Icons.timer,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const PomodoroScreen(),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildMenuButton(
//               context,
//               title: 'Goals',
//               color: Colors.purple,
//               icon: Icons.flag,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const GoalsScreen()),
//                 );
//               },
//             ),
//             const SizedBox(height: 32),
//             Text(
//               'Time Blocking',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 16),
//             Container( // Changed SizedBox to Container for better flexibility
//               height: 24 * 60.0, // 24 hours * 60 minutes
//               child: ListView.builder(
//                 itemCount: 24,
//                 itemBuilder: (context, index) {
//                   final hour = index;
//                   return Container(
//                     height: 60,
//                     decoration: BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(color: Colors.grey.shade300),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 60,
//                           alignment: Alignment.center,
//                           child: Text(
//                             DateFormat.j().format(DateTime(2023, 1, 1, hour)),
//                           ),
//                         ),
//                         Expanded( // This Expanded is fine
//                           child: Stack(
//                             children: tasks
//                                 .where((task) {
//                                   final startParts = task.startTime.split(':');
//                                   final startTime = DateTime(
//                                     widget.day.year, widget.day.month, widget.day.day, int.parse(startParts[0]), int.parse(startParts[1]),);
//                                   final endParts = task.endTime.split(':');
//                                   final endTime = DateTime(
//                                     widget.day.year, widget.day.month, widget.day.day, int.parse(endParts[0]), int.parse(endParts[1]),);

//                                   final hourStart = DateTime(
//                                     widget.day.year, widget.day.month, widget.day.day, hour,);
//                                   final hourEnd = hourStart.add(const Duration(hours: 1));

//                                   return startTime.isBefore(hourEnd) && endTime.isAfter(hourStart);
//                                 })
//                                 .map((task) {
//                                   final startParts = task.startTime.split(':');
//                                   final startTime = DateTime(
//                                     widget.day.year, widget.day.month, widget.day.day, int.parse(startParts[0]), int.parse(startParts[1]),);
//                                   final endParts = task.endTime.split(':');
//                                   final endTime = DateTime(
//                                     widget.day.year, widget.day.month, widget.day.day, int.parse(endParts[0]), int.parse(endParts[1]),);

//                                   final hourStart = DateTime(widget.day.year, widget.day.month, widget.day.day, hour,);
//                                   final hourEnd = hourStart.add(const Duration(hours: 1));

//                                   final top = startTime.isBefore(hourStart) ? 0.0 : startTime.minute.toDouble();
//                                   final endMinute = endTime.isAfter(hourEnd) ? 60.0 : endTime.minute.toDouble();
//                                   final height = endMinute - top;

//                                   return Positioned(
//                                     top: top,
//                                     left: 0,
//                                     right: 0,
//                                     height: max(0, height),
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         color: Color(task.color).withOpacity(0.7),
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(4.0),
//                                         child: Text(
//                                           task.title,
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                           ),
//                         ), // End of Stack
//                       ),
//                     );
//                   },

//               ),
//             ),
          
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddTaskDialog(context),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildMenuButton(
//     BuildContext context, {
//     required String title,
//     required Color color,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           border: Border.all(color: color, width: 2),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: color, size: 32),
//             const SizedBox(width: 16),
//             Text(
//               title,
//               style: TextStyle(
//                 color: color,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAddTaskDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         final titleController = TextEditingController();
//         TimeOfDay? startTime;
//         TimeOfDay? endTime;

//         return AlertDialog(
//           title: const Text('Add Task'),
//           content: StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: titleController,
//                     decoration: const InputDecoration(labelText: 'Title'),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: InkWell(
//                           onTap: () async {
//                             final time = await showTimePicker(
//                               context: context,
//                               initialTime: TimeOfDay.now(),
//                             );
//                             if (time != null) {
//                               setState(() {
//                                 startTime = time;
//                               });
//                             }
//                           },
//                           child: Text(
//                             startTime?.format(context) ?? 'Start Time',
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: InkWell(
//                           onTap: () async {
//                             final time = await showTimePicker(
//                               context: context,
//                               initialTime: TimeOfDay.now(),
//                             );
//                             if (time != null) {
//                               setState(() {
//                                 endTime = time;
//                               });
//                             }
//                           },
//                           child: Text(endTime?.format(context) ?? 'End Time'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (titleController.text.isNotEmpty &&
//                     startTime != null &&
//                     endTime != null) {
//                   final newTask = Task(
//                     id: DateTime.now().toString(),
//                     title: titleController.text,
//                     startTime: '${startTime!.hour}:${startTime!.minute}',
//                     endTime: '${endTime!.hour}:${endTime!.minute}',
//                     date: widget.day,
//                     color: Colors
//                         .primaries[Random().nextInt(Colors.primaries.length)]
//                         .value,
//                   );
//                   Provider.of<TaskProvider>(
//                     context,
//                     listen: false,
//                   ).addTask(newTask);
//                   Navigator.pop(context);
//                 }
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wateera/models/task_model.dart';
import 'package:wateera/providers/task_provider.dart';

import 'goals_screen.dart';
import 'notes_screen.dart';
import 'pomodoro_screen.dart';
import 'tasks_screen.dart';

class DayScreen extends StatefulWidget {
  final DateTime day;

  const DayScreen({super.key, required this.day});

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.getTasksForDate(widget.day);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMenuButton(
              context,
              title: 'Notes',
              color: Colors.blue,
              icon: Icons.note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotesScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              title: 'To-do',
              color: Colors.green,
              icon: Icons.check_circle_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TasksScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              title: 'Pomodoro',
              color: Colors.orange,
              icon: Icons.timer,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PomodoroScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              title: 'Goals',
              color: Colors.purple,
              icon: Icons.flag,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoalsScreen()),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Time Blocking',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // جدول الساعات
            SizedBox(
              height: 24 * 60, // 24 ساعة × 60 دقيقة = 1440
              child: ListView.builder(
                itemCount: 24,
                itemBuilder: (context, index) {
                  final hour = index;
                  return Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        // عرض الساعة
                        Container(
                          width: 60,
                          alignment: Alignment.center,
                          child: Text(
                            DateFormat.j()
                                .format(DateTime(2023, 1, 1, hour)),
                          ),
                        ),
                        // عرض المهام
                        Expanded(
                          child: Stack(
                            children: tasks.where((task) {
                              final startParts =
                                  task.startTime.split(':');
                              final startTime = DateTime(
                                widget.day.year,
                                widget.day.month,
                                widget.day.day,
                                int.parse(startParts[0]),
                                int.parse(startParts[1]),
                              );

                              final endParts =
                                  task.endTime.split(':');
                              final endTime = DateTime(
                                widget.day.year,
                                widget.day.month,
                                widget.day.day,
                                int.parse(endParts[0]),
                                int.parse(endParts[1]),
                              );

                              final hourStart = DateTime(
                                widget.day.year,
                                widget.day.month,
                                widget.day.day,
                                hour,
                              );
                              final hourEnd =
                                  hourStart.add(const Duration(hours: 1));

                              return startTime.isBefore(hourEnd) &&
                                  endTime.isAfter(hourStart);
                            }).map((task) {
                              final startParts =
                                  task.startTime.split(':');
                              final startTime = DateTime(
                                widget.day.year,
                                widget.day.month,
                                widget.day.day,
                                int.parse(startParts[0]),
                                int.parse(startParts[1]),
                              );
                              final endParts =
                                  task.endTime.split(':');
                              final endTime = DateTime(
                                widget.day.year,
                                widget.day.month,
                                widget.day.day,
                                int.parse(endParts[0]),
                                int.parse(endParts[1]),
                              );

                              final hourStart = DateTime(
                                widget.day.year,
                                widget.day.month,
                                widget.day.day,
                                hour,
                              );
                              final hourEnd =
                                  hourStart.add(const Duration(hours: 1));

                              final top = startTime.isBefore(hourStart)
                                  ? 0.0
                                  : startTime.minute.toDouble();
                              final endMinute =
                                  endTime.isAfter(hourEnd)
                                      ? 60.0
                                      : endTime.minute.toDouble();
                              final height = endMinute - top;

                              return Positioned(
                                top: top,
                                left: 0,
                                right: 0,
                                height: max(0, height),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(task.color)
                                        .withValues(alpha: 0.7),
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(4.0),
                                    child: Text(
                                      task.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // زر القوائم العلوية
  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // نافذة إضافة مهمة جديدة
  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        TimeOfDay? startTime;
        TimeOfDay? endTime;

        return AlertDialog(
          title: const Text('Add Task'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration:
                        const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                startTime = time;
                              });
                            }
                          },
                          child: Text(
                            startTime?.format(context) ??
                                'Start Time',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                endTime = time;
                              });
                            }
                          },
                          child: Text(
                            endTime?.format(context) ?? 'End Time',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    startTime != null &&
                    endTime != null) {
                  final newTask = Task(
                    id: DateTime.now().toString(),
                    title: titleController.text,
                    startTime:
                        '${startTime!.hour}:${startTime!.minute}',
                    endTime:
                        '${endTime!.hour}:${endTime!.minute}',
                    date: widget.day,
                    color: Colors
                        .primaries[
                            Random().nextInt(Colors.primaries.length)]
                        .toARGB32(), // بديل آمن لـ .value
                  );
                  Provider.of<TaskProvider>(context, listen: false)
                      .addTask(newTask);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
