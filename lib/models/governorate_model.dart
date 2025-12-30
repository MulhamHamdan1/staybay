class Governorate {
  final int id;
  final String name;

  Governorate({required this.id, required this.name});

  factory Governorate.fromJson(Map<String, dynamic> json) {
    return Governorate(id: json['id'], name: json['name']);
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Governorate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
