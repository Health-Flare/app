// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDoseLogIsarCollection on Isar {
  IsarCollection<DoseLogIsar> get doseLogIsars => this.collection();
}

const DoseLogIsarSchema = CollectionSchema(
  name: r'DoseLogIsar',
  id: -4769545286906262591,
  properties: {
    r'amount': PropertySchema(id: 0, name: r'amount', type: IsarType.double),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'effectiveness': PropertySchema(
      id: 2,
      name: r'effectiveness',
      type: IsarType.string,
    ),
    r'flareIsarId': PropertySchema(
      id: 3,
      name: r'flareIsarId',
      type: IsarType.long,
    ),
    r'loggedAt': PropertySchema(
      id: 4,
      name: r'loggedAt',
      type: IsarType.dateTime,
    ),
    r'medicationIsarId': PropertySchema(
      id: 5,
      name: r'medicationIsarId',
      type: IsarType.long,
    ),
    r'notes': PropertySchema(id: 6, name: r'notes', type: IsarType.string),
    r'profileId': PropertySchema(
      id: 7,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'reason': PropertySchema(id: 8, name: r'reason', type: IsarType.string),
    r'status': PropertySchema(id: 9, name: r'status', type: IsarType.string),
    r'unit': PropertySchema(id: 10, name: r'unit', type: IsarType.string),
  },
  estimateSize: _doseLogIsarEstimateSize,
  serialize: _doseLogIsarSerialize,
  deserialize: _doseLogIsarDeserialize,
  deserializeProp: _doseLogIsarDeserializeProp,
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
    r'medicationIsarId': IndexSchema(
      id: -2464310536086382160,
      name: r'medicationIsarId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'medicationIsarId',
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
  getId: _doseLogIsarGetId,
  getLinks: _doseLogIsarGetLinks,
  attach: _doseLogIsarAttach,
  version: '3.3.0',
);

int _doseLogIsarEstimateSize(
  DoseLogIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.effectiveness;
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
    final value = object.reason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.unit.length * 3;
  return bytesCount;
}

void _doseLogIsarSerialize(
  DoseLogIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.effectiveness);
  writer.writeLong(offsets[3], object.flareIsarId);
  writer.writeDateTime(offsets[4], object.loggedAt);
  writer.writeLong(offsets[5], object.medicationIsarId);
  writer.writeString(offsets[6], object.notes);
  writer.writeLong(offsets[7], object.profileId);
  writer.writeString(offsets[8], object.reason);
  writer.writeString(offsets[9], object.status);
  writer.writeString(offsets[10], object.unit);
}

DoseLogIsar _doseLogIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DoseLogIsar();
  object.amount = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.effectiveness = reader.readStringOrNull(offsets[2]);
  object.flareIsarId = reader.readLongOrNull(offsets[3]);
  object.id = id;
  object.loggedAt = reader.readDateTime(offsets[4]);
  object.medicationIsarId = reader.readLong(offsets[5]);
  object.notes = reader.readStringOrNull(offsets[6]);
  object.profileId = reader.readLong(offsets[7]);
  object.reason = reader.readStringOrNull(offsets[8]);
  object.status = reader.readString(offsets[9]);
  object.unit = reader.readString(offsets[10]);
  return object;
}

P _doseLogIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _doseLogIsarGetId(DoseLogIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _doseLogIsarGetLinks(DoseLogIsar object) {
  return [];
}

void _doseLogIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  DoseLogIsar object,
) {
  object.id = id;
}

extension DoseLogIsarQueryWhereSort
    on QueryBuilder<DoseLogIsar, DoseLogIsar, QWhere> {
  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhere> anyMedicationIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'medicationIsarId'),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhere> anyLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'loggedAt'),
      );
    });
  }
}

extension DoseLogIsarQueryWhere
    on QueryBuilder<DoseLogIsar, DoseLogIsar, QWhereClause> {
  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> profileIdEqualTo(
    int profileId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'profileId', value: [profileId]),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> profileIdNotEqualTo(
    int profileId,
  ) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> profileIdLessThan(
    int profileId, {
    bool include = false,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> profileIdBetween(
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause>
  medicationIsarIdEqualTo(int medicationIsarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'medicationIsarId',
          value: [medicationIsarId],
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause>
  medicationIsarIdNotEqualTo(int medicationIsarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'medicationIsarId',
                lower: [],
                upper: [medicationIsarId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'medicationIsarId',
                lower: [medicationIsarId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'medicationIsarId',
                lower: [medicationIsarId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'medicationIsarId',
                lower: [],
                upper: [medicationIsarId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause>
  medicationIsarIdGreaterThan(int medicationIsarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'medicationIsarId',
          lower: [medicationIsarId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause>
  medicationIsarIdLessThan(int medicationIsarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'medicationIsarId',
          lower: [],
          upper: [medicationIsarId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause>
  medicationIsarIdBetween(
    int lowerMedicationIsarId,
    int upperMedicationIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'medicationIsarId',
          lower: [lowerMedicationIsarId],
          includeLower: includeLower,
          upper: [upperMedicationIsarId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> loggedAtEqualTo(
    DateTime loggedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'loggedAt', value: [loggedAt]),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> loggedAtNotEqualTo(
    DateTime loggedAt,
  ) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> loggedAtGreaterThan(
    DateTime loggedAt, {
    bool include = false,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> loggedAtLessThan(
    DateTime loggedAt, {
    bool include = false,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterWhereClause> loggedAtBetween(
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

extension DoseLogIsarQueryFilter
    on QueryBuilder<DoseLogIsar, DoseLogIsar, QFilterCondition> {
  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'effectiveness'),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'effectiveness'),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'effectiveness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'effectiveness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'effectiveness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'effectiveness',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'effectiveness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'effectiveness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'effectiveness',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'effectiveness',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'effectiveness', value: ''),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  effectivenessIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'effectiveness', value: ''),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  flareIsarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'flareIsarId'),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  flareIsarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'flareIsarId'),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  flareIsarIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'flareIsarId', value: value),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> loggedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'loggedAt', value: value),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> loggedAtBetween(
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  medicationIsarIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'medicationIsarId', value: value),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  medicationIsarIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'medicationIsarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  medicationIsarIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'medicationIsarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  medicationIsarIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'medicationIsarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> notesBetween(
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> notesContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> notesMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'profileId', value: value),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> reasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'reason'),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  reasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'reason'),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> reasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  reasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> reasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> reasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reason',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  reasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> reasonContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> reasonMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'reason',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reason', value: ''),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'reason', value: ''),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> statusContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> statusMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> unitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> unitGreaterThan(
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> unitLessThan(
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> unitBetween(
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> unitContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> unitMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition> unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unit', value: ''),
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterFilterCondition>
  unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'unit', value: ''),
      );
    });
  }
}

extension DoseLogIsarQueryObject
    on QueryBuilder<DoseLogIsar, DoseLogIsar, QFilterCondition> {}

extension DoseLogIsarQueryLinks
    on QueryBuilder<DoseLogIsar, DoseLogIsar, QFilterCondition> {}

extension DoseLogIsarQuerySortBy
    on QueryBuilder<DoseLogIsar, DoseLogIsar, QSortBy> {
  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByEffectiveness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveness', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy>
  sortByEffectivenessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveness', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByFlareIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy>
  sortByMedicationIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationIsarId', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy>
  sortByMedicationIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationIsarId', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }
}

extension DoseLogIsarQuerySortThenBy
    on QueryBuilder<DoseLogIsar, DoseLogIsar, QSortThenBy> {
  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByEffectiveness() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveness', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy>
  thenByEffectivenessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveness', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByFlareIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flareIsarId', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy>
  thenByMedicationIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationIsarId', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy>
  thenByMedicationIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationIsarId', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QAfterSortBy> thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }
}

extension DoseLogIsarQueryWhereDistinct
    on QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct> {
  QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct> distinctByEffectiveness({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'effectiveness',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct> distinctByFlareIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'flareIsarId');
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct> distinctByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loggedAt');
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct>
  distinctByMedicationIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'medicationIsarId');
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct> distinctByReason({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoseLogIsar, DoseLogIsar, QDistinct> distinctByUnit({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit', caseSensitive: caseSensitive);
    });
  }
}

extension DoseLogIsarQueryProperty
    on QueryBuilder<DoseLogIsar, DoseLogIsar, QQueryProperty> {
  QueryBuilder<DoseLogIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DoseLogIsar, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<DoseLogIsar, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DoseLogIsar, String?, QQueryOperations> effectivenessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveness');
    });
  }

  QueryBuilder<DoseLogIsar, int?, QQueryOperations> flareIsarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'flareIsarId');
    });
  }

  QueryBuilder<DoseLogIsar, DateTime, QQueryOperations> loggedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loggedAt');
    });
  }

  QueryBuilder<DoseLogIsar, int, QQueryOperations> medicationIsarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medicationIsarId');
    });
  }

  QueryBuilder<DoseLogIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<DoseLogIsar, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<DoseLogIsar, String?, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<DoseLogIsar, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<DoseLogIsar, String, QQueryOperations> unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }
}
