class CountryItem {
  final int id;
  final String name;
  final String slug;
  CountryItem({required this.id, required this.name, required this.slug});
  factory CountryItem.fromJson(Map<String, dynamic> j) {
    return CountryItem(
      id: int.tryParse(j['id']?.toString() ?? '') ?? (j['id'] as int? ?? 0),
      name: (j['name'] ?? '').toString(),
      slug: (j['slug'] ?? '').toString(),
    );
  }
}

class StateItem {
  final int id;
  final int countryId;
  final String name;
  final String slug;
  StateItem({required this.id, required this.countryId, required this.name, required this.slug});
  factory StateItem.fromJson(Map<String, dynamic> j) {
    int parseInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
    return StateItem(
      id: parseInt(j['id']),
      countryId: parseInt(j['country_id']),
      name: (j['name'] ?? '').toString(),
      slug: (j['slug'] ?? '').toString(),
    );
  }
}

class CityItem {
  final int id;
  final int countryId;
  final int stateId;
  final String name;
  final String slug;
  CityItem({required this.id, required this.countryId, required this.stateId, required this.name, required this.slug});
  factory CityItem.fromJson(Map<String, dynamic> j) {
    int parseInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
    return CityItem(
      id: parseInt(j['id']),
      countryId: parseInt(j['country_id']),
      stateId: parseInt(j['state_id']),
      name: (j['name'] ?? '').toString(),
      slug: (j['slug'] ?? '').toString(),
    );
  }
}

