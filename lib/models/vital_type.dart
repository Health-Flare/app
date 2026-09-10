enum VitalType {
  heartRate,
  bloodPressure,
  weight,
  height,
  temperature,
  oxygenSaturation,
  respiratoryRate,
  bloodGlucose;

  String get label => switch (this) {
    heartRate => 'Heart Rate',
    bloodPressure => 'Blood Pressure',
    weight => 'Weight',
    height => 'Height',
    temperature => 'Temperature',
    oxygenSaturation => 'Oxygen Saturation',
    respiratoryRate => 'Respiratory Rate',
    bloodGlucose => 'Blood Glucose',
  };

  String get defaultUnit => switch (this) {
    heartRate => 'BPM',
    bloodPressure => 'mmHg',
    weight => 'kg',
    height => 'cm',
    temperature => '°C',
    oxygenSaturation => '%',
    respiratoryRate => 'br/min',
    bloodGlucose => 'mmol/L',
  };

  bool get hasSecondaryValue => this == bloodPressure;

  List<String> get availableUnits => switch (this) {
    heartRate => ['BPM'],
    bloodPressure => ['mmHg'],
    weight => ['kg', 'lbs'],
    height => ['cm', 'in'],
    temperature => ['°C', '°F'],
    oxygenSaturation => ['%'],
    respiratoryRate => ['br/min'],
    bloodGlucose => ['mmol/L', 'mg/dL'],
  };

  static VitalType fromString(String value) =>
      VitalType.values.firstWhere((e) => e.name == value);
}
