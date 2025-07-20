import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  final String baseUrl =
      'https://687c7714918b6422432e211d.mockapi.io/api/transactions';

  List<Transaction> get transactions => _transactions;

  Future<void> fetchTransactions() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List jsonData = json.decode(response.body);
        _transactions =
            jsonData.map((e) => Transaction.fromJson(e)).toList()
              ..sort((a, b) => b.date.compareTo(a.date)); // Sort newest first
        notifyListeners();
      } else {
        print('Failed to fetch data');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaction.toJson()),
    );
    if (response.statusCode == 201) {
      final newTx = Transaction.fromJson(json.decode(response.body));
      _transactions.insert(0, newTx);
      notifyListeners();
    }
  }
}
