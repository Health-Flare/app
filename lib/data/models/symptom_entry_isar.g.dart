// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom_entry_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSymptomEntryIsarCollection on Isar {
  IsarCollection<SymptomEntryIsar> get symptomEntryIsars => this.collection();
}

const SymptomEntryIsarSchema = CollectionSchema(
  name: r'SymptomEntryIsar',
  id: -3960743539116373797,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'flareIsarId': PropertySchema(
      id: 1,
      name: r'flareIsarId',
      type: IsarType.long,
    ),
    r'loggedAt': PropertySchema(
      id: 2,
      name: r'loggedAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(id: 3, name: r'name', type: IsarType.string),
    r'notes': PropertySchema(id: 4, name: r'notes', type: IsarType.string),
    r'profileId': PropertySchema(
      id: 5,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'severity': PropertySchema(id: 6, name: r'severity', type: IsarType.long),
    r'userConditionIsarId': PropertySchema(
      id: 7,
      name: r'userConditionIsarId',
      type: IsarType.long,
    ),
    r'userSymptomIsarId': PropertySchema(
      id: 8,
      name: r'userSymptomIsarId',
      type: IsarType.long,
    ),
  },
  estimateSize: _symptomEntryIsarEstimateSize,
  serialize: _symptomEntryIsarSerialize,
  deserialize: _symptomEntryIsarDeserialize,
  deserializeProp: _symptomEntryIsarDeserializeProp,
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
  embeddedSchemas: {},
  getId: _symptomEntryIsarGetId,
  getLinks: _symptomEntryIsarGetLinks,
  attach: _symptomEntryIsarAttach,
  version: '3.3.0',
);

int _symptomEntryIsarEstimateSize(
  SymptomEntryIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _symptomEntryIsarSerialize(
  SymptomEntryIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.flareIsarId);
  writer.writeDateTime(offsets[2], object.loggedAt);
  writer.writeString(offsets[3], object.name);
  writer.writeString(offsets[4], object.notes);
  writer.writeLong(offsets[5], object.profileId);
  writer.writeLong(offsets[6], object.severity);
  writer.writeLong(offsets[7], object.userConditionIsarId);
  writer.writeLong(offsets[8], object.userSymptomIsarId);
}

SymptomEntryIsar _symptomEntryIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SymptomEntryIsar();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.flareIsarId = reader.readLongOrNull(offsets[1]);
  object.id = id;
  object.loggedAt = reader.readDateTime(offsets[2]);
  object.name = reader.readString(offsets[3]);
  object.notes = reader.readStringOrNull(offsets[4]);
  object.profileId = reader.readLong(offsets[5]);
  object.severity = reader.readLong(offsets[6]);
  object.userConditionIsarId = reader.readLongOrNull(offsets[7]);
  object.userSymptomIsarId = reader.readLongOrNull(offsets[8]);
  return object;
}

P _symptomEntryIsarDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _symptomEntryIsarGetId(SymptomEntryIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _symptomEntryIsarGetLinks(SymptomEntryIsar object) {
  return [];
}

void _symptomEntryIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  SymptomEntryIsar object,
) {
  object.id = id;
}

extension SymptomEntryIsarQueryWhereSort
    on QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QWhere> {
  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhere> anyLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'loggedAt'),
      );
    });
  }
}

extension SymptomEntryIsarQueryWhere
    on QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QWhereClause> {
  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
  profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'profileId', value: [profileId]),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
  loggedAtEqualTo(DateTime loggedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'loggedAt', value: [loggedAt]),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterWhereClause>
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

extension SymptomEntryIsarQueryFilter
    on QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QFilterCondition> {
  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  flareIsarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'flareIsarId'),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  flareIsarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'flareIsarId'),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  flareIsarIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'flareIsarId', value: value),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  loggedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'loggedAt', value: value),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'profileId', value: value),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  severityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'severity', value: value),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  severityGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'severity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  severityLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'severity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  severityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'severity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userConditionIsarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'userConditionIsarId'),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userConditionIsarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'userConditionIsarId'),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userConditionIsarIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userConditionIsarId', value: value),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userConditionIsarIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userConditionIsarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userConditionIsarIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userConditionIsarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userConditionIsarIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userConditionIsarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userSymptomIsarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'userSymptomIsarId'),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userSymptomIsarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'userSymptomIsarId'),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userSymptomIsarIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userSymptomIsarId', value: value),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userSymptomIsarIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userSymptomIsarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userSymptomIsarIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userSymptomIsarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterFilterCondition>
  userSymptomIsarIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userSymptomIsarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SymptomEntryIsarQueryObject
    on QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QFilterCondition> {}

extension SymptomEntryIsarQueryLinks
    on QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QFilterCondition> {}

extension SymptomEntryIsarQuerySortBy
    on QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QSortBy> {
  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByFlareIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortBySeverity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortBySeverityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByUserConditionIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userConditionIsarId', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByUserConditionIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userConditionIsarId', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByUserSymptomIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userSymptomIsarId', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  sortByUserSymptomIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userSymptomIsarId', Sort.desc);
    });
  }
}

extension SymptomEntryIsarQuerySortThenBy
    on QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QSortThenBy> {
  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByFlareIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenBySeverity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenBySeverityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByUserConditionIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userConditionIsarId', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByUserConditionIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userConditionIsarId', Sort.desc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByUserSymptomIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userSymptomIsarId', Sort.asc);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QAfterSortBy>
  thenByUserSymptomIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userSymptomIsarId', Sort.desc);
    });
  }
}

extension SymptomEntryIsarQueryWhereDistinct
    on QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QDistinct> {
  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QDistinct>
  distinctByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'flareIsarId');
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QDistinct>
  distinctByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loggedAt');
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QDistinct>
  distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QDistinct>
  distinctBySeverity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'severity');
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QDistinct>
  distinctByUserConditionIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userConditionIsarId');
    });
  }

  QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QDistinct>
  distinctByUserSymptomIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userSymptomIsarId');
    });
  }
}

extension SymptomEntryIsarQueryProperty
    on QueryBuilder<SymptomEntryIsar, SymptomEntryIsar, QQueryProperty> {
  QueryBuilder<SymptomEntryIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SymptomEntryIsar, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SymptomEntryIsar, int?, QQueryOperations> flareIsarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'flareIsarId');
    });
  }

  QueryBuilder<SymptomEntryIsar, DateTime, QQueryOperations>
  loggedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loggedAt');
    });
  }

  QueryBuilder<SymptomEntryIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<SymptomEntryIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<SymptomEntryIsar, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<SymptomEntryIsar, int, QQueryOperations> severityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'severity');
    });
  }

  QueryBuilder<SymptomEntryIsar, int?, QQueryOperations>
  userConditionIsarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userConditionIsarId');
    });
  }

  QueryBuilder<SymptomEntryIsar, int?, QQueryOperations>
  userSymptomIsarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userSymptomIsarId');
    });
  }
}
