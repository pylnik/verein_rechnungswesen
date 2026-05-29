enum PaymentMethod { bar, konto }

enum TransactionType { expense, income, reimbursement }

class Transaction {
  final String id;
  final DateTime timestamp;
  final double amount;
  final String category;
  final PaymentMethod paymentMethod;
  final String notes;
  final String? pdfFile;
  final String? linkedGroup;
  final TransactionType type;
  final String? person;

  const Transaction({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.notes,
    this.pdfFile,
    this.linkedGroup,
    required this.type,
    this.person,
  });

  Transaction copyWith({
    String? id,
    DateTime? timestamp,
    double? amount,
    String? category,
    PaymentMethod? paymentMethod,
    String? notes,
    String? pdfFile,
    String? linkedGroup,
    TransactionType? type,
    String? person,
  }) {
    return Transaction(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      pdfFile: pdfFile ?? this.pdfFile,
      linkedGroup: linkedGroup ?? this.linkedGroup,
      type: type ?? this.type,
      person: person ?? this.person,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'amount': amount,
        'category': category,
        'paymentMethod': paymentMethod.name,
        'notes': notes,
        if (pdfFile != null) 'pdfFile': pdfFile,
        if (linkedGroup != null) 'linkedGroup': linkedGroup,
        'type': type.name,
        if (person != null) 'person': person,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        paymentMethod: PaymentMethod.values.byName(json['paymentMethod'] as String),
        notes: json['notes'] as String,
        pdfFile: json['pdfFile'] as String?,
        linkedGroup: json['linkedGroup'] as String?,
        type: TransactionType.values.byName(json['type'] as String),
        person: json['person'] as String?,
      );
}
