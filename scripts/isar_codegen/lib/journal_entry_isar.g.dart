// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetJournalEntryIsarCollection on Isar {
  IsarCollection<JournalEntryIsar> get journalEntryIsars => this.collection();
}

const JournalEntryIsarSchema = CollectionSchema(
  name: r'JournalEntryIsar',
  id: -2124416504372144628,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'energyLevel': PropertySchema(
      id: 1,
      name: r'energyLevel',
      type: IsarType.long,
    ),
    r'mood': PropertySchema(
      id: 2,
      name: r'mood',
      type: IsarType.long,
    ),
    r'profileId': PropertySchema(
      id: 3,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'snapshots': PropertySchema(
      id: 4,
      name: r'snapshots',
      type: IsarType.objectList,
      target: r'JournalSnapshotIsar',
    )
  },
  estimateSize: _journalEntryIsarEstimateSize,
  serialize: _journalEntryIsarSerialize,
  deserialize: _journalEntryIsarDeserialize,
  deserializeProp: _journalEntryIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'profileId': IndexSchema(
      id: 6052971939042612300,
      name: r'profileId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'profileId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'JournalSnapshotIsar': JournalSnapshotIsarSchema},
  getId: _journalEntryIsarGetId,
  getLinks: _journalEntryIsarGetLinks,
  attach: _journalEntryIsarAttach,
  version: '3.3.0',
);

int _journalEntryIsarEstimateSize(
  JournalEntryIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.snapshots.length * 3;
  {
    final offsets = allOffsets[JournalSnapshotIsar]!;
    for (var i = 0; i < object.snapshots.length; i++) {
      final value = object.snapshots[i];
      bytesCount +=
          JournalSnapshotIsarSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _journalEntryIsarSerialize(
  JournalEntryIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.energyLevel);
  writer.writeLong(offsets[2], object.mood);
  writer.writeLong(offsets[3], object.profileId);
  writer.writeObjectList<JournalSnapshotIsar>(
    offsets[4],
    allOffsets,
    JournalSnapshotIsarSchema.serialize,
    object.snapshots,
  );
}

JournalEntryIsar _journalEntryIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = JournalEntryIsar();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.energyLevel = reader.readLongOrNull(offsets[1]);
  object.id = id;
  object.mood = reader.readLongOrNull(offsets[2]);
  object.profileId = reader.readLong(offsets[3]);
  object.snapshots = reader.readObjectList<JournalSnapshotIsar>(
        offsets[4],
        JournalSnapshotIsarSchema.deserialize,
        allOffsets,
        JournalSnapshotIsar(),
      ) ??
      [];
  return object;
}

P _journalEntryIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readObjectList<JournalSnapshotIsar>(
            offset,
            JournalSnapshotIsarSchema.deserialize,
            allOffsets,
            JournalSnapshotIsar(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _journalEntryIsarGetId(JournalEntryIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _journalEntryIsarGetLinks(JournalEntryIsar object) {
  return [];
}

void _journalEntryIsarAttach(
    IsarCollection<dynamic> col, Id id, JournalEntryIsar object) {
  object.id = id;
}

extension JournalEntryIsarQueryWhereSort
    on QueryBuilder<JournalEntryIsar, JournalEntryIsar, QWhere> {
  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension JournalEntryIsarQueryWhere
    on QueryBuilder<JournalEntryIsar, JournalEntryIsar, QWhereClause> {
  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      profileIdNotEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [],
              upper: [profileId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [profileId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [profileId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [],
              upper: [profileId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      profileIdGreaterThan(
    int profileId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId',
        lower: [profileId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      profileIdLessThan(
    int profileId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId',
        lower: [],
        upper: [profileId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      profileIdBetween(
    int lowerProfileId,
    int upperProfileId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId',
        lower: [lowerProfileId],
        includeLower: includeLower,
        upper: [upperProfileId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterWhereClause>
      createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension JournalEntryIsarQueryFilter
    on QueryBuilder<JournalEntryIsar, JournalEntryIsar, QFilterCondition> {
  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      energyLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'energyLevel',
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      energyLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'energyLevel',
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      energyLevelEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'energyLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      energyLevelGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'energyLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      energyLevelLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'energyLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      energyLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'energyLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      moodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mood',
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      moodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mood',
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      moodEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mood',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      moodGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mood',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      moodLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mood',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      moodBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mood',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      profileIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      profileIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      profileIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'profileId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      snapshotsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snapshots',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      snapshotsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snapshots',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      snapshotsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snapshots',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      snapshotsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snapshots',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      snapshotsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snapshots',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      snapshotsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snapshots',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension JournalEntryIsarQueryObject
    on QueryBuilder<JournalEntryIsar, JournalEntryIsar, QFilterCondition> {
  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterFilterCondition>
      snapshotsElement(FilterQuery<JournalSnapshotIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'snapshots');
    });
  }
}

extension JournalEntryIsarQueryLinks
    on QueryBuilder<JournalEntryIsar, JournalEntryIsar, QFilterCondition> {}

extension JournalEntryIsarQuerySortBy
    on QueryBuilder<JournalEntryIsar, JournalEntryIsar, QSortBy> {
  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      sortByEnergyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyLevel', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      sortByEnergyLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyLevel', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy> sortByMood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      sortByMoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }
}

extension JournalEntryIsarQuerySortThenBy
    on QueryBuilder<JournalEntryIsar, JournalEntryIsar, QSortThenBy> {
  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      thenByEnergyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyLevel', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      thenByEnergyLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyLevel', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy> thenByMood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      thenByMoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.desc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }
}

extension JournalEntryIsarQueryWhereDistinct
    on QueryBuilder<JournalEntryIsar, JournalEntryIsar, QDistinct> {
  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QDistinct>
      distinctByEnergyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'energyLevel');
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QDistinct> distinctByMood() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mood');
    });
  }

  QueryBuilder<JournalEntryIsar, JournalEntryIsar, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }
}

extension JournalEntryIsarQueryProperty
    on QueryBuilder<JournalEntryIsar, JournalEntryIsar, QQueryProperty> {
  QueryBuilder<JournalEntryIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<JournalEntryIsar, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<JournalEntryIsar, int?, QQueryOperations> energyLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'energyLevel');
    });
  }

  QueryBuilder<JournalEntryIsar, int?, QQueryOperations> moodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mood');
    });
  }

  QueryBuilder<JournalEntryIsar, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<JournalEntryIsar, List<JournalSnapshotIsar>, QQueryOperations>
      snapshotsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snapshots');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const JournalSnapshotIsarSchema = Schema(
  name: r'JournalSnapshotIsar',
  id: -4206581265085856407,
  properties: {
    r'body': PropertySchema(
      id: 0,
      name: r'body',
      type: IsarType.string,
    ),
    r'savedAt': PropertySchema(
      id: 1,
      name: r'savedAt',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(
      id: 2,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _journalSnapshotIsarEstimateSize,
  serialize: _journalSnapshotIsarSerialize,
  deserialize: _journalSnapshotIsarDeserialize,
  deserializeProp: _journalSnapshotIsarDeserializeProp,
);

int _journalSnapshotIsarEstimateSize(
  JournalSnapshotIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.body.length * 3;
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _journalSnapshotIsarSerialize(
  JournalSnapshotIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.body);
  writer.writeDateTime(offsets[1], object.savedAt);
  writer.writeString(offsets[2], object.title);
}

JournalSnapshotIsar _journalSnapshotIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = JournalSnapshotIsar();
  object.body = reader.readString(offsets[0]);
  object.savedAt = reader.readDateTime(offsets[1]);
  object.title = reader.readStringOrNull(offsets[2]);
  return object;
}

P _journalSnapshotIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension JournalSnapshotIsarQueryFilter on QueryBuilder<JournalSnapshotIsar,
    JournalSnapshotIsar, QFilterCondition> {
  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      bodyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      bodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      bodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      bodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'body',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      bodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      bodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      bodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      bodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'body',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      bodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      bodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      savedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      savedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      savedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      savedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<JournalSnapshotIsar, JournalSnapshotIsar, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension JournalSnapshotIsarQueryObject on QueryBuilder<JournalSnapshotIsar,
    JournalSnapshotIsar, QFilterCondition> {}
