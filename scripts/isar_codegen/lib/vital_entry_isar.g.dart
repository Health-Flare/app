// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vital_entry_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVitalEntryIsarCollection on Isar {
  IsarCollection<VitalEntryIsar> get vitalEntryIsars => this.collection();
}

const VitalEntryIsarSchema = CollectionSchema(
  name: r'VitalEntryIsar',
  id: -8188326099303951538,
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
    r'notes': PropertySchema(id: 3, name: r'notes', type: IsarType.string),
    r'profileId': PropertySchema(
      id: 4,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'unit': PropertySchema(id: 5, name: r'unit', type: IsarType.string),
    r'value': PropertySchema(id: 6, name: r'value', type: IsarType.double),
    r'value2': PropertySchema(id: 7, name: r'value2', type: IsarType.double),
    r'vitalType': PropertySchema(
      id: 8,
      name: r'vitalType',
      type: IsarType.string,
    ),
  },
  estimateSize: _vitalEntryIsarEstimateSize,
  serialize: _vitalEntryIsarSerialize,
  deserialize: _vitalEntryIsarDeserialize,
  deserializeProp: _vitalEntryIsarDeserializeProp,
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
  getId: _vitalEntryIsarGetId,
  getLinks: _vitalEntryIsarGetLinks,
  attach: _vitalEntryIsarAttach,
  version: '3.3.0',
);

int _vitalEntryIsarEstimateSize(
  VitalEntryIsar object,
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
  bytesCount += 3 + object.unit.length * 3;
  bytesCount += 3 + object.vitalType.length * 3;
  return bytesCount;
}

void _vitalEntryIsarSerialize(
  VitalEntryIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.flareIsarId);
  writer.writeDateTime(offsets[2], object.loggedAt);
  writer.writeString(offsets[3], object.notes);
  writer.writeLong(offsets[4], object.profileId);
  writer.writeString(offsets[5], object.unit);
  writer.writeDouble(offsets[6], object.value);
  writer.writeDouble(offsets[7], object.value2);
  writer.writeString(offsets[8], object.vitalType);
}

VitalEntryIsar _vitalEntryIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VitalEntryIsar();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.flareIsarId = reader.readLongOrNull(offsets[1]);
  object.id = id;
  object.loggedAt = reader.readDateTime(offsets[2]);
  object.notes = reader.readStringOrNull(offsets[3]);
  object.profileId = reader.readLong(offsets[4]);
  object.unit = reader.readString(offsets[5]);
  object.value = reader.readDouble(offsets[6]);
  object.value2 = reader.readDoubleOrNull(offsets[7]);
  object.vitalType = reader.readString(offsets[8]);
  return object;
}

P _vitalEntryIsarDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _vitalEntryIsarGetId(VitalEntryIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vitalEntryIsarGetLinks(VitalEntryIsar object) {
  return [];
}

void _vitalEntryIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  VitalEntryIsar object,
) {
  object.id = id;
}

extension VitalEntryIsarQueryWhereSort
    on QueryBuilder<VitalEntryIsar, VitalEntryIsar, QWhere> {
  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhere> anyLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'loggedAt'),
      );
    });
  }
}

extension VitalEntryIsarQueryWhere
    on QueryBuilder<VitalEntryIsar, VitalEntryIsar, QWhereClause> {
  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause>
  profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'profileId', value: [profileId]),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause>
  loggedAtEqualTo(DateTime loggedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'loggedAt', value: [loggedAt]),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterWhereClause>
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

extension VitalEntryIsarQueryFilter
    on QueryBuilder<VitalEntryIsar, VitalEntryIsar, QFilterCondition> {
  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  flareIsarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'flareIsarId'),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  flareIsarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'flareIsarId'),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  flareIsarIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'flareIsarId', value: value),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  loggedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'loggedAt', value: value),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'profileId', value: value),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
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

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  unitEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  unitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  unitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  unitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  unitStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  unitEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  unitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  unitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'unit',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unit', value: ''),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'unit', value: ''),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  valueEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'value',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  valueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'value',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  valueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'value',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  valueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'value',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  value2IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'value2'),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  value2IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'value2'),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  value2EqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'value2',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  value2GreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'value2',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  value2LessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'value2',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  value2Between(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'value2',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  vitalTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'vitalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  vitalTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'vitalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  vitalTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'vitalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  vitalTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'vitalType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  vitalTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'vitalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  vitalTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'vitalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  vitalTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'vitalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  vitalTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'vitalType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  vitalTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'vitalType', value: ''),
      );
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterFilterCondition>
  vitalTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'vitalType', value: ''),
      );
    });
  }
}

extension VitalEntryIsarQueryObject
    on QueryBuilder<VitalEntryIsar, VitalEntryIsar, QFilterCondition> {}

extension VitalEntryIsarQueryLinks
    on QueryBuilder<VitalEntryIsar, VitalEntryIsar, QFilterCondition> {}

extension VitalEntryIsarQuerySortBy
    on QueryBuilder<VitalEntryIsar, VitalEntryIsar, QSortBy> {
  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  sortByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  sortByFlareIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> sortByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  sortByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> sortByValue2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value2', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  sortByValue2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value2', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> sortByVitalType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitalType', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  sortByVitalTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitalType', Sort.desc);
    });
  }
}

extension VitalEntryIsarQuerySortThenBy
    on QueryBuilder<VitalEntryIsar, VitalEntryIsar, QSortThenBy> {
  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  thenByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  thenByFlareIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  thenByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByValue2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value2', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  thenByValue2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value2', Sort.desc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy> thenByVitalType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitalType', Sort.asc);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QAfterSortBy>
  thenByVitalTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitalType', Sort.desc);
    });
  }
}

extension VitalEntryIsarQueryWhereDistinct
    on QueryBuilder<VitalEntryIsar, VitalEntryIsar, QDistinct> {
  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QDistinct>
  distinctByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'flareIsarId');
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QDistinct> distinctByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loggedAt');
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QDistinct>
  distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QDistinct> distinctByUnit({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QDistinct> distinctByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value');
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QDistinct> distinctByValue2() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value2');
    });
  }

  QueryBuilder<VitalEntryIsar, VitalEntryIsar, QDistinct> distinctByVitalType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vitalType', caseSensitive: caseSensitive);
    });
  }
}

extension VitalEntryIsarQueryProperty
    on QueryBuilder<VitalEntryIsar, VitalEntryIsar, QQueryProperty> {
  QueryBuilder<VitalEntryIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VitalEntryIsar, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<VitalEntryIsar, int?, QQueryOperations> flareIsarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'flareIsarId');
    });
  }

  QueryBuilder<VitalEntryIsar, DateTime, QQueryOperations> loggedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loggedAt');
    });
  }

  QueryBuilder<VitalEntryIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<VitalEntryIsar, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<VitalEntryIsar, String, QQueryOperations> unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }

  QueryBuilder<VitalEntryIsar, double, QQueryOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }

  QueryBuilder<VitalEntryIsar, double?, QQueryOperations> value2Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value2');
    });
  }

  QueryBuilder<VitalEntryIsar, String, QQueryOperations> vitalTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vitalType');
    });
  }
}
