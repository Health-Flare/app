// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_checkin_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyCheckinIsarCollection on Isar {
  IsarCollection<DailyCheckinIsar> get dailyCheckinIsars => this.collection();
}

const DailyCheckinIsarSchema = CollectionSchema(
  name: r'DailyCheckinIsar',
  id: 2343226318212419747,
  properties: {
    r'checkinDate': PropertySchema(
      id: 0,
      name: r'checkinDate',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'cyclePhase': PropertySchema(
      id: 2,
      name: r'cyclePhase',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(id: 3, name: r'notes', type: IsarType.string),
    r'profileId': PropertySchema(
      id: 4,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'stressLevel': PropertySchema(
      id: 5,
      name: r'stressLevel',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'weatherSnapshot': PropertySchema(
      id: 7,
      name: r'weatherSnapshot',
      type: IsarType.object,
      target: r'WeatherSnapshotIsar',
    ),
    r'wellbeing': PropertySchema(
      id: 8,
      name: r'wellbeing',
      type: IsarType.long,
    ),
  },
  estimateSize: _dailyCheckinIsarEstimateSize,
  serialize: _dailyCheckinIsarSerialize,
  deserialize: _dailyCheckinIsarDeserialize,
  deserializeProp: _dailyCheckinIsarDeserializeProp,
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
        ),
      ],
    ),
    r'checkinDate': IndexSchema(
      id: -681195849625738402,
      name: r'checkinDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'checkinDate',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'WeatherSnapshotIsar': WeatherSnapshotIsarSchema},
  getId: _dailyCheckinIsarGetId,
  getLinks: _dailyCheckinIsarGetLinks,
  attach: _dailyCheckinIsarAttach,
  version: '3.3.0',
);

int _dailyCheckinIsarEstimateSize(
  DailyCheckinIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cyclePhase;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.stressLevel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.weatherSnapshot;
    if (value != null) {
      bytesCount +=
          3 +
          WeatherSnapshotIsarSchema.estimateSize(
            value,
            allOffsets[WeatherSnapshotIsar]!,
            allOffsets,
          );
    }
  }
  return bytesCount;
}

void _dailyCheckinIsarSerialize(
  DailyCheckinIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.checkinDate);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.cyclePhase);
  writer.writeString(offsets[3], object.notes);
  writer.writeLong(offsets[4], object.profileId);
  writer.writeString(offsets[5], object.stressLevel);
  writer.writeDateTime(offsets[6], object.updatedAt);
  writer.writeObject<WeatherSnapshotIsar>(
    offsets[7],
    allOffsets,
    WeatherSnapshotIsarSchema.serialize,
    object.weatherSnapshot,
  );
  writer.writeLong(offsets[8], object.wellbeing);
}

DailyCheckinIsar _dailyCheckinIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyCheckinIsar();
  object.checkinDate = reader.readDateTime(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.cyclePhase = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.notes = reader.readStringOrNull(offsets[3]);
  object.profileId = reader.readLong(offsets[4]);
  object.stressLevel = reader.readStringOrNull(offsets[5]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[6]);
  object.weatherSnapshot = reader.readObjectOrNull<WeatherSnapshotIsar>(
    offsets[7],
    WeatherSnapshotIsarSchema.deserialize,
    allOffsets,
  );
  object.wellbeing = reader.readLong(offsets[8]);
  return object;
}

P _dailyCheckinIsarDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readObjectOrNull<WeatherSnapshotIsar>(
            offset,
            WeatherSnapshotIsarSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyCheckinIsarGetId(DailyCheckinIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyCheckinIsarGetLinks(DailyCheckinIsar object) {
  return [];
}

void _dailyCheckinIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  DailyCheckinIsar object,
) {
  object.id = id;
}

extension DailyCheckinIsarQueryWhereSort
    on QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QWhere> {
  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhere>
  anyCheckinDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'checkinDate'),
      );
    });
  }
}

extension DailyCheckinIsarQueryWhere
    on QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QWhereClause> {
  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
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

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'profileId', value: [profileId]),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  profileIdNotEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'profileId',
                lower: [],
                upper: [profileId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'profileId',
                lower: [profileId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'profileId',
                lower: [profileId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'profileId',
                lower: [],
                upper: [profileId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  profileIdGreaterThan(int profileId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'profileId',
          lower: [profileId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  profileIdLessThan(int profileId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'profileId',
          lower: [],
          upper: [profileId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  profileIdBetween(
    int lowerProfileId,
    int upperProfileId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'profileId',
          lower: [lowerProfileId],
          includeLower: includeLower,
          upper: [upperProfileId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  checkinDateEqualTo(DateTime checkinDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'checkinDate',
          value: [checkinDate],
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  checkinDateNotEqualTo(DateTime checkinDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'checkinDate',
                lower: [],
                upper: [checkinDate],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'checkinDate',
                lower: [checkinDate],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'checkinDate',
                lower: [checkinDate],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'checkinDate',
                lower: [],
                upper: [checkinDate],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  checkinDateGreaterThan(DateTime checkinDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'checkinDate',
          lower: [checkinDate],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  checkinDateLessThan(DateTime checkinDate, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'checkinDate',
          lower: [],
          upper: [checkinDate],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterWhereClause>
  checkinDateBetween(
    DateTime lowerCheckinDate,
    DateTime upperCheckinDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'checkinDate',
          lower: [lowerCheckinDate],
          includeLower: includeLower,
          upper: [upperCheckinDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DailyCheckinIsarQueryFilter
    on QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QFilterCondition> {
  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  checkinDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'checkinDate', value: value),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  checkinDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'checkinDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  checkinDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'checkinDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  checkinDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'checkinDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cyclePhase'),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cyclePhase'),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cyclePhase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cyclePhase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cyclePhase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cyclePhase',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cyclePhase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cyclePhase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cyclePhase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cyclePhase',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cyclePhase', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  cyclePhaseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cyclePhase', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'profileId', value: value),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  profileIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'profileId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  profileIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'profileId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  profileIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'profileId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'stressLevel'),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'stressLevel'),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'stressLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stressLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stressLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stressLevel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'stressLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'stressLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'stressLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'stressLevel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stressLevel', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  stressLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'stressLevel', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  updatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  weatherSnapshotIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'weatherSnapshot'),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  weatherSnapshotIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'weatherSnapshot'),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  wellbeingEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'wellbeing', value: value),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  wellbeingGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'wellbeing',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  wellbeingLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'wellbeing',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  wellbeingBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'wellbeing',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DailyCheckinIsarQueryObject
    on QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QFilterCondition> {
  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterFilterCondition>
  weatherSnapshot(FilterQuery<WeatherSnapshotIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'weatherSnapshot');
    });
  }
}

extension DailyCheckinIsarQueryLinks
    on QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QFilterCondition> {}

extension DailyCheckinIsarQuerySortBy
    on QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QSortBy> {
  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByCheckinDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkinDate', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByCheckinDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkinDate', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByCyclePhase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cyclePhase', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByCyclePhaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cyclePhase', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByStressLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByStressLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByWellbeing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellbeing', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  sortByWellbeingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellbeing', Sort.desc);
    });
  }
}

extension DailyCheckinIsarQuerySortThenBy
    on QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QSortThenBy> {
  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByCheckinDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkinDate', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByCheckinDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkinDate', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByCyclePhase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cyclePhase', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByCyclePhaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cyclePhase', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByStressLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByStressLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByWellbeing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellbeing', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QAfterSortBy>
  thenByWellbeingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellbeing', Sort.desc);
    });
  }
}

extension DailyCheckinIsarQueryWhereDistinct
    on QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QDistinct> {
  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QDistinct>
  distinctByCheckinDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkinDate');
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QDistinct>
  distinctByCyclePhase({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cyclePhase', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QDistinct>
  distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QDistinct>
  distinctByStressLevel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stressLevel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QDistinct>
  distinctByWellbeing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wellbeing');
    });
  }
}

extension DailyCheckinIsarQueryProperty
    on QueryBuilder<DailyCheckinIsar, DailyCheckinIsar, QQueryProperty> {
  QueryBuilder<DailyCheckinIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyCheckinIsar, DateTime, QQueryOperations>
  checkinDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkinDate');
    });
  }

  QueryBuilder<DailyCheckinIsar, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DailyCheckinIsar, String?, QQueryOperations>
  cyclePhaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cyclePhase');
    });
  }

  QueryBuilder<DailyCheckinIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<DailyCheckinIsar, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<DailyCheckinIsar, String?, QQueryOperations>
  stressLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stressLevel');
    });
  }

  QueryBuilder<DailyCheckinIsar, DateTime?, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<DailyCheckinIsar, WeatherSnapshotIsar?, QQueryOperations>
  weatherSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weatherSnapshot');
    });
  }

  QueryBuilder<DailyCheckinIsar, int, QQueryOperations> wellbeingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wellbeing');
    });
  }
}
