import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wateera/components/wateera_app_bar.dart';
import 'package:wateera/providers/goal_provider.dart';
import 'package:wateera/models/goal_model.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _filterStatus = 'all'; // all, pending, completed
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final theme = Theme.of(context);
    
    // Filter goals based on status and search query
    final filteredGoals = goalProvider.goals.where((goal) {
      final matchesStatus = _filterStatus == 'all' ||
          (_filterStatus == 'completed' && goal.isCompleted) ||
          (_filterStatus == 'pending' && !goal.isCompleted);
      
      final matchesSearch = goal.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           goal.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesStatus && matchesSearch;
    }).toList();

    // Sort goals: pending first, then completed
    filteredGoals.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.endTime.compareTo(b.endTime);
    });

    return Scaffold(
      appBar: WateeraAppBar(
        title: _isSearching 
          ? TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search goals...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            )
          : const Text('My Goals'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('All Goals'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(Icons.pending, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Pending'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Completed'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCards(goalProvider, theme),
          Expanded(
            child: goalProvider.goals.isEmpty
                ? _buildEmptyState(theme)
                : _buildGoalsList(filteredGoals, theme),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildStatsCards(GoalProvider goalProvider, ThemeData theme) {
    final totalGoals = goalProvider.goals.length;
    final completedGoals = goalProvider.goals.where((goal) => goal.isCompleted).length;
    final pendingGoals = totalGoals - completedGoals;
    final overdue = goalProvider.goals.where((goal) => goal.isOverdue).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              totalGoals.toString(),
              Icons.flag,
              theme.primaryColor,
              theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pending',
              pendingGoals.toString(),
              Icons.pending,
              Colors.orange,
              theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Done',
              completedGoals.toString(),
              Icons.check_circle,
              Colors.green,
              theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Overdue',
              overdue.toString(),
              Icons.warning,
              Colors.red,
              theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag,
              size: 80,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Goals Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Set your first goal and start achieving',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(List<Goal> filteredGoals, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredGoals.length,
      itemBuilder: (context, index) {
        final goal = filteredGoals[index];
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildGoalCard(goal, theme),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGoalCard(Goal goal, ThemeData theme) {
    final cardColor = Color(goal.color);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: goal.isCompleted ? 1 : 4,
        borderRadius: BorderRadius.circular(20),
        color: cardColor.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showGoalDialog(context, goal: goal),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cardColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        goal.isCompleted ? Icons.check_circle : Icons.flag,
                        color: cardColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: goal.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                              color: goal.isCompleted 
                                ? theme.textTheme.bodyLarge?.color?.withOpacity(0.6)
                                : cardColor,
                            ),
                          ),
                          if (goal.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              goal.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: goal.priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: goal.priorityColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        goal.priority.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: goal.priorityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: goal.isOverdue ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatGoalDate(goal.endTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: goal.isOverdue ? Colors.red : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (goal.daysRemaining > 0 && !goal.isCompleted) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: goal.daysRemaining <= 3 
                            ? Colors.red.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${goal.daysRemaining} days left',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: goal.daysRemaining <= 3 ? Colors.red : Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else if (goal.isOverdue && !goal.isCompleted) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Overdue',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else if (goal.isCompleted) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Completed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Provider.of<GoalProvider>(context, listen: false)
                              .toggleGoalCompletion(goal.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goal.isCompleted 
                            ? Colors.grey.withOpacity(0.2)
                            : cardColor.withOpacity(0.1),
                          foregroundColor: goal.isCompleted ? Colors.grey : cardColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: goal.isCompleted 
                                ? Colors.grey.withOpacity(0.3)
                                : cardColor.withOpacity(0.3),
                            ),
                          ),
                        ),
                        icon: Icon(
                          goal.isCompleted ? Icons.undo : Icons.check,
                          size: 18,
                        ),
                        label: Text(
                          goal.isCompleted ? 'Mark Pending' : 'Mark Complete',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showGoalDialog(context, goal: goal);
                        } else if (value == 'delete') {
                          _showDeleteDialog(goal);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => _showGoalDialog(context),
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      label: const Text(
        'Add Goal',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      icon: const Icon(Icons.add),
    );
  }

  void _showGoalDialog(BuildContext context, {Goal? goal}) {
    final titleController = TextEditingController(text: goal?.title ?? '');
    final descriptionController = TextEditingController(text: goal?.description ?? '');
    DateTime selectedDate = goal?.endTime ?? DateTime.now().add(const Duration(days: 7));
    int selectedColor = goal?.color ?? 0xFF4CAF50;
    GoalPriority selectedPriority = goal?.priority ?? GoalPriority.medium;

    final colors = [
      0xFF4CAF50, // Green
      0xFF2196F3, // Blue
      0xFFFF9800, // Orange
      0xFFE91E63, // Pink
      0xFF9C27B0, // Purple
      0xFFFF5722, // Deep Orange
      0xFF607D8B, // Blue Grey
      0xFF795548, // Brown
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(goal == null ? 'Add Goal' : 'Edit Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Priority:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<GoalPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: GoalPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: priority == GoalPriority.high 
                            ? Colors.red 
                            : priority == GoalPriority.medium 
                              ? Colors.orange 
                              : Colors.green),
                          const SizedBox(width: 8),
                          Text(priority.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedPriority = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Color:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: selectedColor == color
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Due Date:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              selectedDate.hour,
                              selectedDate.minute,
                            );
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_formatGoalDate(selectedDate)),
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
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  if (goal == null) {
                    Provider.of<GoalProvider>(context, listen: false).addGoal(
                      titleController.text,
                      selectedDate,
                      description: descriptionController.text,
                      color: selectedColor,
                      priority: selectedPriority,
                    );
                  } else {
                    final updatedGoal = goal.copyWith(
                      title: titleController.text,
                      description: descriptionController.text,
                      endTime: selectedDate,
                      color: selectedColor,
                      priority: selectedPriority,
                    );
                    Provider.of<GoalProvider>(context, listen: false)
                        .updateGoal(updatedGoal);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(goal == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GoalProvider>(context, listen: false)
                  .deleteGoal(goal.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatGoalDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference <= 7) {
      return 'In ${difference} days';
    } else if (difference < -1 && difference >= -7) {
      return '${difference.abs()} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}