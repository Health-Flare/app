// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fluid_intake_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFluidIntakeIsarCollection on Isar {
  IsarCollection<FluidIntakeIsar> get fluidIntakeIsars => this.collection();
}

const FluidIntakeIsarSchema = CollectionSchema(
  name: r'FluidIntakeIsar',
  id: -8451035236573112295,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'drinkType': PropertySchema(
      id: 1,
      name: r'drinkType',
      type: IsarType.string,
    ),
    r'loggedAt': PropertySchema(
      id: 2,
      name: r'loggedAt',
      type: IsarType.dateTime,
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
    r'volumeMl': PropertySchema(
      id: 5,
      name: r'volumeMl',
      type: IsarType.long,
    )
  },
  estimateSize: _fluidIntakeIsarEstimateSize,
  serialize: _fluidIntakeIsarSerialize,
  deserialize: _fluidIntakeIsarDeserialize,
  deserializeProp: _fluidIntakeIsarDeserializeProp,
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
  getId: _fluidIntakeIsarGetId,
  getLinks: _fluidIntakeIsarGetLinks,
  attach: _fluidIntakeIsarAttach,
  version: '3.3.2',
);

int _fluidIntakeIsarEstimateSize(
  FluidIntakeIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.drinkType;
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
  return bytesCount;
}

void _fluidIntakeIsarSerialize(
  FluidIntakeIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.drinkType);
  writer.writeDateTime(offsets[2], object.loggedAt);
  writer.writeString(offsets[3], object.notes);
  writer.writeLong(offsets[4], object.profileId);
  writer.writeLong(offsets[5], object.volumeMl);
}

FluidIntakeIsar _fluidIntakeIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FluidIntakeIsar();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.drinkType = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.loggedAt = reader.readDateTime(offsets[2]);
  object.notes = reader.readStringOrNull(offsets[3]);
  object.profileId = reader.readLong(offsets[4]);
  object.volumeMl = reader.readLong(offsets[5]);
  return object;
}

P _fluidIntakeIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fluidIntakeIsarGetId(FluidIntakeIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fluidIntakeIsarGetLinks(FluidIntakeIsar object) {
  return [];
}

void _fluidIntakeIsarAttach(
    IsarCollection<dynamic> col, Id id, FluidIntakeIsar object) {
  object.id = id;
}

extension FluidIntakeIsarQueryWhereSort
    on QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QWhere> {
  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhere> anyLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'loggedAt'),
      );
    });
  }
}

extension FluidIntakeIsarQueryWhere
    on QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QWhereClause> {
  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
      profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
      loggedAtEqualTo(DateTime loggedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'loggedAt',
        value: [loggedAt],
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterWhereClause>
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

extension FluidIntakeIsarQueryFilter
    on QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QFilterCondition> {
  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'drinkType',
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'drinkType',
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'drinkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'drinkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'drinkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'drinkType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'drinkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'drinkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'drinkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'drinkType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'drinkType',
        value: '',
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      drinkTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'drinkType',
        value: '',
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      loggedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loggedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      loggedAtGreaterThan(
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      loggedAtLessThan(
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      loggedAtBetween(
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
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

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      volumeMlEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'volumeMl',
        value: value,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      volumeMlGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'volumeMl',
        value: value,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      volumeMlLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'volumeMl',
        value: value,
      ));
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterFilterCondition>
      volumeMlBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'volumeMl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FluidIntakeIsarQueryObject
    on QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QFilterCondition> {}

extension FluidIntakeIsarQueryLinks
    on QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QFilterCondition> {}

extension FluidIntakeIsarQuerySortBy
    on QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QSortBy> {
  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      sortByDrinkType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drinkType', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      sortByDrinkTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drinkType', Sort.desc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      sortByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      sortByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      sortByVolumeMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeMl', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      sortByVolumeMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeMl', Sort.desc);
    });
  }
}

extension FluidIntakeIsarQuerySortThenBy
    on QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QSortThenBy> {
  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      thenByDrinkType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drinkType', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      thenByDrinkTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'drinkType', Sort.desc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      thenByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      thenByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      thenByVolumeMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeMl', Sort.asc);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QAfterSortBy>
      thenByVolumeMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeMl', Sort.desc);
    });
  }
}

extension FluidIntakeIsarQueryWhereDistinct
    on QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QDistinct> {
  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QDistinct> distinctByDrinkType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'drinkType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QDistinct>
      distinctByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loggedAt');
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QDistinct>
      distinctByVolumeMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volumeMl');
    });
  }
}

extension FluidIntakeIsarQueryProperty
    on QueryBuilder<FluidIntakeIsar, FluidIntakeIsar, QQueryProperty> {
  QueryBuilder<FluidIntakeIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FluidIntakeIsar, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<FluidIntakeIsar, String?, QQueryOperations> drinkTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'drinkType');
    });
  }

  QueryBuilder<FluidIntakeIsar, DateTime, QQueryOperations> loggedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loggedAt');
    });
  }

  QueryBuilder<FluidIntakeIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<FluidIntakeIsar, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<FluidIntakeIsar, int, QQueryOperations> volumeMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volumeMl');
    });
  }
}
