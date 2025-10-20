import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 2)
class Goal {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    required this.endTime,
    this.isCompleted = false,
  });
}
