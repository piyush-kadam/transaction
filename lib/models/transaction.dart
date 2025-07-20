class Transaction {
  final String id;
  final String title;
  final double amount;
  final String type; // "credit" or "debit"
  final String category;
  final DateTime date;

  var createdAt;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: double.parse(json['amount'].toString()),
      type: json['type'],
      category: json['category'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
    };
  }
}
