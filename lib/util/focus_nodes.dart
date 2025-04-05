import 'package:flutter/material.dart';

typedef Nodes = FocusNodes;

class FocusNodes {
  const FocusNodes();

  // Global Nav
  static FocusNode backNavButton = FocusNode(debugLabel: "backNavButton");

  //Locale page
  static FocusNode localePage = FocusNode(debugLabel: "localePage");
  static FocusNode localeList = FocusNode(debugLabel: "localeList");
  static FocusNode setLocaleButton = FocusNode(debugLabel: "setLocaleButton");

  //Introduction Page
  static FocusNode introductionPage = FocusNode(debugLabel: "introductionPage");
  static FocusNode usernameAutoSizeTextField =
      FocusNode(debugLabel: "usernameAutoSizeTextField");
  static FocusNode credentialAutoSizeTextField =
      FocusNode(debugLabel: "credentialAutoSizeTextField");
  static FocusNode specializationAutoSizeTextField =
      FocusNode(debugLabel: "specializationAutoSizeTextField");
  static FocusNode clinicAutoSizeTextField =
      FocusNode(debugLabel: "clinicAutoSizeTextField");
  static FocusNode contactNoField = FocusNode(debugLabel: "contactNoField");
  static FocusNode securityPinField = FocusNode(debugLabel: "securityPinField");
  static FocusNode prevStep = FocusNode(debugLabel: "preButton");
  static FocusNode nextStep = FocusNode(debugLabel: "nextStep");
  static FocusNode finishSetup = FocusNode(debugLabel: "finishSetup");
  static FocusNode pinAutoSizeTextField =
      FocusNode(debugLabel: "pinAutoSizeTextField");
  static FocusNode dataRetentionSwitchKey =
      FocusNode(debugLabel: "dataRetentionSwitchKey");
  static FocusNode dataRetentionSpinner =
      FocusNode(debugLabel: "dataRetentionSpinner");

  static FocusNode informationSlideKey =
      FocusNode(debugLabel: "informationSlide");
  static FocusNode doctorsProfileSlideKey =
      FocusNode(debugLabel: "doctorsProfileSlide");
  static FocusNode dataRetentionProfileSlideKey =
      FocusNode(debugLabel: "dataRetensionProfileSlide");

  static FocusNode pageStepper = FocusNode(debugLabel: "pageStepper");

  // Select Letterhead Template Page

  static FocusNode selectTemplateSwiper =
      FocusNode(debugLabel: "selectTemplateSwiper");
  static FocusNode datePicker = FocusNode(debugLabel: "datePicker");

  // LetterHead page

  static FocusNode letterHeadPage = FocusNode(debugLabel: "letterHeadPage");
  static FocusNode letterHeadDoneButton =
      FocusNode(debugLabel: "letterHeadDoneButtton");
  static FocusNode letterHeadScanButton =
      FocusNode(debugLabel: "letterHeadScanButton");
  static FocusNode letterHeadSkipButton =
      FocusNode(debugLabel: "letterHeadSkipButton");

  // Splash Page
  static FocusNode splashPage = FocusNode(debugLabel: "splashPage");
  static FocusNode forgotPinButtonm = FocusNode(debugLabel: "forgotPipButton");

  static FocusNode skipButton = FocusNode(debugLabel: "skipButton");

  //Introduction Splash page
  static FocusNode introductionSplashPage =
      FocusNode(debugLabel: "introductionSplashPage");

  // Home Page
  static FocusNode homePage = FocusNode(debugLabel: "homePage");
  static FocusNode homeButton = FocusNode(debugLabel: "homeButton");
  static FocusNode consultationStatusIndicator =
      FocusNode(debugLabel: "consultationStatusIndicator");
  static FocusNode profileNavigationButton =
      FocusNode(debugLabel: "profileNavigationButtonm");
  static FocusNode letterHeadNavigationButton =
      FocusNode(debugLabel: "letterHeadNavigationButton");
  static FocusNode securityNavigationButton =
      FocusNode(debugLabel: "securityNavigatioButton");
  static FocusNode consultationSearchNavButton =
      FocusNode(debugLabel: "consultationSearchNavigatio.labelMediumKey");
  static FocusNode navigationButton = FocusNode(debugLabel: "navigationAction");
  static FocusNode tableCalendar = FocusNode(debugLabel: "tableCalendar");
  static FocusNode consultationCount =
      FocusNode(debugLabel: "consultationCount");
  static FocusNode consultFabButton =
      FocusNode(debugLabel: "consultationFabButton");
  static FocusNode settingsNavButton =
      FocusNode(debugLabel: "settingsNavButton");
  static FocusNode timeline = FocusNode(debugLabel: "timeline");
  static FocusNode logout = FocusNode(debugLabel: "logout");

  // Edit Profile  Page
  static FocusNode editProfileKey = FocusNode(debugLabel: "editProfileKey");
  static FocusNode nameLabelKey = FocusNode(debugLabel: "nameLabelKey");
  static FocusNode specializationLabelKey =
      FocusNode(debugLabel: "specializingLabelKey");
  static FocusNode clinicLabelKey = FocusNode(debugLabel: "clinicLabelKey");
  static FocusNode contactNoLabelKey =
      FocusNode(debugLabel: "contactNoLabelKey");

  // View Profile  Page
  static FocusNode viewPorilfeKey = FocusNode(debugLabel: "viewProfileKey");
  static FocusNode nameLabelViewKey = FocusNode(debugLabel: "nameLabelKey");
  static FocusNode specializationViewLabelKey =
      FocusNode(debugLabel: "specializingLabelKey");

  static FocusNode credentialLabelVieewKey =
      FocusNode(debugLabel: "credentialLabelViewKey");

  static FocusNode clinicLabelViewKey = FocusNode(debugLabel: "clinicLabelKey");
  static FocusNode contactNoLabelViewKey =
      FocusNode(debugLabel: "contactNoLabelKey");

  // Signature Settings page
  static FocusNode editSignatureSettings =
      FocusNode(debugLabel: "signatureSettings");
  static FocusNode enableSignature = FocusNode(debugLabel: "enableSignature");
  static FocusNode showSignaturePad = FocusNode(debugLabel: "showSignaturePad");
  static FocusNode saveSignatureSettings =
      FocusNode(debugLabel: "saveSignatureSettings");

  //Security Page

  static FocusNode securityPage = FocusNode(debugLabel: "securityPage");
  static FocusNode confirmPinField = FocusNode(debugLabel: "condirmPinField");
  static FocusNode savePiButton = FocusNode(debugLabel: "savePiButton");
  static FocusNode changePin = FocusNode(debugLabel: "changePin");
  static FocusNode securitySettings = FocusNode(debugLabel: "securitySettings");

  // Add Consultation Page

  static FocusNode addConsultationPage =
      FocusNode(debugLabel: "addConsultationPage");
  static FocusNode patientSummaryTile =
      FocusNode(debugLabel: "patientSummaryTile");
  static FocusNode genderField = FocusNode(debugLabel: "gender");
  static FocusNode symptomsList = FocusNode(debugLabel: "symptomsList");
  static FocusNode closButton = FocusNode(debugLabel: "closButton");
  static FocusNode prescriptionList = FocusNode(debugLabel: "prescriptionList");
  static FocusNode conditionsAutoSizeTextField =
      FocusNode(debugLabel: "conditionsAutoSizeTextField");
  static FocusNode medicalHistoryList =
      FocusNode(debugLabel: "medicalHistoryList");
  static FocusNode systolicAutoSizeTextField =
      FocusNode(debugLabel: "systolicAutoSizeTextField");
  static FocusNode diastolicAutoSizeTextField =
      FocusNode(debugLabel: "diastolicAutoSizeTextField");
  static FocusNode pulseRateAutoSizeTextField =
      FocusNode(debugLabel: "pulseRateAutoSizeTextField");
  static FocusNode temperatureAutoSizeTextField =
      FocusNode(debugLabel: "temperatureAutoSizeTextField");
  static FocusNode spO2AutoSizeTextField =
      FocusNode(debugLabel: "spO2AutoSizeTextField");
  static FocusNode addSymptomsSlide = FocusNode(debugLabel: "addSymptomSlide");
  static FocusNode addSymptomToList =
      FocusNode(debugLabel: " addToSymptomList");
  static FocusNode vitalSignsTile = FocusNode(debugLabel: "vitalSignsTile");
  static FocusNode testParametersTile =
      FocusNode(debugLabel: "testParametersTile");
  static FocusNode symptomsTile = FocusNode(debugLabel: "symptomsTile");
  static FocusNode addToTestButton = FocusNode(debugLabel: "addToTestButton");
  static FocusNode symtomsList = FocusNode(debugLabel: "symtomsList");
  static FocusNode medicalHistoryTile =
      FocusNode(debugLabel: "medicalHistoryTile");
  static FocusNode presciptionTile = FocusNode(debugLabel: "presciptionTile");
  static FocusNode addPrescriptioButton =
      FocusNode(debugLabel: "addPrescriptioButton");
  static FocusNode conditionDuration =
      FocusNode(debugLabel: "conditionDuration");
  static FocusNode conditionDurationType =
      FocusNode(debugLabel: "conditionDurationType");

  static FocusNode testsTile = FocusNode(debugLabel: "testsTile");

  static FocusNode patientAgeAutoSizeTextField =
      FocusNode(debugLabel: "patientAgeAutoSizeTextField");

  static FocusNode patientNameAutoSizeTextField =
      FocusNode(debugLabel: "patientNameAutoSizeTextField");
  static FocusNode symptomNameAutoSizeTextField =
      FocusNode(debugLabel: "symptomNameAutoSizeTextField");
  static FocusNode notesTile = FocusNode(debugLabel: "notesTile");
  static FocusNode medicalConditionAutoSizeTextField =
      FocusNode(debugLabel: "medicalConditionAutoSizeTextField");
  static FocusNode patientGenderField =
      FocusNode(debugLabel: "patientGenderField");
  static FocusNode addMedicatioButton =
      FocusNode(debugLabel: "addMedicatioButton");
  static FocusNode removeMedicatioButton =
      FocusNode(debugLabel: "removeMedicatioButton");
  static FocusNode medicalHistorySlide =
      FocusNode(debugLabel: "medicalHistorySlide");

  static FocusNode showMedicationSlide =
      FocusNode(debugLabel: "showMedicationSlide");

  static FocusNode durationTypeField =
      FocusNode(debugLabel: "durationTypeField");

  static FocusNode savePrescriptioButton =
      FocusNode(debugLabel: "savePrescriptioButton");

  static FocusNode checkPrescriptioButton =
      FocusNode(debugLabel: "checkPrecriptioButton");
  static FocusNode prescriptionVieButton =
      FocusNode(debugLabel: "viewPrescription");

  static FocusNode patientTaButton = FocusNode(debugLabel: "patientTaButton");
  static FocusNode symptomsTaButton = FocusNode(debugLabel: "symptomsTaButton");
  static FocusNode vitalSignsTaButton =
      FocusNode(debugLabel: "vitalSignsTaButton");
  static FocusNode medicalHistoryTaButton =
      FocusNode(debugLabel: "medicalHistoryTaButton");
  static FocusNode notesTaButton = FocusNode(debugLabel: "notesTaButton");
  static FocusNode prescriptionTaButton =
      FocusNode(debugLabel: "prescriptionTaButton");

  static FocusNode patientTabHeader = FocusNode(debugLabel: "patientTabHeader");
  static FocusNode symptomsTabHeader =
      FocusNode(debugLabel: "patientTabHeader");
  static FocusNode vitalSignsTabHeader =
      FocusNode(debugLabel: "vitalSignsTabHeader");
  static FocusNode medicalHistoryTabHeader =
      FocusNode(debugLabel: "medicalHistoryTabHeader");
  static FocusNode notesTabHeader = FocusNode(debugLabel: "notesTabHeader");
  static FocusNode prescriptionTabHeader =
      FocusNode(debugLabel: "prescriptionTabHeader");

  static FocusNode consultationDateHeader =
      FocusNode(debugLabel: "consultationDateHeader");
  static FocusNode consultationTimeHeader =
      FocusNode(debugLabel: "consultationTimeHeader");
  static FocusNode consultationStatusHeader =
      FocusNode(debugLabel: "consultationStatusHeader");

  static FocusNode saveConsultatioButton =
      FocusNode(debugLabel: "saveConsultatioButton");

  static FocusNode checkConsultatioButton =
      FocusNode(debugLabel: "checkConsultatioButton");
  // Consultation View Page
  static FocusNode consultationViewPage =
      FocusNode(debugLabel: "consultationViewPage");
  static FocusNode patientSummaryViewTile =
      FocusNode(debugLabel: "patientSummaryViewTile");
  static FocusNode prescriptionViewTile =
      FocusNode(debugLabel: "prescriptionViewTile");
  static FocusNode symptomsViewTile = FocusNode(debugLabel: "symptomsViewTile");
  static FocusNode medicalHistoryViewTile =
      FocusNode(debugLabel: "medicalHistoryViewTile");
  static FocusNode vitalSignsViewTile =
      FocusNode(debugLabel: "vitalSignsViewTile");

  // Add Medication Page
  static FocusNode addMedicationPage =
      FocusNode(debugLabel: "addMedicationPage");
  static FocusNode addMedicationStepper =
      FocusNode(debugLabel: "addMedicationStepper");
  static FocusNode durationAutoSizeTextField =
      FocusNode(debugLabel: "durationAutoSizeTextField");
  static FocusNode routeDropDown = FocusNode(debugLabel: "routeDropDown");
  static FocusNode directionsChoiceList =
      FocusNode(debugLabel: "directionsChoiceList");
  static FocusNode frequencyDropDowButton =
      FocusNode(debugLabel: "frequencyDropDowButton");
  static FocusNode medicationNameAutoSizeTextField =
      FocusNode(debugLabel: "medicationNameAutoSizeTextField");
  static FocusNode dosageAutoSizeTextField =
      FocusNode(debugLabel: "dosageAutoSizeTextField");
  static FocusNode drugInfoSlide = FocusNode(debugLabel: "drugInfoSlide");
  static FocusNode scheduleSlide = FocusNode(debugLabel: "scheduleSlide");
  static FocusNode unitDropDown = FocusNode(debugLabel: "unitDropDown");
  static FocusNode timeChoiceChip = FocusNode(debugLabel: "timeChoiceChip");
  static FocusNode saveMedicatioButton =
      FocusNode(debugLabel: "saveMedicatioButton");

  // Prescription Preview Page
  static FocusNode prescriptionPreviewPage =
      FocusNode(debugLabel: "prescriptionPreviewPage");
  static FocusNode prinButton = FocusNode(debugLabel: "prinButton");
  static FocusNode pdfViewWidget = FocusNode(debugLabel: "pdfViewWidget");
  static FocusNode sharButton = FocusNode(debugLabel: "sharButton");

  // Consultation Search Page
  static FocusNode consultationSearchPage =
      FocusNode(debugLabel: "consultationSearchPage");
  static FocusNode dateFilterDropDown =
      FocusNode(debugLabel: "dateFilterDropDown");
  static FocusNode consultationSearchList =
      FocusNode(debugLabel: "consultationSearchList");
  static FocusNode patientNameSearchAutoSizeTextField =
      FocusNode(debugLabel: "patientNameSearchAutoSizeTextField");
  static FocusNode beforeMenuItem = FocusNode(debugLabel: "beforeMenuItem");
  static FocusNode afterMenuItem = FocusNode(debugLabel: "afterMenuItem");
  static FocusNode betweenMenuItem = FocusNode(debugLabel: "betweenMenuItem");
  static FocusNode consultationEdiButton =
      FocusNode(debugLabel: "consultationEdiButton");
  static FocusNode consultationVieButton =
      FocusNode(debugLabel: "FocusNodeultationVieButton");

  // Prescription Settings page
  static FocusNode selectTemplate = FocusNode(debugLabel: "selectTemplate");
  static FocusNode selectFormat = FocusNode(debugLabel: "selectFormat");
  static FocusNode savePrescriptionSettings =
      FocusNode(debugLabel: "savePrescriptionSettings");

  // Edit Pin Setings Page
  static FocusNode editPinSettingsPage =
      FocusNode(debugLabel: "editPinSettingsPage");
  static FocusNode pinResetReminder = FocusNode(debugLabel: "pinResetReminder");
  static FocusNode pinResetDatePicker =
      FocusNode(debugLabel: "pinResetDatePicker");
  static FocusNode newPinField = FocusNode(debugLabel: "PinAutoSizeTextField");

  // Rest Pin Page
  static FocusNode pinField = FocusNode(debugLabel: "pinField");

  // Forgot Pin Page
  static FocusNode forgotPinPage = FocusNode(debugLabel: "forgotPinPage");

  // Data RetentionSettings Page
  static FocusNode dataRetentionSettingsPage =
      FocusNode(debugLabel: "dataRetentionSettingsPage");
  static FocusNode dataRetentionSwitch =
      FocusNode(debugLabel: "dataRetentionSwitch");
  static FocusNode setRetentionDuration =
      FocusNode(debugLabel: "setRetentionDuration");
  static FocusNode setRetentionTaskTime =
      FocusNode(debugLabel: "setRetentionTaskTime");

  // Data Retention Page
  static FocusNode retentionAuditPage =
      FocusNode(debugLabel: "retentionAuditPage");

  static FocusNode saveSettingButton =
      FocusNode(debugLabel: "saveSettingsButton");
}
