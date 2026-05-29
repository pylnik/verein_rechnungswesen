class Group {
  final String id;
  final String name;
  final List<String> transactions;

  const Group({
    required this.id,
    required this.name,
    this.transactions = const [],
  });

  Group copyWith({String? id, String? name, List<String>? transactions}) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      transactions: transactions ?? this.transactions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'transactions': transactions,
      };

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as String,
        name: json['name'] as String,
        transactions: (json['transactions'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
      );
}
