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
      id: json['id'], // <- protección contra null // Asegúrate de que el campo sea un int // Aquí asumimos que 'id' siempre estará presente
      name: json['name'], // Asumimos que 'name' siempre estará presente
      description: json['description'], // Asumimos que 'description' siempre estará presente
    );
  }
}
