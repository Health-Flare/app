// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_symptom_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserSymptomIsarCollection on Isar {
  IsarCollection<UserSymptomIsar> get userSymptomIsars => this.collection();
}

const UserSymptomIsarSchema = CollectionSchema(
  name: r'UserSymptomIsar',
  id: -7777893573421462675,
  properties: {
    r'profileId': PropertySchema(
      id: 0,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'symptomId': PropertySchema(
      id: 1,
      name: r'symptomId',
      type: IsarType.long,
    ),
    r'symptomName': PropertySchema(
      id: 2,
      name: r'symptomName',
      type: IsarType.string,
    ),
    r'trackedSince': PropertySchema(
      id: 3,
      name: r'trackedSince',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _userSymptomIsarEstimateSize,
  serialize: _userSymptomIsarSerialize,
  deserialize: _userSymptomIsarDeserialize,
  deserializeProp: _userSymptomIsarDeserializeProp,
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
    r'symptomId': IndexSchema(
      id: 191490450146583634,
      name: r'symptomId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'symptomId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _userSymptomIsarGetId,
  getLinks: _userSymptomIsarGetLinks,
  attach: _userSymptomIsarAttach,
  version: '3.3.0',
);

int _userSymptomIsarEstimateSize(
  UserSymptomIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.symptomName.length * 3;
  return bytesCount;
}

void _userSymptomIsarSerialize(
  UserSymptomIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.profileId);
  writer.writeLong(offsets[1], object.symptomId);
  writer.writeString(offsets[2], object.symptomName);
  writer.writeDateTime(offsets[3], object.trackedSince);
}

UserSymptomIsar _userSymptomIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserSymptomIsar();
  object.id = id;
  object.profileId = reader.readLong(offsets[0]);
  object.symptomId = reader.readLong(offsets[1]);
  object.symptomName = reader.readString(offsets[2]);
  object.trackedSince = reader.readDateTime(offsets[3]);
  return object;
}

P _userSymptomIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userSymptomIsarGetId(UserSymptomIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userSymptomIsarGetLinks(UserSymptomIsar object) {
  return [];
}

void _userSymptomIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserSymptomIsar object,
) {
  object.id = id;
}

extension UserSymptomIsarQueryWhereSort
    on QueryBuilder<UserSymptomIsar, UserSymptomIsar, QWhere> {
  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhere> anySymptomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'symptomId'),
      );
    });
  }
}

extension UserSymptomIsarQueryWhere
    on QueryBuilder<UserSymptomIsar, UserSymptomIsar, QWhereClause> {
  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
  profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'profileId', value: [profileId]),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
  symptomIdEqualTo(int symptomId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'symptomId', value: [symptomId]),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
  symptomIdNotEqualTo(int symptomId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'symptomId',
                lower: [],
                upper: [symptomId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'symptomId',
                lower: [symptomId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'symptomId',
                lower: [symptomId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'symptomId',
                lower: [],
                upper: [symptomId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
  symptomIdGreaterThan(int symptomId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'symptomId',
          lower: [symptomId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
  symptomIdLessThan(int symptomId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'symptomId',
          lower: [],
          upper: [symptomId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterWhereClause>
  symptomIdBetween(
    int lowerSymptomId,
    int upperSymptomId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'symptomId',
          lower: [lowerSymptomId],
          includeLower: includeLower,
          upper: [upperSymptomId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserSymptomIsarQueryFilter
    on QueryBuilder<UserSymptomIsar, UserSymptomIsar, QFilterCondition> {
  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'profileId', value: value),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
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

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'symptomId', value: value),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'symptomId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'symptomId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'symptomId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'symptomName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'symptomName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'symptomName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'symptomName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'symptomName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'symptomName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'symptomName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'symptomName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'symptomName', value: ''),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  symptomNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'symptomName', value: ''),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  trackedSinceEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trackedSince', value: value),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  trackedSinceGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trackedSince',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  trackedSinceLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trackedSince',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterFilterCondition>
  trackedSinceBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trackedSince',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserSymptomIsarQueryObject
    on QueryBuilder<UserSymptomIsar, UserSymptomIsar, QFilterCondition> {}

extension UserSymptomIsarQueryLinks
    on QueryBuilder<UserSymptomIsar, UserSymptomIsar, QFilterCondition> {}

extension UserSymptomIsarQuerySortBy
    on QueryBuilder<UserSymptomIsar, UserSymptomIsar, QSortBy> {
  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  sortBySymptomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomId', Sort.asc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  sortBySymptomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomId', Sort.desc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  sortBySymptomName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomName', Sort.asc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  sortBySymptomNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomName', Sort.desc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  sortByTrackedSince() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackedSince', Sort.asc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  sortByTrackedSinceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackedSince', Sort.desc);
    });
  }
}

extension UserSymptomIsarQuerySortThenBy
    on QueryBuilder<UserSymptomIsar, UserSymptomIsar, QSortThenBy> {
  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  thenBySymptomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomId', Sort.asc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  thenBySymptomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomId', Sort.desc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  thenBySymptomName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomName', Sort.asc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  thenBySymptomNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomName', Sort.desc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  thenByTrackedSince() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackedSince', Sort.asc);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QAfterSortBy>
  thenByTrackedSinceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackedSince', Sort.desc);
    });
  }
}

extension UserSymptomIsarQueryWhereDistinct
    on QueryBuilder<UserSymptomIsar, UserSymptomIsar, QDistinct> {
  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QDistinct>
  distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QDistinct>
  distinctBySymptomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'symptomId');
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QDistinct>
  distinctBySymptomName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'symptomName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSymptomIsar, UserSymptomIsar, QDistinct>
  distinctByTrackedSince() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackedSince');
    });
  }
}

extension UserSymptomIsarQueryProperty
    on QueryBuilder<UserSymptomIsar, UserSymptomIsar, QQueryProperty> {
  QueryBuilder<UserSymptomIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserSymptomIsar, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<UserSymptomIsar, int, QQueryOperations> symptomIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'symptomId');
    });
  }

  QueryBuilder<UserSymptomIsar, String, QQueryOperations>
  symptomNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'symptomName');
    });
  }

  QueryBuilder<UserSymptomIsar, DateTime, QQueryOperations>
  trackedSinceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackedSince');
    });
  }
}
