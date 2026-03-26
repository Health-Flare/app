// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppointmentIsarCollection on Isar {
  IsarCollection<AppointmentIsar> get appointmentIsars => this.collection();
}

const AppointmentIsarSchema = CollectionSchema(
  name: r'AppointmentIsar',
  id: 5328005997135603422,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'medicationChanges': PropertySchema(
      id: 1,
      name: r'medicationChanges',
      type: IsarType.objectList,
      target: r'MedicationChangeIsar',
    ),
    r'outcomeNotes': PropertySchema(
      id: 2,
      name: r'outcomeNotes',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 3,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'providerName': PropertySchema(
      id: 4,
      name: r'providerName',
      type: IsarType.string,
    ),
    r'questions': PropertySchema(
      id: 5,
      name: r'questions',
      type: IsarType.objectList,
      target: r'AppointmentQuestionIsar',
    ),
    r'scheduledAt': PropertySchema(
      id: 6,
      name: r'scheduledAt',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(id: 7, name: r'status', type: IsarType.string),
    r'title': PropertySchema(id: 8, name: r'title', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _appointmentIsarEstimateSize,
  serialize: _appointmentIsarSerialize,
  deserialize: _appointmentIsarDeserialize,
  deserializeProp: _appointmentIsarDeserializeProp,
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
    r'scheduledAt': IndexSchema(
      id: -1483275037155116518,
      name: r'scheduledAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'scheduledAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {
    r'AppointmentQuestionIsar': AppointmentQuestionIsarSchema,
    r'MedicationChangeIsar': MedicationChangeIsarSchema,
  },
  getId: _appointmentIsarGetId,
  getLinks: _appointmentIsarGetLinks,
  attach: _appointmentIsarAttach,
  version: '3.3.0',
);

int _appointmentIsarEstimateSize(
  AppointmentIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.medicationChanges.length * 3;
  {
    final offsets = allOffsets[MedicationChangeIsar]!;
    for (var i = 0; i < object.medicationChanges.length; i++) {
      final value = object.medicationChanges[i];
      bytesCount += MedicationChangeIsarSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  {
    final value = object.outcomeNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.providerName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.questions.length * 3;
  {
    final offsets = allOffsets[AppointmentQuestionIsar]!;
    for (var i = 0; i < object.questions.length; i++) {
      final value = object.questions[i];
      bytesCount += AppointmentQuestionIsarSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _appointmentIsarSerialize(
  AppointmentIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeObjectList<MedicationChangeIsar>(
    offsets[1],
    allOffsets,
    MedicationChangeIsarSchema.serialize,
    object.medicationChanges,
  );
  writer.writeString(offsets[2], object.outcomeNotes);
  writer.writeLong(offsets[3], object.profileId);
  writer.writeString(offsets[4], object.providerName);
  writer.writeObjectList<AppointmentQuestionIsar>(
    offsets[5],
    allOffsets,
    AppointmentQuestionIsarSchema.serialize,
    object.questions,
  );
  writer.writeDateTime(offsets[6], object.scheduledAt);
  writer.writeString(offsets[7], object.status);
  writer.writeString(offsets[8], object.title);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

AppointmentIsar _appointmentIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppointmentIsar();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.medicationChanges =
      reader.readObjectList<MedicationChangeIsar>(
        offsets[1],
        MedicationChangeIsarSchema.deserialize,
        allOffsets,
        MedicationChangeIsar(),
      ) ??
      [];
  object.outcomeNotes = reader.readStringOrNull(offsets[2]);
  object.profileId = reader.readLong(offsets[3]);
  object.providerName = reader.readStringOrNull(offsets[4]);
  object.questions =
      reader.readObjectList<AppointmentQuestionIsar>(
        offsets[5],
        AppointmentQuestionIsarSchema.deserialize,
        allOffsets,
        AppointmentQuestionIsar(),
      ) ??
      [];
  object.scheduledAt = reader.readDateTime(offsets[6]);
  object.status = reader.readString(offsets[7]);
  object.title = reader.readString(offsets[8]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[9]);
  return object;
}

P _appointmentIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readObjectList<MedicationChangeIsar>(
                offset,
                MedicationChangeIsarSchema.deserialize,
                allOffsets,
                MedicationChangeIsar(),
              ) ??
              [])
          as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readObjectList<AppointmentQuestionIsar>(
                offset,
                AppointmentQuestionIsarSchema.deserialize,
                allOffsets,
                AppointmentQuestionIsar(),
              ) ??
              [])
          as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appointmentIsarGetId(AppointmentIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appointmentIsarGetLinks(AppointmentIsar object) {
  return [];
}

void _appointmentIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  AppointmentIsar object,
) {
  object.id = id;
}

extension AppointmentIsarQueryWhereSort
    on QueryBuilder<AppointmentIsar, AppointmentIsar, QWhere> {
  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhere> anyScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'scheduledAt'),
      );
    });
  }
}

extension AppointmentIsarQueryWhere
    on QueryBuilder<AppointmentIsar, AppointmentIsar, QWhereClause> {
  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
  profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'profileId', value: [profileId]),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
  scheduledAtEqualTo(DateTime scheduledAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'scheduledAt',
          value: [scheduledAt],
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
  scheduledAtNotEqualTo(DateTime scheduledAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scheduledAt',
                lower: [],
                upper: [scheduledAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scheduledAt',
                lower: [scheduledAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scheduledAt',
                lower: [scheduledAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'scheduledAt',
                lower: [],
                upper: [scheduledAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
  scheduledAtGreaterThan(DateTime scheduledAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'scheduledAt',
          lower: [scheduledAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
  scheduledAtLessThan(DateTime scheduledAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'scheduledAt',
          lower: [],
          upper: [scheduledAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterWhereClause>
  scheduledAtBetween(
    DateTime lowerScheduledAt,
    DateTime upperScheduledAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'scheduledAt',
          lower: [lowerScheduledAt],
          includeLower: includeLower,
          upper: [upperScheduledAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AppointmentIsarQueryFilter
    on QueryBuilder<AppointmentIsar, AppointmentIsar, QFilterCondition> {
  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  medicationChangesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'medicationChanges', length, true, length, true);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  medicationChangesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'medicationChanges', 0, true, 0, true);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  medicationChangesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'medicationChanges', 0, false, 999999, true);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  medicationChangesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'medicationChanges', 0, true, length, include);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  medicationChangesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicationChanges',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  medicationChangesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicationChanges',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'outcomeNotes'),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'outcomeNotes'),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'outcomeNotes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'outcomeNotes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'outcomeNotes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'outcomeNotes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'outcomeNotes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'outcomeNotes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'outcomeNotes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'outcomeNotes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'outcomeNotes', value: ''),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  outcomeNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'outcomeNotes', value: ''),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'profileId', value: value),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'providerName'),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'providerName'),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'providerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'providerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'providerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'providerName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'providerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'providerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'providerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'providerName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'providerName', value: ''),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  providerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'providerName', value: ''),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  questionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'questions', length, true, length, true);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  questionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'questions', 0, true, 0, true);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  questionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'questions', 0, false, 999999, true);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  questionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'questions', 0, true, length, include);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  questionsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'questions', length, include, 999999, true);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  questionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'questions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  scheduledAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'scheduledAt', value: value),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  scheduledAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'scheduledAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  scheduledAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'scheduledAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  scheduledAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'scheduledAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  statusEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  statusLessThan(
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  statusBetween(
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
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
}

extension AppointmentIsarQueryObject
    on QueryBuilder<AppointmentIsar, AppointmentIsar, QFilterCondition> {
  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  medicationChangesElement(FilterQuery<MedicationChangeIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'medicationChanges');
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterFilterCondition>
  questionsElement(FilterQuery<AppointmentQuestionIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'questions');
    });
  }
}

extension AppointmentIsarQueryLinks
    on QueryBuilder<AppointmentIsar, AppointmentIsar, QFilterCondition> {}

extension AppointmentIsarQuerySortBy
    on QueryBuilder<AppointmentIsar, AppointmentIsar, QSortBy> {
  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByOutcomeNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcomeNotes', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByOutcomeNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcomeNotes', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByScheduledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppointmentIsarQuerySortThenBy
    on QueryBuilder<AppointmentIsar, AppointmentIsar, QSortThenBy> {
  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByOutcomeNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcomeNotes', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByOutcomeNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcomeNotes', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByScheduledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppointmentIsarQueryWhereDistinct
    on QueryBuilder<AppointmentIsar, AppointmentIsar, QDistinct> {
  QueryBuilder<AppointmentIsar, AppointmentIsar, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QDistinct>
  distinctByOutcomeNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outcomeNotes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QDistinct>
  distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QDistinct>
  distinctByProviderName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QDistinct>
  distinctByScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledAt');
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppointmentIsar, AppointmentIsar, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AppointmentIsarQueryProperty
    on QueryBuilder<AppointmentIsar, AppointmentIsar, QQueryProperty> {
  QueryBuilder<AppointmentIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppointmentIsar, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AppointmentIsar, List<MedicationChangeIsar>, QQueryOperations>
  medicationChangesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medicationChanges');
    });
  }

  QueryBuilder<AppointmentIsar, String?, QQueryOperations>
  outcomeNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outcomeNotes');
    });
  }

  QueryBuilder<AppointmentIsar, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<AppointmentIsar, String?, QQueryOperations>
  providerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerName');
    });
  }

  QueryBuilder<AppointmentIsar, List<AppointmentQuestionIsar>, QQueryOperations>
  questionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questions');
    });
  }

  QueryBuilder<AppointmentIsar, DateTime, QQueryOperations>
  scheduledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledAt');
    });
  }

  QueryBuilder<AppointmentIsar, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<AppointmentIsar, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<AppointmentIsar, DateTime?, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const AppointmentQuestionIsarSchema = Schema(
  name: r'AppointmentQuestionIsar',
  id: -3058351554272644160,
  properties: {
    r'discussed': PropertySchema(
      id: 0,
      name: r'discussed',
      type: IsarType.bool,
    ),
    r'question': PropertySchema(
      id: 1,
      name: r'question',
      type: IsarType.string,
    ),
    r'questionId': PropertySchema(
      id: 2,
      name: r'questionId',
      type: IsarType.string,
    ),
  },
  estimateSize: _appointmentQuestionIsarEstimateSize,
  serialize: _appointmentQuestionIsarSerialize,
  deserialize: _appointmentQuestionIsarDeserialize,
  deserializeProp: _appointmentQuestionIsarDeserializeProp,
);

int _appointmentQuestionIsarEstimateSize(
  AppointmentQuestionIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.question.length * 3;
  bytesCount += 3 + object.questionId.length * 3;
  return bytesCount;
}

void _appointmentQuestionIsarSerialize(
  AppointmentQuestionIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.discussed);
  writer.writeString(offsets[1], object.question);
  writer.writeString(offsets[2], object.questionId);
}

AppointmentQuestionIsar _appointmentQuestionIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppointmentQuestionIsar();
  object.discussed = reader.readBool(offsets[0]);
  object.question = reader.readString(offsets[1]);
  object.questionId = reader.readString(offsets[2]);
  return object;
}

P _appointmentQuestionIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension AppointmentQuestionIsarQueryFilter
    on
        QueryBuilder<
          AppointmentQuestionIsar,
          AppointmentQuestionIsar,
          QFilterCondition
        > {
  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  discussedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'discussed', value: value),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'question',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'question',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'question', value: ''),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'question', value: ''),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'questionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'questionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'questionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'questionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'questionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'questionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'questionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'questionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'questionId', value: ''),
      );
    });
  }

  QueryBuilder<
    AppointmentQuestionIsar,
    AppointmentQuestionIsar,
    QAfterFilterCondition
  >
  questionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'questionId', value: ''),
      );
    });
  }
}

extension AppointmentQuestionIsarQueryObject
    on
        QueryBuilder<
          AppointmentQuestionIsar,
          AppointmentQuestionIsar,
          QFilterCondition
        > {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const MedicationChangeIsarSchema = Schema(
  name: r'MedicationChangeIsar',
  id: -4056118449433865102,
  properties: {
    r'changeId': PropertySchema(
      id: 0,
      name: r'changeId',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'linkedMedicationIsarId': PropertySchema(
      id: 2,
      name: r'linkedMedicationIsarId',
      type: IsarType.long,
    ),
  },
  estimateSize: _medicationChangeIsarEstimateSize,
  serialize: _medicationChangeIsarSerialize,
  deserialize: _medicationChangeIsarDeserialize,
  deserializeProp: _medicationChangeIsarDeserializeProp,
);

int _medicationChangeIsarEstimateSize(
  MedicationChangeIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.changeId.length * 3;
  bytesCount += 3 + object.description.length * 3;
  return bytesCount;
}

void _medicationChangeIsarSerialize(
  MedicationChangeIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.changeId);
  writer.writeString(offsets[1], object.description);
  writer.writeLong(offsets[2], object.linkedMedicationIsarId);
}

MedicationChangeIsar _medicationChangeIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicationChangeIsar();
  object.changeId = reader.readString(offsets[0]);
  object.description = reader.readString(offsets[1]);
  object.linkedMedicationIsarId = reader.readLongOrNull(offsets[2]);
  return object;
}

P _medicationChangeIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension MedicationChangeIsarQueryFilter
    on
        QueryBuilder<
          MedicationChangeIsar,
          MedicationChangeIsar,
          QFilterCondition
        > {
  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  changeIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'changeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  changeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'changeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  changeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'changeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  changeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'changeId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  changeIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'changeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  changeIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'changeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  changeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'changeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  changeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'changeId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  changeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'changeId', value: ''),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  changeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'changeId', value: ''),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  linkedMedicationIsarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'linkedMedicationIsarId'),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  linkedMedicationIsarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'linkedMedicationIsarId'),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  linkedMedicationIsarIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'linkedMedicationIsarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  linkedMedicationIsarIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'linkedMedicationIsarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  linkedMedicationIsarIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'linkedMedicationIsarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    MedicationChangeIsar,
    MedicationChangeIsar,
    QAfterFilterCondition
  >
  linkedMedicationIsarIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'linkedMedicationIsarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension MedicationChangeIsarQueryObject
    on
        QueryBuilder<
          MedicationChangeIsar,
          MedicationChangeIsar,
          QFilterCondition
        > {}
