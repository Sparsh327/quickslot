class UserModel {
  final String id;
  final String name;

  const UserModel({required this.id, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}
