class HistoryModel {
  final int id;
  final String status;
  final String date;
  final double total;

  HistoryModel({
    required this.id,
    required this.status,
    required this.date,
    required this.total,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      status: json['status'] ?? 'Pending',
      date: json['created_at'] ?? '',
      total: double.parse(json['total_price'].toString()),
    );
  }
}
