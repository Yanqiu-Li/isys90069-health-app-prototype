import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'fhir_models.g.dart';

// Base FHIR Resource
@JsonSerializable()
class FhirResource {
  final String resourceType;
  final String id;
  final FhirMeta? meta;
  final String? implicitRules;
  final String? language;

  FhirResource({
    required this.resourceType,
    String? id,
    this.meta,
    this.implicitRules,
    this.language,
  }) : id = id ?? const Uuid().v4();

  factory FhirResource.fromJson(Map<String, dynamic> json) =>
      _$FhirResourceFromJson(json);
  
  Map<String, dynamic> toJson() => _$FhirResourceToJson(this);
}

@JsonSerializable()
class FhirMeta {
  final String? versionId;
  final DateTime? lastUpdated;
  final String? source;
  final List<String>? profile;
  final List<FhirCoding>? security;
  final List<FhirCoding>? tag;

  FhirMeta({
    this.versionId,
    this.lastUpdated,
    this.source,
    this.profile,
    this.security,
    this.tag,
  });

  factory FhirMeta.fromJson(Map<String, dynamic> json) =>
      _$FhirMetaFromJson(json);
  
  Map<String, dynamic> toJson() => _$FhirMetaToJson(this);
}

@JsonSerializable()
class FhirCoding {
  final String? system;
  final String? version;
  final String? code;
  final String? display;
  final bool? userSelected;

  FhirCoding({
    this.system,
    this.version,
    this.code,
    this.display,
    this.userSelected,
  });

  factory FhirCoding.fromJson(Map<String, dynamic> json) =>
      _$FhirCodingFromJson(json);
  
  Map<String, dynamic> toJson() => _$FhirCodingToJson(this);
}

@JsonSerializable()
class FhirCodeableConcept {
  final List<FhirCoding>? coding;
  final String? text;

  FhirCodeableConcept({
    this.coding,
    this.text,
  });

  factory FhirCodeableConcept.fromJson(Map<String, dynamic> json) =>
      _$FhirCodeableConceptFromJson(json);
  
  Map<String, dynamic> toJson() => _$FhirCodeableConceptToJson(this);
}

@JsonSerializable()
class FhirQuantity {
  final double? value;
  final String? comparator;
  final String? unit;
  final String? system;
  final String? code;

  FhirQuantity({
    this.value,
    this.comparator,
    this.unit,
    this.system,
    this.code,
  });

  factory FhirQuantity.fromJson(Map<String, dynamic> json) =>
      _$FhirQuantityFromJson(json);
  
  Map<String, dynamic> toJson() => _$FhirQuantityToJson(this);
}

@JsonSerializable()
class FhirReference {
  final String? reference;
  final String? type;
  final FhirIdentifier? identifier;
  final String? display;

  FhirReference({
    this.reference,
    this.type,
    this.identifier,
    this.display,
  });

  factory FhirReference.fromJson(Map<String, dynamic> json) =>
      _$FhirReferenceFromJson(json);
  
  Map<String, dynamic> toJson() => _$FhirReferenceToJson(this);
}

@JsonSerializable()
class FhirIdentifier {
  final String? use;
  final FhirCodeableConcept? type;
  final String? system;
  final String? value;
  final FhirPeriod? period;

  FhirIdentifier({
    this.use,
    this.type,
    this.system,
    this.value,
    this.period,
  });

  factory FhirIdentifier.fromJson(Map<String, dynamic> json) =>
      _$FhirIdentifierFromJson(json);
  
  Map<String, dynamic> toJson() => _$FhirIdentifierToJson(this);
}

@JsonSerializable()
class FhirPeriod {
  final DateTime? start;
  final DateTime? end;

  FhirPeriod({
    this.start,
    this.end,
  });

  factory FhirPeriod.fromJson(Map<String, dynamic> json) =>
      _$FhirPeriodFromJson(json);
  
  Map<String, dynamic> toJson() => _$FhirPeriodToJson(this);
}

// Blood Pressure Observation
@JsonSerializable()
class BloodPressureObservation extends FhirResource {
  final String status;
  final List<FhirCodeableConcept> category;
  final FhirCodeableConcept code;
  final FhirReference subject;
  final DateTime effectiveDateTime;
  final List<ObservationComponent> component;
  final FhirReference? device;
  final String? bodySite;
  final String? method;

  BloodPressureObservation({
    required this.status,
    required this.category,
    required this.code,
    required this.subject,
    required this.effectiveDateTime,
    required this.component,
    this.device,
    this.bodySite,
    this.method,
    String? id,
    FhirMeta? meta,
  }) : super(
    resourceType: 'Observation',
    id: id,
    meta: meta,
  );

  factory BloodPressureObservation.fromJson(Map<String, dynamic> json) =>
      _$BloodPressureObservationFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$BloodPressureObservationToJson(this);
}

@JsonSerializable()
class ObservationComponent {
  final FhirCodeableConcept code;
  final FhirQuantity? valueQuantity;
  final String? valueString;

  ObservationComponent({
    required this.code,
    this.valueQuantity,
    this.valueString,
  });

  factory ObservationComponent.fromJson(Map<String, dynamic> json) =>
      _$ObservationComponentFromJson(json);
  
  Map<String, dynamic> toJson() => _$ObservationComponentToJson(this);
}

// Medication Request
@JsonSerializable()
class MedicationRequest extends FhirResource {
  final String status;
  final String intent;
  final FhirCodeableConcept medicationCodeableConcept;
  final FhirReference subject;
  final DateTime? authoredOn;
  final FhirReference? requester;
  final List<Dosage>? dosageInstruction;

  MedicationRequest({
    required this.status,
    required this.intent,
    required this.medicationCodeableConcept,
    required this.subject,
    this.authoredOn,
    this.requester,
    this.dosageInstruction,
    String? id,
    FhirMeta? meta,
  }) : super(
    resourceType: 'MedicationRequest',
    id: id,
    meta: meta,
  );

  factory MedicationRequest.fromJson(Map<String, dynamic> json) =>
      _$MedicationRequestFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$MedicationRequestToJson(this);
}

@JsonSerializable()
class Dosage {
  final int? sequence;
  final String? text;
  final List<FhirCodeableConcept>? additionalInstruction;
  final String? patientInstruction;
  final Timing? timing;
  final FhirCodeableConcept? route;
  final List<DoseAndRate>? doseAndRate;

  Dosage({
    this.sequence,
    this.text,
    this.additionalInstruction,
    this.patientInstruction,
    this.timing,
    this.route,
    this.doseAndRate,
  });

  factory Dosage.fromJson(Map<String, dynamic> json) =>
      _$DosageFromJson(json);
  
  Map<String, dynamic> toJson() => _$DosageToJson(this);
}

@JsonSerializable()
class Timing {
  final List<DateTime>? event;
  final TimingRepeat? repeat;
  final FhirCodeableConcept? code;

  Timing({
    this.event,
    this.repeat,
    this.code,
  });

  factory Timing.fromJson(Map<String, dynamic> json) =>
      _$TimingFromJson(json);
  
  Map<String, dynamic> toJson() => _$TimingToJson(this);
}

@JsonSerializable()
class TimingRepeat {
  final int? count;
  final int? countMax;
  final double? duration;
  final double? durationMax;
  final String? durationUnit;
  final int? frequency;
  final int? frequencyMax;
  final double? period;
  final double? periodMax;
  final String? periodUnit;
  final List<String>? dayOfWeek;
  final List<String>? timeOfDay;
  final List<String>? when;
  final int? offset;

  TimingRepeat({
    this.count,
    this.countMax,
    this.duration,
    this.durationMax,
    this.durationUnit,
    this.frequency,
    this.frequencyMax,
    this.period,
    this.periodMax,
    this.periodUnit,
    this.dayOfWeek,
    this.timeOfDay,
    this.when,
    this.offset,
  });

  factory TimingRepeat.fromJson(Map<String, dynamic> json) =>
      _$TimingRepeatFromJson(json);
  
  Map<String, dynamic> toJson() => _$TimingRepeatToJson(this);
}

@JsonSerializable()
class DoseAndRate {
  final FhirCodeableConcept? type;
  final FhirQuantity? doseQuantity;
  final FhirQuantity? rateQuantity;

  DoseAndRate({
    this.type,
    this.doseQuantity,
    this.rateQuantity,
  });

  factory DoseAndRate.fromJson(Map<String, dynamic> json) =>
      _$DoseAndRateFromJson(json);
  
  Map<String, dynamic> toJson() => _$DoseAndRateToJson(this);
}

// Care Plan
@JsonSerializable()
class CarePlan extends FhirResource {
  final String status;
  final String intent;
  final List<FhirCodeableConcept>? category;
  final String? title;
  final String? description;
  final FhirReference subject;
  final FhirPeriod? period;
  final List<CarePlanActivity>? activity;
  final List<CarePlanGoal>? goal;

  CarePlan({
    required this.status,
    required this.intent,
    this.category,
    this.title,
    this.description,
    required this.subject,
    this.period,
    this.activity,
    this.goal,
    String? id,
    FhirMeta? meta,
  }) : super(
    resourceType: 'CarePlan',
    id: id,
    meta: meta,
  );

  factory CarePlan.fromJson(Map<String, dynamic> json) =>
      _$CarePlanFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$CarePlanToJson(this);
}

@JsonSerializable()
class CarePlanActivity {
  final FhirCodeableConcept? outcomeCodeableConcept;
  final List<FhirReference>? outcomeReference;
  final List<FhirAnnotation>? progress;
  final FhirReference? reference;
  final CarePlanActivityDetail? detail;

  CarePlanActivity({
    this.outcomeCodeableConcept,
    this.outcomeReference,
    this.progress,
    this.reference,
    this.detail,
  });

  factory CarePlanActivity.fromJson(Map<String, dynamic> json) =>
      _$CarePlanActivityFromJson(json);
  
  Map<String, dynamic> toJson() => _$CarePlanActivityToJson(this);
}

@JsonSerializable()
class CarePlanActivityDetail {
  final String? kind;
  final String? instantiatesUri;
  final FhirCodeableConcept? code;
  final List<FhirCodeableConcept>? reasonCode;
  final List<FhirReference>? reasonReference;
  final List<CarePlanGoal>? goal;
  final String status;
  final FhirCodeableConcept? statusReason;
  final bool? doNotPerform;
  final Timing? scheduledTiming;
  final FhirPeriod? scheduledPeriod;
  final String? scheduledString;
  final FhirReference? location;
  final List<FhirReference>? performer;
  final FhirCodeableConcept? productCodeableConcept;
  final FhirReference? productReference;
  final FhirQuantity? dailyAmount;
  final FhirQuantity? quantity;
  final String? description;

  CarePlanActivityDetail({
    this.kind,
    this.instantiatesUri,
    this.code,
    this.reasonCode,
    this.reasonReference,
    this.goal,
    required this.status,
    this.statusReason,
    this.doNotPerform,
    this.scheduledTiming,
    this.scheduledPeriod,
    this.scheduledString,
    this.location,
    this.performer,
    this.productCodeableConcept,
    this.productReference,
    this.dailyAmount,
    this.quantity,
    this.description,
  });

  factory CarePlanActivityDetail.fromJson(Map<String, dynamic> json) =>
      _$CarePlanActivityDetailFromJson(json);
  
  Map<String, dynamic> toJson() => _$CarePlanActivityDetailToJson(this);
}

@JsonSerializable()
class CarePlanGoal {
  final String? id;
  final List<FhirCodeableConcept>? category;
  final FhirCodeableConcept? description;
  final FhirReference? subject;
  final String? startDate;
  final String? startCodeableConcept;
  final List<GoalTarget>? target;
  final String? statusDate;
  final String? statusReason;
  final FhirReference? expressedBy;
  final List<FhirReference>? addresses;
  final List<FhirAnnotation>? note;
  final List<FhirCodeableConcept>? outcomeCode;
  final List<FhirReference>? outcomeReference;

  CarePlanGoal({
    this.id,
    this.category,
    this.description,
    this.subject,
    this.startDate,
    this.startCodeableConcept,
    this.target,
    this.statusDate,
    this.statusReason,
    this.expressedBy,
    this.addresses,
    this.note,
    this.outcomeCode,
    this.outcomeReference,
  });

  factory CarePlanGoal.fromJson(Map<String, dynamic> json) =>
      _$CarePlanGoalFromJson(json);
  
  Map<String, dynamic> toJson() => _$CarePlanGoalToJson(this);
}

@JsonSerializable()
class GoalTarget {
  final FhirCodeableConcept? measure;
  final FhirQuantity? detailQuantity;
  final String? detailRange;
  final FhirCodeableConcept? detailCodeableConcept;
  final String? dueDate;
  final FhirDuration? dueDuration;

  GoalTarget({
    this.measure,
    this.detailQuantity,
    this.detailRange,
    this.detailCodeableConcept,
    this.dueDate,
    this.dueDuration,
  });

  factory GoalTarget.fromJson(Map<String, dynamic> json) =>
      _$GoalTargetFromJson(json);
  
  Map<String, dynamic> toJson() => _$GoalTargetToJson(this);
}

@JsonSerializable()
class FhirDuration {
  final double? value;
  final String? comparator;
  final String? unit;
  final String? system;
  final String? code;

  FhirDuration({
    this.value,
    this.comparator,
    this.unit,
    this.system,
    this.code,
  });

  factory FhirDuration.fromJson(Map<String, dynamic> json) =>
      _$FhirDurationFromJson(json);
  
  Map<String, dynamic> toJson() => _$FhirDurationToJson(this);
}

@JsonSerializable()
class FhirAnnotation {
  final FhirReference? authorReference;
  final String? authorString;
  final DateTime? time;
  final String text;

  FhirAnnotation({
    this.authorReference,
    this.authorString,
    this.time,
    required this.text,
  });

  factory FhirAnnotation.fromJson(Map<String, dynamic> json) =>
      _$FhirAnnotationFromJson(json);
  
  Map<String, dynamic> toJson() => _$FhirAnnotationToJson(this);
}