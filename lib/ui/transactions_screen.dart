import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_state.dart';
import '../models/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  final AppState appState;
  const TransactionsScreen({super.key, required this.appState});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  static final _dateFmt = DateFormat('dd.MM.yyyy');
  static final _currencyFmt = NumberFormat.currency(locale: 'de_DE', symbol: '€');

  List<Transaction> get _transactions => widget.appState.transactions;

  Color _amountColor(Transaction t) {
    return t.amount >= 0 ? Colors.green.shade700 : Colors.red.shade700;
  }

  String _typeLabel(TransactionType type) => switch (type) {
        TransactionType.income => 'Einnahme',
        TransactionType.expense => 'Ausgabe',
        TransactionType.reimbursement => 'Erstattung',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Übersicht'),
        centerTitle: false,
      ),
      body: _transactions.isEmpty
          ? const Center(child: Text('Keine Buchungen vorhanden.'))
          : ListView.separated(
              itemCount: _transactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = _transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _amountColor(t).withOpacity(0.15),
                    child: Icon(
                      t.amount >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: _amountColor(t),
                    ),
                  ),
                  title: Text(t.category),
                  subtitle: Text(
                    '${_dateFmt.format(t.timestamp)}  ·  '
                    '${_typeLabel(t.type)}  ·  '
                    '${t.paymentMethod.name.toUpperCase()}'
                    '${t.notes.isNotEmpty ? '\n${t.notes}' : ''}',
                  ),
                  isThreeLine: t.notes.isNotEmpty,
                  trailing: Text(
                    _currencyFmt.format(t.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _amountColor(t),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
