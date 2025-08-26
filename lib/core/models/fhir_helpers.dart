import 'fhir_models.dart';
import '../constants/app_constants.dart';

class FhirHelpers {
  // Create LOINC coding for blood pressure components
  static FhirCoding createLoincCoding(String code, String display) {
    return FhirCoding(
      system: 'http://loinc.org',
      code: code,
      display: display,
    );
  }

  // Create SNOMED CT coding
  static FhirCoding createSnomedCoding(String code, String display) {
    return FhirCoding(
      system: 'http://snomed.info/sct',
      code: code,
      display: display,
    );
  }

  // Create UCUM quantity for mmHg
  static FhirQuantity createBloodPressureQuantity(double value) {
    return FhirQuantity(
      value: value,
      unit: 'mmHg',
      system: 'http://unitsofmeasure.org',
      code: 'mm[Hg]',
    );
  }

  // Create blood pressure observation
  static BloodPressureObservation createBloodPressureObservation({
    required String patientId,
    required double systolic,
    required double diastolic,
    required DateTime timestamp,
    String? deviceId,
    String? position,
    int? cuffSize,
  }) {
    return BloodPressureObservation(
      status: 'final',
      category: [
        FhirCodeableConcept(
          coding: [
            FhirCoding(
              system: 'http://terminology.hl7.org/CodeSystem/observation-category',
              code: 'vital-signs',
              display: 'Vital Signs',
            ),
          ],
        ),
      ],
      code: FhirCodeableConcept(
        coding: [
          createLoincCoding(AppConstants.bpPanelCode, 'Blood pressure panel'),
        ],
        text: 'Blood Pressure',
      ),
      subject: FhirReference(
        reference: 'Patient/$patientId',
      ),
      effectiveDateTime: timestamp,
      component: [
        ObservationComponent(
          code: FhirCodeableConcept(
            coding: [
              createLoincCoding(AppConstants.systolicBpCode, 'Systolic blood pressure'),
            ],
          ),
          valueQuantity: createBloodPressureQuantity(systolic),
        ),
        ObservationComponent(
          code: FhirCodeableConcept(
            coding: [
              createLoincCoding(AppConstants.diastolicBpCode, 'Diastolic blood pressure'),
            ],
          ),
          valueQuantity: createBloodPressureQuantity(diastolic),
        ),
      ],
      device: deviceId != null ? FhirReference(reference: 'Device/$deviceId') : null,
      bodySite: position,
      meta: FhirMeta(
        lastUpdated: DateTime.now(),
        profile: ['http://hl7.org/fhir/StructureDefinition/bp'],
      ),
    );
  }

  // Create medication request for hypertension drugs
  static MedicationRequest createMedicationRequest({
    required String patientId,
    required String medicationCode,
    required String medicationDisplay,
    required String dosage,
    required String frequency,
    String? prescriberId,
  }) {
    return MedicationRequest(
      status: 'active',
      intent: 'order',
      medicationCodeableConcept: FhirCodeableConcept(
        coding: [
          FhirCoding(
            system: 'http://www.nlm.nih.gov/research/umls/rxnorm',
            code: medicationCode,
            display: medicationDisplay,
          ),
        ],
        text: medicationDisplay,
      ),
      subject: FhirReference(
        reference: 'Patient/$patientId',
      ),
      authoredOn: DateTime.now(),
      requester: prescriberId != null 
        ? FhirReference(reference: 'Practitioner/$prescriberId') 
        : null,
      dosageInstruction: [
        Dosage(
          sequence: 1,
          text: '$dosage $frequency',
          timing: Timing(
            code: FhirCodeableConcept(
              text: frequency,
            ),
          ),
        ),
      ],
      meta: FhirMeta(
        lastUpdated: DateTime.now(),
      ),
    );
  }

  // Create lifestyle care plan
  static CarePlan createLifestyleCarePlan({
    required String patientId,
    required String title,
    required List<String> activities,
    required List<String> goals,
  }) {
    return CarePlan(
      status: 'active',
      intent: 'plan',
      category: [
        FhirCodeableConcept(
          coding: [
            createSnomedCoding('386053000', 'Evaluation procedure'),
          ],
          text: 'Lifestyle Intervention',
        ),
      ],
      title: title,
      description: 'Personalized lifestyle intervention plan for hypertension management',
      subject: FhirReference(
        reference: 'Patient/$patientId',
      ),
      period: FhirPeriod(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 90)),
      ),
      activity: activities.map((activity) => CarePlanActivity(
        detail: CarePlanActivityDetail(
          status: 'not-started',
          description: activity,
          code: FhirCodeableConcept(
            text: activity,
          ),
        ),
      )).toList(),
      goal: goals.map((goal) => CarePlanGoal(
        description: FhirCodeableConcept(
          text: goal,
        ),
        subject: FhirReference(
          reference: 'Patient/$patientId',
        ),
      )).toList(),
      meta: FhirMeta(
        lastUpdated: DateTime.now(),
      ),
    );
  }

  // Helper to determine blood pressure category
  static String getBloodPressureCategory(double systolic, double diastolic) {
    if (systolic >= AppConstants.urgentSystolic || 
        diastolic >= AppConstants.urgentDiastolic) {
      return 'Hypertensive Crisis';
    } else if (systolic >= AppConstants.stage1HypertensionSystolic || 
               diastolic >= AppConstants.stage1HypertensionDiastolic) {
      return 'Stage 1 Hypertension';
    } else if (systolic >= AppConstants.highRiskSystolic || 
               diastolic >= AppConstants.highRiskDiastolic) {
      return 'Elevated';
    } else if (systolic < AppConstants.normalSystolic && 
               diastolic < AppConstants.normalDiastolic) {
      return 'Normal';
    } else {
      return 'Pre-hypertension';
    }
  }

  // Check if reading requires urgent attention
  static bool isUrgentReading(double systolic, double diastolic) {
    return systolic >= AppConstants.urgentSystolic || 
           diastolic >= AppConstants.urgentDiastolic;
  }

  // Generate patient reference
  static FhirReference createPatientReference(String patientId) {
    return FhirReference(
      reference: 'Patient/$patientId',
      type: 'Patient',
    );
  }

  // Create device reference for BP cuff
  static FhirReference createDeviceReference(String deviceId) {
    return FhirReference(
      reference: 'Device/$deviceId',
      type: 'Device',
    );
  }

  // Create provenance for audit trail
  static Map<String, dynamic> createProvenance({
    required String targetResourceId,
    required String resourceType,
    required String actorId,
    required String activity,
  }) {
    return {
      'resourceType': 'Provenance',
      'id': const Uuid().v4(),
      'target': [
        {'reference': '$resourceType/$targetResourceId'}
      ],
      'occurredDateTime': DateTime.now().toIso8601String(),
      'recorded': DateTime.now().toIso8601String(),
      'activity': {
        'coding': [
          {
            'system': 'http://terminology.hl7.org/CodeSystem/v3-DataOperation',
            'code': activity,
            'display': activity,
          }
        ]
      },
      'agent': [
        {
          'type': {
            'coding': [
              {
                'system': 'http://terminology.hl7.org/CodeSystem/provenance-participant-type',
                'code': 'author',
                'display': 'Author',
              }
            ]
          },
          'who': {
            'reference': 'Patient/$actorId'
          }
        }
      ]
    };
  }
}