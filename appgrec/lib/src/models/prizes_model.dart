class PrizeModel {
  final int id;
  final String name;
  final String description;

  PrizeModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory PrizeModel.fromJson(Map<String, dynamic> json) {
    return PrizeModel(
      id: json['id'], 
      name: json['name'], 
      description: json['description'],
    );
  }
}
