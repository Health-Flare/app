enum VitalType {
  heartRate,
  bloodPressure,
  weight,
  height,
  temperature,
  oxygenSaturation,
  respiratoryRate,
  bloodGlucose,
  peakFlow,
  steps;

  String get label => switch (this) {
    heartRate => 'Heart Rate',
    bloodPressure => 'Blood Pressure',
    weight => 'Weight',
    height => 'Height',
    temperature => 'Temperature',
    oxygenSaturation => 'Oxygen Saturation',
    respiratoryRate => 'Respiratory Rate',
    bloodGlucose => 'Blood Glucose',
    peakFlow => 'Peak Flow',
    steps => 'Steps',
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
    peakFlow => 'L/min',
    steps => 'steps',
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
    peakFlow => ['L/min'],
    steps => ['steps'],
  };

  static VitalType fromString(String value) =>
      VitalType.values.firstWhere((e) => e.name == value);
}
