// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_database.dart';

// ignore_for_file: type=lint
class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _masterVersionIdMeta = const VerificationMeta(
    'masterVersionId',
  );
  @override
  late final GeneratedColumn<String> masterVersionId = GeneratedColumn<String>(
    'master_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    title,
    description,
    masterVersionId,
    ownerId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('master_version_id')) {
      context.handle(
        _masterVersionIdMeta,
        masterVersionId.isAcceptableOrUnknown(
          data['master_version_id']!,
          _masterVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      masterVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}master_version_id'],
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String title;
  final String? description;

  /// Weicher Verweis; muss auf eine Version mit state = snapshot zeigen
  /// (fachlich erzwungen im Repository, nicht per Fremdschlüssel — R3).
  final String? masterVersionId;

  /// null bis Teil 3 assignOwner ruft (Kapitel 10.3, 16.1).
  final String? ownerId;
  const Recipe({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.title,
    this.description,
    this.masterVersionId,
    this.ownerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || masterVersionId != null) {
      map['master_version_id'] = Variable<String>(masterVersionId);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      masterVersionId: masterVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(masterVersionId),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
    );
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      masterVersionId: serializer.fromJson<String?>(json['masterVersionId']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'masterVersionId': serializer.toJson<String?>(masterVersionId),
      'ownerId': serializer.toJson<String?>(ownerId),
    };
  }

  Recipe copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> masterVersionId = const Value.absent(),
    Value<String?> ownerId = const Value.absent(),
  }) => Recipe(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    masterVersionId: masterVersionId.present
        ? masterVersionId.value
        : this.masterVersionId,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
  );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      masterVersionId: data.masterVersionId.present
          ? data.masterVersionId.value
          : this.masterVersionId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('masterVersionId: $masterVersionId, ')
          ..write('ownerId: $ownerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    title,
    description,
    masterVersionId,
    ownerId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.title == this.title &&
          other.description == this.description &&
          other.masterVersionId == this.masterVersionId &&
          other.ownerId == this.ownerId);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> masterVersionId;
  final Value<String?> ownerId;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.masterVersionId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.masterVersionId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title);
  static Insertable<Recipe> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? masterVersionId,
    Expression<String>? ownerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (masterVersionId != null) 'master_version_id': masterVersionId,
      if (ownerId != null) 'owner_id': ownerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? masterVersionId,
    Value<String?>? ownerId,
    Value<int>? rowid,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      masterVersionId: masterVersionId ?? this.masterVersionId,
      ownerId: ownerId ?? this.ownerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (masterVersionId.present) {
      map['master_version_id'] = Variable<String>(masterVersionId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('masterVersionId: $masterVersionId, ')
          ..write('ownerId: $ownerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeVersionsTable extends RecipeVersions
    with TableInfo<$RecipeVersionsTable, RecipeVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentVersionIdMeta = const VerificationMeta(
    'parentVersionId',
  );
  @override
  late final GeneratedColumn<String> parentVersionId = GeneratedColumn<String>(
    'parent_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionIndexMeta = const VerificationMeta(
    'versionIndex',
  );
  @override
  late final GeneratedColumn<int> versionIndex = GeneratedColumn<int>(
    'version_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<int> servings = GeneratedColumn<int>(
    'servings',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String>
  bakingLossPercent = GeneratedColumn<String>(
    'baking_loss_percent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  ).withConverter<Decimal>($RecipeVersionsTable.$converterbakingLossPercent);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String>
  finalWeightOverrideG =
      GeneratedColumn<String>(
        'final_weight_override_g',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>(
        $RecipeVersionsTable.$converterfinalWeightOverrideGn,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snapshotJsonMeta = const VerificationMeta(
    'snapshotJson',
  );
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
    'snapshot_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snapshotFormatVersionMeta =
      const VerificationMeta('snapshotFormatVersion');
  @override
  late final GeneratedColumn<int> snapshotFormatVersion = GeneratedColumn<int>(
    'snapshot_format_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snapshottedAtMeta = const VerificationMeta(
    'snapshottedAt',
  );
  @override
  late final GeneratedColumn<int> snapshottedAt = GeneratedColumn<int>(
    'snapshotted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    recipeId,
    parentVersionId,
    versionIndex,
    label,
    state,
    servings,
    bakingLossPercent,
    finalWeightOverrideG,
    notes,
    snapshotJson,
    snapshotFormatVersion,
    snapshottedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeVersion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('parent_version_id')) {
      context.handle(
        _parentVersionIdMeta,
        parentVersionId.isAcceptableOrUnknown(
          data['parent_version_id']!,
          _parentVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('version_index')) {
      context.handle(
        _versionIndexMeta,
        versionIndex.isAcceptableOrUnknown(
          data['version_index']!,
          _versionIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versionIndexMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
        _snapshotJsonMeta,
        snapshotJson.isAcceptableOrUnknown(
          data['snapshot_json']!,
          _snapshotJsonMeta,
        ),
      );
    }
    if (data.containsKey('snapshot_format_version')) {
      context.handle(
        _snapshotFormatVersionMeta,
        snapshotFormatVersion.isAcceptableOrUnknown(
          data['snapshot_format_version']!,
          _snapshotFormatVersionMeta,
        ),
      );
    }
    if (data.containsKey('snapshotted_at')) {
      context.handle(
        _snapshottedAtMeta,
        snapshottedAt.isAcceptableOrUnknown(
          data['snapshotted_at']!,
          _snapshottedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeVersion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      parentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_version_id'],
      ),
      versionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_index'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}servings'],
      ),
      bakingLossPercent: $RecipeVersionsTable.$converterbakingLossPercent
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}baking_loss_percent'],
            )!,
          ),
      finalWeightOverrideG: $RecipeVersionsTable.$converterfinalWeightOverrideGn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}final_weight_override_g'],
            ),
          ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      snapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_json'],
      ),
      snapshotFormatVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snapshot_format_version'],
      ),
      snapshottedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snapshotted_at'],
      ),
    );
  }

  @override
  $RecipeVersionsTable createAlias(String alias) {
    return $RecipeVersionsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterbakingLossPercent =
      const DecimalConverter();
  static TypeConverter<Decimal, String> $converterfinalWeightOverrideG =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $converterfinalWeightOverrideGn =
      NullAwareTypeConverter.wrap($converterfinalWeightOverrideG);
}

class RecipeVersion extends DataClass implements Insertable<RecipeVersion> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String recipeId;

  /// Darf auf eine lokal unbekannte Version zeigen (Import/Fork, Kapitel 12.1).
  final String? parentVersionId;

  /// Fortlaufend pro Rezept ab 1, vom Repository vergeben (Kapitel 10.4).
  final int versionIndex;
  final String? label;

  /// 'draft' | 'snapshot' (Kapitel 10.8).
  final String state;

  /// null oder >= 1 (Kapitel 8.5, 10.4).
  final int? servings;

  /// 0..100, Standard 0.
  final Decimal bakingLossPercent;

  /// > 0 oder null; hat Vorrang vor bakingLossPercent (Kapitel 8.5).
  final Decimal? finalWeightOverrideG;
  final String? notes;

  /// Nur bei state = snapshot gesetzt (Kapitel 10.8). Enthält das
  /// vollständige Snapshot-JSON unverändert (Kapitel 13.6/13.7) — Zugriff
  /// ausschließlich über SnapshotService/SnapshotCodec, niemals als
  /// Rohstring im Fachmodell (Kapitel 10.4).
  final String? snapshotJson;

  /// Nur bei state = snapshot gesetzt, aktuell 1.
  final int? snapshotFormatVersion;

  /// Nur bei state = snapshot gesetzt.
  final int? snapshottedAt;
  const RecipeVersion({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.recipeId,
    this.parentVersionId,
    required this.versionIndex,
    this.label,
    required this.state,
    this.servings,
    required this.bakingLossPercent,
    this.finalWeightOverrideG,
    this.notes,
    this.snapshotJson,
    this.snapshotFormatVersion,
    this.snapshottedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['recipe_id'] = Variable<String>(recipeId);
    if (!nullToAbsent || parentVersionId != null) {
      map['parent_version_id'] = Variable<String>(parentVersionId);
    }
    map['version_index'] = Variable<int>(versionIndex);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || servings != null) {
      map['servings'] = Variable<int>(servings);
    }
    {
      map['baking_loss_percent'] = Variable<String>(
        $RecipeVersionsTable.$converterbakingLossPercent.toSql(
          bakingLossPercent,
        ),
      );
    }
    if (!nullToAbsent || finalWeightOverrideG != null) {
      map['final_weight_override_g'] = Variable<String>(
        $RecipeVersionsTable.$converterfinalWeightOverrideGn.toSql(
          finalWeightOverrideG,
        ),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || snapshotJson != null) {
      map['snapshot_json'] = Variable<String>(snapshotJson);
    }
    if (!nullToAbsent || snapshotFormatVersion != null) {
      map['snapshot_format_version'] = Variable<int>(snapshotFormatVersion);
    }
    if (!nullToAbsent || snapshottedAt != null) {
      map['snapshotted_at'] = Variable<int>(snapshottedAt);
    }
    return map;
  }

  RecipeVersionsCompanion toCompanion(bool nullToAbsent) {
    return RecipeVersionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      recipeId: Value(recipeId),
      parentVersionId: parentVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentVersionId),
      versionIndex: Value(versionIndex),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      state: Value(state),
      servings: servings == null && nullToAbsent
          ? const Value.absent()
          : Value(servings),
      bakingLossPercent: Value(bakingLossPercent),
      finalWeightOverrideG: finalWeightOverrideG == null && nullToAbsent
          ? const Value.absent()
          : Value(finalWeightOverrideG),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      snapshotJson: snapshotJson == null && nullToAbsent
          ? const Value.absent()
          : Value(snapshotJson),
      snapshotFormatVersion: snapshotFormatVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(snapshotFormatVersion),
      snapshottedAt: snapshottedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(snapshottedAt),
    );
  }

  factory RecipeVersion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeVersion(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      parentVersionId: serializer.fromJson<String?>(json['parentVersionId']),
      versionIndex: serializer.fromJson<int>(json['versionIndex']),
      label: serializer.fromJson<String?>(json['label']),
      state: serializer.fromJson<String>(json['state']),
      servings: serializer.fromJson<int?>(json['servings']),
      bakingLossPercent: serializer.fromJson<Decimal>(
        json['bakingLossPercent'],
      ),
      finalWeightOverrideG: serializer.fromJson<Decimal?>(
        json['finalWeightOverrideG'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      snapshotJson: serializer.fromJson<String?>(json['snapshotJson']),
      snapshotFormatVersion: serializer.fromJson<int?>(
        json['snapshotFormatVersion'],
      ),
      snapshottedAt: serializer.fromJson<int?>(json['snapshottedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'recipeId': serializer.toJson<String>(recipeId),
      'parentVersionId': serializer.toJson<String?>(parentVersionId),
      'versionIndex': serializer.toJson<int>(versionIndex),
      'label': serializer.toJson<String?>(label),
      'state': serializer.toJson<String>(state),
      'servings': serializer.toJson<int?>(servings),
      'bakingLossPercent': serializer.toJson<Decimal>(bakingLossPercent),
      'finalWeightOverrideG': serializer.toJson<Decimal?>(finalWeightOverrideG),
      'notes': serializer.toJson<String?>(notes),
      'snapshotJson': serializer.toJson<String?>(snapshotJson),
      'snapshotFormatVersion': serializer.toJson<int?>(snapshotFormatVersion),
      'snapshottedAt': serializer.toJson<int?>(snapshottedAt),
    };
  }

  RecipeVersion copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? recipeId,
    Value<String?> parentVersionId = const Value.absent(),
    int? versionIndex,
    Value<String?> label = const Value.absent(),
    String? state,
    Value<int?> servings = const Value.absent(),
    Decimal? bakingLossPercent,
    Value<Decimal?> finalWeightOverrideG = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> snapshotJson = const Value.absent(),
    Value<int?> snapshotFormatVersion = const Value.absent(),
    Value<int?> snapshottedAt = const Value.absent(),
  }) => RecipeVersion(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    recipeId: recipeId ?? this.recipeId,
    parentVersionId: parentVersionId.present
        ? parentVersionId.value
        : this.parentVersionId,
    versionIndex: versionIndex ?? this.versionIndex,
    label: label.present ? label.value : this.label,
    state: state ?? this.state,
    servings: servings.present ? servings.value : this.servings,
    bakingLossPercent: bakingLossPercent ?? this.bakingLossPercent,
    finalWeightOverrideG: finalWeightOverrideG.present
        ? finalWeightOverrideG.value
        : this.finalWeightOverrideG,
    notes: notes.present ? notes.value : this.notes,
    snapshotJson: snapshotJson.present ? snapshotJson.value : this.snapshotJson,
    snapshotFormatVersion: snapshotFormatVersion.present
        ? snapshotFormatVersion.value
        : this.snapshotFormatVersion,
    snapshottedAt: snapshottedAt.present
        ? snapshottedAt.value
        : this.snapshottedAt,
  );
  RecipeVersion copyWithCompanion(RecipeVersionsCompanion data) {
    return RecipeVersion(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      parentVersionId: data.parentVersionId.present
          ? data.parentVersionId.value
          : this.parentVersionId,
      versionIndex: data.versionIndex.present
          ? data.versionIndex.value
          : this.versionIndex,
      label: data.label.present ? data.label.value : this.label,
      state: data.state.present ? data.state.value : this.state,
      servings: data.servings.present ? data.servings.value : this.servings,
      bakingLossPercent: data.bakingLossPercent.present
          ? data.bakingLossPercent.value
          : this.bakingLossPercent,
      finalWeightOverrideG: data.finalWeightOverrideG.present
          ? data.finalWeightOverrideG.value
          : this.finalWeightOverrideG,
      notes: data.notes.present ? data.notes.value : this.notes,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
      snapshotFormatVersion: data.snapshotFormatVersion.present
          ? data.snapshotFormatVersion.value
          : this.snapshotFormatVersion,
      snapshottedAt: data.snapshottedAt.present
          ? data.snapshottedAt.value
          : this.snapshottedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeVersion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('recipeId: $recipeId, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('versionIndex: $versionIndex, ')
          ..write('label: $label, ')
          ..write('state: $state, ')
          ..write('servings: $servings, ')
          ..write('bakingLossPercent: $bakingLossPercent, ')
          ..write('finalWeightOverrideG: $finalWeightOverrideG, ')
          ..write('notes: $notes, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('snapshotFormatVersion: $snapshotFormatVersion, ')
          ..write('snapshottedAt: $snapshottedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    recipeId,
    parentVersionId,
    versionIndex,
    label,
    state,
    servings,
    bakingLossPercent,
    finalWeightOverrideG,
    notes,
    snapshotJson,
    snapshotFormatVersion,
    snapshottedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeVersion &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.recipeId == this.recipeId &&
          other.parentVersionId == this.parentVersionId &&
          other.versionIndex == this.versionIndex &&
          other.label == this.label &&
          other.state == this.state &&
          other.servings == this.servings &&
          other.bakingLossPercent == this.bakingLossPercent &&
          other.finalWeightOverrideG == this.finalWeightOverrideG &&
          other.notes == this.notes &&
          other.snapshotJson == this.snapshotJson &&
          other.snapshotFormatVersion == this.snapshotFormatVersion &&
          other.snapshottedAt == this.snapshottedAt);
}

class RecipeVersionsCompanion extends UpdateCompanion<RecipeVersion> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> recipeId;
  final Value<String?> parentVersionId;
  final Value<int> versionIndex;
  final Value<String?> label;
  final Value<String> state;
  final Value<int?> servings;
  final Value<Decimal> bakingLossPercent;
  final Value<Decimal?> finalWeightOverrideG;
  final Value<String?> notes;
  final Value<String?> snapshotJson;
  final Value<int?> snapshotFormatVersion;
  final Value<int?> snapshottedAt;
  final Value<int> rowid;
  const RecipeVersionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.parentVersionId = const Value.absent(),
    this.versionIndex = const Value.absent(),
    this.label = const Value.absent(),
    this.state = const Value.absent(),
    this.servings = const Value.absent(),
    this.bakingLossPercent = const Value.absent(),
    this.finalWeightOverrideG = const Value.absent(),
    this.notes = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.snapshotFormatVersion = const Value.absent(),
    this.snapshottedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeVersionsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String recipeId,
    this.parentVersionId = const Value.absent(),
    required int versionIndex,
    this.label = const Value.absent(),
    required String state,
    this.servings = const Value.absent(),
    this.bakingLossPercent = const Value.absent(),
    this.finalWeightOverrideG = const Value.absent(),
    this.notes = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.snapshotFormatVersion = const Value.absent(),
    this.snapshottedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       recipeId = Value(recipeId),
       versionIndex = Value(versionIndex),
       state = Value(state);
  static Insertable<RecipeVersion> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? recipeId,
    Expression<String>? parentVersionId,
    Expression<int>? versionIndex,
    Expression<String>? label,
    Expression<String>? state,
    Expression<int>? servings,
    Expression<String>? bakingLossPercent,
    Expression<String>? finalWeightOverrideG,
    Expression<String>? notes,
    Expression<String>? snapshotJson,
    Expression<int>? snapshotFormatVersion,
    Expression<int>? snapshottedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (recipeId != null) 'recipe_id': recipeId,
      if (parentVersionId != null) 'parent_version_id': parentVersionId,
      if (versionIndex != null) 'version_index': versionIndex,
      if (label != null) 'label': label,
      if (state != null) 'state': state,
      if (servings != null) 'servings': servings,
      if (bakingLossPercent != null) 'baking_loss_percent': bakingLossPercent,
      if (finalWeightOverrideG != null)
        'final_weight_override_g': finalWeightOverrideG,
      if (notes != null) 'notes': notes,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (snapshotFormatVersion != null)
        'snapshot_format_version': snapshotFormatVersion,
      if (snapshottedAt != null) 'snapshotted_at': snapshottedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeVersionsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? recipeId,
    Value<String?>? parentVersionId,
    Value<int>? versionIndex,
    Value<String?>? label,
    Value<String>? state,
    Value<int?>? servings,
    Value<Decimal>? bakingLossPercent,
    Value<Decimal?>? finalWeightOverrideG,
    Value<String?>? notes,
    Value<String?>? snapshotJson,
    Value<int?>? snapshotFormatVersion,
    Value<int?>? snapshottedAt,
    Value<int>? rowid,
  }) {
    return RecipeVersionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      recipeId: recipeId ?? this.recipeId,
      parentVersionId: parentVersionId ?? this.parentVersionId,
      versionIndex: versionIndex ?? this.versionIndex,
      label: label ?? this.label,
      state: state ?? this.state,
      servings: servings ?? this.servings,
      bakingLossPercent: bakingLossPercent ?? this.bakingLossPercent,
      finalWeightOverrideG: finalWeightOverrideG ?? this.finalWeightOverrideG,
      notes: notes ?? this.notes,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      snapshotFormatVersion:
          snapshotFormatVersion ?? this.snapshotFormatVersion,
      snapshottedAt: snapshottedAt ?? this.snapshottedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (parentVersionId.present) {
      map['parent_version_id'] = Variable<String>(parentVersionId.value);
    }
    if (versionIndex.present) {
      map['version_index'] = Variable<int>(versionIndex.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (servings.present) {
      map['servings'] = Variable<int>(servings.value);
    }
    if (bakingLossPercent.present) {
      map['baking_loss_percent'] = Variable<String>(
        $RecipeVersionsTable.$converterbakingLossPercent.toSql(
          bakingLossPercent.value,
        ),
      );
    }
    if (finalWeightOverrideG.present) {
      map['final_weight_override_g'] = Variable<String>(
        $RecipeVersionsTable.$converterfinalWeightOverrideGn.toSql(
          finalWeightOverrideG.value,
        ),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (snapshotFormatVersion.present) {
      map['snapshot_format_version'] = Variable<int>(
        snapshotFormatVersion.value,
      );
    }
    if (snapshottedAt.present) {
      map['snapshotted_at'] = Variable<int>(snapshottedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeVersionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('recipeId: $recipeId, ')
          ..write('parentVersionId: $parentVersionId, ')
          ..write('versionIndex: $versionIndex, ')
          ..write('label: $label, ')
          ..write('state: $state, ')
          ..write('servings: $servings, ')
          ..write('bakingLossPercent: $bakingLossPercent, ')
          ..write('finalWeightOverrideG: $finalWeightOverrideG, ')
          ..write('notes: $notes, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('snapshotFormatVersion: $snapshotFormatVersion, ')
          ..write('snapshottedAt: $snapshottedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, RecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodVariantIdMeta = const VerificationMeta(
    'foodVariantId',
  );
  @override
  late final GeneratedColumn<String> foodVariantId = GeneratedColumn<String>(
    'food_variant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> quantity =
      GeneratedColumn<String>(
        'quantity',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($RecipeIngredientsTable.$converterquantity);
  static const VerificationMeta _unitCodeMeta = const VerificationMeta(
    'unitCode',
  );
  @override
  late final GeneratedColumn<String> unitCode = GeneratedColumn<String>(
    'unit_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    versionId,
    position,
    foodVariantId,
    displayName,
    quantity,
    unitCode,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('food_variant_id')) {
      context.handle(
        _foodVariantIdMeta,
        foodVariantId.isAcceptableOrUnknown(
          data['food_variant_id']!,
          _foodVariantIdMeta,
        ),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('unit_code')) {
      context.handle(
        _unitCodeMeta,
        unitCode.isAcceptableOrUnknown(data['unit_code']!, _unitCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCodeMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      foodVariantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_variant_id'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      quantity: $RecipeIngredientsTable.$converterquantity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}quantity'],
        )!,
      ),
      unitCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_code'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterquantity =
      const DecimalConverter();
}

class RecipeIngredient extends DataClass
    implements Insertable<RecipeIngredient> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String versionId;

  /// 1-basiert, lückenlos innerhalb einer Version (Kapitel 10.10).
  final int position;

  /// null = freie Zutat ohne Nährwerte (Kapitel 8.5).
  final String? foodVariantId;
  final String displayName;

  /// >= 0 (Kapitel 11.4). Negative Werte werden bereits vor der Persistenz
  /// durch RecipeChange.validate() bzw. die UI-Formularvalidierung
  /// abgelehnt (Kapitel 8.5).
  final Decimal quantity;

  /// Code aus UnitCatalog (Kapitel 9).
  final String unitCode;
  final String? note;
  const RecipeIngredient({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionId,
    required this.position,
    this.foodVariantId,
    required this.displayName,
    required this.quantity,
    required this.unitCode,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['version_id'] = Variable<String>(versionId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || foodVariantId != null) {
      map['food_variant_id'] = Variable<String>(foodVariantId);
    }
    map['display_name'] = Variable<String>(displayName);
    {
      map['quantity'] = Variable<String>(
        $RecipeIngredientsTable.$converterquantity.toSql(quantity),
      );
    }
    map['unit_code'] = Variable<String>(unitCode);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionId: Value(versionId),
      position: Value(position),
      foodVariantId: foodVariantId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodVariantId),
      displayName: Value(displayName),
      quantity: Value(quantity),
      unitCode: Value(unitCode),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory RecipeIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredient(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      versionId: serializer.fromJson<String>(json['versionId']),
      position: serializer.fromJson<int>(json['position']),
      foodVariantId: serializer.fromJson<String?>(json['foodVariantId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      quantity: serializer.fromJson<Decimal>(json['quantity']),
      unitCode: serializer.fromJson<String>(json['unitCode']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'versionId': serializer.toJson<String>(versionId),
      'position': serializer.toJson<int>(position),
      'foodVariantId': serializer.toJson<String?>(foodVariantId),
      'displayName': serializer.toJson<String>(displayName),
      'quantity': serializer.toJson<Decimal>(quantity),
      'unitCode': serializer.toJson<String>(unitCode),
      'note': serializer.toJson<String?>(note),
    };
  }

  RecipeIngredient copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? versionId,
    int? position,
    Value<String?> foodVariantId = const Value.absent(),
    String? displayName,
    Decimal? quantity,
    String? unitCode,
    Value<String?> note = const Value.absent(),
  }) => RecipeIngredient(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionId: versionId ?? this.versionId,
    position: position ?? this.position,
    foodVariantId: foodVariantId.present
        ? foodVariantId.value
        : this.foodVariantId,
    displayName: displayName ?? this.displayName,
    quantity: quantity ?? this.quantity,
    unitCode: unitCode ?? this.unitCode,
    note: note.present ? note.value : this.note,
  );
  RecipeIngredient copyWithCompanion(RecipeIngredientsCompanion data) {
    return RecipeIngredient(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      position: data.position.present ? data.position.value : this.position,
      foodVariantId: data.foodVariantId.present
          ? data.foodVariantId.value
          : this.foodVariantId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCode: data.unitCode.present ? data.unitCode.value : this.unitCode,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredient(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionId: $versionId, ')
          ..write('position: $position, ')
          ..write('foodVariantId: $foodVariantId, ')
          ..write('displayName: $displayName, ')
          ..write('quantity: $quantity, ')
          ..write('unitCode: $unitCode, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    versionId,
    position,
    foodVariantId,
    displayName,
    quantity,
    unitCode,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredient &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionId == this.versionId &&
          other.position == this.position &&
          other.foodVariantId == this.foodVariantId &&
          other.displayName == this.displayName &&
          other.quantity == this.quantity &&
          other.unitCode == this.unitCode &&
          other.note == this.note);
}

class RecipeIngredientsCompanion extends UpdateCompanion<RecipeIngredient> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> versionId;
  final Value<int> position;
  final Value<String?> foodVariantId;
  final Value<String> displayName;
  final Value<Decimal> quantity;
  final Value<String> unitCode;
  final Value<String?> note;
  final Value<int> rowid;
  const RecipeIngredientsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionId = const Value.absent(),
    this.position = const Value.absent(),
    this.foodVariantId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCode = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String versionId,
    required int position,
    this.foodVariantId = const Value.absent(),
    required String displayName,
    required Decimal quantity,
    required String unitCode,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionId = Value(versionId),
       position = Value(position),
       displayName = Value(displayName),
       quantity = Value(quantity),
       unitCode = Value(unitCode);
  static Insertable<RecipeIngredient> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? versionId,
    Expression<int>? position,
    Expression<String>? foodVariantId,
    Expression<String>? displayName,
    Expression<String>? quantity,
    Expression<String>? unitCode,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionId != null) 'version_id': versionId,
      if (position != null) 'position': position,
      if (foodVariantId != null) 'food_variant_id': foodVariantId,
      if (displayName != null) 'display_name': displayName,
      if (quantity != null) 'quantity': quantity,
      if (unitCode != null) 'unit_code': unitCode,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeIngredientsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? versionId,
    Value<int>? position,
    Value<String?>? foodVariantId,
    Value<String>? displayName,
    Value<Decimal>? quantity,
    Value<String>? unitCode,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return RecipeIngredientsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionId: versionId ?? this.versionId,
      position: position ?? this.position,
      foodVariantId: foodVariantId ?? this.foodVariantId,
      displayName: displayName ?? this.displayName,
      quantity: quantity ?? this.quantity,
      unitCode: unitCode ?? this.unitCode,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (foodVariantId.present) {
      map['food_variant_id'] = Variable<String>(foodVariantId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(
        $RecipeIngredientsTable.$converterquantity.toSql(quantity.value),
      );
    }
    if (unitCode.present) {
      map['unit_code'] = Variable<String>(unitCode.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionId: $versionId, ')
          ..write('position: $position, ')
          ..write('foodVariantId: $foodVariantId, ')
          ..write('displayName: $displayName, ')
          ..write('quantity: $quantity, ')
          ..write('unitCode: $unitCode, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeStepsTable extends RecipeSteps
    with TableInfo<$RecipeStepsTable, RecipeStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructionMeta = const VerificationMeta(
    'instruction',
  );
  @override
  late final GeneratedColumn<String> instruction = GeneratedColumn<String>(
    'instruction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timerSecondsMeta = const VerificationMeta(
    'timerSeconds',
  );
  @override
  late final GeneratedColumn<int> timerSeconds = GeneratedColumn<int>(
    'timer_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    versionId,
    position,
    instruction,
    timerSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('instruction')) {
      context.handle(
        _instructionMeta,
        instruction.isAcceptableOrUnknown(
          data['instruction']!,
          _instructionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructionMeta);
    }
    if (data.containsKey('timer_seconds')) {
      context.handle(
        _timerSecondsMeta,
        timerSeconds.isAcceptableOrUnknown(
          data['timer_seconds']!,
          _timerSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeStep(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      instruction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instruction'],
      )!,
      timerSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timer_seconds'],
      ),
    );
  }

  @override
  $RecipeStepsTable createAlias(String alias) {
    return $RecipeStepsTable(attachedDatabase, alias);
  }
}

class RecipeStep extends DataClass implements Insertable<RecipeStep> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String versionId;

  /// 1-basiert, lückenlos innerhalb einer Version.
  final int position;
  final String instruction;
  final int? timerSeconds;
  const RecipeStep({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.versionId,
    required this.position,
    required this.instruction,
    this.timerSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['version_id'] = Variable<String>(versionId);
    map['position'] = Variable<int>(position);
    map['instruction'] = Variable<String>(instruction);
    if (!nullToAbsent || timerSeconds != null) {
      map['timer_seconds'] = Variable<int>(timerSeconds);
    }
    return map;
  }

  RecipeStepsCompanion toCompanion(bool nullToAbsent) {
    return RecipeStepsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      versionId: Value(versionId),
      position: Value(position),
      instruction: Value(instruction),
      timerSeconds: timerSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(timerSeconds),
    );
  }

  factory RecipeStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeStep(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      versionId: serializer.fromJson<String>(json['versionId']),
      position: serializer.fromJson<int>(json['position']),
      instruction: serializer.fromJson<String>(json['instruction']),
      timerSeconds: serializer.fromJson<int?>(json['timerSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'versionId': serializer.toJson<String>(versionId),
      'position': serializer.toJson<int>(position),
      'instruction': serializer.toJson<String>(instruction),
      'timerSeconds': serializer.toJson<int?>(timerSeconds),
    };
  }

  RecipeStep copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? versionId,
    int? position,
    String? instruction,
    Value<int?> timerSeconds = const Value.absent(),
  }) => RecipeStep(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    versionId: versionId ?? this.versionId,
    position: position ?? this.position,
    instruction: instruction ?? this.instruction,
    timerSeconds: timerSeconds.present ? timerSeconds.value : this.timerSeconds,
  );
  RecipeStep copyWithCompanion(RecipeStepsCompanion data) {
    return RecipeStep(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      position: data.position.present ? data.position.value : this.position,
      instruction: data.instruction.present
          ? data.instruction.value
          : this.instruction,
      timerSeconds: data.timerSeconds.present
          ? data.timerSeconds.value
          : this.timerSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeStep(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionId: $versionId, ')
          ..write('position: $position, ')
          ..write('instruction: $instruction, ')
          ..write('timerSeconds: $timerSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    versionId,
    position,
    instruction,
    timerSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeStep &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.versionId == this.versionId &&
          other.position == this.position &&
          other.instruction == this.instruction &&
          other.timerSeconds == this.timerSeconds);
}

class RecipeStepsCompanion extends UpdateCompanion<RecipeStep> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> versionId;
  final Value<int> position;
  final Value<String> instruction;
  final Value<int?> timerSeconds;
  final Value<int> rowid;
  const RecipeStepsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.versionId = const Value.absent(),
    this.position = const Value.absent(),
    this.instruction = const Value.absent(),
    this.timerSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeStepsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String versionId,
    required int position,
    required String instruction,
    this.timerSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       versionId = Value(versionId),
       position = Value(position),
       instruction = Value(instruction);
  static Insertable<RecipeStep> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? versionId,
    Expression<int>? position,
    Expression<String>? instruction,
    Expression<int>? timerSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (versionId != null) 'version_id': versionId,
      if (position != null) 'position': position,
      if (instruction != null) 'instruction': instruction,
      if (timerSeconds != null) 'timer_seconds': timerSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeStepsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? versionId,
    Value<int>? position,
    Value<String>? instruction,
    Value<int?>? timerSeconds,
    Value<int>? rowid,
  }) {
    return RecipeStepsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      versionId: versionId ?? this.versionId,
      position: position ?? this.position,
      instruction: instruction ?? this.instruction,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (instruction.present) {
      map['instruction'] = Variable<String>(instruction.value);
    }
    if (timerSeconds.present) {
      map['timer_seconds'] = Variable<int>(timerSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeStepsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('versionId: $versionId, ')
          ..write('position: $position, ')
          ..write('instruction: $instruction, ')
          ..write('timerSeconds: $timerSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodVariantsTable extends FoodVariants
    with TableInfo<$FoodVariantsTable, FoodVariant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodVariantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceRefMeta = const VerificationMeta(
    'sourceRef',
  );
  @override
  late final GeneratedColumn<String> sourceRef = GeneratedColumn<String>(
    'source_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> densityGPerMl =
      GeneratedColumn<String>(
        'density_g_per_ml',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FoodVariantsTable.$converterdensityGPerMln);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> gramsPerPiece =
      GeneratedColumn<String>(
        'grams_per_piece',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FoodVariantsTable.$convertergramsPerPiecen);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> servingSizeG =
      GeneratedColumn<String>(
        'serving_size_g',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FoodVariantsTable.$converterservingSizeGn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> energyKcal =
      GeneratedColumn<String>(
        'energy_kcal',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FoodVariantsTable.$converterenergyKcaln);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> fatG =
      GeneratedColumn<String>(
        'fat_g',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FoodVariantsTable.$converterfatGn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> saturatedFatG =
      GeneratedColumn<String>(
        'saturated_fat_g',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FoodVariantsTable.$convertersaturatedFatGn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> carbsG =
      GeneratedColumn<String>(
        'carbs_g',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FoodVariantsTable.$convertercarbsGn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> sugarsG =
      GeneratedColumn<String>(
        'sugars_g',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FoodVariantsTable.$convertersugarsGn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> fiberG =
      GeneratedColumn<String>(
        'fiber_g',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FoodVariantsTable.$converterfiberGn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> proteinG =
      GeneratedColumn<String>(
        'protein_g',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FoodVariantsTable.$converterproteinGn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal?, String> saltG =
      GeneratedColumn<String>(
        'salt_g',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Decimal?>($FoodVariantsTable.$convertersaltGn);
  static const VerificationMeta _extraJsonMeta = const VerificationMeta(
    'extraJson',
  );
  @override
  late final GeneratedColumn<String> extraJson = GeneratedColumn<String>(
    'extra_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    brand,
    barcode,
    source,
    sourceRef,
    ownerId,
    densityGPerMl,
    gramsPerPiece,
    servingSizeG,
    energyKcal,
    fatG,
    saturatedFatG,
    carbsG,
    sugarsG,
    fiberG,
    proteinG,
    saltG,
    extraJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_variants';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodVariant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('source_ref')) {
      context.handle(
        _sourceRefMeta,
        sourceRef.isAcceptableOrUnknown(data['source_ref']!, _sourceRefMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('extra_json')) {
      context.handle(
        _extraJsonMeta,
        extraJson.isAcceptableOrUnknown(data['extra_json']!, _extraJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodVariant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodVariant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ref'],
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      densityGPerMl: $FoodVariantsTable.$converterdensityGPerMln.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}density_g_per_ml'],
        ),
      ),
      gramsPerPiece: $FoodVariantsTable.$convertergramsPerPiecen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}grams_per_piece'],
        ),
      ),
      servingSizeG: $FoodVariantsTable.$converterservingSizeGn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}serving_size_g'],
        ),
      ),
      energyKcal: $FoodVariantsTable.$converterenergyKcaln.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}energy_kcal'],
        ),
      ),
      fatG: $FoodVariantsTable.$converterfatGn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fat_g'],
        ),
      ),
      saturatedFatG: $FoodVariantsTable.$convertersaturatedFatGn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}saturated_fat_g'],
        ),
      ),
      carbsG: $FoodVariantsTable.$convertercarbsGn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}carbs_g'],
        ),
      ),
      sugarsG: $FoodVariantsTable.$convertersugarsGn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sugars_g'],
        ),
      ),
      fiberG: $FoodVariantsTable.$converterfiberGn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fiber_g'],
        ),
      ),
      proteinG: $FoodVariantsTable.$converterproteinGn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}protein_g'],
        ),
      ),
      saltG: $FoodVariantsTable.$convertersaltGn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}salt_g'],
        ),
      ),
      extraJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra_json'],
      )!,
    );
  }

  @override
  $FoodVariantsTable createAlias(String alias) {
    return $FoodVariantsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterdensityGPerMl =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $converterdensityGPerMln =
      NullAwareTypeConverter.wrap($converterdensityGPerMl);
  static TypeConverter<Decimal, String> $convertergramsPerPiece =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $convertergramsPerPiecen =
      NullAwareTypeConverter.wrap($convertergramsPerPiece);
  static TypeConverter<Decimal, String> $converterservingSizeG =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $converterservingSizeGn =
      NullAwareTypeConverter.wrap($converterservingSizeG);
  static TypeConverter<Decimal, String> $converterenergyKcal =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $converterenergyKcaln =
      NullAwareTypeConverter.wrap($converterenergyKcal);
  static TypeConverter<Decimal, String> $converterfatG =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $converterfatGn =
      NullAwareTypeConverter.wrap($converterfatG);
  static TypeConverter<Decimal, String> $convertersaturatedFatG =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $convertersaturatedFatGn =
      NullAwareTypeConverter.wrap($convertersaturatedFatG);
  static TypeConverter<Decimal, String> $convertercarbsG =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $convertercarbsGn =
      NullAwareTypeConverter.wrap($convertercarbsG);
  static TypeConverter<Decimal, String> $convertersugarsG =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $convertersugarsGn =
      NullAwareTypeConverter.wrap($convertersugarsG);
  static TypeConverter<Decimal, String> $converterfiberG =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $converterfiberGn =
      NullAwareTypeConverter.wrap($converterfiberG);
  static TypeConverter<Decimal, String> $converterproteinG =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $converterproteinGn =
      NullAwareTypeConverter.wrap($converterproteinG);
  static TypeConverter<Decimal, String> $convertersaltG =
      const DecimalConverter();
  static TypeConverter<Decimal?, String?> $convertersaltGn =
      NullAwareTypeConverter.wrap($convertersaltG);
}

class FoodVariant extends DataClass implements Insertable<FoodVariant> {
  final String id;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String name;
  final String? brand;

  /// Grundlage der Duplikaterkennung beim Import (Kapitel 13.6).
  final String? barcode;

  /// 'custom' | 'import' | 'usda' (Kapitel 10.6).
  final String source;
  final String? sourceRef;

  /// wie recipes.owner_id (Kapitel 10.3).
  final String? ownerId;
  final Decimal? densityGPerMl;
  final Decimal? gramsPerPiece;
  final Decimal? servingSizeG;
  final Decimal? energyKcal;
  final Decimal? fatG;
  final Decimal? saturatedFatG;
  final Decimal? carbsG;
  final Decimal? sugarsG;
  final Decimal? fiberG;
  final Decimal? proteinG;
  final Decimal? saltG;

  /// Standard '{}'. Zusätzliche Nährwerte, Decimal-Werte als Strings
  /// (Kapitel 8.1).
  final String extraJson;
  const FoodVariant({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    this.brand,
    this.barcode,
    required this.source,
    this.sourceRef,
    this.ownerId,
    this.densityGPerMl,
    this.gramsPerPiece,
    this.servingSizeG,
    this.energyKcal,
    this.fatG,
    this.saturatedFatG,
    this.carbsG,
    this.sugarsG,
    this.fiberG,
    this.proteinG,
    this.saltG,
    required this.extraJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceRef != null) {
      map['source_ref'] = Variable<String>(sourceRef);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || densityGPerMl != null) {
      map['density_g_per_ml'] = Variable<String>(
        $FoodVariantsTable.$converterdensityGPerMln.toSql(densityGPerMl),
      );
    }
    if (!nullToAbsent || gramsPerPiece != null) {
      map['grams_per_piece'] = Variable<String>(
        $FoodVariantsTable.$convertergramsPerPiecen.toSql(gramsPerPiece),
      );
    }
    if (!nullToAbsent || servingSizeG != null) {
      map['serving_size_g'] = Variable<String>(
        $FoodVariantsTable.$converterservingSizeGn.toSql(servingSizeG),
      );
    }
    if (!nullToAbsent || energyKcal != null) {
      map['energy_kcal'] = Variable<String>(
        $FoodVariantsTable.$converterenergyKcaln.toSql(energyKcal),
      );
    }
    if (!nullToAbsent || fatG != null) {
      map['fat_g'] = Variable<String>(
        $FoodVariantsTable.$converterfatGn.toSql(fatG),
      );
    }
    if (!nullToAbsent || saturatedFatG != null) {
      map['saturated_fat_g'] = Variable<String>(
        $FoodVariantsTable.$convertersaturatedFatGn.toSql(saturatedFatG),
      );
    }
    if (!nullToAbsent || carbsG != null) {
      map['carbs_g'] = Variable<String>(
        $FoodVariantsTable.$convertercarbsGn.toSql(carbsG),
      );
    }
    if (!nullToAbsent || sugarsG != null) {
      map['sugars_g'] = Variable<String>(
        $FoodVariantsTable.$convertersugarsGn.toSql(sugarsG),
      );
    }
    if (!nullToAbsent || fiberG != null) {
      map['fiber_g'] = Variable<String>(
        $FoodVariantsTable.$converterfiberGn.toSql(fiberG),
      );
    }
    if (!nullToAbsent || proteinG != null) {
      map['protein_g'] = Variable<String>(
        $FoodVariantsTable.$converterproteinGn.toSql(proteinG),
      );
    }
    if (!nullToAbsent || saltG != null) {
      map['salt_g'] = Variable<String>(
        $FoodVariantsTable.$convertersaltGn.toSql(saltG),
      );
    }
    map['extra_json'] = Variable<String>(extraJson);
    return map;
  }

  FoodVariantsCompanion toCompanion(bool nullToAbsent) {
    return FoodVariantsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      source: Value(source),
      sourceRef: sourceRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRef),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      densityGPerMl: densityGPerMl == null && nullToAbsent
          ? const Value.absent()
          : Value(densityGPerMl),
      gramsPerPiece: gramsPerPiece == null && nullToAbsent
          ? const Value.absent()
          : Value(gramsPerPiece),
      servingSizeG: servingSizeG == null && nullToAbsent
          ? const Value.absent()
          : Value(servingSizeG),
      energyKcal: energyKcal == null && nullToAbsent
          ? const Value.absent()
          : Value(energyKcal),
      fatG: fatG == null && nullToAbsent ? const Value.absent() : Value(fatG),
      saturatedFatG: saturatedFatG == null && nullToAbsent
          ? const Value.absent()
          : Value(saturatedFatG),
      carbsG: carbsG == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsG),
      sugarsG: sugarsG == null && nullToAbsent
          ? const Value.absent()
          : Value(sugarsG),
      fiberG: fiberG == null && nullToAbsent
          ? const Value.absent()
          : Value(fiberG),
      proteinG: proteinG == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinG),
      saltG: saltG == null && nullToAbsent
          ? const Value.absent()
          : Value(saltG),
      extraJson: Value(extraJson),
    );
  }

  factory FoodVariant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodVariant(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      source: serializer.fromJson<String>(json['source']),
      sourceRef: serializer.fromJson<String?>(json['sourceRef']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      densityGPerMl: serializer.fromJson<Decimal?>(json['densityGPerMl']),
      gramsPerPiece: serializer.fromJson<Decimal?>(json['gramsPerPiece']),
      servingSizeG: serializer.fromJson<Decimal?>(json['servingSizeG']),
      energyKcal: serializer.fromJson<Decimal?>(json['energyKcal']),
      fatG: serializer.fromJson<Decimal?>(json['fatG']),
      saturatedFatG: serializer.fromJson<Decimal?>(json['saturatedFatG']),
      carbsG: serializer.fromJson<Decimal?>(json['carbsG']),
      sugarsG: serializer.fromJson<Decimal?>(json['sugarsG']),
      fiberG: serializer.fromJson<Decimal?>(json['fiberG']),
      proteinG: serializer.fromJson<Decimal?>(json['proteinG']),
      saltG: serializer.fromJson<Decimal?>(json['saltG']),
      extraJson: serializer.fromJson<String>(json['extraJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'barcode': serializer.toJson<String?>(barcode),
      'source': serializer.toJson<String>(source),
      'sourceRef': serializer.toJson<String?>(sourceRef),
      'ownerId': serializer.toJson<String?>(ownerId),
      'densityGPerMl': serializer.toJson<Decimal?>(densityGPerMl),
      'gramsPerPiece': serializer.toJson<Decimal?>(gramsPerPiece),
      'servingSizeG': serializer.toJson<Decimal?>(servingSizeG),
      'energyKcal': serializer.toJson<Decimal?>(energyKcal),
      'fatG': serializer.toJson<Decimal?>(fatG),
      'saturatedFatG': serializer.toJson<Decimal?>(saturatedFatG),
      'carbsG': serializer.toJson<Decimal?>(carbsG),
      'sugarsG': serializer.toJson<Decimal?>(sugarsG),
      'fiberG': serializer.toJson<Decimal?>(fiberG),
      'proteinG': serializer.toJson<Decimal?>(proteinG),
      'saltG': serializer.toJson<Decimal?>(saltG),
      'extraJson': serializer.toJson<String>(extraJson),
    };
  }

  FoodVariant copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    String? source,
    Value<String?> sourceRef = const Value.absent(),
    Value<String?> ownerId = const Value.absent(),
    Value<Decimal?> densityGPerMl = const Value.absent(),
    Value<Decimal?> gramsPerPiece = const Value.absent(),
    Value<Decimal?> servingSizeG = const Value.absent(),
    Value<Decimal?> energyKcal = const Value.absent(),
    Value<Decimal?> fatG = const Value.absent(),
    Value<Decimal?> saturatedFatG = const Value.absent(),
    Value<Decimal?> carbsG = const Value.absent(),
    Value<Decimal?> sugarsG = const Value.absent(),
    Value<Decimal?> fiberG = const Value.absent(),
    Value<Decimal?> proteinG = const Value.absent(),
    Value<Decimal?> saltG = const Value.absent(),
    String? extraJson,
  }) => FoodVariant(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    barcode: barcode.present ? barcode.value : this.barcode,
    source: source ?? this.source,
    sourceRef: sourceRef.present ? sourceRef.value : this.sourceRef,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    densityGPerMl: densityGPerMl.present
        ? densityGPerMl.value
        : this.densityGPerMl,
    gramsPerPiece: gramsPerPiece.present
        ? gramsPerPiece.value
        : this.gramsPerPiece,
    servingSizeG: servingSizeG.present ? servingSizeG.value : this.servingSizeG,
    energyKcal: energyKcal.present ? energyKcal.value : this.energyKcal,
    fatG: fatG.present ? fatG.value : this.fatG,
    saturatedFatG: saturatedFatG.present
        ? saturatedFatG.value
        : this.saturatedFatG,
    carbsG: carbsG.present ? carbsG.value : this.carbsG,
    sugarsG: sugarsG.present ? sugarsG.value : this.sugarsG,
    fiberG: fiberG.present ? fiberG.value : this.fiberG,
    proteinG: proteinG.present ? proteinG.value : this.proteinG,
    saltG: saltG.present ? saltG.value : this.saltG,
    extraJson: extraJson ?? this.extraJson,
  );
  FoodVariant copyWithCompanion(FoodVariantsCompanion data) {
    return FoodVariant(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      source: data.source.present ? data.source.value : this.source,
      sourceRef: data.sourceRef.present ? data.sourceRef.value : this.sourceRef,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      densityGPerMl: data.densityGPerMl.present
          ? data.densityGPerMl.value
          : this.densityGPerMl,
      gramsPerPiece: data.gramsPerPiece.present
          ? data.gramsPerPiece.value
          : this.gramsPerPiece,
      servingSizeG: data.servingSizeG.present
          ? data.servingSizeG.value
          : this.servingSizeG,
      energyKcal: data.energyKcal.present
          ? data.energyKcal.value
          : this.energyKcal,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      saturatedFatG: data.saturatedFatG.present
          ? data.saturatedFatG.value
          : this.saturatedFatG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      sugarsG: data.sugarsG.present ? data.sugarsG.value : this.sugarsG,
      fiberG: data.fiberG.present ? data.fiberG.value : this.fiberG,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      saltG: data.saltG.present ? data.saltG.value : this.saltG,
      extraJson: data.extraJson.present ? data.extraJson.value : this.extraJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodVariant(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('ownerId: $ownerId, ')
          ..write('densityGPerMl: $densityGPerMl, ')
          ..write('gramsPerPiece: $gramsPerPiece, ')
          ..write('servingSizeG: $servingSizeG, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('fatG: $fatG, ')
          ..write('saturatedFatG: $saturatedFatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('sugarsG: $sugarsG, ')
          ..write('fiberG: $fiberG, ')
          ..write('proteinG: $proteinG, ')
          ..write('saltG: $saltG, ')
          ..write('extraJson: $extraJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    brand,
    barcode,
    source,
    sourceRef,
    ownerId,
    densityGPerMl,
    gramsPerPiece,
    servingSizeG,
    energyKcal,
    fatG,
    saturatedFatG,
    carbsG,
    sugarsG,
    fiberG,
    proteinG,
    saltG,
    extraJson,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodVariant &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.barcode == this.barcode &&
          other.source == this.source &&
          other.sourceRef == this.sourceRef &&
          other.ownerId == this.ownerId &&
          other.densityGPerMl == this.densityGPerMl &&
          other.gramsPerPiece == this.gramsPerPiece &&
          other.servingSizeG == this.servingSizeG &&
          other.energyKcal == this.energyKcal &&
          other.fatG == this.fatG &&
          other.saturatedFatG == this.saturatedFatG &&
          other.carbsG == this.carbsG &&
          other.sugarsG == this.sugarsG &&
          other.fiberG == this.fiberG &&
          other.proteinG == this.proteinG &&
          other.saltG == this.saltG &&
          other.extraJson == this.extraJson);
}

class FoodVariantsCompanion extends UpdateCompanion<FoodVariant> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> barcode;
  final Value<String> source;
  final Value<String?> sourceRef;
  final Value<String?> ownerId;
  final Value<Decimal?> densityGPerMl;
  final Value<Decimal?> gramsPerPiece;
  final Value<Decimal?> servingSizeG;
  final Value<Decimal?> energyKcal;
  final Value<Decimal?> fatG;
  final Value<Decimal?> saturatedFatG;
  final Value<Decimal?> carbsG;
  final Value<Decimal?> sugarsG;
  final Value<Decimal?> fiberG;
  final Value<Decimal?> proteinG;
  final Value<Decimal?> saltG;
  final Value<String> extraJson;
  final Value<int> rowid;
  const FoodVariantsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.densityGPerMl = const Value.absent(),
    this.gramsPerPiece = const Value.absent(),
    this.servingSizeG = const Value.absent(),
    this.energyKcal = const Value.absent(),
    this.fatG = const Value.absent(),
    this.saturatedFatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.sugarsG = const Value.absent(),
    this.fiberG = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.saltG = const Value.absent(),
    this.extraJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodVariantsCompanion.insert({
    required String id,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    required String source,
    this.sourceRef = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.densityGPerMl = const Value.absent(),
    this.gramsPerPiece = const Value.absent(),
    this.servingSizeG = const Value.absent(),
    this.energyKcal = const Value.absent(),
    this.fatG = const Value.absent(),
    this.saturatedFatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.sugarsG = const Value.absent(),
    this.fiberG = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.saltG = const Value.absent(),
    this.extraJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       source = Value(source);
  static Insertable<FoodVariant> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? barcode,
    Expression<String>? source,
    Expression<String>? sourceRef,
    Expression<String>? ownerId,
    Expression<String>? densityGPerMl,
    Expression<String>? gramsPerPiece,
    Expression<String>? servingSizeG,
    Expression<String>? energyKcal,
    Expression<String>? fatG,
    Expression<String>? saturatedFatG,
    Expression<String>? carbsG,
    Expression<String>? sugarsG,
    Expression<String>? fiberG,
    Expression<String>? proteinG,
    Expression<String>? saltG,
    Expression<String>? extraJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (barcode != null) 'barcode': barcode,
      if (source != null) 'source': source,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (ownerId != null) 'owner_id': ownerId,
      if (densityGPerMl != null) 'density_g_per_ml': densityGPerMl,
      if (gramsPerPiece != null) 'grams_per_piece': gramsPerPiece,
      if (servingSizeG != null) 'serving_size_g': servingSizeG,
      if (energyKcal != null) 'energy_kcal': energyKcal,
      if (fatG != null) 'fat_g': fatG,
      if (saturatedFatG != null) 'saturated_fat_g': saturatedFatG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (sugarsG != null) 'sugars_g': sugarsG,
      if (fiberG != null) 'fiber_g': fiberG,
      if (proteinG != null) 'protein_g': proteinG,
      if (saltG != null) 'salt_g': saltG,
      if (extraJson != null) 'extra_json': extraJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodVariantsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? barcode,
    Value<String>? source,
    Value<String?>? sourceRef,
    Value<String?>? ownerId,
    Value<Decimal?>? densityGPerMl,
    Value<Decimal?>? gramsPerPiece,
    Value<Decimal?>? servingSizeG,
    Value<Decimal?>? energyKcal,
    Value<Decimal?>? fatG,
    Value<Decimal?>? saturatedFatG,
    Value<Decimal?>? carbsG,
    Value<Decimal?>? sugarsG,
    Value<Decimal?>? fiberG,
    Value<Decimal?>? proteinG,
    Value<Decimal?>? saltG,
    Value<String>? extraJson,
    Value<int>? rowid,
  }) {
    return FoodVariantsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      source: source ?? this.source,
      sourceRef: sourceRef ?? this.sourceRef,
      ownerId: ownerId ?? this.ownerId,
      densityGPerMl: densityGPerMl ?? this.densityGPerMl,
      gramsPerPiece: gramsPerPiece ?? this.gramsPerPiece,
      servingSizeG: servingSizeG ?? this.servingSizeG,
      energyKcal: energyKcal ?? this.energyKcal,
      fatG: fatG ?? this.fatG,
      saturatedFatG: saturatedFatG ?? this.saturatedFatG,
      carbsG: carbsG ?? this.carbsG,
      sugarsG: sugarsG ?? this.sugarsG,
      fiberG: fiberG ?? this.fiberG,
      proteinG: proteinG ?? this.proteinG,
      saltG: saltG ?? this.saltG,
      extraJson: extraJson ?? this.extraJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceRef.present) {
      map['source_ref'] = Variable<String>(sourceRef.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (densityGPerMl.present) {
      map['density_g_per_ml'] = Variable<String>(
        $FoodVariantsTable.$converterdensityGPerMln.toSql(densityGPerMl.value),
      );
    }
    if (gramsPerPiece.present) {
      map['grams_per_piece'] = Variable<String>(
        $FoodVariantsTable.$convertergramsPerPiecen.toSql(gramsPerPiece.value),
      );
    }
    if (servingSizeG.present) {
      map['serving_size_g'] = Variable<String>(
        $FoodVariantsTable.$converterservingSizeGn.toSql(servingSizeG.value),
      );
    }
    if (energyKcal.present) {
      map['energy_kcal'] = Variable<String>(
        $FoodVariantsTable.$converterenergyKcaln.toSql(energyKcal.value),
      );
    }
    if (fatG.present) {
      map['fat_g'] = Variable<String>(
        $FoodVariantsTable.$converterfatGn.toSql(fatG.value),
      );
    }
    if (saturatedFatG.present) {
      map['saturated_fat_g'] = Variable<String>(
        $FoodVariantsTable.$convertersaturatedFatGn.toSql(saturatedFatG.value),
      );
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<String>(
        $FoodVariantsTable.$convertercarbsGn.toSql(carbsG.value),
      );
    }
    if (sugarsG.present) {
      map['sugars_g'] = Variable<String>(
        $FoodVariantsTable.$convertersugarsGn.toSql(sugarsG.value),
      );
    }
    if (fiberG.present) {
      map['fiber_g'] = Variable<String>(
        $FoodVariantsTable.$converterfiberGn.toSql(fiberG.value),
      );
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<String>(
        $FoodVariantsTable.$converterproteinGn.toSql(proteinG.value),
      );
    }
    if (saltG.present) {
      map['salt_g'] = Variable<String>(
        $FoodVariantsTable.$convertersaltGn.toSql(saltG.value),
      );
    }
    if (extraJson.present) {
      map['extra_json'] = Variable<String>(extraJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodVariantsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('ownerId: $ownerId, ')
          ..write('densityGPerMl: $densityGPerMl, ')
          ..write('gramsPerPiece: $gramsPerPiece, ')
          ..write('servingSizeG: $servingSizeG, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('fatG: $fatG, ')
          ..write('saturatedFatG: $saturatedFatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('sugarsG: $sugarsG, ')
          ..write('fiberG: $fiberG, ')
          ..write('proteinG: $proteinG, ')
          ..write('saltG: $saltG, ')
          ..write('extraJson: $extraJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CoreDatabase extends GeneratedDatabase {
  _$CoreDatabase(QueryExecutor e) : super(e);
  $CoreDatabaseManager get managers => $CoreDatabaseManager(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeVersionsTable recipeVersions = $RecipeVersionsTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $RecipeStepsTable recipeSteps = $RecipeStepsTable(this);
  late final $FoodVariantsTable foodVariants = $FoodVariantsTable(this);
  late final Index idxRecipesTitle = Index(
    'idx_recipes_title',
    'CREATE INDEX idx_recipes_title ON recipes (title)',
  );
  late final Index idxRecipesOwnerId = Index(
    'idx_recipes_owner_id',
    'CREATE INDEX idx_recipes_owner_id ON recipes (owner_id)',
  );
  late final Index idxRecipeVersionsRecipeId = Index(
    'idx_recipe_versions_recipe_id',
    'CREATE INDEX idx_recipe_versions_recipe_id ON recipe_versions (recipe_id)',
  );
  late final Index idxRecipeVersionsRecipeIdVersionIndex = Index(
    'idx_recipe_versions_recipe_id_version_index',
    'CREATE INDEX idx_recipe_versions_recipe_id_version_index ON recipe_versions (recipe_id, version_index)',
  );
  late final Index idxRecipeVersionsState = Index(
    'idx_recipe_versions_state',
    'CREATE INDEX idx_recipe_versions_state ON recipe_versions (state)',
  );
  late final Index idxRecipeIngredientsVersionId = Index(
    'idx_recipe_ingredients_version_id',
    'CREATE INDEX idx_recipe_ingredients_version_id ON recipe_ingredients (version_id)',
  );
  late final Index idxRecipeIngredientsVersionIdPosition = Index(
    'idx_recipe_ingredients_version_id_position',
    'CREATE INDEX idx_recipe_ingredients_version_id_position ON recipe_ingredients (version_id, position)',
  );
  late final Index idxRecipeStepsVersionId = Index(
    'idx_recipe_steps_version_id',
    'CREATE INDEX idx_recipe_steps_version_id ON recipe_steps (version_id)',
  );
  late final Index idxRecipeStepsVersionIdPosition = Index(
    'idx_recipe_steps_version_id_position',
    'CREATE INDEX idx_recipe_steps_version_id_position ON recipe_steps (version_id, position)',
  );
  late final Index idxFoodVariantsName = Index(
    'idx_food_variants_name',
    'CREATE INDEX idx_food_variants_name ON food_variants (name)',
  );
  late final Index idxFoodVariantsBarcode = Index(
    'idx_food_variants_barcode',
    'CREATE INDEX idx_food_variants_barcode ON food_variants (barcode)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recipes,
    recipeVersions,
    recipeIngredients,
    recipeSteps,
    foodVariants,
    idxRecipesTitle,
    idxRecipesOwnerId,
    idxRecipeVersionsRecipeId,
    idxRecipeVersionsRecipeIdVersionIndex,
    idxRecipeVersionsState,
    idxRecipeIngredientsVersionId,
    idxRecipeIngredientsVersionIdPosition,
    idxRecipeStepsVersionId,
    idxRecipeStepsVersionIdPosition,
    idxFoodVariantsName,
    idxFoodVariantsBarcode,
  ];
}

typedef $$RecipesTableCreateCompanionBuilder = RecipesCompanion Function({
  required String id,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  required String title,
  Value<String?> description,
  Value<String?> masterVersionId,
  Value<String?> ownerId,
  Value<int> rowid,
});
typedef $$RecipesTableUpdateCompanionBuilder = RecipesCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> title,
  Value<String?> description,
  Value<String?> masterVersionId,
  Value<String?> ownerId,
  Value<int> rowid,
});

class $$RecipesTableFilterComposer
    extends Composer<_$CoreDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
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

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get masterVersionId => $composableBuilder(
    column: $table.masterVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipesTableOrderingComposer
    extends Composer<_$CoreDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
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

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get masterVersionId => $composableBuilder(
    column: $table.masterVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$CoreDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get masterVersionId => $composableBuilder(
    column: $table.masterVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$CoreDatabase,
          $RecipesTable,
          Recipe,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (Recipe, BaseReferences<_$CoreDatabase, $RecipesTable, Recipe>),
          Recipe,
          PrefetchHooks Function()
        > {
  $$RecipesTableTableManager(_$CoreDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> masterVersionId = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                title: title,
                description: description,
                masterVersionId: masterVersionId,
                ownerId: ownerId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> masterVersionId = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                title: title,
                description: description,
                masterVersionId: masterVersionId,
                ownerId: ownerId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecipesTable, Recipe>(table),
                  BaseReferences<_$CoreDatabase, $RecipesTable, Recipe>(
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

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$CoreDatabase,
      $RecipesTable,
      Recipe,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (Recipe, BaseReferences<_$CoreDatabase, $RecipesTable, Recipe>),
      Recipe,
      PrefetchHooks Function()
    >;
typedef $$RecipeVersionsTableCreateCompanionBuilder =
    RecipeVersionsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String recipeId,
      Value<String?> parentVersionId,
      required int versionIndex,
      Value<String?> label,
      required String state,
      Value<int?> servings,
      Value<Decimal> bakingLossPercent,
      Value<Decimal?> finalWeightOverrideG,
      Value<String?> notes,
      Value<String?> snapshotJson,
      Value<int?> snapshotFormatVersion,
      Value<int?> snapshottedAt,
      Value<int> rowid,
    });
typedef $$RecipeVersionsTableUpdateCompanionBuilder =
    RecipeVersionsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> recipeId,
      Value<String?> parentVersionId,
      Value<int> versionIndex,
      Value<String?> label,
      Value<String> state,
      Value<int?> servings,
      Value<Decimal> bakingLossPercent,
      Value<Decimal?> finalWeightOverrideG,
      Value<String?> notes,
      Value<String?> snapshotJson,
      Value<int?> snapshotFormatVersion,
      Value<int?> snapshottedAt,
      Value<int> rowid,
    });

class $$RecipeVersionsTableFilterComposer
    extends Composer<_$CoreDatabase, $RecipeVersionsTable> {
  $$RecipeVersionsTableFilterComposer({
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

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versionIndex => $composableBuilder(
    column: $table.versionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String>
  get bakingLossPercent => $composableBuilder(
    column: $table.bakingLossPercent,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String>
  get finalWeightOverrideG => $composableBuilder(
    column: $table.finalWeightOverrideG,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snapshotFormatVersion => $composableBuilder(
    column: $table.snapshotFormatVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snapshottedAt => $composableBuilder(
    column: $table.snapshottedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeVersionsTableOrderingComposer
    extends Composer<_$CoreDatabase, $RecipeVersionsTable> {
  $$RecipeVersionsTableOrderingComposer({
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

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versionIndex => $composableBuilder(
    column: $table.versionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bakingLossPercent => $composableBuilder(
    column: $table.bakingLossPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalWeightOverrideG => $composableBuilder(
    column: $table.finalWeightOverrideG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snapshotFormatVersion => $composableBuilder(
    column: $table.snapshotFormatVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snapshottedAt => $composableBuilder(
    column: $table.snapshottedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeVersionsTableAnnotationComposer
    extends Composer<_$CoreDatabase, $RecipeVersionsTable> {
  $$RecipeVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get parentVersionId => $composableBuilder(
    column: $table.parentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versionIndex => $composableBuilder(
    column: $table.versionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get bakingLossPercent =>
      $composableBuilder(
        column: $table.bakingLossPercent,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal?, String> get finalWeightOverrideG =>
      $composableBuilder(
        column: $table.finalWeightOverrideG,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snapshotFormatVersion => $composableBuilder(
    column: $table.snapshotFormatVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snapshottedAt => $composableBuilder(
    column: $table.snapshottedAt,
    builder: (column) => column,
  );
}

class $$RecipeVersionsTableTableManager
    extends
        RootTableManager<
          _$CoreDatabase,
          $RecipeVersionsTable,
          RecipeVersion,
          $$RecipeVersionsTableFilterComposer,
          $$RecipeVersionsTableOrderingComposer,
          $$RecipeVersionsTableAnnotationComposer,
          $$RecipeVersionsTableCreateCompanionBuilder,
          $$RecipeVersionsTableUpdateCompanionBuilder,
          (
            RecipeVersion,
            BaseReferences<_$CoreDatabase, $RecipeVersionsTable, RecipeVersion>,
          ),
          RecipeVersion,
          PrefetchHooks Function()
        > {
  $$RecipeVersionsTableTableManager(
    _$CoreDatabase db,
    $RecipeVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String?> parentVersionId = const Value.absent(),
                Value<int> versionIndex = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int?> servings = const Value.absent(),
                Value<Decimal> bakingLossPercent = const Value.absent(),
                Value<Decimal?> finalWeightOverrideG = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> snapshotJson = const Value.absent(),
                Value<int?> snapshotFormatVersion = const Value.absent(),
                Value<int?> snapshottedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeVersionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                recipeId: recipeId,
                parentVersionId: parentVersionId,
                versionIndex: versionIndex,
                label: label,
                state: state,
                servings: servings,
                bakingLossPercent: bakingLossPercent,
                finalWeightOverrideG: finalWeightOverrideG,
                notes: notes,
                snapshotJson: snapshotJson,
                snapshotFormatVersion: snapshotFormatVersion,
                snapshottedAt: snapshottedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String recipeId,
                Value<String?> parentVersionId = const Value.absent(),
                required int versionIndex,
                Value<String?> label = const Value.absent(),
                required String state,
                Value<int?> servings = const Value.absent(),
                Value<Decimal> bakingLossPercent = const Value.absent(),
                Value<Decimal?> finalWeightOverrideG = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> snapshotJson = const Value.absent(),
                Value<int?> snapshotFormatVersion = const Value.absent(),
                Value<int?> snapshottedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeVersionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                recipeId: recipeId,
                parentVersionId: parentVersionId,
                versionIndex: versionIndex,
                label: label,
                state: state,
                servings: servings,
                bakingLossPercent: bakingLossPercent,
                finalWeightOverrideG: finalWeightOverrideG,
                notes: notes,
                snapshotJson: snapshotJson,
                snapshotFormatVersion: snapshotFormatVersion,
                snapshottedAt: snapshottedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecipeVersionsTable, RecipeVersion>(table),
                  BaseReferences<
                    _$CoreDatabase,
                    $RecipeVersionsTable,
                    RecipeVersion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$CoreDatabase,
      $RecipeVersionsTable,
      RecipeVersion,
      $$RecipeVersionsTableFilterComposer,
      $$RecipeVersionsTableOrderingComposer,
      $$RecipeVersionsTableAnnotationComposer,
      $$RecipeVersionsTableCreateCompanionBuilder,
      $$RecipeVersionsTableUpdateCompanionBuilder,
      (
        RecipeVersion,
        BaseReferences<_$CoreDatabase, $RecipeVersionsTable, RecipeVersion>,
      ),
      RecipeVersion,
      PrefetchHooks Function()
    >;
typedef $$RecipeIngredientsTableCreateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String versionId,
      required int position,
      Value<String?> foodVariantId,
      required String displayName,
      required Decimal quantity,
      required String unitCode,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$RecipeIngredientsTableUpdateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> versionId,
      Value<int> position,
      Value<String?> foodVariantId,
      Value<String> displayName,
      Value<Decimal> quantity,
      Value<String> unitCode,
      Value<String?> note,
      Value<int> rowid,
    });

class $$RecipeIngredientsTableFilterComposer
    extends Composer<_$CoreDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer({
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

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodVariantId => $composableBuilder(
    column: $table.foodVariantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get quantity =>
      $composableBuilder(
        column: $table.quantity,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeIngredientsTableOrderingComposer
    extends Composer<_$CoreDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer({
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

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodVariantId => $composableBuilder(
    column: $table.foodVariantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeIngredientsTableAnnotationComposer
    extends Composer<_$CoreDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get versionId =>
      $composableBuilder(column: $table.versionId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get foodVariantId => $composableBuilder(
    column: $table.foodVariantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal, String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unitCode =>
      $composableBuilder(column: $table.unitCode, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$RecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$CoreDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient,
          $$RecipeIngredientsTableFilterComposer,
          $$RecipeIngredientsTableOrderingComposer,
          $$RecipeIngredientsTableAnnotationComposer,
          $$RecipeIngredientsTableCreateCompanionBuilder,
          $$RecipeIngredientsTableUpdateCompanionBuilder,
          (
            RecipeIngredient,
            BaseReferences<
              _$CoreDatabase,
              $RecipeIngredientsTable,
              RecipeIngredient
            >,
          ),
          RecipeIngredient,
          PrefetchHooks Function()
        > {
  $$RecipeIngredientsTableTableManager(
    _$CoreDatabase db,
    $RecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> versionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> foodVariantId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<Decimal> quantity = const Value.absent(),
                Value<String> unitCode = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeIngredientsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                versionId: versionId,
                position: position,
                foodVariantId: foodVariantId,
                displayName: displayName,
                quantity: quantity,
                unitCode: unitCode,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String versionId,
                required int position,
                Value<String?> foodVariantId = const Value.absent(),
                required String displayName,
                required Decimal quantity,
                required String unitCode,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeIngredientsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                versionId: versionId,
                position: position,
                foodVariantId: foodVariantId,
                displayName: displayName,
                quantity: quantity,
                unitCode: unitCode,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecipeIngredientsTable, RecipeIngredient>(table),
                  BaseReferences<
                    _$CoreDatabase,
                    $RecipeIngredientsTable,
                    RecipeIngredient
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$CoreDatabase,
      $RecipeIngredientsTable,
      RecipeIngredient,
      $$RecipeIngredientsTableFilterComposer,
      $$RecipeIngredientsTableOrderingComposer,
      $$RecipeIngredientsTableAnnotationComposer,
      $$RecipeIngredientsTableCreateCompanionBuilder,
      $$RecipeIngredientsTableUpdateCompanionBuilder,
      (
        RecipeIngredient,
        BaseReferences<
          _$CoreDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient
        >,
      ),
      RecipeIngredient,
      PrefetchHooks Function()
    >;
typedef $$RecipeStepsTableCreateCompanionBuilder =
    RecipeStepsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String versionId,
      required int position,
      required String instruction,
      Value<int?> timerSeconds,
      Value<int> rowid,
    });
typedef $$RecipeStepsTableUpdateCompanionBuilder =
    RecipeStepsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> versionId,
      Value<int> position,
      Value<String> instruction,
      Value<int?> timerSeconds,
      Value<int> rowid,
    });

class $$RecipeStepsTableFilterComposer
    extends Composer<_$CoreDatabase, $RecipeStepsTable> {
  $$RecipeStepsTableFilterComposer({
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

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timerSeconds => $composableBuilder(
    column: $table.timerSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipeStepsTableOrderingComposer
    extends Composer<_$CoreDatabase, $RecipeStepsTable> {
  $$RecipeStepsTableOrderingComposer({
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

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timerSeconds => $composableBuilder(
    column: $table.timerSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipeStepsTableAnnotationComposer
    extends Composer<_$CoreDatabase, $RecipeStepsTable> {
  $$RecipeStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get versionId =>
      $composableBuilder(column: $table.versionId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timerSeconds => $composableBuilder(
    column: $table.timerSeconds,
    builder: (column) => column,
  );
}

class $$RecipeStepsTableTableManager
    extends
        RootTableManager<
          _$CoreDatabase,
          $RecipeStepsTable,
          RecipeStep,
          $$RecipeStepsTableFilterComposer,
          $$RecipeStepsTableOrderingComposer,
          $$RecipeStepsTableAnnotationComposer,
          $$RecipeStepsTableCreateCompanionBuilder,
          $$RecipeStepsTableUpdateCompanionBuilder,
          (
            RecipeStep,
            BaseReferences<_$CoreDatabase, $RecipeStepsTable, RecipeStep>,
          ),
          RecipeStep,
          PrefetchHooks Function()
        > {
  $$RecipeStepsTableTableManager(_$CoreDatabase db, $RecipeStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> versionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> instruction = const Value.absent(),
                Value<int?> timerSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeStepsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                versionId: versionId,
                position: position,
                instruction: instruction,
                timerSeconds: timerSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String versionId,
                required int position,
                required String instruction,
                Value<int?> timerSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeStepsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                versionId: versionId,
                position: position,
                instruction: instruction,
                timerSeconds: timerSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecipeStepsTable, RecipeStep>(table),
                  BaseReferences<_$CoreDatabase, $RecipeStepsTable, RecipeStep>(
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

typedef $$RecipeStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$CoreDatabase,
      $RecipeStepsTable,
      RecipeStep,
      $$RecipeStepsTableFilterComposer,
      $$RecipeStepsTableOrderingComposer,
      $$RecipeStepsTableAnnotationComposer,
      $$RecipeStepsTableCreateCompanionBuilder,
      $$RecipeStepsTableUpdateCompanionBuilder,
      (
        RecipeStep,
        BaseReferences<_$CoreDatabase, $RecipeStepsTable, RecipeStep>,
      ),
      RecipeStep,
      PrefetchHooks Function()
    >;
typedef $$FoodVariantsTableCreateCompanionBuilder =
    FoodVariantsCompanion Function({
      required String id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String name,
      Value<String?> brand,
      Value<String?> barcode,
      required String source,
      Value<String?> sourceRef,
      Value<String?> ownerId,
      Value<Decimal?> densityGPerMl,
      Value<Decimal?> gramsPerPiece,
      Value<Decimal?> servingSizeG,
      Value<Decimal?> energyKcal,
      Value<Decimal?> fatG,
      Value<Decimal?> saturatedFatG,
      Value<Decimal?> carbsG,
      Value<Decimal?> sugarsG,
      Value<Decimal?> fiberG,
      Value<Decimal?> proteinG,
      Value<Decimal?> saltG,
      Value<String> extraJson,
      Value<int> rowid,
    });
typedef $$FoodVariantsTableUpdateCompanionBuilder =
    FoodVariantsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> name,
      Value<String?> brand,
      Value<String?> barcode,
      Value<String> source,
      Value<String?> sourceRef,
      Value<String?> ownerId,
      Value<Decimal?> densityGPerMl,
      Value<Decimal?> gramsPerPiece,
      Value<Decimal?> servingSizeG,
      Value<Decimal?> energyKcal,
      Value<Decimal?> fatG,
      Value<Decimal?> saturatedFatG,
      Value<Decimal?> carbsG,
      Value<Decimal?> sugarsG,
      Value<Decimal?> fiberG,
      Value<Decimal?> proteinG,
      Value<Decimal?> saltG,
      Value<String> extraJson,
      Value<int> rowid,
    });

class $$FoodVariantsTableFilterComposer
    extends Composer<_$CoreDatabase, $FoodVariantsTable> {
  $$FoodVariantsTableFilterComposer({
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

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get densityGPerMl =>
      $composableBuilder(
        column: $table.densityGPerMl,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get gramsPerPiece =>
      $composableBuilder(
        column: $table.gramsPerPiece,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get servingSizeG =>
      $composableBuilder(
        column: $table.servingSizeG,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get energyKcal =>
      $composableBuilder(
        column: $table.energyKcal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get fatG =>
      $composableBuilder(
        column: $table.fatG,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get saturatedFatG =>
      $composableBuilder(
        column: $table.saturatedFatG,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get carbsG =>
      $composableBuilder(
        column: $table.carbsG,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get sugarsG =>
      $composableBuilder(
        column: $table.sugarsG,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get fiberG =>
      $composableBuilder(
        column: $table.fiberG,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get proteinG =>
      $composableBuilder(
        column: $table.proteinG,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal?, Decimal, String> get saltG =>
      $composableBuilder(
        column: $table.saltG,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodVariantsTableOrderingComposer
    extends Composer<_$CoreDatabase, $FoodVariantsTable> {
  $$FoodVariantsTableOrderingComposer({
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

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get densityGPerMl => $composableBuilder(
    column: $table.densityGPerMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gramsPerPiece => $composableBuilder(
    column: $table.gramsPerPiece,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingSizeG => $composableBuilder(
    column: $table.servingSizeG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get energyKcal => $composableBuilder(
    column: $table.energyKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saturatedFatG => $composableBuilder(
    column: $table.saturatedFatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sugarsG => $composableBuilder(
    column: $table.sugarsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiberG => $composableBuilder(
    column: $table.fiberG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saltG => $composableBuilder(
    column: $table.saltG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodVariantsTableAnnotationComposer
    extends Composer<_$CoreDatabase, $FoodVariantsTable> {
  $$FoodVariantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceRef =>
      $composableBuilder(column: $table.sourceRef, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get densityGPerMl =>
      $composableBuilder(
        column: $table.densityGPerMl,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal?, String> get gramsPerPiece =>
      $composableBuilder(
        column: $table.gramsPerPiece,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal?, String> get servingSizeG =>
      $composableBuilder(
        column: $table.servingSizeG,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal?, String> get energyKcal =>
      $composableBuilder(
        column: $table.energyKcal,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal?, String> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get saturatedFatG =>
      $composableBuilder(
        column: $table.saturatedFatG,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal?, String> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get sugarsG =>
      $composableBuilder(column: $table.sugarsG, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get fiberG =>
      $composableBuilder(column: $table.fiberG, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal?, String> get saltG =>
      $composableBuilder(column: $table.saltG, builder: (column) => column);

  GeneratedColumn<String> get extraJson =>
      $composableBuilder(column: $table.extraJson, builder: (column) => column);
}

class $$FoodVariantsTableTableManager
    extends
        RootTableManager<
          _$CoreDatabase,
          $FoodVariantsTable,
          FoodVariant,
          $$FoodVariantsTableFilterComposer,
          $$FoodVariantsTableOrderingComposer,
          $$FoodVariantsTableAnnotationComposer,
          $$FoodVariantsTableCreateCompanionBuilder,
          $$FoodVariantsTableUpdateCompanionBuilder,
          (
            FoodVariant,
            BaseReferences<_$CoreDatabase, $FoodVariantsTable, FoodVariant>,
          ),
          FoodVariant,
          PrefetchHooks Function()
        > {
  $$FoodVariantsTableTableManager(_$CoreDatabase db, $FoodVariantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodVariantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodVariantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodVariantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<Decimal?> densityGPerMl = const Value.absent(),
                Value<Decimal?> gramsPerPiece = const Value.absent(),
                Value<Decimal?> servingSizeG = const Value.absent(),
                Value<Decimal?> energyKcal = const Value.absent(),
                Value<Decimal?> fatG = const Value.absent(),
                Value<Decimal?> saturatedFatG = const Value.absent(),
                Value<Decimal?> carbsG = const Value.absent(),
                Value<Decimal?> sugarsG = const Value.absent(),
                Value<Decimal?> fiberG = const Value.absent(),
                Value<Decimal?> proteinG = const Value.absent(),
                Value<Decimal?> saltG = const Value.absent(),
                Value<String> extraJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodVariantsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                brand: brand,
                barcode: barcode,
                source: source,
                sourceRef: sourceRef,
                ownerId: ownerId,
                densityGPerMl: densityGPerMl,
                gramsPerPiece: gramsPerPiece,
                servingSizeG: servingSizeG,
                energyKcal: energyKcal,
                fatG: fatG,
                saturatedFatG: saturatedFatG,
                carbsG: carbsG,
                sugarsG: sugarsG,
                fiberG: fiberG,
                proteinG: proteinG,
                saltG: saltG,
                extraJson: extraJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required String source,
                Value<String?> sourceRef = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<Decimal?> densityGPerMl = const Value.absent(),
                Value<Decimal?> gramsPerPiece = const Value.absent(),
                Value<Decimal?> servingSizeG = const Value.absent(),
                Value<Decimal?> energyKcal = const Value.absent(),
                Value<Decimal?> fatG = const Value.absent(),
                Value<Decimal?> saturatedFatG = const Value.absent(),
                Value<Decimal?> carbsG = const Value.absent(),
                Value<Decimal?> sugarsG = const Value.absent(),
                Value<Decimal?> fiberG = const Value.absent(),
                Value<Decimal?> proteinG = const Value.absent(),
                Value<Decimal?> saltG = const Value.absent(),
                Value<String> extraJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodVariantsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                brand: brand,
                barcode: barcode,
                source: source,
                sourceRef: sourceRef,
                ownerId: ownerId,
                densityGPerMl: densityGPerMl,
                gramsPerPiece: gramsPerPiece,
                servingSizeG: servingSizeG,
                energyKcal: energyKcal,
                fatG: fatG,
                saturatedFatG: saturatedFatG,
                carbsG: carbsG,
                sugarsG: sugarsG,
                fiberG: fiberG,
                proteinG: proteinG,
                saltG: saltG,
                extraJson: extraJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodVariantsTable, FoodVariant>(table),
                  BaseReferences<
                    _$CoreDatabase,
                    $FoodVariantsTable,
                    FoodVariant
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodVariantsTableProcessedTableManager =
    ProcessedTableManager<
      _$CoreDatabase,
      $FoodVariantsTable,
      FoodVariant,
      $$FoodVariantsTableFilterComposer,
      $$FoodVariantsTableOrderingComposer,
      $$FoodVariantsTableAnnotationComposer,
      $$FoodVariantsTableCreateCompanionBuilder,
      $$FoodVariantsTableUpdateCompanionBuilder,
      (
        FoodVariant,
        BaseReferences<_$CoreDatabase, $FoodVariantsTable, FoodVariant>,
      ),
      FoodVariant,
      PrefetchHooks Function()
    >;

class $CoreDatabaseManager {
  final _$CoreDatabase _db;
  $CoreDatabaseManager(this._db);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeVersionsTableTableManager get recipeVersions =>
      $$RecipeVersionsTableTableManager(_db, _db.recipeVersions);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$RecipeStepsTableTableManager get recipeSteps =>
      $$RecipeStepsTableTableManager(_db, _db.recipeSteps);
  $$FoodVariantsTableTableManager get foodVariants =>
      $$FoodVariantsTableTableManager(_db, _db.foodVariants);
}
