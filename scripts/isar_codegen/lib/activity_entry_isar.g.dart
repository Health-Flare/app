// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_entry_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetActivityEntryIsarCollection on Isar {
  IsarCollection<ActivityEntryIsar> get activityEntryIsars => this.collection();
}

const ActivityEntryIsarSchema = CollectionSchema(
  name: r'ActivityEntryIsar',
  id: -7190157713795349152,
  properties: {
    r'activityType': PropertySchema(
      id: 0,
      name: r'activityType',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'durationMinutes': PropertySchema(
      id: 3,
      name: r'durationMinutes',
      type: IsarType.long,
    ),
    r'effortLevel': PropertySchema(
      id: 4,
      name: r'effortLevel',
      type: IsarType.long,
    ),
    r'flareIsarId': PropertySchema(
      id: 5,
      name: r'flareIsarId',
      type: IsarType.long,
    ),
    r'loggedAt': PropertySchema(
      id: 6,
      name: r'loggedAt',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(id: 7, name: r'notes', type: IsarType.string),
    r'profileId': PropertySchema(
      id: 8,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'weatherSnapshot': PropertySchema(
      id: 10,
      name: r'weatherSnapshot',
      type: IsarType.object,
      target: r'WeatherSnapshotIsar',
    ),
  },
  estimateSize: _activityEntryIsarEstimateSize,
  serialize: _activityEntryIsarSerialize,
  deserialize: _activityEntryIsarDeserialize,
  deserializeProp: _activityEntryIsarDeserializeProp,
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
    r'loggedAt': IndexSchema(
      id: 1838198766103160564,
      name: r'loggedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'loggedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'WeatherSnapshotIsar': WeatherSnapshotIsarSchema},
  getId: _activityEntryIsarGetId,
  getLinks: _activityEntryIsarGetLinks,
  attach: _activityEntryIsarAttach,
  version: '3.3.0',
);

int _activityEntryIsarEstimateSize(
  ActivityEntryIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.activityType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.description.length * 3;
  {
    final value = object.notes;
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

void _activityEntryIsarSerialize(
  ActivityEntryIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activityType);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.description);
  writer.writeLong(offsets[3], object.durationMinutes);
  writer.writeLong(offsets[4], object.effortLevel);
  writer.writeLong(offsets[5], object.flareIsarId);
  writer.writeDateTime(offsets[6], object.loggedAt);
  writer.writeString(offsets[7], object.notes);
  writer.writeLong(offsets[8], object.profileId);
  writer.writeDateTime(offsets[9], object.updatedAt);
  writer.writeObject<WeatherSnapshotIsar>(
    offsets[10],
    allOffsets,
    WeatherSnapshotIsarSchema.serialize,
    object.weatherSnapshot,
  );
}

ActivityEntryIsar _activityEntryIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ActivityEntryIsar();
  object.activityType = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.description = reader.readString(offsets[2]);
  object.durationMinutes = reader.readLongOrNull(offsets[3]);
  object.effortLevel = reader.readLongOrNull(offsets[4]);
  object.flareIsarId = reader.readLongOrNull(offsets[5]);
  object.id = id;
  object.loggedAt = reader.readDateTime(offsets[6]);
  object.notes = reader.readStringOrNull(offsets[7]);
  object.profileId = reader.readLong(offsets[8]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[9]);
  object.weatherSnapshot = reader.readObjectOrNull<WeatherSnapshotIsar>(
    offsets[10],
    WeatherSnapshotIsarSchema.deserialize,
    allOffsets,
  );
  return object;
}

P _activityEntryIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readObjectOrNull<WeatherSnapshotIsar>(
            offset,
            WeatherSnapshotIsarSchema.deserialize,
            allOffsets,
          ))
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _activityEntryIsarGetId(ActivityEntryIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _activityEntryIsarGetLinks(
  ActivityEntryIsar object,
) {
  return [];
}

void _activityEntryIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  ActivityEntryIsar object,
) {
  object.id = id;
}

extension ActivityEntryIsarQueryWhereSort
    on QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QWhere> {
  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhere>
  anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhere>
  anyLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'loggedAt'),
      );
    });
  }
}

extension ActivityEntryIsarQueryWhere
    on QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QWhereClause> {
  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
  idBetween(
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
  profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'profileId', value: [profileId]),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
  loggedAtEqualTo(DateTime loggedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'loggedAt', value: [loggedAt]),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
  loggedAtNotEqualTo(DateTime loggedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'loggedAt',
                lower: [],
                upper: [loggedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'loggedAt',
                lower: [loggedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'loggedAt',
                lower: [loggedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'loggedAt',
                lower: [],
                upper: [loggedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
  loggedAtGreaterThan(DateTime loggedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'loggedAt',
          lower: [loggedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
  loggedAtLessThan(DateTime loggedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'loggedAt',
          lower: [],
          upper: [loggedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterWhereClause>
  loggedAtBetween(
    DateTime lowerLoggedAt,
    DateTime upperLoggedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'loggedAt',
          lower: [lowerLoggedAt],
          includeLower: includeLower,
          upper: [upperLoggedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ActivityEntryIsarQueryFilter
    on QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QFilterCondition> {
  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'activityType'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'activityType'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'activityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'activityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'activityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'activityType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'activityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'activityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'activityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'activityType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'activityType', value: ''),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  activityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'activityType', value: ''),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  descriptionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  durationMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'durationMinutes'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  durationMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'durationMinutes'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  durationMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationMinutes', value: value),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  durationMinutesGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  durationMinutesLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  durationMinutesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  effortLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'effortLevel'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  effortLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'effortLevel'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  effortLevelEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'effortLevel', value: value),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  effortLevelGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'effortLevel',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  effortLevelLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'effortLevel',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  effortLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'effortLevel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  flareIsarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'flareIsarId'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  flareIsarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'flareIsarId'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  flareIsarIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'flareIsarId', value: value),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  flareIsarIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'flareIsarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  flareIsarIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'flareIsarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  flareIsarIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'flareIsarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  loggedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'loggedAt', value: value),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  loggedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'loggedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  loggedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'loggedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  loggedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'loggedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'profileId', value: value),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  weatherSnapshotIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'weatherSnapshot'),
      );
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  weatherSnapshotIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'weatherSnapshot'),
      );
    });
  }
}

extension ActivityEntryIsarQueryObject
    on QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QFilterCondition> {
  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterFilterCondition>
  weatherSnapshot(FilterQuery<WeatherSnapshotIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'weatherSnapshot');
    });
  }
}

extension ActivityEntryIsarQueryLinks
    on QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QFilterCondition> {}

extension ActivityEntryIsarQuerySortBy
    on QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QSortBy> {
  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByActivityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByActivityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByEffortLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effortLevel', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByEffortLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effortLevel', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByFlareIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ActivityEntryIsarQuerySortThenBy
    on QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QSortThenBy> {
  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByActivityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByActivityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByEffortLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effortLevel', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByEffortLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effortLevel', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByFlareIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ActivityEntryIsarQueryWhereDistinct
    on QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QDistinct> {
  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QDistinct>
  distinctByActivityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QDistinct>
  distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QDistinct>
  distinctByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMinutes');
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QDistinct>
  distinctByEffortLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effortLevel');
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QDistinct>
  distinctByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'flareIsarId');
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QDistinct>
  distinctByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loggedAt');
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QDistinct>
  distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QDistinct>
  distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ActivityEntryIsarQueryProperty
    on QueryBuilder<ActivityEntryIsar, ActivityEntryIsar, QQueryProperty> {
  QueryBuilder<ActivityEntryIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ActivityEntryIsar, String?, QQueryOperations>
  activityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityType');
    });
  }

  QueryBuilder<ActivityEntryIsar, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ActivityEntryIsar, String, QQueryOperations>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<ActivityEntryIsar, int?, QQueryOperations>
  durationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMinutes');
    });
  }

  QueryBuilder<ActivityEntryIsar, int?, QQueryOperations>
  effortLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effortLevel');
    });
  }

  QueryBuilder<ActivityEntryIsar, int?, QQueryOperations>
  flareIsarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'flareIsarId');
    });
  }

  QueryBuilder<ActivityEntryIsar, DateTime, QQueryOperations>
  loggedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loggedAt');
    });
  }

  QueryBuilder<ActivityEntryIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<ActivityEntryIsar, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<ActivityEntryIsar, DateTime?, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<ActivityEntryIsar, WeatherSnapshotIsar?, QQueryOperations>
  weatherSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weatherSnapshot');
    });
  }
}
