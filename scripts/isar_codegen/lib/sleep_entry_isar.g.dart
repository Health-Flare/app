// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_entry_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSleepEntryIsarCollection on Isar {
  IsarCollection<SleepEntryIsar> get sleepEntryIsars => this.collection();
}

const SleepEntryIsarSchema = CollectionSchema(
  name: r'SleepEntryIsar',
  id: 2388838124894363134,
  properties: {
    r'bedtime': PropertySchema(
      id: 0,
      name: r'bedtime',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isNap': PropertySchema(
      id: 2,
      name: r'isNap',
      type: IsarType.bool,
    ),
    r'notes': PropertySchema(
      id: 3,
      name: r'notes',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 4,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'qualityRating': PropertySchema(
      id: 5,
      name: r'qualityRating',
      type: IsarType.long,
    ),
    r'wakeTime': PropertySchema(
      id: 6,
      name: r'wakeTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _sleepEntryIsarEstimateSize,
  serialize: _sleepEntryIsarSerialize,
  deserialize: _sleepEntryIsarDeserialize,
  deserializeProp: _sleepEntryIsarDeserializeProp,
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
    r'wakeTime': IndexSchema(
      id: -1914056347915511836,
      name: r'wakeTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'wakeTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _sleepEntryIsarGetId,
  getLinks: _sleepEntryIsarGetLinks,
  attach: _sleepEntryIsarAttach,
  version: '3.3.0',
);

int _sleepEntryIsarEstimateSize(
  SleepEntryIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _sleepEntryIsarSerialize(
  SleepEntryIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.bedtime);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeBool(offsets[2], object.isNap);
  writer.writeString(offsets[3], object.notes);
  writer.writeLong(offsets[4], object.profileId);
  writer.writeLong(offsets[5], object.qualityRating);
  writer.writeDateTime(offsets[6], object.wakeTime);
}

SleepEntryIsar _sleepEntryIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SleepEntryIsar();
  object.bedtime = reader.readDateTime(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.isNap = reader.readBool(offsets[2]);
  object.notes = reader.readStringOrNull(offsets[3]);
  object.profileId = reader.readLong(offsets[4]);
  object.qualityRating = reader.readLongOrNull(offsets[5]);
  object.wakeTime = reader.readDateTime(offsets[6]);
  return object;
}

P _sleepEntryIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sleepEntryIsarGetId(SleepEntryIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sleepEntryIsarGetLinks(SleepEntryIsar object) {
  return [];
}

void _sleepEntryIsarAttach(
    IsarCollection<dynamic> col, Id id, SleepEntryIsar object) {
  object.id = id;
}

extension SleepEntryIsarQueryWhereSort
    on QueryBuilder<SleepEntryIsar, SleepEntryIsar, QWhere> {
  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhere> anyWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'wakeTime'),
      );
    });
  }
}

extension SleepEntryIsarQueryWhere
    on QueryBuilder<SleepEntryIsar, SleepEntryIsar, QWhereClause> {
  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause>
      profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause>
      wakeTimeEqualTo(DateTime wakeTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'wakeTime',
        value: [wakeTime],
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause>
      wakeTimeNotEqualTo(DateTime wakeTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'wakeTime',
              lower: [],
              upper: [wakeTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'wakeTime',
              lower: [wakeTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'wakeTime',
              lower: [wakeTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'wakeTime',
              lower: [],
              upper: [wakeTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause>
      wakeTimeGreaterThan(
    DateTime wakeTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'wakeTime',
        lower: [wakeTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause>
      wakeTimeLessThan(
    DateTime wakeTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'wakeTime',
        lower: [],
        upper: [wakeTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterWhereClause>
      wakeTimeBetween(
    DateTime lowerWakeTime,
    DateTime upperWakeTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'wakeTime',
        lower: [lowerWakeTime],
        includeLower: includeLower,
        upper: [upperWakeTime],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SleepEntryIsarQueryFilter
    on QueryBuilder<SleepEntryIsar, SleepEntryIsar, QFilterCondition> {
  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      bedtimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bedtime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      bedtimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bedtime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      bedtimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bedtime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      bedtimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bedtime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      isNapEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNap',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      qualityRatingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'qualityRating',
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      qualityRatingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'qualityRating',
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      qualityRatingEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qualityRating',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      qualityRatingGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qualityRating',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      qualityRatingLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qualityRating',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      qualityRatingBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qualityRating',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      wakeTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wakeTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      wakeTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wakeTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      wakeTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wakeTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterFilterCondition>
      wakeTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wakeTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SleepEntryIsarQueryObject
    on QueryBuilder<SleepEntryIsar, SleepEntryIsar, QFilterCondition> {}

extension SleepEntryIsarQueryLinks
    on QueryBuilder<SleepEntryIsar, SleepEntryIsar, QFilterCondition> {}

extension SleepEntryIsarQuerySortBy
    on QueryBuilder<SleepEntryIsar, SleepEntryIsar, QSortBy> {
  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> sortByBedtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bedtime', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      sortByBedtimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bedtime', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> sortByIsNap() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNap', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> sortByIsNapDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNap', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      sortByQualityRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualityRating', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      sortByQualityRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualityRating', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> sortByWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      sortByWakeTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.desc);
    });
  }
}

extension SleepEntryIsarQuerySortThenBy
    on QueryBuilder<SleepEntryIsar, SleepEntryIsar, QSortThenBy> {
  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> thenByBedtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bedtime', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      thenByBedtimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bedtime', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> thenByIsNap() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNap', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> thenByIsNapDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNap', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      thenByQualityRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualityRating', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      thenByQualityRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualityRating', Sort.desc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy> thenByWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.asc);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QAfterSortBy>
      thenByWakeTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.desc);
    });
  }
}

extension SleepEntryIsarQueryWhereDistinct
    on QueryBuilder<SleepEntryIsar, SleepEntryIsar, QDistinct> {
  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QDistinct> distinctByBedtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bedtime');
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QDistinct> distinctByIsNap() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNap');
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QDistinct>
      distinctByQualityRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qualityRating');
    });
  }

  QueryBuilder<SleepEntryIsar, SleepEntryIsar, QDistinct> distinctByWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wakeTime');
    });
  }
}

extension SleepEntryIsarQueryProperty
    on QueryBuilder<SleepEntryIsar, SleepEntryIsar, QQueryProperty> {
  QueryBuilder<SleepEntryIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SleepEntryIsar, DateTime, QQueryOperations> bedtimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bedtime');
    });
  }

  QueryBuilder<SleepEntryIsar, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SleepEntryIsar, bool, QQueryOperations> isNapProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNap');
    });
  }

  QueryBuilder<SleepEntryIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<SleepEntryIsar, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<SleepEntryIsar, int?, QQueryOperations> qualityRatingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qualityRating');
    });
  }

  QueryBuilder<SleepEntryIsar, DateTime, QQueryOperations> wakeTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wakeTime');
    });
  }
}
