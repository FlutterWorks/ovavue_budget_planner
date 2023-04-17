class UpdateBudgetData {
  const UpdateBudgetData({
    required this.id,
    required this.path,
    required this.title,
    required this.amount,
    required this.description,
    required this.endedAt,
  });

  final String id;
  final String path;
  final String title;
  final int amount;
  final String description;
  final DateTime? endedAt;
}
