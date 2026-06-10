import 'venue_model.dart';

class BookingSlotModel {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final VenueModel venue;

  const BookingSlotModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.venue,
  });

  factory BookingSlotModel.fromJson(Map<String, dynamic> json) =>
      BookingSlotModel(
        id: json['id'] as String,
        date: json['date'] as String,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
        status: json['status'] as String,
        venue: VenueModel.fromJson(json['venue'] as Map<String, dynamic>),
      );
}

class BookingModel {
  final String id;
  final String createdAt;
  final BookingSlotModel slot;

  const BookingModel({
    required this.id,
    required this.createdAt,
    required this.slot,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id'] as String,
        createdAt: json['createdAt'] as String,
        slot: BookingSlotModel.fromJson(json['slot'] as Map<String, dynamic>),
      );
}
