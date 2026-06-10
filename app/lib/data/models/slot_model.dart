class SlotModel {
  final String id;
  final String venueId;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  const SlotModel({
    required this.id,
    required this.venueId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  bool get isAvailable => status == 'AVAILABLE';

  factory SlotModel.fromJson(Map<String, dynamic> json) => SlotModel(
        id: json['id'] as String,
        venueId: json['venueId'] as String,
        date: json['date'] as String,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
        status: json['status'] as String,
      );

  SlotModel copyWith({String? status}) => SlotModel(
        id: id,
        venueId: venueId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        status: status ?? this.status,
      );
}
