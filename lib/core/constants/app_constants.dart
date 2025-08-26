class AppConstants {
  static const String appName = 'Hypertension Manager';
  static const String appVersion = '1.0.0';
  
  // FHIR Standards
  static const String fhirVersion = '4.0.1';
  
  // LOINC Codes for Blood Pressure
  static const String systolicBpCode = '8480-6';
  static const String diastolicBpCode = '8462-4';
  static const String bpPanelCode = '85354-9';
  
  // SNOMED CT Codes
  static const String hypertensionCode = '38341003';
  static const String diabetesCode = '73211009';
  static const String ckdCode = '431855005';
  
  // Blood Pressure Thresholds (mmHg)
  static const int normalSystolic = 120;
  static const int normalDiastolic = 80;
  static const int stage1HypertensionSystolic = 140;
  static const int stage1HypertensionDiastolic = 90;
  static const int highRiskSystolic = 130;
  static const int highRiskDiastolic = 80;
  static const int urgentSystolic = 180;
  static const int urgentDiastolic = 120;
  
  // Medication Adherence
  static const double goodAdherenceThreshold = 0.8; // 80%
  static const int consecutiveSkipAlert = 3;
  
  // Database
  static const String databaseName = 'hypertension_app.db';
  static const int databaseVersion = 1;
  
  // Sync Settings
  static const Duration syncInterval = Duration(hours: 24);
  static const int maxRetries = 3;
  
  // Notification Settings
  static const String medicationReminderChannel = 'medication_reminders';
  static const String bpMeasurementChannel = 'bp_measurements';
  static const String urgentAlertChannel = 'urgent_alerts';
  
  // BCT (Behavior Change Techniques) Categories
  static const List<String> bctCategories = [
    'Goals and planning',
    'Feedback and monitoring',
    'Social support',
    'Shaping knowledge',
    'Natural consequences',
    'Comparison of behavior',
    'Associations',
    'Repetition and substitution',
    'Comparison of outcomes',
    'Reward and threat',
    'Regulation',
    'Antecedents',
    'Identity',
    'Scheduled consequences',
    'Self-belief',
    'Covert learning'
  ];
  
  // Lifestyle Goals
  static const Map<String, dynamic> lifestyleTargets = {
    'exercise_minutes_weekly': 150,
    'salt_grams_daily': 5.0,
    'weight_loss_kg_monthly': 2.0,
    'alcohol_units_weekly': 14,
    'sleep_hours_daily': 7.0,
  };
  
  // API Endpoints
  static const String baseUrl = 'https://api.hypertension-app.com';
  static const String fhirEndpoint = '/fhir/R4';
  static const String syncEndpoint = '/sync';
  static const String ragEndpoint = '/assistant/query';
  
  // OAuth/SMART on FHIR
  static const String smartAuthEndpoint = '/auth/smart';
  static const List<String> requiredScopes = [
    'patient/Observation.read',
    'patient/Observation.write',
    'patient/MedicationRequest.read',
    'patient/MedicationStatement.write',
    'patient/Condition.read',
    'patient/CarePlan.read',
    'patient/CarePlan.write',
    'patient/QuestionnaireResponse.write',
    'patient/DocumentReference.write'
  ];
}