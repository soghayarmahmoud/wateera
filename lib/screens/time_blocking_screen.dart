import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wateera/components/wateera_app_bar.dart';
import 'package:wateera/models/time_block_model.dart';
import 'package:wateera/providers/time_block_provider.dart';
import 'package:uuid/uuid.dart';

class TimeBlockingScreen extends StatefulWidget {
  const TimeBlockingScreen({super.key});

  @override
  State<TimeBlockingScreen> createState() => _TimeBlockingScreenState();
}

class _TimeBlockingScreenState extends State<TimeBlockingScreen> {
  final ScrollController _scrollController = ScrollController();
  final Uuid _uuid = const Uuid();
  
  // Hours from 6 AM to 11 PM (18 hours)
  static const int startHour = 6;
  static const int endHour = 23;
  static const int totalHours = endHour - startHour + 1;
  static const double hourHeight = 80.0;

  @override
  void initState() {
    super.initState();
    // Scroll to current time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    final currentHour = now.hour;
    if (currentHour >= startHour && currentHour <= endHour) {
      final position = (currentHour - startHour) * hourHeight;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeBlockProvider = Provider.of<TimeBlockProvider>(context);
    final theme = Theme.of(context);
    final selectedDate = timeBlockProvider.selectedDate;
    final timeBlocks = timeBlockProvider.getTimeBlocksForDate(selectedDate);

    return Scaffold(
      appBar: WateeraAppBar(
        title: Text(_formatDate(selectedDate)),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              timeBlockProvider.setSelectedDate(DateTime.now());
              _scrollToCurrentTime();
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDatePicker(context, timeBlockProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(timeBlockProvider, theme),
          _buildStatsBar(timeBlockProvider, theme),
          Expanded(
            child: _buildTimeGrid(timeBlocks, theme, timeBlockProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTimeBlockDialog(context, timeBlockProvider),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        label: const Text('Add Block'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector(TimeBlockProvider provider, ThemeData theme) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 3));
          final isSelected = _isSameDay(date, provider.selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => provider.setSelectedDate(date),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected 
                  ? theme.primaryColor
                  : isToday 
                    ? theme.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected
                  ? Border.all(color: theme.primaryColor, width: 2)
                  : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected 
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isSelected 
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsBar(TimeBlockProvider provider, ThemeData theme) {
    final stats = provider.getStatistics();
    final activeBlock = stats['activeBlock'] as TimeBlock?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (activeBlock != null) ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(activeBlock.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(activeBlock.color).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      color: Color(activeBlock.color),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Now: ${activeBlock.title}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Color(activeBlock.color),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            activeBlock.timeRange,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Color(activeBlock.color).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    'Total',
                    stats['totalToday'].toString(),
                    Icons.schedule,
                    theme.primaryColor,
                    theme,
                  ),
                  _buildStatItem(
                    'Done',
                    stats['completedToday'].toString(),
                    Icons.check_circle,
                    Colors.green,
                    theme,
                  ),
                  _buildStatItem(
                    'Rate',
                    '${(stats['completionRate'] * 100).toInt()}%',
                    Icons.trending_up,
                    Colors.orange,
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeGrid(List<TimeBlock> timeBlocks, ThemeData theme, TimeBlockProvider provider) {
    return Stack(
      children: [
        // Time labels and grid lines
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: List.generate(totalHours, (index) {
              final hour = startHour + index;
              return _buildHourRow(hour, theme);
            }),
          ),
        ),
        // Time blocks overlay
        SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            height: totalHours * hourHeight,
            margin: const EdgeInsets.only(left: 60),
            child: Stack(
              children: timeBlocks.map((block) => _buildTimeBlockWidget(
                block, theme, provider,
              )).toList(),
            ),
          ),
        ),
        // Current time indicator
        if (_isToday(provider.selectedDate)) _buildCurrentTimeIndicator(theme),
      ],
    );
  }

  Widget _buildHourRow(int hour, ThemeData theme) {
    final isCurrentHour = _isToday(Provider.of<TimeBlockProvider>(context).selectedDate) &&
        DateTime.now().hour == hour;

    return Container(
      height: hourHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        color: isCurrentHour 
          ? theme.primaryColor.withOpacity(0.05)
          : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.only(right: 8, top: 4),
            child: Text(
              _formatHour(hour),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isCurrentHour 
                  ? theme.primaryColor
                  : theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                fontWeight: isCurrentHour ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: theme.dividerColor.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlockWidget(TimeBlock block, ThemeData theme, TimeBlockProvider provider) {
    final startMinutes = (block.startTime.hour - startHour) * 60 + block.startTime.minute;
    final durationMinutes = block.duration.inMinutes;
    final top = (startMinutes / 60) * hourHeight;
    final height = (durationMinutes / 60) * hourHeight;

    return Positioned(
      top: top,
      left: 4,
      right: 4,
      height: height,
      child: Draggable<TimeBlock>(
        data: block,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 200,
            height: height,
            decoration: BoxDecoration(
              color: Color(block.color).withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildTimeBlockContent(block, theme, true),
          ),
        ),
        childWhenDragging: Container(
          decoration: BoxDecoration(
            color: Color(block.color).withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(block.color).withOpacity(0.5),
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: () => _showTimeBlockDetails(context, block, provider),
          child: Container(
            decoration: BoxDecoration(
              color: Color(block.color).withOpacity(block.isCompleted ? 0.6 : 0.9),
              borderRadius: BorderRadius.circular(8),
              border: block.isActive
                ? Border.all(color: Colors.white, width: 2)
                : null,
              boxShadow: block.isActive
                ? [
                    BoxShadow(
                      color: Color(block.color).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
            ),
            child: _buildTimeBlockContent(block, theme, false),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBlockContent(TimeBlock block, ThemeData theme, bool isDragging) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                block.type.icon,
                size: 16,
                color: isDragging ? Colors.white : Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  block.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDragging ? Colors.white : Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    decoration: block.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (block.isCompleted)
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: isDragging ? Colors.white : Colors.white.withOpacity(0.9),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            block.timeRange,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDragging ? Colors.white70 : Colors.white.withOpacity(0.7),
            ),
          ),
          if (block.description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              block.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDragging ? Colors.white70 : Colors.white.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentTimeIndicator(ThemeData theme) {
    final now = DateTime.now();
    final currentMinutes = (now.hour - startHour) * 60 + now.minute;
    final top = (currentMinutes / 60) * hourHeight;

    if (currentMinutes < 0 || currentMinutes > totalHours * 60) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: top,
      left: 60,
      right: 0,
      child: Container(
        height: 2,
        color: Colors.red,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context, TimeBlockProvider provider) async {
    final date = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      provider.setSelectedDate(date);
    }
  }

  void _showAddTimeBlockDialog(BuildContext context, TimeBlockProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AddTimeBlockDialog(
        selectedDate: provider.selectedDate,
        onAdd: (timeBlock) async {
          try {
            await provider.addTimeBlock(timeBlock);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Time block added successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showTimeBlockDetails(BuildContext context, TimeBlock block, TimeBlockProvider provider) {
    showDialog(
      context: context,
      builder: (context) => TimeBlockDetailsDialog(
        timeBlock: block,
        onUpdate: (updatedBlock) async {
          try {
            await provider.updateTimeBlock(updatedBlock);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Time block updated')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
        onDelete: () async {
          await provider.deleteTimeBlock(block.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Time block deleted')),
            );
          }
        },
        onToggleComplete: () async {
          await provider.toggleTimeBlockCompletion(block.id);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _getDayName(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }
}

// Add Time Block Dialog
class AddTimeBlockDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(TimeBlock) onAdd;

  const AddTimeBlockDialog({
    super.key,
    required this.selectedDate,
    required this.onAdd,
  });

  @override
  State<AddTimeBlockDialog> createState() => _AddTimeBlockDialogState();
}

class _AddTimeBlockDialogState extends State<AddTimeBlockDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();
  
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  TimeBlockType _selectedType = TimeBlockType.work;
  Color _selectedColor = TimeBlockType.work.defaultColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add Time Block'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TimeBlockType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: TimeBlockType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, size: 20),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    _selectedColor = value.defaultColor;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (time != null) {
                        setState(() {
                          _startTime = time;
                          // Auto-adjust end time to be 1 hour later
                          _endTime = TimeOfDay(
                            hour: (time.hour + 1) % 24,
                            minute: time.minute,
                          );
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (time != null) {
                        setState(() {
                          _endTime = time;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _titleController.text.isNotEmpty ? () {
            final timeBlock = TimeBlock(
              id: _uuid.v4(),
              title: _titleController.text,
              description: _descriptionController.text,
              date: widget.selectedDate,
              startTime: _startTime,
              endTime: _endTime,
              color: _selectedColor.value,
              type: _selectedType,
              createdAt: DateTime.now(),
            );
            
            widget.onAdd(timeBlock);
            Navigator.pop(context);
          } : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Time Block Details Dialog
class TimeBlockDetailsDialog extends StatefulWidget {
  final TimeBlock timeBlock;
  final Function(TimeBlock) onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;

  const TimeBlockDetailsDialog({
    super.key,
    required this.timeBlock,
    required this.onUpdate,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  State<TimeBlockDetailsDialog> createState() => _TimeBlockDetailsDialogState();
}

class _TimeBlockDetailsDialogState extends State<TimeBlockDetailsDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TimeBlockType _selectedType;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.timeBlock.title);
    _descriptionController = TextEditingController(text: widget.timeBlock.description);
    _startTime = widget.timeBlock.startTime;
    _endTime = widget.timeBlock.endTime;
    _selectedType = widget.timeBlock.type;
    _selectedColor = Color(widget.timeBlock.color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(widget.timeBlock.type.icon, color: Color(widget.timeBlock.color)),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.timeBlock.title)),
          IconButton(
            icon: Icon(
              widget.timeBlock.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: widget.timeBlock.isCompleted ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              widget.onToggleComplete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (time != null) {
                        setState(() {
                          _startTime = time;
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (time != null) {
                        setState(() {
                          _endTime = time;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Time Block'),
                content: const Text('Are you sure you want to delete this time block?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onDelete();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedBlock = widget.timeBlock.copyWith(
              title: _titleController.text,
              description: _descriptionController.text,
              startTime: _startTime,
              endTime: _endTime,
              type: _selectedType,
              color: _selectedColor.value,
            );
            
            widget.onUpdate(updatedBlock);
            Navigator.pop(context);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
