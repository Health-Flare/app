// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_snapshot_isar.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const WeatherSnapshotIsarSchema = Schema(
  name: r'WeatherSnapshotIsar',
  id: 8129277358068888021,
  properties: {
    r'capturedAt': PropertySchema(
      id: 0,
      name: r'capturedAt',
      type: IsarType.dateTime,
    ),
    r'humidityPercent': PropertySchema(
      id: 1,
      name: r'humidityPercent',
      type: IsarType.long,
    ),
    r'pressureHPa': PropertySchema(
      id: 2,
      name: r'pressureHPa',
      type: IsarType.double,
    ),
    r'temperatureCelsius': PropertySchema(
      id: 3,
      name: r'temperatureCelsius',
      type: IsarType.double,
    ),
    r'weatherCode': PropertySchema(
      id: 4,
      name: r'weatherCode',
      type: IsarType.long,
    ),
    r'windSpeedKmh': PropertySchema(
      id: 5,
      name: r'windSpeedKmh',
      type: IsarType.double,
    )
  },
  estimateSize: _weatherSnapshotIsarEstimateSize,
  serialize: _weatherSnapshotIsarSerialize,
  deserialize: _weatherSnapshotIsarDeserialize,
  deserializeProp: _weatherSnapshotIsarDeserializeProp,
);

int _weatherSnapshotIsarEstimateSize(
  WeatherSnapshotIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _weatherSnapshotIsarSerialize(
  WeatherSnapshotIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.capturedAt);
  writer.writeLong(offsets[1], object.humidityPercent);
  writer.writeDouble(offsets[2], object.pressureHPa);
  writer.writeDouble(offsets[3], object.temperatureCelsius);
  writer.writeLong(offsets[4], object.weatherCode);
  writer.writeDouble(offsets[5], object.windSpeedKmh);
}

WeatherSnapshotIsar _weatherSnapshotIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WeatherSnapshotIsar();
  object.capturedAt = reader.readDateTimeOrNull(offsets[0]);
  object.humidityPercent = reader.readLongOrNull(offsets[1]);
  object.pressureHPa = reader.readDoubleOrNull(offsets[2]);
  object.temperatureCelsius = reader.readDoubleOrNull(offsets[3]);
  object.weatherCode = reader.readLongOrNull(offsets[4]);
  object.windSpeedKmh = reader.readDoubleOrNull(offsets[5]);
  return object;
}

P _weatherSnapshotIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension WeatherSnapshotIsarQueryFilter on QueryBuilder<WeatherSnapshotIsar,
    WeatherSnapshotIsar, QFilterCondition> {
  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      capturedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'capturedAt',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      capturedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'capturedAt',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      capturedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      capturedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      capturedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      capturedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'capturedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      humidityPercentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'humidityPercent',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      humidityPercentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'humidityPercent',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      humidityPercentEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'humidityPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      humidityPercentGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'humidityPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      humidityPercentLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'humidityPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      humidityPercentBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'humidityPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      pressureHPaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pressureHPa',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      pressureHPaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pressureHPa',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      pressureHPaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pressureHPa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      pressureHPaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pressureHPa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      pressureHPaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pressureHPa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      pressureHPaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pressureHPa',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      temperatureCelsiusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'temperatureCelsius',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      temperatureCelsiusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'temperatureCelsius',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      temperatureCelsiusEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'temperatureCelsius',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      temperatureCelsiusGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'temperatureCelsius',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      temperatureCelsiusLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'temperatureCelsius',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      temperatureCelsiusBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'temperatureCelsius',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      weatherCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weatherCode',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      weatherCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weatherCode',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      weatherCodeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weatherCode',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      weatherCodeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weatherCode',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      weatherCodeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weatherCode',
        value: value,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      weatherCodeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weatherCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      windSpeedKmhIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'windSpeedKmh',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      windSpeedKmhIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'windSpeedKmh',
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      windSpeedKmhEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'windSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      windSpeedKmhGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'windSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      windSpeedKmhLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'windSpeedKmh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeatherSnapshotIsar, WeatherSnapshotIsar, QAfterFilterCondition>
      windSpeedKmhBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'windSpeedKmh',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension WeatherSnapshotIsarQueryObject on QueryBuilder<WeatherSnapshotIsar,
    WeatherSnapshotIsar, QFilterCondition> {}
