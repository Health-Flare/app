// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elimination_entry_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEliminationEntryIsarCollection on Isar {
  IsarCollection<EliminationEntryIsar> get eliminationEntryIsars =>
      this.collection();
}

const EliminationEntryIsarSchema = CollectionSchema(
  name: r'EliminationEntryIsar',
  id: -7838621079663212693,
  properties: {
    r'blood': PropertySchema(
      id: 0,
      name: r'blood',
      type: IsarType.bool,
    ),
    r'bristolType': PropertySchema(
      id: 1,
      name: r'bristolType',
      type: IsarType.long,
    ),
    r'count': PropertySchema(
      id: 2,
      name: r'count',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'kind': PropertySchema(
      id: 4,
      name: r'kind',
      type: IsarType.string,
    ),
    r'loggedAt': PropertySchema(
      id: 5,
      name: r'loggedAt',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 6,
      name: r'notes',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 7,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'urgency': PropertySchema(
      id: 8,
      name: r'urgency',
      type: IsarType.bool,
    )
  },
  estimateSize: _eliminationEntryIsarEstimateSize,
  serialize: _eliminationEntryIsarSerialize,
  deserialize: _eliminationEntryIsarDeserialize,
  deserializeProp: _eliminationEntryIsarDeserializeProp,
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
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _eliminationEntryIsarGetId,
  getLinks: _eliminationEntryIsarGetLinks,
  attach: _eliminationEntryIsarAttach,
  version: '3.3.2',
);

int _eliminationEntryIsarEstimateSize(
  EliminationEntryIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.kind.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _eliminationEntryIsarSerialize(
  EliminationEntryIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.blood);
  writer.writeLong(offsets[1], object.bristolType);
  writer.writeLong(offsets[2], object.count);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.kind);
  writer.writeDateTime(offsets[5], object.loggedAt);
  writer.writeString(offsets[6], object.notes);
  writer.writeLong(offsets[7], object.profileId);
  writer.writeBool(offsets[8], object.urgency);
}

EliminationEntryIsar _eliminationEntryIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EliminationEntryIsar();
  object.blood = reader.readBool(offsets[0]);
  object.bristolType = reader.readLongOrNull(offsets[1]);
  object.count = reader.readLong(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.id = id;
  object.kind = reader.readString(offsets[4]);
  object.loggedAt = reader.readDateTime(offsets[5]);
  object.notes = reader.readStringOrNull(offsets[6]);
  object.profileId = reader.readLong(offsets[7]);
  object.urgency = reader.readBool(offsets[8]);
  return object;
}

P _eliminationEntryIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _eliminationEntryIsarGetId(EliminationEntryIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _eliminationEntryIsarGetLinks(
    EliminationEntryIsar object) {
  return [];
}

void _eliminationEntryIsarAttach(
    IsarCollection<dynamic> col, Id id, EliminationEntryIsar object) {
  object.id = id;
}

extension EliminationEntryIsarQueryWhereSort
    on QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QWhere> {
  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhere>
      anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhere>
      anyLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'loggedAt'),
      );
    });
  }
}

extension EliminationEntryIsarQueryWhere
    on QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QWhereClause> {
  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
      profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
      loggedAtEqualTo(DateTime loggedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'loggedAt',
        value: [loggedAt],
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
      loggedAtNotEqualTo(DateTime loggedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loggedAt',
              lower: [],
              upper: [loggedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loggedAt',
              lower: [loggedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loggedAt',
              lower: [loggedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loggedAt',
              lower: [],
              upper: [loggedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
      loggedAtGreaterThan(
    DateTime loggedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'loggedAt',
        lower: [loggedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
      loggedAtLessThan(
    DateTime loggedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'loggedAt',
        lower: [],
        upper: [loggedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterWhereClause>
      loggedAtBetween(
    DateTime lowerLoggedAt,
    DateTime upperLoggedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'loggedAt',
        lower: [lowerLoggedAt],
        includeLower: includeLower,
        upper: [upperLoggedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EliminationEntryIsarQueryFilter on QueryBuilder<EliminationEntryIsar,
    EliminationEntryIsar, QFilterCondition> {
  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> bloodEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blood',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> bristolTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bristolType',
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> bristolTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bristolType',
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> bristolTypeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bristolType',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> bristolTypeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bristolType',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> bristolTypeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bristolType',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> bristolTypeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bristolType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> countEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> countGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> countLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> countBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'count',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
          QAfterFilterCondition>
      kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
          QAfterFilterCondition>
      kindMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kind',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> loggedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loggedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> loggedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loggedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> loggedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loggedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> loggedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loggedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> notesBetween(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> notesStartsWith(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
          QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
          QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> profileIdGreaterThan(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> profileIdLessThan(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> profileIdBetween(
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

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar,
      QAfterFilterCondition> urgencyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urgency',
        value: value,
      ));
    });
  }
}

extension EliminationEntryIsarQueryObject on QueryBuilder<EliminationEntryIsar,
    EliminationEntryIsar, QFilterCondition> {}

extension EliminationEntryIsarQueryLinks on QueryBuilder<EliminationEntryIsar,
    EliminationEntryIsar, QFilterCondition> {}

extension EliminationEntryIsarQuerySortBy
    on QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QSortBy> {
  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByBlood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blood', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByBloodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blood', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByBristolType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bristolType', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByBristolTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bristolType', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByUrgency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgency', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      sortByUrgencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgency', Sort.desc);
    });
  }
}

extension EliminationEntryIsarQuerySortThenBy
    on QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QSortThenBy> {
  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByBlood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blood', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByBloodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blood', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByBristolType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bristolType', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByBristolTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bristolType', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByUrgency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgency', Sort.asc);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QAfterSortBy>
      thenByUrgencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgency', Sort.desc);
    });
  }
}

extension EliminationEntryIsarQueryWhereDistinct
    on QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QDistinct> {
  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QDistinct>
      distinctByBlood() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blood');
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QDistinct>
      distinctByBristolType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bristolType');
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QDistinct>
      distinctByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'count');
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QDistinct>
      distinctByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QDistinct>
      distinctByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loggedAt');
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<EliminationEntryIsar, EliminationEntryIsar, QDistinct>
      distinctByUrgency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'urgency');
    });
  }
}

extension EliminationEntryIsarQueryProperty on QueryBuilder<
    EliminationEntryIsar, EliminationEntryIsar, QQueryProperty> {
  QueryBuilder<EliminationEntryIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EliminationEntryIsar, bool, QQueryOperations> bloodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blood');
    });
  }

  QueryBuilder<EliminationEntryIsar, int?, QQueryOperations>
      bristolTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bristolType');
    });
  }

  QueryBuilder<EliminationEntryIsar, int, QQueryOperations> countProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'count');
    });
  }

  QueryBuilder<EliminationEntryIsar, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<EliminationEntryIsar, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<EliminationEntryIsar, DateTime, QQueryOperations>
      loggedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loggedAt');
    });
  }

  QueryBuilder<EliminationEntryIsar, String?, QQueryOperations>
      notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<EliminationEntryIsar, int, QQueryOperations>
      profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<EliminationEntryIsar, bool, QQueryOperations> urgencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'urgency');
    });
  }
}
