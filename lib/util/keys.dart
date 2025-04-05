import 'package:flutter/foundation.dart';

typedef K = Keys;

class Keys {
  const Keys();

  // Global Nav
  static const backNavButton = Key("backNavButton");
  static const tileStatusExpanded = Key("expanded");
  static const tileStatusCollapsed = Key("collapsed");

  //Login Page
  static const loginButton = Key("loginButton");
  static const forgotPinButton = Key("forgotPinButton");

  // Password Reset Page
  static const homeButton = Key("homeButton");
  static const nextButton = Key("nextButton");

  //Locale page
  static const localePage = Key("localePage");
  static const localeList = Key("localeList");
  static const setLocaleButton = Key("setLocaleButton");

  //Introduction Page
  static const introductionPage = Key("introductionPage");
  static const firstNameTextField = Key("firstNameTextField");
  static const lastNameTextField = Key("lastNameTextField");
  static const credentialTextField = Key("credentialTextField");
  static const specializationDropDown = Key("specializationSelectField");
  static const clinicTextField = Key("clinicTextField");
  static const contactNoField = Key("contactNoField");
  static const prevStep = Key("pre.labelMedium");
  static const nextStep = Key("nextStep");
  static const finishSetup = Key("finishSetup");
  static const pinTextField = Key("pinAutoSizeTextField");
  static const dataRetentionSwitchKey = Key("dataRetentionSwitchKey");
  static const dataRetentionSpinner = Key("dataRetentionSpinner");

  static const informationSlideKey = Key("informationSlide");
  static const doctorsProfileSlideKey = Key("doctorsProfileSlide");
  static const dataRetentionProfileSlideKey = Key("dataRetensionProfileSlide");
  static const securitySettingsSlideKey = Key("securitySettingsSlide");

  static const pageStepper = Key("pageStepper");

  // Select Letterhead Template Page

  static const selectTemplateSwiper = Key("selectTemplateSwiper");
  static const datePicker = Key("datePicker");
  static const checked = Key("checked");
  static const unchecked = Key("unchecked");

  // LetterHead page

  static const letterHeadPage = Key("letterHeadPage");
  static const letterHeadDoneButton = Key("letterHeadDoneButton");
  static const letterHeadScanButton = Key("letterHeadScanButton");
  static const letterHeadSkipButton = Key("letterHeadSkipButton");

  // Splash Page
  static const splashPage = Key("splashPage");

  static const skipBuutton = Key("skipButton");

  //Introduction Splash page
  static const introductionSplashPage = Key("introductionSplashPage");
  static const startTourButton = Key("startTourButton");

  // Home Page
  static const homePage = Key("homnePage");
  static const consultationStatusIndicator = Key("consultationStatusIndicator");
  static const profileNavigationButton = Key("profileNavigationButton");
  static const letterHeadNavigationButton = Key("letterHeadNavigationButton");
  static const securityNavigatioButton = Key("securityNavigatio.labelMedium");
  static const consultationSearchNButton =
      Key("consultationSearchNavigationButton");
  static const navigationButton = Key("navigationActionButton");
  static const consultationCount = Key("consultationCount");
  static const consultFabButton = Key("consultationFabButton");
  static const settingsButton = Key("settingsButton");
  static const selectedDateLabel = Key("selectedDateLabel");
  static const timeLineKey = Key("timeLineLabel");
  static const deleteConsultationButton = Key("deleteConsultationButton");
  static const viewConsultationButton = Key("viewConsultationButton");
  static const editConsultationButton = Key("editConsultationButton");
  static const logoutButton = Key("logoutButton");

  // ProfileView Page
  static const nameLabelKey = Key("nameLabelKey");
  static const specializationLabelKey = Key("specializingLabelKey");
  static const clinicLabelKey = Key("clinicLabelKey");
  static const contactNoLabelKey = Key("contactNoLabelKey");
  static const credentialLabelKey = Key("credentialLabelKey");
  static const editProfileButtonKey = Key("editProfileButtonKey");

  // LetterheadSelection Page
  static const saveLetterHeadSelectionButton =
      Key("saveLetterHeadSelectionButton");
  static const letterHeadSelectionCoursel = Key("letterHeadSelectionCoursel");
  static const selectedOption = Key("selectedOption");

  //Security Page

  static const securityPage = Key("securityPage");
  static const confirmPinField = Key("condirmPinField");
  static const saveButton = Key("saveButton");
  static const pinReset = Key("pinReset");
  static const securitySettings = Key("securitySettings");

  // Add Consultation Page

  static const addConsultationPage = Key("addConsultationPage");
  static const consultationHeader = Key("consultationHeader");
  static const consultationDate = Key("consultationDate");
  static const genderField = Key("gender");
  static const symptomsList = Key("symptomsList");
  static const testsList = Key("testsList");
  static const closeButton = Key("closeButton");
  static const prescriptionList = Key("prescriptionList");
  static const medicalHistoryName = Key("medicalHistoryNameField");
  static const addMedicalHistory = Key("addMedicalHistory");

  static const medicalHistoryList = Key("medicalHistoryList");

  static const addSymptomsSlide = Key("addSymptomSlide");
  static const addSymptomToList = Key(" addToSymptomList");

  static const addTestToList = Key("addToTestsList");
  static const vitalSignsTile = Key("vitalSignsTile");
  static const parametersTile = Key("parametersTile");
  static const addParameterButton = Key("addParameterButton");
  static const parameterList = Key("parameterList");
  static const testsTile = Key("testsTile");
  static const bpSwitch = Key("bpWitch");
  static const bpSystolicField = Key("bpSystolicKey");
  static const bpDiastolicField = Key("bpDiastolicKey");
  static const hrSwitch = Key("hrSwitch");
  static const hrField = Key("hrField");
  static const tempSwitch = Key("tempSwitch");
  static const tempSlider = Key("tempSlider");
  static const tempValue = Key("tmpValue");
  static const spo2Switch = Key("spo2Switch");
  static const spo2Slider = Key("spo2Slider");
  static const spo2Value = Key("spo2Value");
  static const symptomsTile = Key("symptomsTile");
  static const addSymptomButton = Key("addSymptonButton");
  static const medicalHistoryTile = Key("medicalHistoryTile");
  static const presciptionTile = Key("presciptionTile");
  static const addToNotesButton = Key("addToNotes");
  static const notlesList = Key("notesList");

  static const timesIconList = Key("timesIconList");
  static const daybreak = Key("daybreak");
  static const morning = Key("morning");
  static const afternoon = Key("afternoon");
  static const evening = Key("evening");
  static const night = Key("night");

  static const addPrescriptionButton = Key("addPrescriptionButton");
  static const conditionDuration = Key("conditionDuration");
  static const conditionDurationType = Key("conditionDurationType");

  static const parameterNameField = Key("parameterNameField");
  static const parameterValueField = Key("parameterValueField");
  static const paramaeterUnitField = Key("parameterUnitField");

  static const patientAgeAutoSizeTextField = Key("patientAgeAutoSizeTextField");
  static const patientWeightTextField = Key("patientWeightTextField");
  static const patientSummaryTile = Key("patientSummaryTile");
  static const patientNameAutoSizeTextField =
      Key("patientNameAutoSizeTextField");
  static const symptomNameAutoSizeTextField =
      Key("symptomNameAutoSizeTextField");
  static const notesTile = Key("notesTile");
  static const medicalConditionAutoSizeTextField =
      Key("medicalConditionAutoSizeTextField");
  static const patientGenderField = Key("patientGenderField");
  static const addMedicatioButton = Key("addMedicatioButton");
  static const removeMedicationButton = Key("removeMedicationButton");
  static const deleteMedicationButton = Key("deleteMedicationButton");
  static const medicalHistorySlide = Key("medicalHistorySlide");
  static const addToMedicalHistory = Key("addToMedicalHistory");
  static const showMedicationSlide = Key("showMedicationSlide");
  static const durationField = Key("durationField");
  static const durationTypeField = Key("durationTypeField");

  static const checkButton = Key("checkButton");
  static const prescriptionViewButton = Key("viewPrescription");

  static const patientTab = Key("patientTab");
  static const symptomsTab = Key("symptomsTab");
  static const vitalSignsTab = Key("vitalSignsTa");
  static const medicalHistoryTab = Key("medicalHistoryTab");
  static const notesTab = Key("notesTab");
  static const prescriptionTab = Key("prescriptionTaa");

  static const patientTabHeader = Key("patientTabHeader");
  static const symptomsTabHeader = Key("patientTabHeader");
  static const vitalSignsTabHeader = Key("vitalSignsTabHeader");
  static const medicalHistoryTabHeader = Key("medicalHistoryTabHeader");
  static const notesTabHeader = Key("notesTabHeader");
  static const prescriptionTabHeader = Key("prescriptionTabHeader");

  static const consultationDateHeader = Key("consultationDateHeader");
  static const consultationTimeHeader = Key("consultationTimeHeader");
  static const consultationStatusHeader = Key("consultationStatusHeader");

  //View Consultation page
  static const symptomsViewList = Key("symptomsViewList");
  static const parametersViewList = Key("symptomsViewList");
  static const prescriptionViewList = Key("prescriptionViewList");
  static const investgationsViewList = Key("investgationsViewList");
  static const notesViewList = Key("notesViewList");
  static const medicaHistoryViewList = Key("medicaHistoryViewList");
  static const bpViewField = Key("bpViewField");
  static const hrViewField = Key("hrViewField");
  static const tempViewField = Key("tempField");
  static const spo2Field = Key("spo2Field");

  // Add Test Page

  static const testName = Key("testName");
  static const addTest = Key("addTest");
  static const addTestButton = Key("addTestButton");

  // Add Notes Page

  static const noteTextField = Key("noteTextField");
  static const addNote = Key("addNote");

  // Consultation View Page
  static const consultationViewPage = Key("consultationViewPage");
  static const patientSummaryViewTile = Key("patientSummaryViewTile");
  static const prescriptionViewTile = Key("prescriptionViewTile");
  static const symptomsViewTile = Key("symptomsViewTile");
  static const medicalHistoryViewTile = Key("medicalHistoryViewTile");
  static const testsViewTile = Key("testsViewTile");
  static const vitalSignsViewTile = Key("vitalSignsViewTile");

  // Add Medication Page
  static const addMedicationPage = Key("addMedicationPage");
  static const addMedicationStepper = Key("addMedicationStepper");
  static const durationSpinbox = Key("durationSpinbox");
  static const routeDropDown = Key("routeDropDown");
  static const directionsChoiceList = Key("directionsChoiceList");
  static const frequencyDropDownButton = Key("frequencyDropDown");
  static const medicationNameAutoSizeTextField =
      Key("medicationNameAutoSizeTextField");
  static const dosageAutoSizeTextField = Key("dosageAutoSizeTextField");
  static const drugInfoSlide = Key("drugInfoSlide");
  static const scheduleSlide = Key("scheduleSlide");
  static const unitDropDown = Key("unitDropDown");
  static const timeChoiceChip = Key("timeChoiceChip");
  static const isHalfOption = Key("isHalfOption");

  // Remove medication page
  static const removeMedicationNameField = Key("removeMedicationNameField");
  static const removeMedicationRouteDropDown = Key("removeMedicationDropDown");
  static const removeMedicationConfirmButton =
      Key("removeMedicationConfirmButton");

  // Prescription Preview Page
  static const prescriptionPreviewPage = Key("prescriptionPreviewPage");
  static const printButton = Key("prin.labelMedium");
  static const pdfViewWidget = Key("pdfViewWidget");
  static const shareButon = Key("shar.labelMedium");

  // Consultation Search Page
  static const consultationSearchPage = Key("consultationSearchPage");
  static const dateSearchSwitch = Key("searchDateSwitch");
  static const dateOptionSwitch = Key("dateOptionSwitch");
  static const dateFilterSwitch = Key("dateFilterDropDown");
  static const selectDateLeftButton = Key("selectDateLeftButton");
  static const selectDateRightButton = Key("SelectDateRightButton");
  static const date1ValueLabel1 = Key("dateValueLabel1");
  static const date1ValueLabel2 = Key("dateValueLabel2");
  static const cancelButton = Key("canncelButton");

  static const consultationSearchList = Key("consultationSearchList");

  static const patientNameSearchAutoSizeTextField =
      Key("patientNameSearchAutoSizeTextField");
  static const beforeMenuItem = Key("beforeMenuItem");
  static const afterMenuItem = Key("afterMenuItem");
  static const betweenMenuItem = Key("betweenMenuItem");
  static const constultationEditButton = Key("consultationEdi.labelMedium");
  static const consultationViewButton = Key("constultationVie.labelMedium");

  //Select Date Page
  static const dateSelectionSlider = Key("dateSelectionSlider");

  // Edit Pin Setings Page
  static const editPinSettingsPage = Key("editPinSettingsPage");
  static const pinResetReminder = Key("pinResetReminder");
  static const pinResetDatePicker = Key("pinResetDatePicker");
  static const forgotPinPage = Key("forgotPinPage");

  // Data RetentionSettings Page
  static const dataRetentionSettingsPage = Key("dataRetentionSettingsPage");
  static const dataRetentionSwitch = Key("dataRetentionSwitch");
  static const dataRetentionTouchSpin = Key("dataRetentionTouchSpin");
  static const addDays = Key("addDays");
  static const subtractDays = Key("subtractDays");
  static const setRetentionTaskTime = Key("setRetentionTaskTime");

  // Data Retention Page
  static const retentionAuditPage = Key("retentionAuditPage");
}
