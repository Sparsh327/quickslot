class VenueModel {
  final String id;
  final String name;
  final String description;
  final String sport;
  final String address;

  const VenueModel({
    required this.id,
    required this.name,
    required this.description,
    required this.sport,
    required this.address,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) => VenueModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        sport: json['sport'] as String,
        address: json['address'] as String,
      );
}
