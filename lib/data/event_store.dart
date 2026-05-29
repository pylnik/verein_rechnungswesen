import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import '../models/transaction.dart';
import '../models/category.dart';
import '../models/group.dart';

const _fileName = 'events.jsonl';

enum EventType {
  transactionCreated,
  transactionUpdated,
  transactionDeleted,
  categoryCreated,
  categoryDeleted,
  groupCreated,
  groupUpdated,
}

class AppEvent {
  final EventType type;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  const AppEvent({
    required this.type,
    required this.timestamp,
    required this.payload,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'payload': payload,
      };

  factory AppEvent.fromJson(Map<String, dynamic> json) => AppEvent(
        type: EventType.values.byName(json['type'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        payload: json['payload'] as Map<String, dynamic>,
      );
}

class EventStore {
  final String baseDirectory;
  late final File _file;

  EventStore({required this.baseDirectory}) {
    _file = File(p.join(baseDirectory, _fileName));
  }

  /// Appends a single event to the JSONL file.
  Future<void> append(AppEvent event) async {
    await _file.parent.create(recursive: true);
    final line = '${jsonEncode(event.toJson())}\n';
    await _file.writeAsString(line, mode: FileMode.append, flush: true);
  }

  /// Reads all events from the JSONL file in order.
  Future<List<AppEvent>> readAll() async {
    if (!_file.existsSync()) return [];
    final lines = await _file.readAsLines();
    final events = <AppEvent>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      try {
        events.add(AppEvent.fromJson(jsonDecode(trimmed) as Map<String, dynamic>));
      } catch (_) {
        // Skip malformed lines (e.g. partial writes after a crash)
      }
    }
    return events;
  }

  // ── Convenience write helpers ──────────────────────────────────────────

  Future<void> addTransaction(Transaction t) => append(AppEvent(
        type: EventType.transactionCreated,
        timestamp: DateTime.now(),
        payload: t.toJson(),
      ));

  Future<void> updateTransaction(Transaction t) => append(AppEvent(
        type: EventType.transactionUpdated,
        timestamp: DateTime.now(),
        payload: t.toJson(),
      ));

  Future<void> deleteTransaction(String id) => append(AppEvent(
        type: EventType.transactionDeleted,
        timestamp: DateTime.now(),
        payload: {'id': id},
      ));

  Future<void> addCategory(Category c) => append(AppEvent(
        type: EventType.categoryCreated,
        timestamp: DateTime.now(),
        payload: c.toJson(),
      ));

  Future<void> deleteCategory(String id) => append(AppEvent(
        type: EventType.categoryDeleted,
        timestamp: DateTime.now(),
        payload: {'id': id},
      ));

  Future<void> addGroup(Group g) => append(AppEvent(
        type: EventType.groupCreated,
        timestamp: DateTime.now(),
        payload: g.toJson(),
      ));

  Future<void> updateGroup(Group g) => append(AppEvent(
        type: EventType.groupUpdated,
        timestamp: DateTime.now(),
        payload: g.toJson(),
      ));
}
