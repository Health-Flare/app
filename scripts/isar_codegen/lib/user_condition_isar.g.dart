// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_condition_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserConditionIsarCollection on Isar {
  IsarCollection<UserConditionIsar> get userConditionIsars => this.collection();
}

const UserConditionIsarSchema = CollectionSchema(
  name: r'UserConditionIsar',
  id: 3050801340719130101,
  properties: {
    r'conditionId': PropertySchema(
      id: 0,
      name: r'conditionId',
      type: IsarType.long,
    ),
    r'conditionName': PropertySchema(
      id: 1,
      name: r'conditionName',
      type: IsarType.string,
    ),
    r'diagnosedAt': PropertySchema(
      id: 2,
      name: r'diagnosedAt',
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
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.string,
    ),
    r'statusHistory': PropertySchema(
      id: 6,
      name: r'statusHistory',
      type: IsarType.objectList,
      target: r'ConditionStatusEventIsar',
    ),
    r'trackedSince': PropertySchema(
      id: 7,
      name: r'trackedSince',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _userConditionIsarEstimateSize,
  serialize: _userConditionIsarSerialize,
  deserialize: _userConditionIsarDeserialize,
  deserializeProp: _userConditionIsarDeserializeProp,
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
    r'conditionId': IndexSchema(
      id: -56228966697477001,
      name: r'conditionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'conditionId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'ConditionStatusEventIsar': ConditionStatusEventIsarSchema
  },
  getId: _userConditionIsarGetId,
  getLinks: _userConditionIsarGetLinks,
  attach: _userConditionIsarAttach,
  version: '3.3.0',
);

int _userConditionIsarEstimateSize(
  UserConditionIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.conditionName.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.statusHistory.length * 3;
  {
    final offsets = allOffsets[ConditionStatusEventIsar]!;
    for (var i = 0; i < object.statusHistory.length; i++) {
      final value = object.statusHistory[i];
      bytesCount += ConditionStatusEventIsarSchema.estimateSize(
          value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _userConditionIsarSerialize(
  UserConditionIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.conditionId);
  writer.writeString(offsets[1], object.conditionName);
  writer.writeDateTime(offsets[2], object.diagnosedAt);
  writer.writeString(offsets[3], object.notes);
  writer.writeLong(offsets[4], object.profileId);
  writer.writeString(offsets[5], object.status);
  writer.writeObjectList<ConditionStatusEventIsar>(
    offsets[6],
    allOffsets,
    ConditionStatusEventIsarSchema.serialize,
    object.statusHistory,
  );
  writer.writeDateTime(offsets[7], object.trackedSince);
}

UserConditionIsar _userConditionIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserConditionIsar();
  object.conditionId = reader.readLong(offsets[0]);
  object.conditionName = reader.readString(offsets[1]);
  object.diagnosedAt = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.notes = reader.readStringOrNull(offsets[3]);
  object.profileId = reader.readLong(offsets[4]);
  object.status = reader.readString(offsets[5]);
  object.statusHistory = reader.readObjectList<ConditionStatusEventIsar>(
        offsets[6],
        ConditionStatusEventIsarSchema.deserialize,
        allOffsets,
        ConditionStatusEventIsar(),
      ) ??
      [];
  object.trackedSince = reader.readDateTime(offsets[7]);
  return object;
}

P _userConditionIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readObjectList<ConditionStatusEventIsar>(
            offset,
            ConditionStatusEventIsarSchema.deserialize,
            allOffsets,
            ConditionStatusEventIsar(),
          ) ??
          []) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userConditionIsarGetId(UserConditionIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userConditionIsarGetLinks(
    UserConditionIsar object) {
  return [];
}

void _userConditionIsarAttach(
    IsarCollection<dynamic> col, Id id, UserConditionIsar object) {
  object.id = id;
}

extension UserConditionIsarQueryWhereSort
    on QueryBuilder<UserConditionIsar, UserConditionIsar, QWhere> {
  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhere>
      anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhere>
      anyConditionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'conditionId'),
      );
    });
  }
}

extension UserConditionIsarQueryWhere
    on QueryBuilder<UserConditionIsar, UserConditionIsar, QWhereClause> {
  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
      profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
      conditionIdEqualTo(int conditionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conditionId',
        value: [conditionId],
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
      conditionIdNotEqualTo(int conditionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conditionId',
              lower: [],
              upper: [conditionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conditionId',
              lower: [conditionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conditionId',
              lower: [conditionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conditionId',
              lower: [],
              upper: [conditionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
      conditionIdGreaterThan(
    int conditionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conditionId',
        lower: [conditionId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
      conditionIdLessThan(
    int conditionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conditionId',
        lower: [],
        upper: [conditionId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterWhereClause>
      conditionIdBetween(
    int lowerConditionId,
    int upperConditionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conditionId',
        lower: [lowerConditionId],
        includeLower: includeLower,
        upper: [upperConditionId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserConditionIsarQueryFilter
    on QueryBuilder<UserConditionIsar, UserConditionIsar, QFilterCondition> {
  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conditionId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conditionId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conditionId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conditionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conditionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conditionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conditionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conditionName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'conditionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'conditionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conditionName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conditionName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conditionName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      conditionNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conditionName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      diagnosedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'diagnosedAt',
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      diagnosedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'diagnosedAt',
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      diagnosedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diagnosedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      diagnosedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'diagnosedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      diagnosedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'diagnosedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      diagnosedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'diagnosedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
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

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusHistoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'statusHistory',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusHistoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'statusHistory',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusHistoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'statusHistory',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusHistoryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'statusHistory',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusHistoryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'statusHistory',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusHistoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'statusHistory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      trackedSinceEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackedSince',
        value: value,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      trackedSinceGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackedSince',
        value: value,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      trackedSinceLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackedSince',
        value: value,
      ));
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      trackedSinceBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackedSince',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserConditionIsarQueryObject
    on QueryBuilder<UserConditionIsar, UserConditionIsar, QFilterCondition> {
  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterFilterCondition>
      statusHistoryElement(FilterQuery<ConditionStatusEventIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'statusHistory');
    });
  }
}

extension UserConditionIsarQueryLinks
    on QueryBuilder<UserConditionIsar, UserConditionIsar, QFilterCondition> {}

extension UserConditionIsarQuerySortBy
    on QueryBuilder<UserConditionIsar, UserConditionIsar, QSortBy> {
  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByConditionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionId', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByConditionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionId', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByConditionName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionName', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByConditionNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionName', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByDiagnosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diagnosedAt', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByDiagnosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diagnosedAt', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByTrackedSince() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackedSince', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      sortByTrackedSinceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackedSince', Sort.desc);
    });
  }
}

extension UserConditionIsarQuerySortThenBy
    on QueryBuilder<UserConditionIsar, UserConditionIsar, QSortThenBy> {
  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByConditionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionId', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByConditionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionId', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByConditionName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionName', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByConditionNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionName', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByDiagnosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diagnosedAt', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByDiagnosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diagnosedAt', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByTrackedSince() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackedSince', Sort.asc);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QAfterSortBy>
      thenByTrackedSinceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackedSince', Sort.desc);
    });
  }
}

extension UserConditionIsarQueryWhereDistinct
    on QueryBuilder<UserConditionIsar, UserConditionIsar, QDistinct> {
  QueryBuilder<UserConditionIsar, UserConditionIsar, QDistinct>
      distinctByConditionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conditionId');
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QDistinct>
      distinctByConditionName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conditionName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QDistinct>
      distinctByDiagnosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diagnosedAt');
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserConditionIsar, UserConditionIsar, QDistinct>
      distinctByTrackedSince() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackedSince');
    });
  }
}

extension UserConditionIsarQueryProperty
    on QueryBuilder<UserConditionIsar, UserConditionIsar, QQueryProperty> {
  QueryBuilder<UserConditionIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserConditionIsar, int, QQueryOperations> conditionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conditionId');
    });
  }

  QueryBuilder<UserConditionIsar, String, QQueryOperations>
      conditionNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conditionName');
    });
  }

  QueryBuilder<UserConditionIsar, DateTime?, QQueryOperations>
      diagnosedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diagnosedAt');
    });
  }

  QueryBuilder<UserConditionIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<UserConditionIsar, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<UserConditionIsar, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<UserConditionIsar, List<ConditionStatusEventIsar>,
      QQueryOperations> statusHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusHistory');
    });
  }

  QueryBuilder<UserConditionIsar, DateTime, QQueryOperations>
      trackedSinceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackedSince');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ConditionStatusEventIsarSchema = Schema(
  name: r'ConditionStatusEventIsar',
  id: 8681434537255973331,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'eventType': PropertySchema(
      id: 1,
      name: r'eventType',
      type: IsarType.string,
    )
  },
  estimateSize: _conditionStatusEventIsarEstimateSize,
  serialize: _conditionStatusEventIsarSerialize,
  deserialize: _conditionStatusEventIsarDeserialize,
  deserializeProp: _conditionStatusEventIsarDeserializeProp,
);

int _conditionStatusEventIsarEstimateSize(
  ConditionStatusEventIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.eventType.length * 3;
  return bytesCount;
}

void _conditionStatusEventIsarSerialize(
  ConditionStatusEventIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeString(offsets[1], object.eventType);
}

ConditionStatusEventIsar _conditionStatusEventIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ConditionStatusEventIsar();
  object.date = reader.readDateTime(offsets[0]);
  object.eventType = reader.readString(offsets[1]);
  return object;
}

P _conditionStatusEventIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ConditionStatusEventIsarQueryFilter on QueryBuilder<
    ConditionStatusEventIsar, ConditionStatusEventIsar, QFilterCondition> {
  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> eventTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> eventTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> eventTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> eventTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> eventTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> eventTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
          QAfterFilterCondition>
      eventTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eventType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
          QAfterFilterCondition>
      eventTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eventType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> eventTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventType',
        value: '',
      ));
    });
  }

  QueryBuilder<ConditionStatusEventIsar, ConditionStatusEventIsar,
      QAfterFilterCondition> eventTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eventType',
        value: '',
      ));
    });
  }
}

extension ConditionStatusEventIsarQueryObject on QueryBuilder<
    ConditionStatusEventIsar, ConditionStatusEventIsar, QFilterCondition> {}
