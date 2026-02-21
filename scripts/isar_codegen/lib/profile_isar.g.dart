// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProfileIsarCollection on Isar {
  IsarCollection<ProfileIsar> get profileIsars => this.collection();
}

const ProfileIsarSchema = CollectionSchema(
  name: r'ProfileIsar',
  id: -325470882510700457,
  properties: {
    r'avatarPath': PropertySchema(
      id: 0,
      name: r'avatarPath',
      type: IsarType.string,
    ),
    r'dateOfBirth': PropertySchema(
      id: 1,
      name: r'dateOfBirth',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _profileIsarEstimateSize,
  serialize: _profileIsarSerialize,
  deserialize: _profileIsarDeserialize,
  deserializeProp: _profileIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _profileIsarGetId,
  getLinks: _profileIsarGetLinks,
  attach: _profileIsarAttach,
  version: '3.3.0',
);

int _profileIsarEstimateSize(
  ProfileIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.avatarPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _profileIsarSerialize(
  ProfileIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.avatarPath);
  writer.writeDateTime(offsets[1], object.dateOfBirth);
  writer.writeString(offsets[2], object.name);
}

ProfileIsar _profileIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProfileIsar();
  object.avatarPath = reader.readStringOrNull(offsets[0]);
  object.dateOfBirth = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.name = reader.readString(offsets[2]);
  return object;
}

P _profileIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _profileIsarGetId(ProfileIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _profileIsarGetLinks(ProfileIsar object) {
  return [];
}

void _profileIsarAttach(
    IsarCollection<dynamic> col, Id id, ProfileIsar object) {
  object.id = id;
}

extension ProfileIsarQueryWhereSort
    on QueryBuilder<ProfileIsar, ProfileIsar, QWhere> {
  QueryBuilder<ProfileIsar, ProfileIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProfileIsarQueryWhere
    on QueryBuilder<ProfileIsar, ProfileIsar, QWhereClause> {
  QueryBuilder<ProfileIsar, ProfileIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterWhereClause> idBetween(
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
}

extension ProfileIsarQueryFilter
    on QueryBuilder<ProfileIsar, ProfileIsar, QFilterCondition> {
  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avatarPath',
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avatarPath',
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avatarPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'avatarPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'avatarPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatarPath',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      avatarPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'avatarPath',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      dateOfBirthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dateOfBirth',
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      dateOfBirthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dateOfBirth',
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      dateOfBirthEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      dateOfBirthGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      dateOfBirthLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      dateOfBirthBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateOfBirth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension ProfileIsarQueryObject
    on QueryBuilder<ProfileIsar, ProfileIsar, QFilterCondition> {}

extension ProfileIsarQueryLinks
    on QueryBuilder<ProfileIsar, ProfileIsar, QFilterCondition> {}

extension ProfileIsarQuerySortBy
    on QueryBuilder<ProfileIsar, ProfileIsar, QSortBy> {
  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> sortByAvatarPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarPath', Sort.asc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> sortByAvatarPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarPath', Sort.desc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> sortByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> sortByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ProfileIsarQuerySortThenBy
    on QueryBuilder<ProfileIsar, ProfileIsar, QSortThenBy> {
  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> thenByAvatarPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarPath', Sort.asc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> thenByAvatarPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarPath', Sort.desc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> thenByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> thenByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension ProfileIsarQueryWhereDistinct
    on QueryBuilder<ProfileIsar, ProfileIsar, QDistinct> {
  QueryBuilder<ProfileIsar, ProfileIsar, QDistinct> distinctByAvatarPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatarPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QDistinct> distinctByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateOfBirth');
    });
  }

  QueryBuilder<ProfileIsar, ProfileIsar, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension ProfileIsarQueryProperty
    on QueryBuilder<ProfileIsar, ProfileIsar, QQueryProperty> {
  QueryBuilder<ProfileIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProfileIsar, String?, QQueryOperations> avatarPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatarPath');
    });
  }

  QueryBuilder<ProfileIsar, DateTime?, QQueryOperations> dateOfBirthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateOfBirth');
    });
  }

  QueryBuilder<ProfileIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
