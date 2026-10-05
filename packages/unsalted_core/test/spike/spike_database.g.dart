// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spike_database.dart';

// ignore_for_file: type=lint
class $SpikeNotesTable extends SpikeNotes
    with TableInfo<$SpikeNotesTable, SpikeNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpikeNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, body];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spike_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpikeNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpikeNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpikeNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $SpikeNotesTable createAlias(String alias) {
    return $SpikeNotesTable(attachedDatabase, alias);
  }
}

class SpikeNote extends DataClass implements Insertable<SpikeNote> {
  final String id;
  final String body;
  const SpikeNote({required this.id, required this.body});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['body'] = Variable<String>(body);
    return map;
  }

  SpikeNotesCompanion toCompanion(bool nullToAbsent) {
    return SpikeNotesCompanion(id: Value(id), body: Value(body));
  }

  factory SpikeNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpikeNote(
      id: serializer.fromJson<String>(json['id']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'body': serializer.toJson<String>(body),
    };
  }

  SpikeNote copyWith({String? id, String? body}) =>
      SpikeNote(id: id ?? this.id, body: body ?? this.body);
  SpikeNote copyWithCompanion(SpikeNotesCompanion data) {
    return SpikeNote(
      id: data.id.present ? data.id.value : this.id,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpikeNote(')
          ..write('id: $id, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpikeNote && other.id == this.id && other.body == this.body);
}

class SpikeNotesCompanion extends UpdateCompanion<SpikeNote> {
  final Value<String> id;
  final Value<String> body;
  final Value<int> rowid;
  const SpikeNotesCompanion({
    this.id = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpikeNotesCompanion.insert({
    required String id,
    required String body,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       body = Value(body);
  static Insertable<SpikeNote> custom({
    Expression<String>? id,
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpikeNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? body,
    Value<int>? rowid,
  }) {
    return SpikeNotesCompanion(
      id: id ?? this.id,
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpikeNotesCompanion(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SpikeDatabase extends GeneratedDatabase {
  _$SpikeDatabase(QueryExecutor e) : super(e);
  $SpikeDatabaseManager get managers => $SpikeDatabaseManager(this);
  late final $SpikeNotesTable spikeNotes = $SpikeNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [spikeNotes];
}

typedef $$SpikeNotesTableCreateCompanionBuilder = SpikeNotesCompanion Function({
  required String id,
  required String body,
  Value<int> rowid,
});
typedef $$SpikeNotesTableUpdateCompanionBuilder = SpikeNotesCompanion Function({
  Value<String> id,
  Value<String> body,
  Value<int> rowid,
});

class $$SpikeNotesTableFilterComposer
    extends Composer<_$SpikeDatabase, $SpikeNotesTable> {
  $$SpikeNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpikeNotesTableOrderingComposer
    extends Composer<_$SpikeDatabase, $SpikeNotesTable> {
  $$SpikeNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpikeNotesTableAnnotationComposer
    extends Composer<_$SpikeDatabase, $SpikeNotesTable> {
  $$SpikeNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $$SpikeNotesTableTableManager
    extends
        RootTableManager<
          _$SpikeDatabase,
          $SpikeNotesTable,
          SpikeNote,
          $$SpikeNotesTableFilterComposer,
          $$SpikeNotesTableOrderingComposer,
          $$SpikeNotesTableAnnotationComposer,
          $$SpikeNotesTableCreateCompanionBuilder,
          $$SpikeNotesTableUpdateCompanionBuilder,
          (
            SpikeNote,
            BaseReferences<_$SpikeDatabase, $SpikeNotesTable, SpikeNote>,
          ),
          SpikeNote,
          PrefetchHooks Function()
        > {
  $$SpikeNotesTableTableManager(_$SpikeDatabase db, $SpikeNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpikeNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpikeNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpikeNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SpikeNotesCompanion(id: id, body: body, rowid: rowid),
          createCompanionCallback: ({
            required String id,
            required String body,
            Value<int> rowid = const Value.absent(),
          }) => SpikeNotesCompanion.insert(id: id, body: body, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpikeNotesTable, SpikeNote>(table),
                  BaseReferences<_$SpikeDatabase, $SpikeNotesTable, SpikeNote>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpikeNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$SpikeDatabase,
      $SpikeNotesTable,
      SpikeNote,
      $$SpikeNotesTableFilterComposer,
      $$SpikeNotesTableOrderingComposer,
      $$SpikeNotesTableAnnotationComposer,
      $$SpikeNotesTableCreateCompanionBuilder,
      $$SpikeNotesTableUpdateCompanionBuilder,
      (SpikeNote, BaseReferences<_$SpikeDatabase, $SpikeNotesTable, SpikeNote>),
      SpikeNote,
      PrefetchHooks Function()
    >;

class $SpikeDatabaseManager {
  final _$SpikeDatabase _db;
  $SpikeDatabaseManager(this._db);
  $$SpikeNotesTableTableManager get spikeNotes =>
      $$SpikeNotesTableTableManager(_db, _db.spikeNotes);
}
