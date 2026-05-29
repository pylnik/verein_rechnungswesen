import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/transaction.dart';
import '../models/category.dart';
import '../models/group.dart';
import 'event_store.dart';

class AppState {
  final EventStore _store;

  final Map<String, Transaction> _transactions = {};
  final Map<String, Category> _categories = {};
  final Map<String, Group> _groups = {};

  AppState({required EventStore store}) : _store = store;

  // ── Public read-only views ─────────────────────────────────────────────

  /// All transactions, newest first.
  List<Transaction> get transactions {
    final list = _transactions.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<Category> get categories => List.unmodifiable(_categories.values);

  List<Group> get groups => List.unmodifiable(_groups.values);

  // ── Initialisation ─────────────────────────────────────────────────────

  /// Loads default categories from the bundled asset if the store is empty.
  Future<void> init() async {
    final events = await _store.readAll();
    if (events.isEmpty) {
      await _seedDefaultCategories();
    }
    _replay(events);
  }

  Future<void> _seedDefaultCategories() async {
    final raw = await rootBundle.loadString('assets/categories.json');
    final names = (jsonDecode(raw) as List<dynamic>).cast<String>();
    for (final name in names) {
      final cat = Category(id: name.toLowerCase().replaceAll(' ', '_'), name: name);
      await _store.addCategory(cat);
    }
  }

  void _replay(List<AppEvent> events) {
    for (final event in events) {
      _apply(event);
    }
  }

  void _apply(AppEvent event) {
    switch (event.type) {
      case EventType.transactionCreated:
        final t = Transaction.fromJson(event.payload);
        _transactions[t.id] = t;
      case EventType.transactionUpdated:
        final t = Transaction.fromJson(event.payload);
        _transactions[t.id] = t;
      case EventType.transactionDeleted:
        _transactions.remove(event.payload['id'] as String);
      case EventType.categoryCreated:
        final c = Category.fromJson(event.payload);
        _categories[c.id] = c;
      case EventType.categoryDeleted:
        _categories.remove(event.payload['id'] as String);
      case EventType.groupCreated:
        final g = Group.fromJson(event.payload);
        _groups[g.id] = g;
      case EventType.groupUpdated:
        final g = Group.fromJson(event.payload);
        _groups[g.id] = g;
    }
  }

  // ── Mutation helpers (write + apply) ───────────────────────────────────

  Future<void> addTransaction(Transaction t) async {
    await _store.addTransaction(t);
    _transactions[t.id] = t;
  }

  Future<void> updateTransaction(Transaction t) async {
    await _store.updateTransaction(t);
    _transactions[t.id] = t;
  }

  Future<void> deleteTransaction(String id) async {
    await _store.deleteTransaction(id);
    _transactions.remove(id);
  }

  Future<void> addCategory(Category c) async {
    await _store.addCategory(c);
    _categories[c.id] = c;
  }

  Future<void> deleteCategory(String id) async {
    await _store.deleteCategory(id);
    _categories.remove(id);
  }

  Future<void> addGroup(Group g) async {
    await _store.addGroup(g);
    _groups[g.id] = g;
  }

  Future<void> updateGroup(Group g) async {
    await _store.updateGroup(g);
    _groups[g.id] = g;
  }
}
