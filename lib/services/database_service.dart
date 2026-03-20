import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/daily_entry.dart';

/// Manages all SQLite persistence for daily entries.
///
/// Tables
/// ──────
/// daily_entries  – one row per calendar day
/// entry_values   – per-category numeric values (FK → daily_entries)
/// entry_tags     – user-mentioned tags (FK → daily_entries)
class DatabaseService {
  static const _dbName = 'leichtgesagt.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE daily_entries (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            date           TEXT    NOT NULL UNIQUE,
            transcript     TEXT,
            is_standard_tag INTEGER NOT NULL DEFAULT 0,
            is_skipped     INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE entry_values (
            id       INTEGER PRIMARY KEY AUTOINCREMENT,
            entry_id INTEGER NOT NULL REFERENCES daily_entries(id) ON DELETE CASCADE,
            category TEXT    NOT NULL,
            value    REAL    NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE entry_tags (
            id       INTEGER PRIMARY KEY AUTOINCREMENT,
            entry_id INTEGER NOT NULL REFERENCES daily_entries(id) ON DELETE CASCADE,
            tag      TEXT    NOT NULL
          )
        ''');
      },
    );
  }

  // ─── Write ──────────────────────────────────────────────────────────────────

  /// Upserts a [DailyEntry] (one entry per calendar day).
  /// If a row for the same date already exists it is replaced.
  Future<int> saveEntry(DailyEntry entry) async {
    final db = await _database;
    final dateKey = entry.dateKey;

    return db.transaction((txn) async {
      // Upsert the parent row
      final existing = await txn.query(
        'daily_entries',
        where: 'date = ?',
        whereArgs: [dateKey],
        limit: 1,
      );

      final int entryId;
      if (existing.isEmpty) {
        entryId = await txn.insert('daily_entries', {
          'date': dateKey,
          'transcript': entry.transcript,
          'is_standard_tag': entry.isStandardTag ? 1 : 0,
          'is_skipped': entry.isSkipped ? 1 : 0,
        });
      } else {
        entryId = existing.first['id'] as int;
        await txn.update(
          'daily_entries',
          {
            'transcript': entry.transcript,
            'is_standard_tag': entry.isStandardTag ? 1 : 0,
            'is_skipped': entry.isSkipped ? 1 : 0,
          },
          where: 'id = ?',
          whereArgs: [entryId],
        );
        // Delete child rows so we can re-insert cleanly
        await txn
            .delete('entry_values', where: 'entry_id = ?', whereArgs: [entryId]);
        await txn
            .delete('entry_tags', where: 'entry_id = ?', whereArgs: [entryId]);
      }

      // Insert values
      for (final kv in entry.values.entries) {
        await txn.insert('entry_values', {
          'entry_id': entryId,
          'category': kv.key,
          'value': kv.value,
        });
      }

      // Insert tags
      for (final tag in entry.tags) {
        await txn.insert('entry_tags', {
          'entry_id': entryId,
          'tag': tag,
        });
      }

      return entryId;
    });
  }

  // ─── Read ───────────────────────────────────────────────────────────────────

  /// Returns the entry for a given calendar day, or null if none exists.
  Future<DailyEntry?> getEntry(DateTime date) async {
    final db = await _database;
    final dateKey = DailyEntry.normaliseDate(date);
    final key =
        '${dateKey.year.toString().padLeft(4, '0')}-'
        '${dateKey.month.toString().padLeft(2, '0')}-'
        '${dateKey.day.toString().padLeft(2, '0')}';

    final rows = await db.query(
      'daily_entries',
      where: 'date = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _buildEntry(db, rows.first);
  }

  /// Returns all entries within [from]..[to] (inclusive), oldest-first.
  Future<List<DailyEntry>> getEntriesRange(
      DateTime from, DateTime to) async {
    final db = await _database;
    final fromKey = _dateKey(from);
    final toKey = _dateKey(to);

    final rows = await db.query(
      'daily_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [fromKey, toKey],
      orderBy: 'date ASC',
    );
    return Future.wait(rows.map((r) => _buildEntry(db, r)));
  }

  /// Returns all entries in the database, oldest-first.
  Future<List<DailyEntry>> getAllEntries() async {
    final db = await _database;
    final rows =
        await db.query('daily_entries', orderBy: 'date ASC');
    return Future.wait(rows.map((r) => _buildEntry(db, r)));
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Future<DailyEntry> _buildEntry(
      Database db, Map<String, Object?> row) async {
    final id = row['id'] as int;
    final dateStr = row['date'] as String;
    final parts = dateStr.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    final valueRows = await db.query(
      'entry_values',
      where: 'entry_id = ?',
      whereArgs: [id],
    );
    final values = {
      for (final v in valueRows) v['category'] as String: v['value'] as double
    };

    final tagRows = await db.query(
      'entry_tags',
      where: 'entry_id = ?',
      whereArgs: [id],
    );
    final tags = tagRows.map((t) => t['tag'] as String).toList();

    return DailyEntry(
      id: id,
      date: date,
      values: values,
      tags: tags,
      transcript: row['transcript'] as String?,
      isStandardTag: (row['is_standard_tag'] as int) == 1,
      isSkipped: (row['is_skipped'] as int) == 1,
    );
  }

  String _dateKey(DateTime dt) {
    final d = DailyEntry.normaliseDate(dt);
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}
