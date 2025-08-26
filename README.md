# Hypertension Management Mobile App

A comprehensive Flutter mobile application for hypertension management supporting lifestyle coaching, self-measured blood pressure (SMBP), medication support, and an LLM-based AI assistant.

## 📱 Features

### 🩺 Blood Pressure Monitoring (SMBP)
- Record blood pressure measurements manually or via Bluetooth-enabled devices
- IEEE 11073-10407 standard compliance for device interoperability
- Automatic categorization based on AHA/ACC guidelines
- Trend analysis and variability metrics
- Urgent reading alerts (≥180/120 mmHg)
- Weekly and monthly averages

### 🏃‍♂️ Lifestyle Coaching
- Evidence-based behavior change techniques (BCTTv1)
- Personalized goals and action plans
- Self-monitoring tools for diet, exercise, weight, and sleep
- Progress tracking with visual feedback
- Weekly challenges and achievements
- DASH diet recommendations

### 💊 Medication Management
- Comprehensive medication tracking with RxNorm coding
- Smart reminders based on prescription schedules
- Adherence analytics and reporting
- Side effect logging with AdverseEvent tracking
- Barcode scanning for easy medication entry
- E-prescription import support

### 🤖 AI Health Assistant
- RAG-based knowledge system with vetted medical sources
- Evidence-based responses with citations
- Privacy-preserving design with on-device de-identification
- Educational content on hypertension management
- 24/7 availability for health questions

## 🏗️ Architecture

### Standards Compliance
- **HL7 FHIR R4**: Primary data model for interoperability
- **LOINC**: Observation codes (8480-6 for SBP, 8462-4 for DBP)
- **SNOMED CT**: Clinical terminology
- **RxNorm**: Medication coding
- **UCUM**: Units of measure
- **IEEE 11073**: Personal health device standards

### Data Security
- **SQLCipher**: Encrypted local database storage
- **AES-256**: Data at rest encryption
- **TLS 1.3**: Secure data transmission
- **OAuth 2.0 + PKCE**: Authentication
- **SMART on FHIR**: EHR integration
- **Android Keystore/iOS Keychain**: Secure key storage

### Technical Stack
- **Frontend**: Flutter 3.10+ with Material 3 design
- **State Management**: Riverpod
- **Database**: SQLite with SQLCipher encryption
- **Bluetooth**: Flutter Blue Plus for device connectivity
- **Notifications**: Flutter Local Notifications
- **Charts**: FL Chart and Syncfusion Charts
- **Authentication**: OAuth2 with secure storage

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode for mobile development
- Git for version control

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd hypertension_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   # For development
   flutter run

   # For specific platform
   flutter run -d android
   flutter run -d ios
   ```

### Configuration

1. **Environment Variables**
   Create `.env` file in the root directory:
   ```
   BASE_URL=https://api.hypertension-app.com
   FHIR_ENDPOINT=/fhir/R4
   SMART_AUTH_ENDPOINT=/auth/smart
   ```

2. **Firebase Setup** (Optional)
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Configure FCM for push notifications

3. **EHR Integration**
   - Configure SMART on FHIR endpoints
   - Set up OAuth client credentials
   - Register redirect URIs

## 📊 Data Models

### FHIR Resources
- **Observation**: Blood pressure readings with LOINC codes
- **MedicationRequest**: Prescriptions with RxNorm coding
- **MedicationStatement**: Actual medication intake
- **CarePlan**: Lifestyle intervention plans
- **QuestionnaireResponse**: Lifestyle assessments
- **DocumentReference**: Reports and summaries
- **Device**: Blood pressure monitors and health devices
- **Provenance**: Audit trail for all data operations

### Local Database Schema
```sql
-- FHIR resources stored as JSON
fhir_resources (id, resource_type, subject_id, data, sync_status)

-- Optimized tables for frequent queries
blood_pressure_readings (id, patient_id, systolic, diastolic, timestamp)
medications (id, patient_id, medication_code, dosage, frequency)
medication_events (id, medication_id, status, scheduled_time)
```

## 🔧 Development

### Project Structure
```
lib/
├── core/
│   ├── constants/       # App constants and configurations
│   ├── database/        # Database services and models
│   ├── models/          # FHIR models and helpers
│   ├── services/        # Core services (auth, notifications)
│   └── utils/           # Utility functions
├── features/
│   ├── auth/            # Authentication module
│   ├── smbp/            # Blood pressure module
│   ├── lifestyle/       # Lifestyle coaching module
│   ├── medication/      # Medication management module
│   └── assistant/       # AI assistant module
└── shared/
    ├── widgets/         # Reusable UI components
    └── themes/          # App theming
```

### Code Standards
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Implement proper error handling
- Write unit and integration tests
- Document complex business logic

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Test coverage
flutter test --coverage
```

## 📱 Platform Support

### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Permissions: Bluetooth, Camera, Storage, Location

### iOS
- Minimum iOS: 12.0
- Permissions: HealthKit, Bluetooth, Camera, Photos
- Background modes: Background processing, fetch

## 🔒 Privacy & Security

### Data Protection
- End-to-end encryption for sensitive health data
- Local data encrypted with SQLCipher
- Secure key management with platform keystores
- Automatic PHI redaction in logs

### Compliance
- HIPAA compliant data handling
- GDPR privacy controls
- Data minimization principles
- User consent management
- Right to data portability and deletion

### AI Safety
- Guardrails prevent medical advice generation
- Responses include source citations
- Uncertainty indicators when evidence is insufficient
- Clear disclaimers about limitations

## 🌐 EHR Integration

### SMART on FHIR
- OAuth 2.0 authorization flow
- Scoped access to patient data
- Automatic token refresh
- Patient-mediated data sharing

### Data Exchange
**Reads from EHR:**
- MedicationRequest (prescriptions)
- Condition (diagnoses)
- AllergyIntolerance
- Historical observations

**Writes to EHR:**
- Blood pressure observations
- Medication adherence statements
- Lifestyle questionnaire responses
- Care plan activities
- Weekly/monthly reports

## 📈 Analytics & Monitoring

### Health Metrics
- Blood pressure trends and variability
- Medication adherence rates
- Lifestyle goal achievement
- Device usage patterns

### Performance Monitoring
- App crash reporting
- Network request monitoring
- Database performance metrics
- User engagement analytics

## 🚀 Deployment

### Build Commands
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS Archive
flutter build ipa --release
```

### CI/CD Pipeline
- Automated testing on pull requests
- Code quality checks with static analysis
- Security scanning for vulnerabilities
- Automated deployment to app stores

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the project's coding standards
- Write tests for new features
- Update documentation as needed
- Ensure FHIR compliance for health data
- Test on both Android and iOS platforms

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For technical support or questions:
- Create an issue in the GitHub repository
- Email: support@hypertension-app.com
- Documentation: [docs.hypertension-app.com](https://docs.hypertension-app.com)

## 🙏 Acknowledgments

- American Heart Association for clinical guidelines
- HL7 FHIR community for interoperability standards
- Flutter team for the excellent framework
- Open source contributors and maintainers

## 📋 Roadmap

### Version 1.1
- Apple HealthKit integration
- Google Fit synchronization
- Enhanced charts and analytics
- Multi-language support

### Version 1.2
- Telemedicine integration
- Family sharing features
- Advanced AI insights
- Wearable device support

### Version 2.0
- Clinical trial participation
- Research data contribution
- Advanced predictive analytics
- Personalized treatment recommendations