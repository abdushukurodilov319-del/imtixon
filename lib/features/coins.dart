import 'package:flutter/material.dart';

class CoinTransaction {
  final String id;
  final String studentName;
  final int amount;
  final String reason;
  final DateTime date;

  CoinTransaction({required this.id, required this.studentName, required this.amount, required this.reason, required this.date});
}

class CoinsDashboard extends StatelessWidget {
  const CoinsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      CoinTransaction(id: '1', studentName: 'Ali Valiev', amount: 50, reason: 'Darsdagi faollik', date: DateTime.now()),
      CoinTransaction(id: '2', studentName: 'Olim Toshov', amount: 100, reason: 'Uy vazifasi', date: DateTime.now()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Coin Tranzaksiyalari')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.monetization_on, color: Colors.white)),
              title: Text(tx.studentName),
              subtitle: Text(tx.reason),
              trailing: Text('+${tx.amount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
            ),
          );
        },
      ),
    );
  }
}
